import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

// Configurações do seu projeto Real no Firebase
const _projectId = 'pi3-g37';
const _apiKey = 'AIzaSyADO1CV7lulvmQWDeBKengiXFvjonGZ3i8';

Uri _functionUri(String functionName) {
  return Uri.parse('https://southamerica-east1-$_projectId.cloudfunctions.net/$functionName');
}

Uri _authSignInUri() {
  return Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey');
}

Future<Map<String, dynamic>> _callFunction(
    String functionName, {
      Map<String, dynamic> data = const {},
      String? idToken,
    }) async {
  final headers = {'Content-Type': 'application/json'};
  if (idToken != null) {
    headers['Authorization'] = 'Bearer $idToken';
  }

  final response = await http.post(
    _functionUri(functionName),
    headers: headers,
    body: jsonEncode({'data': data}),
  );

  final payload = jsonDecode(response.body);

  if (response.statusCode != 200 || payload['error'] != null) {
    throw Exception('Erro na function $functionName: ${payload['error']}');
  }

  return payload['result'] as Map<String, dynamic>? ?? {};
}

void main() {
  String? idToken;
  String? testExchangeId;
  String? targetStartupId; // <-- Variável nova para guardar o ID real do banco!

  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final testEmail = 'banca.teste.$timestamp@puc-campinas.edu.br';
  const testPassword = 'senhaSuperSegura123';

  setUpAll(() async {
    print('--------------------------------------------------');
    print('🔧 PREPARANDO AMBIENTE DE TESTES');
    print('📧 Criando usuário único: $testEmail');

    await _callFunction('createUser', data: {
      'nome': 'Avaliador MesclaInvest',
      'email': testEmail,
      'cpf': '000.000.000-00',
      'celular': '19999999999',
      'senha': testPassword
    });

    final response = await http.post(
      _authSignInUri(),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': testEmail,
        'password': testPassword,
        'returnSecureToken': true,
      }),
    );

    final payload = jsonDecode(response.body);

    if (response.statusCode == 200) {
      idToken = payload['idToken'];
      print('✅ Usuário criado e logado com sucesso!');
      print('--------------------------------------------------\n');
    } else {
      fail('Falha crítica ao obter Token de Autenticação: $payload');
    }
  });

  group('1. Catálogo de Startups (Leitura de Dados)', () {

    test('listStartups retorna o catálogo e captura um ID real do banco', () async {
      final result = await _callFunction('listStartups', idToken: idToken);

      expect(result['count'], isNotNull);
      expect(result['data'], isA<List<dynamic>>());

      final startups = result['data'] as List<dynamic>;
      expect(startups, isNotEmpty, reason: 'O banco de dados não tem nenhuma startup cadastrada!');

      // PESCA O ID REAL DA PRIMEIRA STARTUP QUE VOLTAR DO BANCO
      targetStartupId = startups.first['id'];
      print('🎯 ID real capturado para os testes: $targetStartupId');
    });

    test('getStartupDetails traz os detalhes completos da startup capturada', () async {
      final result = await _callFunction('getStartupDetails', idToken: idToken, data: {
        'id': targetStartupId, // <-- Usando o ID dinâmico
      });

      final data = result['data'];
      expect(data['id'], targetStartupId);
      expect(data['access'], isNotNull);
    });

    test('getStartupPriceHistory retorna o histórico de preços', () async {
      final result = await _callFunction('getStartupPriceHistory', idToken: idToken, data: {
        'startupId': targetStartupId, // <-- Usando o ID dinâmico
        'range': 'ALL'
      });

      expect(result['history'], isA<List<dynamic>>());
    });
  });

  group('2. Carteira e Dashboard do Investidor', () {
    test('getWalletDetails retorna os dados da carteira recém-criada', () async {
      final result = await _callFunction('getWalletDetails', idToken: idToken);
      expect(result['wallet'], isNotNull);
    });

    test('updateWallet adiciona saldo com sucesso na conta', () async {
      final result = await _callFunction('updateWallet', idToken: idToken, data: {
        'balanceChangeCents': 150000
      });
      expect(result['success'], true);
    });

    test('getUserDashboardData traz os cálculos iniciais zerados', () async {
      final result = await _callFunction('getUserDashboardData', idToken: idToken);
      expect(result['patrimonioTotalCents'], isNotNull);
      expect(result['portfolio'], isA<List<dynamic>>());
    });
  });

  group('3. Investimentos e Tokens (Operações Reais)', () {
    test('buyStartupToken realiza a compra de tokens da startup capturada', () async {
      final result = await _callFunction('buyStartupToken', idToken: idToken, data: {
        'startupId': targetStartupId, // <-- Usando o ID dinâmico
        'tokenAmount': 5
      });
      expect(result['success'], true);
    });

    test('listMyInvestments lista os tokens que acabaram de ser comprados', () async {
      final result = await _callFunction('listMyInvestments', idToken: idToken);
      final data = result['data'] as List<dynamic>;

      expect(data, isNotEmpty);
      expect(data.first['id'], targetStartupId); // Verifica se o ID bate
    });
  });

  group('4. Balcão de Negociações (Exchange)', () {
    test('createExchangeRequest cria uma oferta de venda no balcão', () async {
      final result = await _callFunction('createExchangeRequest', idToken: idToken, data: {
        'startupId': targetStartupId, // <-- Usando o ID dinâmico
        'quantity': 2,
        'purchasePriceCents': 5000
      });
      expect(result['success'], true);
    });

    test('listExchanges carrega ofertas globais e identifica a oferta recém-criada', () async {
      final result = await _callFunction('listExchanges', idToken: idToken);

      final minhas = result['minhas'] as List<dynamic>;
      expect(minhas, isNotEmpty);

      testExchangeId = minhas.first['id'];
    });

    test('deleteExchangeRequest cancela a oferta corretamente', () async {
      if (testExchangeId != null) {
        final result = await _callFunction('deleteExchangeRequest', idToken: idToken, data: {
          'startupId': targetStartupId, // <-- Usando o ID dinâmico
          'exchangeId': testExchangeId
        });
        expect(result['success'], true);
      } else {
        fail('Nenhuma oferta foi registrada no banco de dados para ser deletada.');
      }
    });

    test('acceptExchangeRequest barra troca se os parametros estiverem vazios', () async {
      try {
        await _callFunction('acceptExchangeRequest', idToken: idToken, data: {
          'exchangeId': '',
          'startupId': targetStartupId
        });
        fail('O backend deveria ter barrado essa requisição com erro de argumento inválido.');
      } catch (e) {
        // Converte o erro para maiúsculo para garantir que vai achar o INVALID_ARGUMENT
        // ou busca a mensagem exata que você escreveu na Function
        final erroString = e.toString().toUpperCase();
        expect(erroString.contains('INVALID_ARGUMENT') || erroString.contains('OBRIGATÓRIO'), isTrue);
      }
    });
  });
}