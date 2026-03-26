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
| Nicolas Nogueira | 24801664 | [@nickinh0](https://github.com/nickinh0) |
| Otávio Augusto | 24025832 | [@otavigoto](https://github.com/otavigoto) |

---

## 📁 Documentação

| Artefato | Descrição | Link |
|----------|-----------|------|
| Planilha de Startups | Base de dados simulada com 5 startups fictícias do ecossistema Mescla | [Ver planilha](https://github.com/bruno-cesar02/ES-PI3-2026-T1-G37/blob/main/Docs/planilha_startups_PI3_G37.xlsx) |

---

## 🎯 Funcionalidades

### Autenticação

- Cadastro de usuários com e-mail, CPF, telefone e senha
- Login seguro com recuperação de senha

### Catálogo de Startups

- Visualização de startups cadastradas no ecossistema
- Informações detalhadas: descrição, estrutura societária, capital aportado
- Filtros por estágio de desenvolvimento (Nova ideia, Em operação, Em expansão)
- Acesso a documentos: sumário executivo, plano de negócios, vídeos demo

### Negociação Simulada de Tokens

- Balcão de compra/venda de tokens (simulado)
- Carteira digital com saldo fictício em reais
- Ofertas de compra/venda entre usuários cadastrados

### Dashboard de Investimentos

- Acompanhamento de valorização dos tokens
- Gráficos de variação (diário, semanal, mensal, YTD)
- Cálculo de tendências baseado em transações simuladas

### Interação com Startups

- Envio de perguntas públicas/privadas aos empreendedores
- Feed de atualizações e eventos das startups

---

## 🛠️ Tecnologias

### Backend

- **Node.js** (LTS) — Ambiente de execução
- **TypeScript / JavaScript** — Linguagem
- **Firebase Firestore** — Banco de dados NoSQL

### Mobile

- **Flutter** (3.x) — Framework multiplataforma
- **Dart** — Linguagem

### Ferramentas de Desenvolvimento

- **Visual Studio Code** / **Android Studio** — IDEs
- **Git** — Controle de versão
- **GitHub** — Hospedagem de código e gestão de projeto
- **GitHub Projects** — Gerenciamento de tarefas (Kanban)

---

## 🚀 Como Executar

### Pré-requisitos

- [Node.js](https://nodejs.org/) (versão LTS mais recente)
- [Flutter SDK](https://flutter.dev/) (3.x ou superior)
- [Git](https://git-scm.com/)
- Conta no [Firebase](https://firebase.google.com/) com projeto configurado

### Backend

1. Clone o repositório:

```bash
git clone https://github.com/bruno-cesar02/ES-PI3-2026-T0101-G37.git
cd ES-PI3-2026-T0101-G37/backend
```

2. Instale as dependências:

```bash
npm install
```

3. Configure as variáveis de ambiente:
   - Crie um arquivo `.env` na raiz do `backend`
   - Adicione as credenciais do Firebase e outras configurações necessárias

4. Execute o servidor:

```bash
npm run dev
```

### Mobile

1. Entre na pasta do aplicativo:

```bash
cd mobile
```

2. Instale as dependências do Flutter:

```bash
flutter pub get
```

3. Configure o Firebase:
   - Adicione o arquivo `google-services.json` na pasta `android/app`
   - Adicione o arquivo `GoogleService-Info.plist` na pasta `ios/Runner`

4. Execute o aplicativo:

```bash
flutter run
```

---

## 📂 Estrutura do Projeto

```
ES-PI3-2026-T0101-G37/
├── backend/                 # API Node.js + TypeScript
│   ├── src/
│   │   ├── controllers/     # Lógica de negócio
│   │   ├── models/          # Modelos de dados (Firestore)
│   │   ├── routes/          # Rotas da API
│   │   ├── middlewares/     # Autenticação, validação
│   │   └── config/          # Configurações (Firebase, etc.)
│   ├── package.json
│   └── tsconfig.json
│
├── mobile/                  # Aplicativo Flutter
│   ├── lib/
│   │   ├── screens/         # Telas do app
│   │   ├── widgets/         # Componentes reutilizáveis
│   │   ├── services/        # Integração com API
│   │   ├── models/          # DTOs
│   │   └── main.dart
│   └── pubspec.yaml
│
├── Docs/                    # Documentação e artefatos do projeto
│   └── planilha_startups_PI3_G37.xlsx
│   └── MesclaInvest_MapaMental.pdf
│
└── README.md
```

---

## 📝 Licença

Este projeto é de uso exclusivamente acadêmico, desenvolvido para fins educacionais na PUC-Campinas.
