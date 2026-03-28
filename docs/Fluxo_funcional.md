# 📄 Especificação Funcional – Fluxos, Recorrência e Pontuação

## App de Tarefas em Pares – Flutter + Firebase

---

# 1. Fluxo Geral do Usuário

## 1.1 Fluxo Principal do Sistema

```text
Cadastro/Login
      ↓
Criar ou Entrar em um Par
      ↓
Criar Tarefa
      ↓
Recorrências são geradas automaticamente
      ↓
Executor inicia tarefa
      ↓
Executor finaliza tarefa
      ↓
Solicitante valida
      ↓
Sistema calcula pontuação
      ↓
Atualiza termômetros
      ↓
Ao final da recorrência → Recompensa
```

---

# 2. Fluxo de Telas

## 2.1 Lista de Telas

| Ordem | Tela               | Descrição |
| ----- | ------------------ | --------- |
| 1     | Login              |           |
| 2     | Cadastro           |           |
| 3     | Dashboard          |           |
| 4     | Meus Pares         |           |
| 5     | Convites           |           |
| 6     | Lista de Tarefas   |           |
| 7     | Nova Tarefa        |           |
| 8     | Detalhe da Tarefa  |           |
| 9     | Minhas Tarefas (MyTasksPage) | Tarefas atribuídas ao executor (NOVO) |
| 10    | Execução da Tarefa |           |
| 11    | Validação          |           |
| 11    | Termômetro         |           |
| 12    | Relatórios         |           |
| 13    | Recompensas        |           |
| 14    | Perfil             |           |

---

# 3. Fluxo de Formação de Par

## 3.1 Fluxo

```text
Usuário A → Convida Usuário B
Usuário B → Recebe convite
Usuário B → Aceita
Sistema → Cria PAR
Par pode criar tarefas
```

## 3.2 Estados do Convite

| Status   | Descrição         |
| -------- | ----------------- |
| pending  | Aguardando aceite |
| accepted | Aceito            |
| rejected | Recusado          |

---

# 4. Fluxo de Criação de Tarefa

## 4.1 Passos

```text
Selecionar Par
Inserir Nome
Inserir Descrição
Definir Recorrência
Definir período da recorrência
Definir horário
Definir tempo previsto
Definir pontuação
Definir recompensa
Salvar
```

## 4.2 Regra de Auto-Atribuição (NOVO)

O sistema **não permite** que o criador da tarefa a execute. A atribuição é automática:

```text
• createdBy = usuário logado (solicitante/requester)
• assignedTo = outro membro do par (executor)
• NÃO existe campo de seleção de executor na UI
• O sistema calcula automaticamente quem é o executor
```

### Regras do Firestore

```text
assignedTo != request.auth.uid   (executor não pode ser o criador)
createdBy == request.auth.uid    (criador deve ser o usuário logado)
```

### Fluxo Atualizado

```text
Usuário A seleciona par (A + B)
      ↓
Preenche: nome, descrição, pontuação, recorrência
      ↓
Sistema define automaticamente:
  createdBy = A (solicitante)
  assignedTo = B (executor)
      ↓
Firestore valida regras de segurança
      ↓
Tarefa salva
      ↓
Sistema gera recorrências automaticamente
```

---

# 5. Regras de Recorrência

## 5.1 Tipos de Recorrência

| Tipo      | Descrição      |
| --------- | -------------- |
| Diário    | Todos os dias  |
| Semanal   | Dias da semana |
| Mensal    | Dia do mês     |
| Intervalo | A cada X dias  |
| Única     | Apenas uma vez |

---

## 5.2 Geração das Ocorrências

Quando uma tarefa recorrente é criada, o sistema deve gerar **ocorrências**.

Exemplo:

Tarefa: Lavar louça
Recorrência: Diário
Período: 01/04 até 10/04

Sistema gera:

```text
01/04 - Ocorrência
02/04 - Ocorrência
03/04 - Ocorrência
...
10/04 - Ocorrência
```

Cada ocorrência terá status próprio.

---

# 6. Estados de uma Ocorrência de Tarefa

