# Task Pair App

Aplicativo multiplataforma de **rastreamento de tarefas, pontuação e recompensas para pares de usuários**, desenvolvido em Flutter com backend Firebase.

O sistema permite que duas pessoas formem um par, definam tarefas recorrentes, executem e validem as tarefas entre si, acumulem pontos e desbloqueiem recompensas.

---

## Tech Stack

| Camada              | Tecnologia                |
| ------------------- | ------------------------- |
| Frontend            | Flutter (web, mobile, desktop) |
| Gerenciamento de Estado | Riverpod              |
| Navegação           | GoRouter                  |
| Autenticação        | Firebase Auth             |
| Banco de Dados      | Cloud Firestore           |
| Armazenamento       | Firebase Storage          |
| Notificações        | Firebase Cloud Messaging  |
| Arquitetura         | Clean Architecture + Feature-First |

---

## Início Rápido

### Pré-requisitos

- Flutter SDK 3.0+
- Firebase CLI + FlutterFire CLI
- Node.js 18+

### Instalação

```bash
# Clone o repositório
git clone <URL_DO_REPOSITORIO>
cd task_pair_app

# Instale dependências
flutter pub get

# Configure o Firebase
firebase login
flutterfire configure

# Execute o app
flutter run -d chrome
```

Para instruções detalhadas, veja [docs/SETUP.md](docs/SETUP.md).

---

## Features

| #  | Feature                    | Descrição                                      | Status |
| -- | -------------------------- | ---------------------------------------------- | ------ |
| 1  | Autenticação               | Registro, login, perfil, recuperação de senha   | ✅     |
| 2  | Gerenciamento de Pares     | Criar, convidar, aceitar/recusar, sair          | ✅     |
| 3  | Gerenciamento de Tarefas   | Criar, editar, deletar, listar                  | ✅     |
| 4  | Motor de Recorrência       | Diário, semanal, mensal, única                  | ✅     |
| 5  | Execução de Tarefas        | Executar com notas e foto de evidência          | ✅     |
| 6  | Validação de Tarefas       | Aprovar/reprovar com feedback                   | ✅     |
| 7  | Sistema de Pontuação       | Pontos por validação, acumulação, termômetros   | ✅     |
| 8  | Recompensas                | Meta de pontos, desbloqueio, progresso          | ✅     |
| 9  | Dashboard                  | Termômetros, tarefas do dia, ações rápidas      | ✅     |
| 10 | Relatórios                 | Estatísticas, filtros por período               | ✅     |

---

## Arquitetura

O projeto segue **Clean Architecture** com organização **Feature-First**:

```
lib/
├── core/           # Infraestrutura (constantes, erros, utils, extensions)
├── data/           # Modelos de dados e implementações de repositórios
├── domain/         # Entidades, interfaces de repositórios e use cases
├── features/       # Módulos por funcionalidade (auth, tasks, pairs, ...)
├── routes/         # Configuração de rotas (GoRouter)
├── services/       # Serviços Firebase (Auth, Firestore, Storage, FCM)
└── shared/         # Widgets e temas compartilhados
```

### Fluxo de dependência

```
Page → Provider → Use Case → Repository Interface ← Repository Impl → Firebase
```

Para detalhes completos, veja [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## Estrutura dos Dados

10 coleções no Firestore: `users`, `pairs`, `pairInvites`, `tasks`, `taskRecurrences`, `taskOccurrences`, `taskExecutions`, `taskValidations`, `scores`, `rewards`.

Regras de segurança e índices compostos configurados em `firebase/`.

Para detalhes completos, veja [docs/DATA_MODEL.md](docs/DATA_MODEL.md).

---

## Testes

```bash
# Executar todos os testes
flutter test

# Testes unitários
flutter test test/unit/

# Testes de widget
flutter test test/widget/

# Cobertura
flutter test --coverage
```

---

## Documentação

| Documento                                      | Descrição                            |
| ---------------------------------------------- | ------------------------------------ |
| [docs/SETUP.md](docs/SETUP.md)                | Guia de configuração do desenvolvedor|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)   | Documentação de arquitetura          |
| [docs/FEATURES.md](docs/FEATURES.md)           | Documentação detalhada das features  |
| [docs/DATA_MODEL.md](docs/DATA_MODEL.md)       | Modelo de dados e regras Firestore   |
| [docs/Requisitos.md](docs/Requisitos.md)       | Especificação de requisitos          |
| [docs/Fluxo_funcional.md](docs/Fluxo_funcional.md) | Fluxos funcionais do sistema    |

---

## Screenshots

<!-- TODO: Adicionar screenshots das telas principais -->

| Tela              | Screenshot |
| ----------------- | ---------- |
| Login             | —          |
| Dashboard         | —          |
| Tarefas           | —          |
| Execução          | —          |
| Validação         | —          |
| Pontuação         | —          |
| Recompensas       | —          |
| Relatórios        | —          |

---

## Protótipos HTML

Protótipos interativos das telas estão disponíveis em `prototypes/`. Abra `prototypes/index.html` no navegador para navegar entre os protótipos.

---

## Desenvolvimento com Agentes IA

Este repositório é desenvolvido usando Agentes IA coordenados por um Orquestrador.

Os agentes estão definidos em `.github/agents/` e cada um tem responsabilidade específica:
Orchestrator, Architecture, Flutter UI, Firebase, Domain, Recurrence, Score, Testing, Documentation e HTML Prototype.

---

## Licença

Projeto privado. Todos os direitos reservados.