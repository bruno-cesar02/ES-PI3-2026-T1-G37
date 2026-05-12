import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

// ── Configurações do Emulador Local
const _projectId = 'pi3-g37';
const _functionsOrigin = 'http://127.0.0.1:5001';


Uri _functionUri(String functionName) {
  return Uri.parse('$_functionsOrigin/$_projectId/southamerica-east1/$functionName');
}

void main() {
  group('Firebase Callable Functions de Usuários', () {

    test('createUser deve criar usuário no Auth e salvar no Firestore', () async {

      // 1. Prepara os dados falsos para o teste 
      final dadosCadastro = {
        'nome': 'Bruno Mota Teste',
        'email': 'bruno.teste@puc-campinas.edu.br',
        'cpf': '123.456.789-00',
        'celular': '11999999999',
        'senha': 'senhaSuperSegura123'
      };

      print('Enviando requisição para o emulador...');

      // 2. Chama a function "createUser" localmente
      final response = await http.post(
        _functionUri('createUser'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': dadosCadastro}),
      );

      // 3. Decodifica a resposta
      final payload = jsonDecode(response.body);

      print('Resposta do Servidor: $payload');

      // 4. Verifica se a function retornou sucesso (Status 200) e a mensagem correta
      expect(response.statusCode, 200);
      expect(payload['result']['data']['message'], 'Usuário criado com sucesso!');
      expect(payload['result']['data']['uid'], isNotNull);
    });
    test('Deve retornar erro ao tentar cadastrar um e-mail que já existe', () async {
      final dadosCadastro = {
        'nome': 'Bruno Mota',
        'email': 'bruno.teste@puc-campinas.edu.br', // Mesmo e-mail do teste anterior!
        'cpf': '111.222.333-44',
        'celular': '11999999999',
        'senha': 'senhaSuperSegura123'
      };

      final response = await http.post(
        _functionUri('createUser'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': dadosCadastro}),
      );

      final payload = jsonDecode(response.body);

      // Verifica se a function retornou um erro
      expect(payload['error'], isNotNull);

      // Verifica se a mensagem de erro é exatamente a do backend
      expect(payload['error']['message'], 'Este e-mail já está em uso.');
    });
    test('Deve bloquear cadastro se faltarem campos obrigatórios', () async {
      final dadosIncompletos = {
        'nome': 'Bruno',
        'email': 'bruno@email.com',
        //falta cpf, celular e etc...
      };

      final response = await http.post(
        _functionUri('createUser'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': dadosIncompletos}),
      );

      final payload = jsonDecode(response.body);

      expect(payload['error'], isNotNull);
      expect(payload['error']['message'], 'Todos os campos são obrigatórios.');
    });
    test('Deve retornar erro interno se a senha for muito curta', () async {
      final dadosSenhaFraca = {
        'nome': 'Bruno',
        'email': 'novo.usuario@puc-campinas.edu.br',
        'cpf': '000.000.000-00',
        'celular': '11000000000',
        'senha': '123' // Senha fraca (menor que 6 caracteres)
      };

      final response = await http.post(
        _functionUri('createUser'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': dadosSenhaFraca}),
      );

      final payload = jsonDecode(response.body);

      expect(payload['error'], isNotNull);
      
      expect(payload['error']['message'], 'Erro ao criar o usuário no sistema de senhas.');
    });
  });
}