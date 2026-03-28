# Modelo de Dados — Task Pair App

## Índice

- [Visão Geral](#visão-geral)
- [Coleções do Firestore](#coleções-do-firestore)
  - [users](#users)
  - [pairs](#pairs)
  - [pairInvites](#pairinvites)
  - [tasks](#tasks)
  - [taskRecurrences](#taskrecurrences)
  - [taskOccurrences](#taskoccurrences)
  - [taskExecutions](#taskexecutions)
  - [taskValidations](#taskvalidations)
  - [scores](#scores)
  - [rewards](#rewards)
- [Relacionamentos](#relacionamentos)
- [Regras de Segurança](#regras-de-segurança)
- [Índices Compostos](#índices-compostos)

---

## Visão Geral

O Task Pair App utiliza **Cloud Firestore** como banco de dados NoSQL. Todas as coleções são de nível raiz (top-level collections), sem subcoleções aninhadas.

### Coleções

| Coleção             | Constante no código          | Descrição                   |
| ------------------- | ---------------------------- | --------------------------- |
| `users`             | `usersCollection`            | Perfis de usuários          |
| `pairs`             | `pairsCollection`            | Pares formados              |
| `pairInvites`       | `pairInvitesCollection`      | Convites para pares         |
| `tasks`             | `tasksCollection`            | Tarefas criadas             |
| `taskRecurrences`   | `taskRecurrencesCollection`  | Regras de recorrência       |
| `taskOccurrences`   | `taskOccurrencesCollection`  | Ocorrências geradas         |
| `taskExecutions`    | `taskExecutionsCollection`   | Execuções realizadas        |
| `taskValidations`   | `taskValidationsCollection`  | Validações feitas           |
| `scores`            | `scoresCollection`           | Pontuações acumuladas       |
| `rewards`           | `rewardsCollection`          | Recompensas configuradas    |

As constantes estão definidas em `lib/core/constants/firestore_constants.dart`.

---

## Coleções do Firestore

### users

Perfis dos usuários do sistema. O ID do documento é o UID do Firebase Auth.

| Campo         | Tipo        | Obrigatório | Descrição                       |
| ------------- | ----------- | ----------- | ------------------------------- |
| `email`       | string      | Sim         | Email do usuário                |
| `displayName` | string      | Não         | Nome de exibição                |
| `photoUrl`    | string      | Não         | URL da foto de perfil (Storage) |
| `createdAt`   | timestamp   | Sim         | Data de criação da conta        |

**Exemplo de documento:**
```json
{
  "email": "joao@email.com",
  "displayName": "João Silva",
  "photoUrl": "https://firebasestorage.googleapis.com/.../profile.jpg",
  "createdAt": "2026-01-15T10:30:00Z"
}
```

> **Nota**: O campo `pairId` foi removido. A participação em pares é descoberta consultando a coleção `pairs` onde `requesterId == userId` OU `executorId == userId`. Um usuário pode participar de múltiplos pares.

---

### pairs

Pares formados entre dois usuários com papéis explícitos (solicitante e executor).

| Campo         | Tipo        | Obrigatório | Descrição                         |
| ------------- | ----------- | ----------- | --------------------------------- |
| `requesterId` | string      | Sim         | UID do solicitante (cria tarefas) |
| `executorId`  | string      | Sim         | UID do executor (executa tarefas) |
| `createdAt`   | timestamp   | Sim         | Data de criação do par            |
| `name`        | string      | Sim         | Nome do par                       |
| `scoreTarget` | number      | Sim         | Meta de pontuação (padrão: 100)   |

**Exemplo de documento:**
```json
{
  "requesterId": "uid_joao",
  "executorId": "uid_maria",
  "createdAt": "2026-01-20T14:00:00Z",
  "name": "João & Maria",
  "scoreTarget": 100
}
```

> **Nota**: O modelo suporta relacionamento **1:N** — um mesmo usuário pode participar de múltiplos pares com diferentes pessoas, podendo ser solicitante em alguns pares e executor em outros.

---

### pairInvites

Convites enviados para formação de pares.

| Campo        | Tipo        | Obrigatório | Descrição                         |
| ------------ | ----------- | ----------- | --------------------------------- |
| `fromUserId` | string      | Sim         | UID de quem enviou o convite      |
| `toEmail`    | string      | Sim         | Email do convidado                |
| `pairId`     | string      | Sim         | ID do par que será formado        |
| `status`     | string      | Sim         | `pending`, `accepted`, `declined` |
| `createdAt`  | timestamp   | Sim         | Data de envio do convite          |

**Exemplo de documento:**
```json
{
  "fromUserId": "uid_joao",
  "toEmail": "maria@email.com",
  "pairId": "pair_abc123",
  "status": "pending",
  "createdAt": "2026-01-20T14:00:00Z"
}
```

---

### tasks

Tarefas criadas dentro de um par.

| Campo          | Tipo        | Obrigatório | Descrição                          |
| -------------- | ----------- | ----------- | ---------------------------------- |
| `pairId`       | string      | Sim         | ID do par                          |
| `title`        | string      | Sim         | Nome da tarefa                     |
| `description`  | string      | Não         | Descrição detalhada                |
| `assignedTo`   | string      | Não         | UID do executor designado          |
| `points`       | number      | Sim         | Pontos base da tarefa              |
| `isActive`     | boolean     | Sim         | Se a tarefa está ativa             |
| `recurrenceId` | string      | Não         | ID da regra de recorrência         |
| `createdAt`    | timestamp   | Sim         | Data de criação                    |
| `createdBy`    | string      | Sim         | UID de quem criou                  |

**Exemplo de documento:**
```json
{
  "pairId": "pair_abc123",
  "title": "Lavar a louça",
  "description": "Lavar toda a louça do jantar",
  "assignedTo": "uid_joao",
  "points": 10,
  "isActive": true,
  "recurrenceId": "rec_xyz789",
  "createdAt": "2026-02-01T09:00:00Z",
  "createdBy": "uid_maria"
}
```

---

### taskRecurrences

Regras de recorrência vinculadas a tarefas.

| Campo         | Tipo        | Obrigatório | Descrição                               |
| ------------- | ----------- | ----------- | --------------------------------------- |
| `taskId`      | string      | Sim         | ID da tarefa associada                  |
| `type`        | string      | Sim         | `daily`, `weekly`, `monthly`, `once`    |
| `daysOfWeek`  | array<int>  | Não         | Dias da semana (1=Seg ... 7=Dom)        |
| `dayOfMonth`  | number      | Não         | Dia do mês (para recorrência mensal)    |
| `startDate`   | timestamp   | Sim         | Data de início                          |
| `endDate`     | timestamp   | Não         | Data de fim (null = 30 dias)            |
| `isActive`    | boolean     | Sim         | Se a recorrência está ativa             |

**Exemplo — Recorrência semanal:**
```json
{
  "taskId": "task_123",
  "type": "weekly",
  "daysOfWeek": [1, 3, 5],
  "dayOfMonth": null,
  "startDate": "2026-04-01T00:00:00Z",
  "endDate": "2026-06-30T00:00:00Z",
  "isActive": true
}
```

**Exemplo — Recorrência mensal:**
```json
{
  "taskId": "task_456",
  "type": "monthly",
  "daysOfWeek": null,
  "dayOfMonth": 15,
  "startDate": "2026-01-01T00:00:00Z",
  "endDate": "2026-12-31T00:00:00Z",
  "isActive": true
}
```

---

### taskOccurrences

Ocorrências individuais geradas pelo motor de recorrência.

| Campo        | Tipo        | Obrigatório | Descrição                                      |
| ------------ | ----------- | ----------- | ---------------------------------------------- |
| `taskId`     | string      | Sim         | ID da tarefa originadora                       |
| `pairId`     | string      | Sim         | ID do par (desnormalizado para queries)         |
| `dueDate`    | timestamp   | Sim         | Data prevista para execução                    |
| `status`     | string      | Sim         | `pending`, `executed`, `validated`, `missed`   |
| `assignedTo` | string      | Não         | UID do executor designado                      |

**Exemplo de documento:**
```json
{
  "taskId": "task_123",
  "pairId": "pair_abc123",
  "dueDate": "2026-04-15T00:00:00Z",
  "status": "pending",
  "assignedTo": "uid_joao"
}
```

> **Nota**: O campo `pairId` é desnormalizado (replicado da tarefa) para permitir queries eficientes sem necessidade de join.

---

### taskExecutions

Registros de execução de tarefas.

| Campo          | Tipo        | Obrigatório | Descrição                          |
| -------------- | ----------- | ----------- | ---------------------------------- |
| `occurrenceId` | string      | Sim         | ID da ocorrência executada         |
| `taskId`       | string      | Sim         | ID da tarefa (para regras de segurança) |
| `executedBy`   | string      | Sim         | UID do executor                    |
| `executedAt`   | timestamp   | Sim         | Data/hora da execução              |
| `notes`        | string      | Não         | Observações do executor            |
| `photoUrl`     | string      | Não         | URL da foto de evidência (Storage) |

**Exemplo de documento:**
```json
{
  "occurrenceId": "occ_001",
  "taskId": "task_123",
  "executedBy": "uid_joao",
  "executedAt": "2026-04-15T19:30:00Z",
  "notes": "Lavei toda a louça e organizei o escorredor",
  "photoUrl": "https://firebasestorage.googleapis.com/.../evidence.jpg"
}
```

---

### taskValidations

Validações feitas pelo parceiro do par.

| Campo          | Tipo        | Obrigatório | Descrição                          |
| -------------- | ----------- | ----------- | ---------------------------------- |
| `executionId`  | string      | Sim         | ID da execução validada            |
| `occurrenceId` | string      | Sim         | ID da ocorrência (para regras)     |
| `validatedBy`  | string      | Sim         | UID do validador                   |
| `validatedAt`  | timestamp   | Sim         | Data/hora da validação             |
| `isApproved`   | boolean     | Sim         | Se a execução foi aprovada         |
| `feedback`     | string      | Não         | Comentário do validador            |

**Exemplo — Aprovação:**
```json
{
  "executionId": "exec_001",
  "occurrenceId": "occ_001",
  "validatedBy": "uid_maria",
  "validatedAt": "2026-04-15T20:00:00Z",
  "isApproved": true,
  "feedback": "Muito bem feito!"
}
```

**Exemplo — Reprovação:**
```json
{
  "executionId": "exec_002",
  "occurrenceId": "occ_002",
  "validatedBy": "uid_maria",
  "validatedAt": "2026-04-16T20:00:00Z",
  "isApproved": false,
  "feedback": "Faltou limpar as panelas"
}
```

> **Nota**: Validações possuem campo `pairId` desnormalizado para queries via índice composto.

---

### scores

Pontuações acumuladas por usuário dentro de um par.

| Campo          | Tipo        | Obrigatório | Descrição                       |
| -------------- | ----------- | ----------- | ------------------------------- |
| `pairId`       | string      | Sim         | ID do par                       |
| `userId`       | string      | Sim         | UID do usuário                  |
| `totalPoints`  | number      | Sim         | Total acumulado de pontos       |
| `periodPoints` | number      | Sim         | Pontos do período atual         |
| `updatedAt`    | timestamp   | Sim         | Última atualização              |

**Exemplo de documento:**
```json
{
  "pairId": "pair_abc123",
  "userId": "uid_joao",
  "totalPoints": 85,
  "periodPoints": 30,
  "updatedAt": "2026-04-15T20:00:00Z"
}
```

---

### rewards

Recompensas configuradas para um par.

| Campo            | Tipo        | Obrigatório | Descrição                           |
| ---------------- | ----------- | ----------- | ----------------------------------- |
| `pairId`         | string      | Sim         | ID do par                           |
| `title`          | string      | Sim         | Nome da recompensa                  |
| `description`    | string      | Não         | Descrição detalhada                 |
| `requiredPoints` | number      | Sim         | Pontos necessários para desbloquear |
| `isUnlocked`     | boolean     | Sim         | Se já foi desbloqueada              |
| `unlockedAt`     | timestamp   | Não         | Data/hora do desbloqueio            |

**Exemplo — Recompensa bloqueada:**
```json
{
  "pairId": "pair_abc123",
  "title": "Jantar no restaurante favorito",
  "description": "Comemoração por atingir a meta mensal",
  "requiredPoints": 200,
  "isUnlocked": false,
  "unlockedAt": null
}
```

**Exemplo — Recompensa desbloqueada:**
```json
{
  "pairId": "pair_abc123",
  "title": "Cinema no fim de semana",
  "description": null,
  "requiredPoints": 50,
  "isUnlocked": true,
  "unlockedAt": "2026-04-10T15:00:00Z"
}
```

---

## Relacionamentos

### Diagrama de Entidade-Relacionamento

```
users ────────┐
              │ requesterId / executorId
              ▼
           pairs ──────────┐
              │             │ pairId
              │             ▼
              │         pairInvites
              │
              │ pairId
              ▼
           tasks ──────────────────┐
              │                    │ taskId
              │ taskId             ▼
              │               taskRecurrences
              │
              │ taskId + pairId
              ▼
        taskOccurrences
              │
              │ occurrenceId + taskId
              ▼
        taskExecutions
              │
              │ executionId + occurrenceId
              ▼
        taskValidations

           scores ◄──── pairId + userId
           rewards ◄──── pairId
```

### Resumo dos Relacionamentos

| Origem            | Destino            | Tipo   | Campo(s)                        |
| ----------------- | ------------------ | ------ | ------------------------------- |
| pairs             | users (solicitante)| N:1    | `requesterId` → users.id        |
| pairs             | users (executor)   | N:1    | `executorId` → users.id         |
| pairInvites       | pairs              | N:1    | `pairId` → pairs.id             |
| pairInvites       | users              | N:1    | `fromUserId` → users.id         |
| tasks             | pairs              | N:1    | `pairId` → pairs.id             |
| taskRecurrences   | tasks              | 1:1    | `taskId` → tasks.id             |
| taskOccurrences   | tasks              | N:1    | `taskId` → tasks.id             |
| taskOccurrences   | pairs              | N:1    | `pairId` → pairs.id (desnorm.)  |
| taskExecutions    | taskOccurrences    | 1:1    | `occurrenceId` → taskOccurrences.id |
| taskExecutions    | tasks              | N:1    | `taskId` → tasks.id             |
| taskValidations   | taskExecutions     | 1:1    | `executionId` → taskExecutions.id |
| taskValidations   | taskOccurrences    | N:1    | `occurrenceId` → taskOccurrences.id |
| scores            | pairs              | N:1    | `pairId` → pairs.id             |
| scores            | users              | N:1    | `userId` → users.id             |
| rewards           | pairs              | N:1    | `pairId` → pairs.id             |

---

## Regras de Segurança

As regras de segurança do Firestore estão definidas em `firebase/firestore.rules`.

### Princípios

1. **Autenticação obrigatória** — todas as operações requerem `request.auth != null`
2. **Isolamento por par** — dados de um par só são acessíveis por seus membros
3. **Separação de papéis** — executor e validador devem ser pessoas diferentes
4. **Imutabilidade seletiva** — execuções e validações não podem ser deletadas

### Resumo por Coleção

| Coleção           | Leitura             | Criação              | Atualização          | Deleção              |
| ----------------- | ------------------- | -------------------- | -------------------- | -------------------- |
| `users`           | Qualquer autenticado| Próprio usuário      | Próprio usuário      | ❌ Proibido          |
| `pairs`           | Membros do par      | Membro do par        | Membros do par       | Membros do par       |
| `pairInvites`     | Remetente ou destinatário | Remetente      | Remetente ou destinatário | Remetente         |
| `tasks`           | Membros do par      | Membros do par       | Membros do par       | Membros do par       |
| `taskRecurrences` | Membros do par (via task) | Membros do par  | Membros do par       | Membros do par       |
| `taskOccurrences` | Membros do par      | Membros do par       | Membros do par       | Membros do par       |
| `taskExecutions`  | Membros do par (via task) | Executor designado | Executor original | ❌ Proibido          |
| `taskValidations` | Membros do par (via occ.) | Validador ≠ executor | Validador original | ❌ Proibido       |
| `scores`          | Membros do par      | Membros do par       | Membros do par       | ❌ Proibido          |
| `rewards`         | Membros do par      | Membros do par       | Membros do par       | Membros do par       |

### Funções Auxiliares (Helper Functions)

```javascript
isAuthenticated()     // Verifica se request.auth != null
isOwner(userId)       // Verifica se auth.uid == userId
isPairMember(pairId)  // Verifica se auth.uid é requesterId ou executorId do par
isTaskPairMember(taskId) // Verifica se é membro do par via tarefa
```

---

## Índices Compostos

Definidos em `firebase/firestore.indexes.json`.

| #  | Coleção           | Campos                          | Escopo      | Uso                                  |
| -- | ----------------- | ------------------------------- | ----------- | ------------------------------------ |
| 1  | taskOccurrences   | `pairId` ↑, `status` ↑         | COLLECTION  | Filtrar ocorrências por par e status |
| 2  | scores            | `userId` ↑, `pairId` ↑         | COLLECTION  | Buscar score de usuário em um par    |
| 3  | pairInvites       | `toEmail` ↑, `status` ↑        | COLLECTION  | Convites pendentes por email         |
| 4  | taskOccurrences   | `pairId` ↑, `dueDate` ↑        | COLLECTION  | Ocorrências ordenadas por data       |
| 5  | taskOccurrences   | `taskId` ↑, `dueDate` ↑        | COLLECTION  | Ocorrências de uma tarefa por data   |
| 6  | taskValidations   | `pairId` ↑, `validatedAt` ↓    | COLLECTION  | Validações recentes do par           |

### Quando Criar Novos Índices

Índices compostos são necessários quando:
- Uma query usa `where()` em um campo **e** `orderBy()` em outro
- Uma query usa `where()` em dois campos diferentes
- O Firestore emite erro de índice ausente no console

Para adicionar um novo índice, edite `firebase/firestore.indexes.json` e faça deploy:

```bash
firebase deploy --only firestore:indexes
```
