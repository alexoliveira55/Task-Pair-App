# 📄 Especificação de Requisitos – App de Tarefas em Pares

## Flutter Multiplataforma com Firebase

---

# 1. Visão Geral do Sistema

## 1.1 Objetivo

Desenvolver um aplicativo multiplataforma em Flutter que permita a **definição, execução, validação e acompanhamento de tarefas acordadas entre pares**, com sistema de pontuação, recorrência e recompensas.

O sistema deverá funcionar inicialmente **sem backend próprio**, utilizando **Firebase como backend serverless** para:

* Autenticação
* Banco de dados
* Sincronização em tempo real
* Armazenamento
* Notificações

---

# 2. Arquitetura do Sistema

## 2.1 Arquitetura Geral

```id="qqf9y7"
Flutter App
    |
    |-- Firebase Authentication
    |-- Cloud Firestore
    |-- Firebase Storage
    |-- Firebase Cloud Messaging
```

## 2.2 Tecnologias

| Camada             | Tecnologia               |
| ------------------ | ------------------------ |
| Frontend           | Flutter                  |
| Estado             | Riverpod ou Provider     |
| Banco de dados     | Cloud Firestore          |
| Autenticação       | Firebase Auth            |
| Notificações       | Firebase Cloud Messaging |
| Storage            | Firebase Storage         |
| Analytics (futuro) | Firebase Analytics       |

---

# 3. Conceito Principal do Sistema

O sistema gira em torno de **PARES e TAREFAS RECORRENTES COM PONTUAÇÃO**.

## 3.1 Estrutura Conceitual

```id="8h02q5"
Usuário
   |
   -> Par
         |
         -> Tarefas
                |
                -> Execuções
                        |
                        -> Validação
                                |
                                -> Pontuação
```

---

# 4. Requisitos Funcionais

# 4.1 Usuários

## RF001 – Cadastro de Usuário

Usuário deve poder:

* Criar conta
* Fazer login
* Recuperar senha
* Editar perfil
* Foto de perfil

Autenticação via:

* Email e senha
* Google (futuro)

---

# 4.2 Formação de Pares

## RF010 – Convidar Usuário para Par

Usuário deve poder convidar outro usuário por:

* Email
* Código de convite

## RF011 – Aceitar Convite

Usuário convidado aceita e forma o par.

## RF012 – Um usuário pode ter vários pares

Exemplo:

```id="jyd9u5"
João
 - Esposa
 - Filho
 - Funcionário
```

---

# 4.3 Cadastro de Tarefas

## RF020 – Criar Tarefa

Campos obrigatórios:

| Campo            | Descrição                 |
| ---------------- | ------------------------- |
| Nome da tarefa   | Texto curto               |
| Descrição        | Texto longo               |
| Recorrência      | Diário / Semanal / Mensal |
| Data início      | Data                      |
| Data fim         | Data                      |
| Horário previsto | Hora                      |
| Tempo previsto   | Minutos                   |
| Pontuação        | Inteiro                   |
| Recompensa       | Texto                     |
| Executor         | Usuário                   |
| Solicitante      | Usuário                   |

---

# 4.4 Execução da Tarefa

## RF030 – Iniciar Tarefa

Executor registra:

* Data/hora início real

## RF031 – Finalizar Tarefa

Executor registra:

* Data/hora fim real

---

# 4.5 Validação da Execução

## RF040 – Validar Tarefa

Solicitante deve validar com:

| Status                | Percentual |
| --------------------- | ---------- |
| Cumprida totalmente   | 100%       |
| Cumprida parcialmente | 10% a 90%  |
| Não cumprida          | 0%         |

Solicitante pode adicionar:

* Observação

---

# 4.6 Pontuação

## RF050 – Cálculo de Pontuação

### Regras

| Situação     | Resultado          |
| ------------ | ------------------ |
| 100%         | Pontuação total    |
| Parcial      | Proporcional       |
| Não cumprida | Pontuação negativa |

### Fórmula

```id="yknknp"
Pontuação = PontosDaTarefa * Percentual / 100
```

Se não cumprida:

```id="r1trj5"
Pontuação = PontosDaTarefa * -1
```

---

# 4.7 Internacionalização (i18n)

## RF200 – Detecção Automática de Idioma

O sistema deve detectar automaticamente o idioma do sistema operacional e configurar a interface:

* `pt` ou `pt_BR` → Português (Brasil)
* `en` ou variantes → Inglês
* Outros idiomas → Português (Brasil) como fallback

## RF201 – Troca Manual de Idioma

Usuário deve poder trocar o idioma manualmente via configurações:

* Opções: Padrão do Sistema, Português (Brasil), Inglês
* Troca imediata sem reiniciar o app
* Preferência persistida em SharedPreferences

## RF202 – Textos Localizados

Todas as strings de interface devem estar em arquivos ARB:

* Labels, botões, mensagens, títulos, status
* Strings com parâmetros (interpolação)
* Pluralização conforme idioma

## RF203 – Formatação Regional

Datas e números formatados conforme convenção do idioma:

| Aspecto | pt_BR | en |
|---------|-------|----|
| Data | dd/MM/yyyy | MM/dd/yyyy |
| Hora | HH:mm | h:mm AM/PM |

