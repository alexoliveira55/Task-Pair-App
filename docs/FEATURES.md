# Documentação de Features — Task Pair App

## Índice

1. [Autenticação](#1-autenticação)
2. [Gerenciamento de Pares](#2-gerenciamento-de-pares)
3. [Gerenciamento de Tarefas](#3-gerenciamento-de-tarefas)
4. [Motor de Recorrência](#4-motor-de-recorrência)
5. [Execução de Tarefas](#5-execução-de-tarefas)
6. [Validação de Tarefas](#6-validação-de-tarefas)
7. [Sistema de Pontuação](#7-sistema-de-pontuação)
8. [Recompensas](#8-recompensas)
9. [Dashboard](#9-dashboard)
10. [Relatórios](#10-relatórios)
11. [Internacionalização (i18n)](#11-internacionalização-i18n)

---

## 1. Autenticação

### Descrição

Sistema de autenticação baseado em Firebase Auth com email e senha.

### Funcionalidades

| Funcionalidade      | Descrição                                          |
| ------------------- | -------------------------------------------------- |
| Registro            | Criar conta com nome, email e senha                |
| Login               | Entrar com email e senha                           |
| Logout              | Sair da conta                                      |
| Recuperar Senha     | Envio de email de redefinição                      |
| Editar Perfil       | Alterar nome de exibição e foto de perfil          |

### Telas

- **LoginPage** (`/login`) — Formulário de email e senha com validação
- **RegisterPage** (`/register`) — Formulário de nome, email e senha
- **ProfilePage** (`/profile`) — Visualizar e editar dados do perfil, upload de foto

### Fluxo de Registro

```
Usuário preenche nome, email e senha
    ↓
Firebase Auth cria conta
    ↓
Sistema cria documento em users/
    ↓
Redireciona para Dashboard
```

### Fluxo de Login

```
Usuário informa email e senha
    ↓
Firebase Auth valida credenciais
    ↓
authStateProvider detecta usuário logado
    ↓
GoRouter redireciona para /dashboard
```

### Providers

| Provider                    | Tipo                  | Função                          |
| --------------------------- | --------------------- | ------------------------------- |
| `authStateProvider`         | StreamProvider        | Observa estado de autenticação  |
| `currentUserEntityProvider` | FutureProvider        | Carrega dados do usuário logado |
| `authNotifierProvider`      | StateNotifierProvider | Login, registro, logout         |

### Regras de Segurança

- Qualquer usuário autenticado pode ler perfis (necessário para convites e info do parceiro)
- Somente o próprio usuário pode criar/atualizar seu documento
- Deleção de perfil não é permitida

---

## 2. Gerenciamento de Pares

### Descrição

Sistema para formação e gerenciamento de pares entre dois usuários. Um usuário pode ter múltiplos pares (ex: cônjuge, filho, colega).

### Funcionalidades

| Funcionalidade     | Descrição                                      |
| ------------------ | ---------------------------------------------- |
| Criar Par          | Cria um novo par e envia convite               |
| Convidar Usuário   | Convite por email                              |
| Aceitar Convite    | Aceitar convite pendente e formar o par        |
| Recusar Convite    | Recusar convite recebido                       |
| Sair do Par        | Remover-se de um par existente                 |

### Telas

- **PairManagementPage** (`/pair-management`) — Listar pares, aceitar convites, ver detalhes
- **InvitePage** (`/invite`) — Enviar convite por email

### Fluxo de Criação de Par

```
Usuário A cria par com nome
    ↓
Sistema salva par no Firestore (requesterId = A)
    ↓
Usuário A convida Usuário B por email
    ↓
Sistema cria pairInvite com status "pending"
    ↓
Usuário B vê convite pendente
    ↓
Usuário B aceita convite
    ↓
Sistema atualiza convite para "accepted"
    ↓
Sistema atualiza par com executorId = B
    ↓
Par formado! Podem criar tarefas.
```

### Estados do Convite

| Status     | Descrição           |
| ---------- | ------------------- |
| `pending`  | Aguardando aceite   |
| `accepted` | Aceito              |
| `declined` | Recusado            |

### Providers

| Provider                | Tipo                  | Função                            |
| ----------------------- | --------------------- | --------------------------------- |
| `currentPairProvider`   | Provider              | Par selecionado (ou primeiro)     |
| `myPairsProvider`       | StreamProvider        | Todos os pares do usuário         |
| `pairsAsRequesterProvider`| Provider            | Pares onde usuário é solicitante   |
| `pairsAsExecutorProvider` | Provider            | Pares onde usuário é executor      |
| `selectedPairIdProvider`| StateProvider         | ID do par selecionado             |
| `pendingInvitesProvider`| StreamProvider        | Convites pendentes recebidos      |
| `pairNotifierProvider`  | StateNotifierProvider | Ações de criar par, aceitar, etc. |

### Entidades

- **PairEntity**: `id`, `requesterId`, `executorId`, `createdAt`, `name`, `scoreTarget`
- **PairInviteEntity**: `id`, `fromUserId`, `toEmail`, `pairId`, `status`, `createdAt`

---

## 3. Gerenciamento de Tarefas

### Descrição

Criação, edição e gerenciamento de tarefas dentro de um par. Cada tarefa pode ter recorrência, pontuação e um executor designado.

### Funcionalidades

| Funcionalidade  | Descrição                                         |
| --------------- | ------------------------------------------------- |
| Criar Tarefa    | Definir título, descrição, executor e pontuação   |
| Editar Tarefa   | Alterar dados de uma tarefa existente             |
| Deletar Tarefa  | Remover tarefa e seus dados relacionados          |
| Listar Tarefas  | Visualizar todas as tarefas do par                |

### Telas

- **TaskListPage** (`/tasks`) — Lista de tarefas do par com botão de adicionar
- **TaskFormPage** (`/tasks/new`) — Formulário de criação de tarefa
- **TaskFormPage** (`/tasks/:id/edit`) — Formulário de edição de tarefa

### Campos da Tarefa

| Campo         | Tipo     | Obrigatório | Descrição                          |
| ------------- | -------- | ----------- | ---------------------------------- |
| `title`       | String   | Sim         | Nome da tarefa                     |
| `description` | String   | Não         | Descrição detalhada                |
| `createdBy`   | String   | Sim         | ID do solicitante (usuário logado, automático) |
| `assignedTo`  | String   | Sim         | ID do executor (outro membro do par, automático) |
| `points`      | int      | Sim         | Pontos base da tarefa (padrão: 10) |
| `isActive`    | bool     | Sim         | Se a tarefa está ativa             |
| `recurrenceId`| String   | Não         | ID da recorrência vinculada        |

### Auto-Assignment Rule

Tasks enforce a **self-assignment prevention** rule:

- `createdBy` is always the **current authenticated user** (the requester/solicitante)
- `assignedTo` is automatically set to the **other member of the pair** (the executor)
- There is **no UI field** for selecting `assignedTo` — it is computed automatically
- Firestore security rules enforce: `assignedTo != request.auth.uid` and `createdBy == request.auth.uid`
- This ensures the requester can never assign a task to themselves

### Fluxo de Criação

```
Selecionar par
    ↓
Preencher nome e descrição
    ↓
(assignedTo é automaticamente o outro membro do par)
    ↓
Definir pontuação
    ↓
Definir recorrência (opcional)
    ↓
Salvar tarefa
    ↓
Firestore rules validate: createdBy == auth.uid && assignedTo != auth.uid
    ↓
Se recorrente: sistema gera ocorrências automaticamente
```

### Providers

| Provider             | Tipo                  | Função                   |
| -------------------- | --------------------- | ------------------------ |
| `tasksProvider`      | StreamProvider.family | Tarefas do par em tempo real |
| `taskNotifierProvider`| StateNotifierProvider | CRUD de tarefas          |

---

## 4. Motor de Recorrência

### Descrição

O motor de recorrência gera automaticamente ocorrências de tarefas com base no tipo de recorrência configurado. Cada ocorrência representa uma instância da tarefa em uma data específica.

### Tipos de Recorrência

| Tipo       | Constante          | Descrição                            | Exemplo                       |
| ---------- | ------------------ | ------------------------------------ | ----------------------------- |
| Diário     | `daily`            | Uma ocorrência por dia               | Todos os dias de 01/04 a 30/04 |
| Semanal    | `weekly`           | Ocorrências nos dias da semana definidos | Seg, Qua, Sex                |
| Mensal     | `monthly`          | Uma ocorrência por mês no dia definido  | Dia 15 de cada mês           |
| Única      | `once`             | Uma única ocorrência                 | Apenas em 01/04              |

### Entidade TaskRecurrenceEntity

| Campo         | Tipo       | Descrição                              |
| ------------- | ---------- | -------------------------------------- |
| `id`          | String     | Identificador único                    |
| `taskId`      | String     | Tarefa associada                       |
| `type`        | String     | Tipo: daily, weekly, monthly, once     |
| `daysOfWeek`  | List<int>? | Dias da semana (1=Seg ... 7=Dom)       |
| `dayOfMonth`  | int?       | Dia do mês para recorrência mensal     |
| `startDate`   | DateTime   | Data de início                         |
| `endDate`     | DateTime?  | Data de fim (null = 30 dias a partir do início) |
| `isActive`    | bool       | Se a recorrência está ativa            |

### Como Funciona a Geração

O `GenerateOccurrencesUseCase` recebe uma recorrência e gera ocorrências:

1. **Diário**: itera dia a dia do `startDate` ao `endDate`
2. **Semanal**: itera dia a dia, filtrando pelos `daysOfWeek` definidos
3. **Mensal**: gera uma ocorrência no `dayOfMonth` de cada mês no período
4. **Única**: gera uma única ocorrência no `startDate`

Para cada data gerada, cria um `TaskOccurrenceEntity` com status `pending`.

### Exemplo: Recorrência Diária

```
Tarefa: Lavar louça
Tipo: Diário
Período: 01/04 a 10/04

Ocorrências geradas:
├── 01/04 - pending
├── 02/04 - pending
├── 03/04 - pending
├── ...
└── 10/04 - pending
```

### Exemplo: Recorrência Semanal

```
Tarefa: Limpar casa
Tipo: Semanal
Dias: [1, 3, 5] (Seg, Qua, Sex)
Período: 01/04 a 30/04

Apenas ocorrências nas Segundas, Quartas e Sextas do período.
```

### Entidade TaskOccurrenceEntity

| Campo        | Tipo      | Descrição                               |
| ------------ | --------- | --------------------------------------- |
| `id`         | String    | Identificador único                     |
| `taskId`     | String    | Tarefa originadora                      |
| `pairId`     | String    | Par associado (desnormalizado)          |
| `dueDate`    | DateTime  | Data prevista da execução               |
| `status`     | String    | Status: pending, executed, validated, missed |
| `assignedTo` | String?   | Executor designado                      |

### Estados da Ocorrência

| Status      | Descrição                          |
| ----------- | ---------------------------------- |
| `pending`   | Aguardando execução                |
| `executed`  | Executor concluiu a tarefa         |
| `validated` | Solicitante validou a execução     |
| `missed`    | Tarefa não foi executada no prazo  |

---

## 5. Execução de Tarefas

### Descrição

O executor de uma tarefa pode registrar a execução de uma ocorrência, incluindo notas e evidência fotográfica.

### Funcionalidades

| Funcionalidade     | Descrição                                     |
| ------------------ | --------------------------------------------- |
| Executar Tarefa    | Registrar execução de uma ocorrência          |
| Adicionar Notas    | Incluir observações sobre a execução          |
| Anexar Foto        | Evidência fotográfica via câmera ou galeria   |

### Telas

- **MyTasksPage** (`/my-tasks`) — Lists executor's assigned task occurrences in 3 sections
- **TaskExecutionPage** (`/execute/:occurrenceId`) — Formulário de execução

### MyTasksPage (NEW)

Dedicated page showing all tasks assigned to the current user (executor view):

| Section                | Content                                           |
| ---------------------- | ------------------------------------------------- |
| **Pending**            | Occurrences awaiting execution, with Execute button |
| **Executed**           | Occurrences executed but awaiting validation       |
| **Validated**          | Occurrences already validated by the requester     |

The executor taps "Execute" on a pending occurrence to navigate to `/execute/:occurrenceId`.

### Fluxo de Execução

```
Executor opens MyTasksPage (/my-tasks)
    ↓
Sees pending occurrences assigned to them
    ↓
Taps "Execute" on a pending occurrence
    ↓
Navigates to /execute/:occurrenceId
    ↓
Preenche notas (opcional)
    ↓
Anexa foto (opcional)
    ↓
Confirma execução
    ↓
Sistema cria TaskExecution
    ↓
Status da ocorrência muda para "executed"
    ↓
Tarefa aparece na seção "Executed" do MyTasksPage
    ↓
Tarefa vai para fila de validação do solicitante
```

### Entidade TaskExecutionEntity

| Campo          | Tipo      | Descrição                        |
| -------------- | --------- | -------------------------------- |
| `id`           | String    | Identificador único              |
| `occurrenceId` | String    | Ocorrência executada             |
| `taskId`       | String    | Tarefa originadora               |
| `executedBy`   | String    | ID do executor                   |
| `executedAt`   | DateTime  | Data/hora da execução            |
| `notes`        | String?   | Observações do executor          |
| `photoUrl`     | String?   | URL da foto de evidência         |

### Providers

| Provider                           | Tipo                  | Função                                         |
| ---------------------------------- | --------------------- | ---------------------------------------------- |
| `executionNotifierProvider`        | StateNotifierProvider | Registrar execução                             |
| `myPendingOccurrencesProvider`     | StreamProvider        | Occurrences assigned to user, status=pending   |
| `myExecutedOccurrencesProvider`    | StreamProvider        | Occurrences assigned to user, status=executed  |
| `myValidatedOccurrencesProvider`   | StreamProvider        | Occurrences assigned to user, status=validated |
| `executionByOccurrenceIdProvider`  | FutureProvider.family | Looks up execution record by occurrence ID     |

### Regras de Segurança

- Somente o executor designado pode criar a execução
- Somente o executor pode atualizar sua própria execução
- Deleção não é permitida

---

## 6. Validação de Tarefas

### Descrição

O parceiro do par (solicitante) valida a execução feita pelo executor, aprovando ou reprovando com feedback.

### Funcionalidades

| Funcionalidade        | Descrição                                  |
| --------------------- | ------------------------------------------ |
| Validar Execução      | Aprovar ou reprovar a execução             |
| Adicionar Feedback    | Comentários sobre a execução               |

### Tela

- **ValidationPage** (`/validate/:executionId`) — Formulário de validação

### Fluxo de Validação

```
Solicitante abre validações pendentes
    ↓
Seleciona execução para validar
    ↓
Escolhe: Aprovado ou Reprovado
    ↓
Adiciona feedback (opcional)
    ↓
Confirma validação
    ↓
Sistema cria TaskValidation
    ↓
Sistema calcula pontuação
    ↓
Atualiza scores e termômetros
```

### Entidade TaskValidationEntity

| Campo          | Tipo      | Descrição                        |
| -------------- | --------- | -------------------------------- |
| `id`           | String    | Identificador único              |
| `executionId`  | String    | Execução sendo validada          |
| `occurrenceId` | String    | Ocorrência associada             |
| `validatedBy`  | String    | ID do validador                  |
| `validatedAt`  | DateTime  | Data/hora da validação           |
| `isApproved`   | bool      | Se a execução foi aprovada       |
| `feedback`     | String?   | Comentário do validador          |

### Providers

| Provider                      | Tipo                  | Função                 |
| ----------------------------- | --------------------- | ---------------------- |
| `validationNotifierProvider`  | StateNotifierProvider | Criar validação        |

### Regras de Segurança

- Somente membros do par podem ler validações
- O validador **não pode ser** o mesmo que executou a tarefa
- Somente o validador original pode atualizar
- Deleção não é permitida

---

## 7. Sistema de Pontuação

### Descrição

Sistema de pontuação baseado na execução e validação de tarefas. Cada tarefa tem uma pontuação base que é aplicada conforme o resultado da validação.

### Fórmula de Pontuação

**Tarefa aprovada:**
```
Pontuação = PontosDaTarefa (pontuação total)
```

**Tarefa não aprovada:**
```
Pontuação = PontosDaTarefa * -1 (pontuação negativa)
```

### Tipos de Pontuação Acumulada

| Tipo                  | Descrição                             |
| --------------------- | ------------------------------------- |
| Pontuação Total       | Soma de todas as pontuações do usuário|
| Pontuação por Par     | Pontuação no contexto de um par       |
| Pontuação do Período  | Pontuação no mês/semana atual         |

### Entidade ScoreEntity

| Campo          | Tipo      | Descrição                        |
| -------------- | --------- | -------------------------------- |
| `id`           | String    | Identificador único              |
| `pairId`       | String    | Par associado                    |
| `userId`       | String    | Usuário que recebeu os pontos    |
| `totalPoints`  | int       | Total acumulado de pontos        |
| `periodPoints` | int       | Pontos do período atual          |
| `updatedAt`    | DateTime  | Última atualização               |

### Tela

- **ScorePage** (`/score`) — Exibe pontuações do par com termômetro de progresso

### Providers

| Provider                       | Tipo                  | Função                             |
| ------------------------------ | --------------------- | ---------------------------------- |
| `scoresProvider`               | StreamProvider.family | Pontuações do par em tempo real    |
| `totalPairPointsProvider`      | Provider              | Total de pontos combinados do par  |
| `thermometerProgressProvider`  | Provider              | Progresso percentual (0.0 - 1.0)  |

### Cálculo do Termômetro

```
Progresso = totalPairPoints / scoreTarget
```

Onde `scoreTarget` é definido no `PairEntity` (padrão: 100 pontos).

---

## 8. Recompensas

### Descrição

Sistema de recompensas vinculadas ao par. Cada recompensa tem uma meta de pontos necessários para ser desbloqueada.

### Funcionalidades

| Funcionalidade        | Descrição                                    |
| --------------------- | -------------------------------------------- |
| Criar Recompensa      | Definir título, descrição e pontos necessários|
| Ver Progresso         | Termômetro mostrando progresso para a meta   |
| Desbloquear           | Recompensa é desbloqueada ao atingir a meta  |
| Deletar Recompensa    | Remover recompensa do par                    |

### Tela

- **RewardsPage** (`/rewards`) — Lista de recompensas com progresso e criação

### Entidade RewardEntity

| Campo            | Tipo      | Descrição                          |
| ---------------- | --------- | ---------------------------------- |
| `id`             | String    | Identificador único                |
| `pairId`         | String    | Par associado                      |
| `title`          | String    | Nome da recompensa                 |
| `description`    | String?   | Descrição detalhada                |
| `requiredPoints` | int       | Pontos necessários para desbloquear|
| `isUnlocked`     | bool      | Se já foi desbloqueada             |
| `unlockedAt`     | DateTime? | Data/hora do desbloqueio           |

### Fluxo de Desbloqueio

```
Par acumula pontos via validações
    ↓
totalPairPoints >= requiredPoints
    ↓
Recompensa é desbloqueada
    ↓
isUnlocked = true, unlockedAt = agora
```

### Termômetro de Recompensa

Cada recompensa tem seu próprio termômetro:

```
Progresso = totalPairPoints / requiredPoints
```

Exemplo:
```
Recompensa: Jantar especial
Necessários: 200 pontos
Acumulados: 150 pontos
Progresso: 75% ████████████░░░░
```

### Providers

| Provider                  | Tipo                  | Função                       |
| ------------------------- | --------------------- | ---------------------------- |
| `rewardsProvider`         | StreamProvider.family | Recompensas do par           |
| `rewardsNotifierProvider` | StateNotifierProvider | CRUD de recompensas          |

---

## 9. Dashboard

### Descrição

Tela principal do aplicativo com **2 abas** que separam a visão de executor e solicitante. Redesenhada para refletir a regra de auto-assignment: quem cria a tarefa é o solicitante, quem executa é o outro membro do par.

### Tela

- **DashboardPage** (`/dashboard`) — Tela principal após login, com 2 abas (TabBar)

### Tab 1: "Tarefas que faço" (Tasks I Execute)

Visão do **executor** — mostra tarefas atribuídas ao usuário corrente:

| Componente                      | Descrição                                              |
| ------------------------------- | ------------------------------------------------------ |
| Thermometer (own progress)      | Termômetro de progresso do próprio usuário como executor |
| Pending Occurrences             | Ocorrências pending assignadas a mim, com botão "Executar" |
| Executed (awaiting validation)  | Ocorrências que executei, aguardando validação           |

The thermometer is shown **only** in this tab (executor's own progress).

### Tab 2: "Tarefas que solicito" (Tasks I Request)

Visão do **solicitante** — mostra tarefas criadas pelo usuário corrente:

| Componente                       | Descrição                                                |
| -------------------------------- | -------------------------------------------------------- |
| Quick Actions                    | Botões: Criar Tarefa, Recompensas, Relatórios, Meus Pares |
| Occurrences Needing Validation   | Ocorrências executadas pelo parceiro, com botão "Validar" |
| My Requested Tasks               | Lista de tarefas que criei, com opções de editar/deletar  |

No thermometer is shown in this tab — it is a management/validation view.

### Widgets Customizados

- **ThermometerWidget**: Widget de canvas customizado que renderiza um termômetro visual representando o progresso de pontuação do executor

### Fluxo

```
Usuário faz login
    ↓
Redireciona para /dashboard
    ↓
Carrega dados do par ativo
    ↓
Tab "Tarefas que faço" (padrão):
├── Termômetro de progresso do executor
├── Ocorrências pendentes (com botão Executar → /execute/:id)
└── Ocorrências executadas aguardando validação

Tab "Tarefas que solicito":
├── Ações rápidas (criar tarefa, recompensas, relatórios, pares)
├── Ocorrências aguardando validação (com botão Validar → /validate/:id)
└── Tarefas que criei (com editar/deletar)
```

### Providers

| Provider                                | Tipo                  | Função                                          |
| --------------------------------------- | --------------------- | ----------------------------------------------- |
| `dashboardDataProvider`                 | FutureProvider        | Agrega dados para o dashboard                   |
| `myAssignedTasksProvider`               | StreamProvider        | Tasks where current user is assignedTo (executor) |
| `myRequestedTasksProvider`              | StreamProvider        | Tasks where current user is createdBy (requester) |
| `pendingValidationOccurrencesProvider`  | StreamProvider        | Occurrences executed by partner, awaiting my validation |
| `myPendingOccurrencesProvider`          | StreamProvider        | Occurrences assigned to me, status=pending       |
| `myExecutedOccurrencesProvider`         | StreamProvider        | Occurrences I executed, awaiting validation      |

### Tipos de Termômetro

O termômetro aparece **apenas na aba do executor** ("Tarefas que faço"):

| Termômetro               | Descrição                                | Tab         |
| ------------------------ | ---------------------------------------- | ----------- |
| Termômetro do Executor   | Progresso de pontuação do executor       | Executor    |
| Termômetro Mensal        | Pontuação acumulada no mês               | Executor    |
| Termômetro de Recompensa | Progresso para a próxima recompensa      | Executor    |

---

## 10. Relatórios

### Descrição

Visualização de estatísticas detalhadas sobre tarefas, execuções e pontuações.

### Funcionalidades

| Funcionalidade       | Descrição                                   |
| -------------------- | ------------------------------------------- |
| Estatísticas Gerais  | Total de tarefas, executadas, validadas     |
| Filtro por Período   | Filtrar dados por semana, mês, período      |
| Resumo de Pontuação  | Pontos por executor e por tarefa            |

### Tela

- **ReportsPage** (`/reports`) — Exibição de estatísticas com filtros

### Métricas Disponíveis

| Métrica                 | Descrição                              |
| ----------------------- | -------------------------------------- |
| Total de Tarefas        | Quantidade de tarefas ativas no par    |
| Tarefas Executadas      | Ocorrências com status `executed`      |
| Tarefas Validadas       | Ocorrências com status `validated`     |
| Tarefas Pendentes       | Ocorrências com status `pending`       |
| Tarefas Não Cumpridas   | Ocorrências com status `missed`        |
| Pontuação Total         | Soma de pontos acumulados              |
| Pontuação do Período    | Pontos no período selecionado          |

### Providers

| Provider           | Tipo           | Função                            |
| ------------------ | -------------- | --------------------------------- |
| `reportsProvider`  | FutureProvider | Calcula estatísticas de relatório |

### Filtros de Período

| Filtro     | Descrição              |
| ---------- | ---------------------- |
| Semana     | Últimos 7 dias         |
| Mês        | Mês vigente            |
| Período    | Intervalo personalizado|

---

## Resumo das Features

| #  | Feature            | Telas | Entidades                         | Status |
| -- | ------------------ | ----- | --------------------------------- | ------ |
| 1  | Autenticação       | 3     | UserEntity                        | ✅     |
| 2  | Pares              | 2     | PairEntity, PairInviteEntity      | ✅     |
| 3  | Tarefas            | 2     | TaskEntity                        | ✅ (auto-assignment) |
| 4  | Recorrência        | —     | TaskRecurrenceEntity, TaskOccurrenceEntity | ✅ |
| 5  | Execução           | 2     | TaskExecutionEntity               | ✅ (+ MyTasksPage) |
| 6  | Validação          | 1     | TaskValidationEntity              | ✅     |
| 7  | Pontuação          | 1     | ScoreEntity                       | ✅     |
| 8  | Recompensas        | 1     | RewardEntity                      | ✅     |
| 9  | Dashboard          | 1     | —                                 | ✅ (2 tabs) |
| 10 | Relatórios         | 1     | —                                 | ✅     |
| 11 | Internacionalização| 1     | —                                 | ⬜     |

---

## 11. Internacionalização (i18n)

### Descrição

Sistema de internacionalização que permite ao aplicativo operar em múltiplos idiomas, com detecção automática do idioma do sistema e opção de troca manual pelo usuário.

### Idiomas Suportados

| Idioma               | Código Locale | Tipo     |
| -------------------- | ------------- | -------- |
| Português (Brasil)   | `pt_BR`       | Padrão / Fallback |
| Inglês               | `en`          | Suportado |

### Funcionalidades

| Funcionalidade              | Descrição                                              |
| --------------------------- | ------------------------------------------------------ |
| Detecção Automática         | Identifica idioma do sistema e aplica automaticamente  |
| Troca Manual de Idioma      | Seletor de idioma em configurações                     |
| Persistência de Preferência | Salva escolha do usuário em SharedPreferences          |
| Formatação Regional         | Datas e números conforme convenção do idioma           |

### Tela

- **Configurações** (`/settings` ou seção em `/profile`) — Seletor de idioma

### Tecnologia

| Componente             | Tecnologia                  |
| ---------------------- | --------------------------- |
| Framework i18n         | `flutter_localizations`     |
| Formato de tradução    | ARB (`.arb`)                |
| Geração de código      | `flutter gen-l10n`          |
| Persistência local     | `SharedPreferences`         |
| Estado                 | Riverpod (`localeProvider`) |

### Fluxo de Detecção

```
App inicia
    ↓
Verifica preferência salva (SharedPreferences)
    ↓
[Se existe] → Usa locale salvo
[Se não]    → Detecta idioma do sistema
    ↓
[pt/pt_BR] → Português (Brasil)
[en/en_*]  → Inglês
[Outros]   → Português (Brasil) — fallback
```

### Providers

| Provider           | Tipo                  | Função                           |
| ------------------ | --------------------- | -------------------------------- |
| `localeProvider`   | StateNotifierProvider | Gerencia locale ativo do app     |

### Arquivos de Tradução

| Arquivo            | Descrição                         |
| ------------------ | --------------------------------- |
| `lib/l10n/app_pt_BR.arb` | Strings em Português (Brasil) |
| `lib/l10n/app_en.arb`    | Strings em Inglês             |

### Especificação Completa

Consulte [docs/INTERNATIONALIZATION.md](INTERNATIONALIZATION.md) para a especificação detalhada de requisitos, incluindo tabelas de chaves ARB, regras de formatação regional e critérios de aceite.
