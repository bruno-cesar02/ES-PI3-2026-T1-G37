# MesclaInvest

![Turma](https://img.shields.io/badge/Turma-T0101-blue)
![Grupo](https://img.shields.io/badge/Grupo-37-green)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Node.js](https://img.shields.io/badge/Node.js-LTS-339933?logo=node.js)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase)

Plataforma mobile para simulação de investimentos em startups do ecossistema de inovação Mescla (PUC-Campinas). O aplicativo permite que usuários visualizem startups cadastradas, acompanhem informações institucionais e simulem a compra/venda de tokens representativos de participações digitais.

> ⚠️ **Importante:** Este projeto é **exclusivamente acadêmico**. Todas as operações de negociação são simuladas, sem envolvimento de ativos reais ou sistemas financeiros externos.

---

## 📋 Contexto Acadêmico

Este sistema faz parte do **Projeto Integrador 3** do curso de **Engenharia de Software** da **PUC-Campinas**, sob orientação da **Profa. Me. Renata**. O escopo visa aplicar conceitos de arquitetura de software, desenvolvimento mobile e integração backend/frontend em um cenário de sistema de investimentos simulado baseado em tokenização.

---

## 👥 Integrantes

| Nome | RA | GitHub |
|------|----|--------|
| Bruno César | 24795502 | [@bruno-cesar02](https://github.com/bruno-cesar02) |
| Eduardo Neves | 24026029 | [@Edunevesa1](https://github.com/Edunevesa1) |
| Luiz Coutinho | 24025981 | [@LuizPolydoroCoutinho](https://github.com/LuizPolydoroCoutinho) |
| Nicolas Nogueira | 24801664 | [@nickinh0](https://github.com/nickinh0) |
| Otávio Augusto | 24025832 | [@otavigoto](https://github.com/otavigoto) |
| Tomás Cubeiro | 24023817 | [@tomascubeiro](https://github.com/tomascubeiro) |

---

## 📁 Documentação

| Artefato | Descrição | Link |
|----------|-----------|------|
| Planilha de Startups | Base de dados simulada com 5 startups fictícias do ecossistema Mescla | [Ver planilha](https://github.com/bruno-cesar02/ES-PI3-2026-T1-G37/blob/main/Docs/planilha_startups_PI3_G37.xlsx) |
| Mapa Mental | Mapa mental do projeto MesclaInvest | [Ver mapa mental](https://github.com/bruno-cesar02/ES-PI3-2026-T1-G37/blob/main/Docs/MesclaInvest_MapaMental.pdf) |
| Protótipo | Protótipo das telas no Figma | [Ver Protótipo](https://www.figma.com/design/iFanzqYmKIKEcJ7jwSX0WY/MesclaInvest?node-id=93-283&p=f&t=UXkwEj6OCs1PIzGT-0) |

---

## 🎯 Funcionalidades

### Autenticação
* Cadastro de usuários com e-mail, CPF, telefone e senha
* Login seguro com recuperação de senha
* Segurança avançada com Autenticação de 2 Fatores (MFA) via SMS

### Catálogo de Startups
* Visualização de startups cadastradas no ecossistema
* Informações detalhadas: descrição, estrutura societária, capital aportado
* Filtros por estágio de desenvolvimento (Nova ideia, Em operação, Em expansão)
* Acesso a documentos: sumário executivo, pitch decks (PDF), vídeos demo embutidos

### Negociação Simulada de Tokens (Exchange P2P)
* Balcão de compra/venda de tokens (simulado)
* Carteira digital com saldo fictício em reais
* Ofertas de compra/venda de mercado secundário entre usuários cadastrados

### Dashboard de Investimentos
* Acompanhamento de valorização dos tokens da carteira
* Gráficos de variação de preços e tendências baseadas no histórico de transações do Firestore

### Interação com Startups
* Envio de perguntas públicas/privadas aos empreendedores (Mural de Q&A)

---

## 🛠️ Tecnologias

### Backend (Serverless)
* **Node.js** (LTS) — Ambiente de execução
* **TypeScript** — Linguagem principal
* **Firebase Cloud Functions** — Regras de negócio, endpoints callable e integração segura
* **Firebase Firestore** — Banco de dados NoSQL
* **Firebase Authentication** — Gerenciamento de usuários e segurança
* **Firebase Storage** — Hospedagem de imagens (logos) e PDFs

### Mobile
* **Flutter** (3.x) — Framework multiplataforma
* **Dart** — Linguagem

### Ferramentas de Desenvolvimento
* **Visual Studio Code** / **Android Studio** — IDEs
* **Git** — Controle de versão
* **GitHub** — Hospedagem de código e gestão de projeto
* **GitHub Projects** — Gerenciamento de tarefas (Kanban)

---

## 🚀 Como Executar e Testar

### Pré-requisitos
* [Node.js](https://nodejs.org/) (versão LTS mais recente)
* [Flutter SDK](https://flutter.dev/) (3.x ou superior)
* [Git](https://git-scm.com/)
* Conta no [Firebase](https://firebase.google.com/) com projeto configurado

### 1. Clone o repositório
```bash
git clone https://github.com/bruno-cesar02/ES-PI3-2026-T1-G37.git
cd ES-PI3-2026-T1-G37
```

### 2. Rodando o Backend Localmente (Emuladores)
```bash
cd Backend/functions
npm install
npm run build
firebase emulators:start
```

### 3. Rodando o Mobile
```bash
cd Mobile
flutter pub get
flutter run
```

### 4. Executando Testes Automatizados (TDD)
O sistema possui testes de integração validados diretamente no ambiente Firebase real ou no emulador.

```bash
cd Mobile
flutter test test/integration_test.dart
```

---

## 📂 Estrutura do Projeto

Abaixo a estrutura com a arquitetura serverless focada em domínios:

```text
ES-PI3-2026-T1-G37/
├── Backend/
│   ├── functions/
│   │   ├── src/
│   │   │   ├── exchange/    # Handlers, repositories e types do Balcão de Negócios
│   │   │   ├── startups/    # Handlers, repositories e types do Catálogo e Q&A
│   │   │   ├── users/       # Handlers, repositories e types de Autenticação e Perfis
│   │   │   └── wallet/      # Handlers, repositories e types da Carteira e Saldos
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── firestore.rules      # Regras de segurança do banco
│   └── firebase.json
│
├── Mobile/                  # Aplicativo Flutter
│   ├── lib/
│   │   ├── config/          # Instâncias e inicializadores
│   │   ├── models/          # Entidades do app
│   │   ├── screens/         # Telas (Catálogo, Perfil, Gavetas, etc)
│   │   ├── services/        # Serviços integrados às Functions
│   │   ├── theme/           # Cores e tipografia
│   │   └── widgets/         # Componentes visuais
│   ├── test/                # Testes de integração (TDD)
│   └── pubspec.yaml
│
├── Docs/                    # Documentação e artefatos do projeto
│   ├── planilha_startups_PI3_G37.xlsx
│   └── MesclaInvest_MapaMental.pdf
│
└── README.md
```

---

## 📝 Licença

Este projeto é de uso exclusivamente acadêmico, desenvolvido para fins educacionais na PUC-Campinas.