| Status       | Descrição           |
| ------------ | ------------------- |
| Pendente     | Ainda não iniciada  |
| Em andamento | Executor iniciou    |
| Finalizada   | Executor finalizou  |
| Validada     | Solicitante validou |
| Não cumprida | Não executada       |
| Expirada     | Passou do prazo     |

---

# 7. Fluxo de Execução da Tarefa

## 7.1 Acesso via MyTasksPage (NOVO)

O executor acessa suas tarefas pela rota `/my-tasks` (MyTasksPage), que exibe:

| Seção              | Conteúdo                                         |
| ------------------- | ------------------------------------------------ |
| **Pendentes**       | Ocorrências a executar, com botão "Executar"     |
| **Executadas**      | Ocorrências feitas, aguardando validação          |
| **Validadas**       | Ocorrências já validadas pelo solicitante         |

## 7.2 Fluxo de Execução

```text
Executor abre MyTasksPage (/my-tasks)
      ↓
Vê ocorrências pendentes atribuídas a ele
      ↓
Clica "Executar" em uma ocorrência
      ↓
Navega para /execute/:occurrenceId
      ↓
Sistema grava data/hora início
      ↓
Executor realiza tarefa
      ↓
Clica "Finalizar"
      ↓
Sistema grava data/hora fim
      ↓
Ocorrência move para seção "Executadas"
      ↓
Tarefa vai para validação do solicitante
```

### Providers novos

| Provider                               | Função                                        |
| -------------------------------------- | --------------------------------------------- |
| `myPendingOccurrencesProvider`         | Ocorrências do executor com status pending     |
| `myExecutedOccurrencesProvider`        | Ocorrências executadas aguardando validação    |
| `myValidatedOccurrencesProvider`       | Ocorrências já validadas                       |
| `executionByOccurrenceIdProvider`      | Busca execução por ID da ocorrência            |

---

# 8. Fluxo de Validação

```text
Solicitante abre validações pendentes
      ↓
Seleciona tarefa
      ↓
Escolhe:
    - 100%
    - 90%
    - 80%
    - ...
    - 10%
    - Não cumprida
      ↓
Adiciona observação (opcional)
      ↓
Confirma validação
      ↓
Sistema calcula pontuação
      ↓
Atualiza termômetros
```

---

# 9. Modelo de Pontuação

## 9.1 Pontuação por Execução

Fórmula:

```text
Pontuação = PontosDaTarefa * Percentual / 100
```

## 9.2 Não Cumprida

```text
Pontuação = PontosDaTarefa * -1
```

---

# 10. Pontuação Acumulada

Cada executor terá:

| Tipo                   | Descrição          |
| ---------------------- | ------------------ |
| Pontuação Total        | Todas as tarefas   |
| Pontuação por Par      | Por relacionamento |
| Pontuação por Tarefa   | Por tipo de tarefa |
| Pontuação por Período  | Semana/Mês         |
| Sequência de execuções | Gamificação        |
| Recompensas obtidas    | Histórico          |

---

# 11. Termômetros (Muito Importante)

## 11.1 Tipos de Termômetro

| Termômetro               | Descrição                 |
| ------------------------ | ------------------------- |
| Termômetro da tarefa     | Progresso da recorrência  |
| Termômetro do executor   | Pontuação total           |
| Termômetro do par        | Pontuação entre o par     |
| Termômetro mensal        | Pontuação no mês          |
| Termômetro de recompensa | Progresso para recompensa |

---

## 11.2 Exemplo – Termômetro da Tarefa

```text
Tarefa: Lavar louça
Recorrências: 10
Executadas: 7
Validadas: 6

Progresso: 60%
```

---

# 12. Regras de Recompensa

A recompensa é liberada quando:

```text
Pontuação obtida >= Pontuação esperada da recorrência
```

Exemplo:

| Recorrências | Pontos por tarefa | Pontos esperados |
| ------------ | ----------------- | ---------------- |
| 10           | 10                | 100              |

Se usuário fizer 100 pontos → ganha recompensa.

---

# 13. Estrutura de Dados – Firestore (Atualizada)

## Collections

```text
users
pairs
pairInvites
tasks
taskOccurrences
taskExecutions
taskValidations
scores
rewards
```

