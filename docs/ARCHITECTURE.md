# Documentação de Arquitetura — Task Pair App

## Índice

- [Visão Geral](#visão-geral)
- [Clean Architecture](#clean-architecture)
- [Diagrama de Camadas](#diagrama-de-camadas)
- [Estrutura Feature-First](#estrutura-feature-first)
- [Gerenciamento de Estado (Riverpod)](#gerenciamento-de-estado-riverpod)
- [Navegação (GoRouter)](#navegação-gorouter)
- [Camada de Serviços Firebase](#camada-de-serviços-firebase)
- [Padrão Repository](#padrão-repository)
- [Como Adicionar uma Nova Feature](#como-adicionar-uma-nova-feature)

---

## Visão Geral

O Task Pair App segue **Clean Architecture** combinada com organização **Feature-First** e o **Repository Pattern** para comunicação com o Firebase.

### Princípios Fundamentais

1. **Separação de responsabilidades** — cada camada tem um papel claro
2. **Dependência unidirecional** — camadas externas dependem das internas, nunca o contrário
3. **Domínio puro** — entidades e interfaces de repositório não dependem de Flutter ou Firebase
4. **Testabilidade** — uso de interfaces permite mocks para testes unitários
5. **Feature-first** — organização por funcionalidade, não por tipo de arquivo

---

## Clean Architecture

O projeto é organizado em três camadas principais:

### Camada de Domínio (`lib/domain/`)

A camada mais interna. Contém regras de negócio puras em Dart, sem dependências de frameworks.

| Diretório       | Conteúdo                                        |
| --------------- | ----------------------------------------------- |
| `entities/`     | Entidades de negócio (imutáveis com Equatable)  |
| `repositories/` | Interfaces abstratas dos repositórios           |
| `usecases/`     | Casos de uso com lógica de negócio              |

**Exemplo de entidade:**
```dart
class TaskEntity extends Equatable {
  final String id;
  final String pairId;
  final String title;
  final int points;
  // ... outros campos
}
```

**Exemplo de interface de repositório:**
```dart
abstract class TaskRepository {
  Future<TaskEntity> createTask(TaskEntity task);
  Stream<List<TaskEntity>> watchTasksByPairId(String pairId);
  Future<void> deleteTask(String taskId);
}
```

### Camada de Dados (`lib/data/`)

Implementa as interfaces definidas na camada de domínio.

| Diretório       | Conteúdo                                            |
| --------------- | --------------------------------------------------- |
| `models/`       | Modelos de dados com serialização Firestore          |
| `repositories/` | Implementações concretas dos repositórios            |

**Modelo de dados** — responsável pela conversão entre Firestore e Entidade:
```dart
class TaskModel {
  factory TaskModel.fromMap(Map<String, dynamic> map, String id);
  factory TaskModel.fromEntity(TaskEntity entity);
  Map<String, dynamic> toMap();
  TaskEntity toEntity();
}
```

### Camada de Apresentação (`lib/features/`)

Contém toda a UI e o gerenciamento de estado.

| Diretório     | Conteúdo                                  |
| ------------- | ----------------------------------------- |
| `pages/`      | Páginas/telas do Flutter                  |
| `widgets/`    | Widgets específicos da feature            |
| `providers/`  | Providers Riverpod                        |

---

## Diagrama de Camadas

```
┌──────────────────────────────────────────────────────┐
│                   APRESENTAÇÃO                       │
│  ┌──────────────────────────────────────────────┐    │
│  │  Pages (Flutter Widgets)                     │    │
│  │  ├── LoginPage, RegisterPage, ProfilePage    │    │
│  │  ├── DashboardPage (2 tabs: executor/requester) │    │
│  │  ├── PairManagementPage, InvitePage          │    │
│  │  ├── TaskListPage, TaskFormPage              │    │
│  │  ├── TaskExecutionPage, MyTasksPage          │    │
│  │  ├── ValidationPage                          │    │
│  │  ├── ScorePage, RewardsPage                  │    │
│  │  └── ReportsPage                             │    │
│  └──────────────────────────────────────────────┘    │
│  ┌──────────────────────────────────────────────┐    │
│  │  Providers (Riverpod)                        │    │
│  │  ├── authNotifierProvider                    │    │
│  │  ├── pairNotifierProvider                    │    │
│  │  ├── taskNotifierProvider                    │    │
│  │  ├── executionNotifierProvider               │    │
│  │  ├── validationNotifierProvider              │    │
│  │  ├── scoresProvider                          │    │
│  │  ├── rewardsNotifierProvider                 │    │
│  │  └── dashboardDataProvider, reportsProvider  │    │
│  └──────────────────────────────────────────────┘    │
├──────────────────────────────────────────────────────┤
│                     DOMÍNIO                          │
│  ┌──────────────────────────────────────────────┐    │
│  │  Entities (Equatable, imutáveis)             │    │
│  │  ├── UserEntity, PairEntity                  │    │
│  │  ├── PairInviteEntity                        │    │
│  │  ├── TaskEntity, TaskRecurrenceEntity        │    │
│  │  ├── TaskOccurrenceEntity                    │    │
│  │  ├── TaskExecutionEntity                     │    │
│  │  ├── TaskValidationEntity                    │    │
│  │  ├── ScoreEntity, RewardEntity               │    │
│  └──────────────────────────────────────────────┘    │
│  ┌──────────────────────────────────────────────┐    │
│  │  Repository Interfaces (abstract classes)    │    │
│  │  Use Cases (regras de negócio)               │    │
│  └──────────────────────────────────────────────┘    │
├──────────────────────────────────────────────────────┤
│                      DADOS                           │
│  ┌──────────────────────────────────────────────┐    │
│  │  Models (serialização Firestore)             │    │
│  │  Repository Implementations                  │    │
│  └──────────────────────────────────────────────┘    │
├──────────────────────────────────────────────────────┤
│                    SERVIÇOS                          │
│  ┌──────────────────────────────────────────────┐    │
│  │  FirebaseAuthService                         │    │
│  │  FirestoreService (CRUD genérico)            │    │
│  │  StorageService (upload/download)            │    │
│  │  FcmService (notificações push)              │    │
│  └──────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────┘
```

### Fluxo de Dependência

```
Page → Provider → Use Case → Repository Interface ← Repository Impl → FirestoreService → Firestore
```

A camada de domínio **nunca** depende de Firebase ou Flutter. Apenas a camada de dados conhece o Firebase.

---

## Estrutura Feature-First

Cada funcionalidade é organizada como um módulo independente dentro de `lib/features/`:

```
lib/features/
├── auth/
│   └── presentation/
│       ├── pages/
│       │   ├── login_page.dart
│       │   ├── register_page.dart
│       │   └── profile_page.dart
│       └── providers/
│           └── auth_provider.dart
├── dashboard/
│   └── presentation/
│       ├── pages/
│       │   └── dashboard_page.dart
│       ├── widgets/
│       │   └── thermometer_widget.dart
│       └── providers/
│           └── dashboard_provider.dart
├── pairs/
│   └── presentation/
│       ├── pages/
│       │   ├── pair_management_page.dart
│       │   └── invite_page.dart
│       └── providers/
│           └── pair_provider.dart
├── tasks/
│   └── presentation/
│       ├── pages/
│       │   ├── task_list_page.dart
│       │   └── task_form_page.dart
│       └── providers/
│           └── task_provider.dart
├── execution/
│   └── presentation/
│       ├── pages/
│       │   ├── task_execution_page.dart
│       │   └── my_tasks_page.dart
│       └── providers/
│           └── execution_provider.dart
├── validation/
│   └── presentation/
│       ├── pages/
│       │   └── validation_page.dart
│       └── providers/
│           └── validation_provider.dart
├── recurrence/
│   ├── use_cases/
│   │   └── generate_occurrences_use_case.dart
│   └── presentation/
│       └── providers/
│           └── recurrence_provider.dart
├── score/
│   └── presentation/
│       ├── pages/
│       │   └── score_page.dart
│       └── providers/
│           └── score_provider.dart
├── rewards/
│   └── presentation/
│       ├── pages/
│       │   └── rewards_page.dart
│       └── providers/
│           └── rewards_provider.dart
└── reports/
    └── presentation/
        ├── pages/
        │   └── reports_page.dart
        └── providers/
            └── reports_provider.dart
```

### Por que Feature-First?

- **Localidade**: tudo relacionado a uma feature está junto
- **Escalabilidade**: novas features não afetam as existentes
- **Navegabilidade**: fácil encontrar o código de cada funcionalidade
- **Independência**: features podem ser desenvolvidas em paralelo

---

## Gerenciamento de Estado (Riverpod)

O projeto usa **flutter_riverpod** para gerenciamento de estado reativo.

### Padrões Utilizados

#### 1. Provider para serviços e repositórios

```dart
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.read(firestoreServiceProvider));
});
```

#### 2. StreamProvider para dados em tempo real

```dart
final tasksProvider = StreamProvider.family<List<TaskEntity>, String>((ref, pairId) {
  final repo = ref.read(taskRepositoryProvider);
  return repo.watchTasksByPairId(pairId);
});
```

#### 3. StateNotifierProvider para estado mutável

```dart
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(ref);
});
```

#### 4. Consumo nas páginas com `.when`

```dart
final tasksAsync = ref.watch(tasksProvider(pairId));

tasksAsync.when(
  data: (tasks) => ListView.builder(...),
  loading: () => LoadingWidget(),
  error: (err, stack) => AppErrorWidget(message: err.toString()),
);
```

### Mapa de Providers

| Provider                     | Tipo                  | Descrição                              |
| ---------------------------- | --------------------- | -------------------------------------- |
| `authStateProvider`          | StreamProvider        | Estado de autenticação Firebase        |
| `currentUserEntityProvider`  | FutureProvider        | Dados do usuário logado                |
| `authNotifierProvider`       | StateNotifierProvider | Ações de auth (login, register, etc.)  |
| `currentPairProvider`        | Provider              | Par selecionado (ou primeiro) do usuário  |
| `myPairsProvider`            | StreamProvider        | Todos os pares do usuário atual          |
| `pairsAsRequesterProvider`   | Provider              | Pares onde usuário é solicitante         |
| `pairsAsExecutorProvider`    | Provider              | Pares onde usuário é executor            |
| `selectedPairIdProvider`     | StateProvider         | ID do par selecionado atualmente        |
| `pendingInvitesProvider`     | StreamProvider        | Convites pendentes                     |
| `pairNotifierProvider`       | StateNotifierProvider | Ações de pares                         |
| `tasksProvider`              | StreamProvider.family | Tarefas por pairId (tempo real)        |
| `taskNotifierProvider`       | StateNotifierProvider | Ações de tarefas (CRUD)                |
| `executionNotifierProvider`  | StateNotifierProvider | Ações de execução                      |
| `myPendingOccurrencesProvider` | StreamProvider      | Occurrences assigned to user (pending)  |
| `myExecutedOccurrencesProvider` | StreamProvider     | Occurrences executed by user (awaiting) |
| `myValidatedOccurrencesProvider` | StreamProvider    | Occurrences validated for user          |
| `executionByOccurrenceIdProvider` | FutureProvider.family | Lookup execution by occurrence ID   |
| `validationNotifierProvider` | StateNotifierProvider | Ações de validação                     |
| `scoresProvider`             | StreamProvider.family | Pontuações por par                     |
| `totalPairPointsProvider`    | Provider              | Total de pontos do par                 |
| `thermometerProgressProvider`| Provider              | Progresso do termômetro (0.0 - 1.0)   |
| `rewardsProvider`            | StreamProvider.family | Recompensas por par                    |
| `rewardsNotifierProvider`    | StateNotifierProvider | Ações de recompensas                   |
| `recurrenceProvider`         | Provider              | Use case de gerar ocorrências          |
| `occurrencesProvider`        | StreamProvider.family | Ocorrências por par/tarefa             |
| `dashboardDataProvider`      | FutureProvider        | Dados agregados do dashboard           |
| `myAssignedTasksProvider`    | StreamProvider        | Tasks assigned to current user (executor) |
| `myRequestedTasksProvider`   | StreamProvider        | Tasks created by current user (requester) |
| `pendingValidationOccurrencesProvider` | StreamProvider | Occurrences awaiting user's validation |
| `reportsProvider`            | FutureProvider        | Dados de relatórios                    |

---

## Navegação (GoRouter)

O roteamento é gerenciado pelo **GoRouter** com guarda de autenticação.

### Configuração

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/dashboard';
      return null;
    },
    routes: [ ... ],
  );
});
```

### Tabela de Rotas

| Rota                        | Página              | Parâmetros               |
| --------------------------- | ------------------- | ------------------------ |
| `/login`                    | LoginPage           | —                        |
| `/register`                 | RegisterPage        | —                        |
| `/dashboard`                | DashboardPage (2 tabs)| —                        |
| `/pair-management`          | PairManagementPage  | —                        |
| `/invite`                   | InvitePage          | —                        |
| `/tasks`                    | TaskListPage        | —                        |
| `/tasks/new`                | TaskFormPage        | —                        |
| `/tasks/:id/edit`           | TaskFormPage        | `id` (taskId)            |
| `/my-tasks`                 | MyTasksPage         | —                        |
| `/execute/:occurrenceId`    | TaskExecutionPage   | `occurrenceId`           |
| `/validate/:executionId`    | ValidationPage      | `executionId`            |
| `/score`                    | ScorePage           | —                        |
| `/rewards`                  | RewardsPage         | —                        |
| `/reports`                  | ReportsPage         | —                        |
| `/profile`                  | ProfilePage         | —                        |

### Guarda de Autenticação

- Usuários **não autenticados** são redirecionados para `/login`
- Usuários **autenticados** que tentam acessar `/login` ou `/register` são redirecionados para `/dashboard`

---

## Camada de Serviços Firebase

Os serviços Firebase encapsulam toda a comunicação com o backend.

### FirebaseAuthService (`lib/services/firebase_auth_service.dart`)

| Método              | Descrição                                |
| ------------------- | ---------------------------------------- |
| `signIn()`          | Login com email e senha                  |
| `register()`        | Registro com email, senha e display name |
| `signOut()`         | Logout                                   |
| `updateDisplayName` | Atualizar nome de exibição               |
| `authStateChanges`  | Stream do estado de autenticação         |

### FirestoreService (`lib/services/firestore_service.dart`)

Serviço genérico de CRUD para Firestore:

| Método             | Descrição                                    |
| ------------------ | -------------------------------------------- |
| `createDocument()` | Cria documento com ID automático ou definido  |
| `getDocument()`    | Busca documento por ID                       |
| `updateDocument()` | Atualiza campos de um documento              |
| `deleteDocument()` | Remove documento                             |
| `watchCollection()`| Stream de documentos com filtros opcionais   |
| `queryDocuments()` | Busca com filtros (where clauses)            |

### StorageService (`lib/services/storage_service.dart`)

| Método             | Descrição                        |
| ------------------ | -------------------------------- |
| `uploadFile()`     | Upload de arquivo (File)         |
| `uploadBytes()`    | Upload de bytes                  |
| `deleteFile()`     | Remove arquivo do Storage        |
| `getDownloadUrl()` | Obtém URL pública do arquivo     |

### FcmService (`lib/services/fcm_service.dart`)

| Método                   | Descrição                          |
| ------------------------ | ---------------------------------- |
| `getToken()`             | Obtém token FCM do dispositivo     |
| `subscribeToTopic()`     | Inscreve em tópico de notificação  |
| `unsubscribeFromTopic()` | Remove inscrição de tópico         |
| `onMessage`              | Stream de mensagens recebidas      |

---

## Padrão Repository

O Repository Pattern cria uma abstração entre a camada de domínio e a fonte de dados.

### Estrutura

```
domain/repositories/           ← Interfaces (abstract classes)
    ├── auth_repository.dart
    ├── pair_repository.dart
    ├── task_repository.dart
    ├── ...

data/repositories/             ← Implementações concretas
    ├── auth_repository_impl.dart
    ├── pair_repository_impl.dart
    ├── task_repository_impl.dart
    ├── ...
```

### Exemplo completo

**Interface (domínio):**
```dart
abstract class TaskRepository {
  Future<TaskEntity> createTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String taskId);
  Stream<List<TaskEntity>> watchTasksByPairId(String pairId);
  Future<TaskEntity?> getTaskById(String taskId);
}
```

**Implementação (dados):**
```dart
class TaskRepositoryImpl implements TaskRepository {
  final FirestoreService _firestoreService;

  TaskRepositoryImpl(this._firestoreService);

  @override
  Future<TaskEntity> createTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    final id = await _firestoreService.createDocument(
      FirestoreConstants.tasksCollection,
      model.toMap(),
    );
    return task.copyWith(id: id);
  }
  // ...
}
```

### Benefícios

1. **Testabilidade**: use mocks da interface para testes unitários
2. **Flexibilidade**: troque Firebase por outra fonte de dados sem alterar o domínio
3. **Separação**: a camada de domínio não conhece Timestamps, Maps ou Firestore

---

## Como Adicionar uma Nova Feature

Guia passo a passo para adicionar uma nova funcionalidade ao projeto:

### Passo 1: Definir a Entidade

Crie a entidade em `lib/domain/entities/`:

```dart
// lib/domain/entities/nova_entity.dart
class NovaEntity extends Equatable {
  final String id;
  final String campo1;
  // ...

  const NovaEntity({required this.id, required this.campo1});

  NovaEntity copyWith({String? id, String? campo1}) { ... }

  @override
  List<Object?> get props => [id, campo1];
}
```

### Passo 2: Definir a Interface do Repositório

Crie em `lib/domain/repositories/`:

```dart
// lib/domain/repositories/nova_repository.dart
abstract class NovaRepository {
  Future<NovaEntity> create(NovaEntity entity);
  Stream<List<NovaEntity>> watchAll(String filtroId);
  Future<void> delete(String id);
}
```

### Passo 3: Criar o Modelo de Dados

Crie em `lib/data/models/`:

```dart
// lib/data/models/nova_model.dart
class NovaModel {
  factory NovaModel.fromMap(Map<String, dynamic> map, String id);
  factory NovaModel.fromEntity(NovaEntity entity);
  Map<String, dynamic> toMap();
  NovaEntity toEntity();
}
```

### Passo 4: Implementar o Repositório

Crie em `lib/data/repositories/`:

```dart
// lib/data/repositories/nova_repository_impl.dart
class NovaRepositoryImpl implements NovaRepository {
  final FirestoreService _firestoreService;
  NovaRepositoryImpl(this._firestoreService);
  // ... implementações
}
```

### Passo 5: Adicionar Constante da Coleção

Em `lib/core/constants/firestore_constants.dart`:

```dart
static const String novaCollection = 'novaCollection';
```

### Passo 6: Criar os Providers

Em `lib/features/nova/presentation/providers/`:

```dart
final novaRepositoryProvider = Provider<NovaRepository>((ref) {
  return NovaRepositoryImpl(ref.read(firestoreServiceProvider));
});

final novasProvider = StreamProvider.family<List<NovaEntity>, String>((ref, filtroId) {
  return ref.read(novaRepositoryProvider).watchAll(filtroId);
});
```

### Passo 7: Criar as Páginas

Em `lib/features/nova/presentation/pages/`:

```dart
class NovaPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final novasAsync = ref.watch(novasProvider(filtroId));
    return novasAsync.when(
      data: (items) => ...,
      loading: () => const LoadingWidget(),
      error: (err, _) => AppErrorWidget(message: err.toString()),
    );
  }
}
```

### Passo 8: Adicionar a Rota

Em `lib/routes/app_router.dart`:

```dart
GoRoute(
  path: '/nova',
  builder: (context, state) => const NovaPage(),
),
```

### Passo 9: Criar Regras de Segurança

Adicione em `firebase/firestore.rules`:

```
match /novaCollection/{docId} {
  allow read: if isAuthenticated() && isPairMember(resource.data.pairId);
  allow create: if isAuthenticated() && isPairMember(request.resource.data.pairId);
  // ...
}
```

### Passo 10: Escrever Testes

Crie testes unitários em `test/unit/` e testes de widget em `test/widget/`.

---

## Componentes Compartilhados

### Widgets (`lib/shared/widgets/`)

| Widget             | Descrição                                      |
| ------------------ | ---------------------------------------------- |
| `AppButton`        | Botão reutilizável com loading e variantes     |
| `AppTextField`     | Campo de texto com validação                   |
| `AppErrorWidget`   | Widget padronizado para erros                  |
| `LoadingWidget`    | Indicador de carregamento                      |
| `ResponsiveLayout` | Layout responsivo para múltiplas plataformas   |

### Temas (`lib/shared/themes/`)

- `AppTheme.light` — Tema claro Material 3
- `AppTheme.dark` — Tema escuro Material 3
- `AppColors` — Constantes de cores do app

### Tratamento de Erros (`lib/core/errors/`)

Classes de exceção customizadas para cada camada:
- `FirestoreException` — erros de banco de dados
- `AuthException` — erros de autenticação
- `StorageException` — erros de armazenamento

---

## Decisões Arquiteturais (ADRs)

| # | Decisão                                    | Justificativa                                              |
| - | ------------------------------------------ | ---------------------------------------------------------- |
| 1 | Clean Architecture + Feature-First         | Separação de responsabilidades e organização por domínio    |
| 2 | Riverpod para estado                       | Tipagem forte, testabilidade, suporte a streams             |
| 3 | GoRouter para navegação                    | Declarativo, type-safe, integração com Riverpod             |
| 4 | Equatable nas entidades                    | Comparação por valor, imutabilidade                         |
| 5 | Firestore como backend serverless          | Sincronização em tempo real, sem servidor próprio           |
| 6 | Repository Pattern                         | Desacoplamento entre domínio e fonte de dados               |
| 7 | Modelos separados das entidades            | Responsabilidades distintas (serialização vs. negócio)      |
| 8 | Feature-first ao invés de layer-first      | Melhor escalabilidade e coesão por funcionalidade           |
| 9 | Task auto-assignment (self-prevention)     | `assignedTo` auto-computed to other pair member; Firestore rules enforce `assignedTo != auth.uid` and `createdBy == auth.uid` |
| 10 | Dashboard 2-tab design (executor/requester) | Separates concerns: executor sees own tasks + thermometer, requester manages tasks + validates |
