/*
  Nome: Nicolas Carvalho Nogueira
  RA: 24801664
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/tela_inicial_screen.dart';
import 'package:mobile/services/getWalletDataService.dart';
import 'package:mobile/widgets/gaveta_ativar_mfa.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  String? nome;
  String? cpf;
  String? email;
  String? celular;
  bool isLoading = true;
  String totalInvestido = '0,00';
  String qtdStartups = '0';
  bool is2faEnabled = false;

  Future<void> _carregarPerfilUsuario() async {
    try {
      final usuarioLogado = FirebaseAuth.instance.currentUser;
      if (usuarioLogado != null) {
        email = usuarioLogado.email;
        final fatores = await usuarioLogado.multiFactor.getEnrolledFactors();
        is2faEnabled = fatores.isNotEmpty;
      }

      final resposta = await FirebaseFunctions.instanceFor(region: 'southamerica-east1')
          .httpsCallable('getUserProfile')
          .call();

      final carteiraData = await GetWalletDataService().fetchWalletDetails();

      final Map<dynamic, dynamic> dadosBrutos = resposta.data as Map<dynamic, dynamic>;
      final Map<dynamic, dynamic> dadosFinais =
      dadosBrutos.containsKey('data') && dadosBrutos['data'] != null
          ? dadosBrutos['data'] as Map<dynamic, dynamic>
          : dadosBrutos;

      if (mounted) {
        setState(() {
          nome = dadosFinais['nome']?.toString();
          cpf = dadosFinais['cpf']?.toString();
          celular = dadosFinais['celular']?.toString();
          email = dadosFinais['email']?.toString() ?? email;

          if (carteiraData != null) {
            final dadosCart = carteiraData.containsKey('data') ? carteiraData['data'] : carteiraData;
            final double valPatrimonio = (dadosCart['wallet']?['totalequity'] ?? 0) / 100;
            totalInvestido = valPatrimonio.toStringAsFixed(2).replaceAll('.', ',');
            final List<dynamic> tokens = dadosCart['invested'] ?? [];
            qtdStartups = tokens.length.toString();
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('\n====== ERRO AO LER DADOS ======\n$e\n================================\n');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarPerfilUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 12, 20),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Meu Perfil', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700)),
                const SizedBox(height: 24),

                // --- CARTÃO PRINCIPAL ---
                Container(
                  decoration: BoxDecoration(color: const Color(0xFF1E222D), borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.blueAccent,
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              nome != null && nome!.isNotEmpty ? nome![0].toUpperCase() : '-',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: isLoading
                                  ? [const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2))]
                                  : [
                                Text(nome ?? 'Não informado', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                                Text(email ?? 'Sem email cadastrado', style: const TextStyle(color: Colors.grey, fontSize: 14))
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          isLoading
                              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(cpf != null ? 'CPF: $cpf' : 'CPF: Não informado', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          isLoading
                              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(celular != null ? 'Celular: $celular' : 'Celular: Não informado', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- CARTÕES DE INVESTIMENTO ---
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF1E222D), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total investido', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            const SizedBox(height: 8),
                            isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text('R\$ $totalInvestido', style: const TextStyle(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF1E222D), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Startups', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            const SizedBox(height: 8),
                            isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(qtdStartups, style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text('CONTA', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFF1E222D), borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      child: const Icon(Icons.person_outline, color: Colors.blueAccent),
                    ),
                    title: const Text('Dados Pessoais', style: TextStyle(color: Colors.white)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),

                // --- SEGURANÇA ---
                const Text('SEGURANÇA', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFF1E222D), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent.withOpacity(0.1),
                          child: const Icon(Icons.shield_outlined, color: Colors.blueAccent),
                        ),
                        title: const Text('Autenticação 2FA', style: TextStyle(color: Colors.white)),
                        trailing: Switch(
                          value: is2faEnabled,
                          activeColor: Colors.blueAccent,
                          onChanged: (bool novoValor) async {
                            // 1. A MÁGICA: Força a atualização dos dados do usuário com a nuvem
                            await FirebaseAuth.instance.currentUser?.reload();

                            // 2. Pega o usuário já com os dados atualizados
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;

                            if (novoValor == true) {
                              // Verifica se o e-mail está confirmado
                              if (!user.emailVerified) {
                                try {
                                  await user.sendEmailVerification();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Enviamos um link de confirmação para o seu e-mail. Clique nele para poder ativar o 2FA!'),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 5),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Erro ao enviar e-mail. Tente novamente mais tarde.'), backgroundColor: Colors.redAccent),
                                    );
                                  }
                                }
                                setState(() { is2faEnabled = false; });
                                return;
                              }

                              // Trava do Celular
                              if (celular == null || celular!.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Nenhum celular cadastrado no perfil.'), backgroundColor: Colors.redAccent),
                                );
                                setState(() { is2faEnabled = false; });
                                return;
                              }

                              // Abre a gaveta de SMS
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => GavetaAtivarMfa(telefoneSalvo: celular!),
                              );

                              // Atualiza o usuário após fechar a gaveta
                              await user.reload();
                              final userAtualizado = FirebaseAuth.instance.currentUser;
                              if (userAtualizado != null) {
                                final fatoresAtuais = await userAtualizado.multiFactor.getEnrolledFactors();
                                setState(() { is2faEnabled = fatoresAtuais.isNotEmpty; });
                              }

                            } else {
                              // O usuário quer DESATIVAR
                              try {
                                final fatores = await user.multiFactor.getEnrolledFactors();
                                for (var fator in fatores) {
                                  await user.multiFactor.unenroll(multiFactorInfo: fator);
                                }

                                setState(() { is2faEnabled = false; });

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Segurança extra desativada.'), backgroundColor: Colors.orange));
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao desativar o 2FA.'), backgroundColor: Colors.redAccent));
                                }
                              }
                            }
                          },
                        ),
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent.withOpacity(0.1),
                            child: const Icon(Icons.lock_outline, color: Colors.blueAccent),
                          ),
                          title: const Text('Alterar senha', style: TextStyle(color: Colors.white)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                          onTap: () {}
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- BOTÃO DE SAIR ---
                TextButton(
                  onPressed: () async {
                    try{
                      await FirebaseAuth.instance.signOut();
                      if(!context.mounted) return;
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const TelaInicialScreen()), (route) => false);
                    } catch (e) {
                      debugPrint("Erro ao deslogar: $e");
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível deslogar. Verifique sua internet')));
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text('Sair da Conta', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}