---

# 14. Estrutura TaskOccurrences (Muito importante)

```json
{
  "id": "occurrenceId",
  "taskId": "taskId",
  "date": "2026-04-01",
  "scheduledStartTime": "19:00",
  "expectedDuration": 30,
  "status": "pending",
  "executionId": null
}
```

---

# 15. Dashboard (Tela Principal) — Redesenhado com 2 Abas

O Dashboard foi redesenhado com **2 abas (TabBar)** para separar as visões de executor e solicitante.

## Aba 1: "Tarefas que faço" (Visão do Executor)

Exibe as tarefas atribuídas ao usuário logado:

* **Termômetro de progresso** do executor (pontuação própria)
* **Ocorrências pendentes** com botão "Executar" (→ /execute/:id)
* **Ocorrências executadas** aguardando validação do solicitante

> O termômetro aparece **apenas nesta aba** (progresso do executor).

## Aba 2: "Tarefas que solicito" (Visão do Solicitante)

Exibe as tarefas criadas pelo usuário logado:

* **Ações rápidas**: Criar Tarefa, Recompensas, Relatórios, Meus Pares
* **Ocorrências aguardando validação** com botão "Validar" (→ /validate/:id)
* **Tarefas que criei**: lista com opções de editar e deletar

> **Não há termômetro** nesta aba — é uma visão de gerenciamento.

## Providers do Dashboard

| Provider                                | Função                                          |
| --------------------------------------- | ----------------------------------------------- |
| `myAssignedTasksProvider`               | Tarefas onde sou executor (assignedTo == eu)    |
| `myRequestedTasksProvider`              | Tarefas onde sou solicitante (createdBy == eu)  |
| `pendingValidationOccurrencesProvider`  | Ocorrências executadas pelo parceiro, aguardando minha validação |
| `myPendingOccurrencesProvider`          | Ocorrências atribuídas a mim, status pending     |
| `myExecutedOccurrencesProvider`         | Ocorrências que executei, aguardando validação   |

## Fluxo Atualizado

```text
Usuário faz login
      ↓
Redireciona para /dashboard
      ↓
Carrega dados do par ativo
      ↓
Aba "Tarefas que faço" (padrão):
  ├── Termômetro de progresso do executor
  ├── Ocorrências pendentes (botão Executar)
  └── Ocorrências executadas (aguardando validação)

Aba "Tarefas que solicito":
  ├── Ações rápidas
  ├── Ocorrências para validar (botão Validar)
  └── Minhas tarefas (editar/deletar)
```

---

# 16. Prompt para Copilot – Gerar Fluxo de Telas

Use este prompt no repositório:

```text
Create the navigation and screens for a Flutter task tracking app for pairs.

Screens:
- Login
- Register
- Dashboard
- Pair List
- Pair Invitations
- Task List
- Create Task
- Task Details
- Task Execution
- Task Validation
- Score Dashboard
- Rewards
- Reports
- Profile

Use Flutter with:
- Riverpod
- GoRouter
- Firebase Auth
- Cloud Firestore

The app must support web, desktop and mobile layouts.
```

---

# 17. Prompt – Regras de Recorrência

```text
Implement a recurrence engine for tasks in Flutter.

Recurrence types:
- Daily
- Weekly (select weekdays)
- Monthly (day of month)
- Every X days
- One time

The system must generate task occurrences and store them in Firestore.
Each occurrence must have its own status and execution record.
```

---

# 18. Prompt – Sistema de Pontuação

```text
Implement a scoring system for a task tracking app.

Rules:
- Score = task points * validation percent / 100
- If task not completed, score is negative task points
- Scores must be accumulated per:
  - User
  - Pair
  - Task
  - Month
- Update score after each validation
- Update progress thermometer
```

---

# 19. Próximo Passo (Arquitetura)

O próximo passo agora seria definir:

## Arquitetura do App Flutter

* Camadas
* Repositórios
* Serviços Firebase
* Estados
* Navegação
* Sincronização
* Estrutura de entidades (models)

Se quiser, posso montar a **arquitetura completa do projeto Flutter** já preparada para os agentes desenvolverem.