---

# 5. Acompanhamento (Termômetros)

## RF060 – Termômetro por Tarefa

Executor visualiza progresso da tarefa.

## RF061 – Termômetro Geral

Executor visualiza pontuação total.

## RF062 – Visão do Solicitante

Solicitante visualiza:

* Pontuação por executor
* Pontuação por tarefa
* Histórico
* Ranking (futuro)

---

# 6. Estrutura do Banco – Firebase Firestore

## 6.1 Coleções

```id="vt00u0"
users
pairs
pairInvites
tasks
taskExecutions
scores
rewards
```

---

## 6.2 Documento – Users

```json
{
  "id": "uid",
  "name": "João",
  "email": "joao@email.com",
  "photoUrl": "",
  "createdAt": "timestamp"
}
```

---

## 6.3 Documento – Pairs

```json
{
  "id": "pairId",
  "userA": "uid1",
  "userB": "uid2",
  "createdAt": "timestamp",
  "status": "active"
}
```

---

## 6.4 Documento – Tasks

```json
{
  "id": "taskId",
  "pairId": "pairId",
  "name": "Lavar louça",
  "description": "Lavar toda louça do jantar",
  "recurrence": "daily",
  "startDate": "date",
  "endDate": "date",
  "scheduledTime": "19:00",
  "expectedDuration": 30,
  "points": 10,
  "reward": "Filme no sábado",
  "executorId": "uid",
  "requesterId": "uid"
}
```

---

## 6.5 Documento – Task Executions

```json
{
  "id": "executionId",
  "taskId": "taskId",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "validationPercent": 100,
  "validationNote": "",
  "score": 10,
  "status": "approved"
}
```

---

# 7. Telas do Sistema

| Tela        | Descrição         |
| ----------- | ----------------- |
| Login       | Autenticação      |
| Dashboard   | Termômetros       |
| Pares       | Gerenciar pares   |
| Tarefas     | Lista de tarefas  |
| Nova tarefa | Cadastro          |
| Execução    | Iniciar/finalizar |
| Validação   | Validar execução  |
| Relatórios  | Histórico         |
| Recompensas | Metas             |

---

# 8. Prompts para Agentes no Copilot

## 8.1 Prompt – Criar Estrutura Flutter + Firebase

```text
Create a Flutter multi-platform app (web, desktop, mobile) integrated with Firebase.

Use:
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging

Architecture:
- Clean Architecture
- Repository Pattern
- Riverpod state management

Modules:
- Authentication
- Pair Management
- Task Management
- Task Execution
- Task Validation
- Score System
- Dashboard with thermometer progress
```

---

## 8.2 Prompt – Protótipos Interativos HTML

```text
Create interactive HTML prototypes for a task tracking app for pairs.

Pages:
- Login
- Dashboard with thermometer score
- Pair management
- Task list
- Task creation form
- Task execution start/finish
- Task validation
- Reports
- Rewards

Use:
- HTML
- CSS
- JavaScript
- Responsive layout
- Progress bars as thermometer
```

---

## 8.3 Prompt – Documentação Rica para Usuário

```text
Generate a rich documentation website in HTML for a task tracking app.

Include:
- Introduction
- How pairs work
- How to create tasks
- How to execute tasks
- How validation works
- How scoring works
- Rewards system
- Dashboard explanation
- FAQ
- Responsive layout
- Navigation sidebar
```

---

# 9. Roadmap de Desenvolvimento

## Fase 1 – Base

* Flutter project
* Firebase integration
* Login
* Cadastro usuário

## Fase 2 – Pares

* Convite
* Aceite
* Lista de pares

## Fase 3 – Tarefas

* CRUD tarefas
* Recorrência

## Fase 4 – Execução

* Iniciar
* Finalizar
* Validação

## Fase 5 – Pontuação

* Regras
* Termômetros
* Dashboard

## Fase 6 – Recompensas

* Metas
* Histórico
* Relatórios

## Fase 7 – Internacionalização

* Detecção automática de idioma do sistema
* Suporte a Português (Brasil) e Inglês
* Seletor manual de idioma
* Migração de strings hardcoded para ARB
* Formatação regional de datas e números

---

# 10. Estrutura de Pastas Flutter (Sugerida)

```id="g6ir90"
lib/
 ├── core/
 ├── models/
 ├── services/
 │     ├── firebase/
 │     ├── auth/
 │     ├── firestore/
 ├── repositories/
 ├── features/
 │     ├── auth/
 │     ├── pairs/
 │     ├── tasks/
 │     ├── executions/
 │     ├── validation/
 │     ├── dashboard/
 │     ├── rewards/
 ├── widgets/
 ├── theme/
 └── main.dart
```

---

# 11. Nome do App (Sugestões)

Algumas ideias:

* DuoTask
* PairTask
* EntreNós
* Combinado
* TaskTermo
* PontuaAí
* ParPerfeito
* DuoScore

---

Se quiser, o próximo passo ideal agora é:

## ➜ Desenhar o fluxo de telas + regras de recorrência + modelo de pontuação acumulada

Isso já permite começar o desenvolvimento com agentes no Copilot praticamente guiado pela documentação.
