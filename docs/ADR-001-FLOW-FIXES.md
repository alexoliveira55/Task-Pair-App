# ADR-001: Three Flow Fixes — Architecture Plan

**Status:** Implemented  
**Date:** 2026-03-25  
**Context:** The app has 3 critical flow problems affecting task assignment, executor access, and dashboard views.

> **Nota (pós-implementação):** As mudanças descritas neste ADR foram implementadas. `PairEntity` agora usa `requesterId`/`executorId` (no lugar de `user1Id`/`user2Id`). `UserEntity.pairId` foi removido. `UserRepository.updatePairId()` foi removido. O campo `pairId` que ainda existe em documentos da coleção `users` no Firestore é um dado legado (orphaned) e deve ser removido manualmente ou via script de migração.

---

## Current State Analysis

### Entities (no changes needed)
- `PairEntity` — `{id, user1Id, user2Id, name, scoreTarget, createdAt}`
- `TaskEntity` — `{id, pairId, title, description, assignedTo?, points, isActive, recurrenceId?, createdAt, createdBy}`
- `TaskOccurrenceEntity` — `{id, taskId, pairId, dueDate, status, assignedTo?}`
- `TaskExecutionEntity` — `{id, occurrenceId, taskId, executedBy, executedAt, notes?, photoUrl?}`
- `ScoreEntity` — `{id, pairId, userId, totalPoints, periodPoints, updatedAt}`
- `UserEntity` — `{id, email, displayName?, photoUrl?, createdAt, pairId?, isAdmin}`

### Key Problem: Single-Pair Architecture
- `UserEntity.pairId` stores ONE pair ID → must support MULTIPLE pairs (RF012)
- `currentPairProvider` watches `user.pairId` → single pair stream
- ALL downstream providers (`tasksProvider`, `occurrencesProvider`, `scoresProvider`) depend on `currentPairProvider`
- No query method exists for "all pairs where user is a member"
- No query method exists for "occurrences assigned to me"

---

## Problem 1: Task Self-Assignment

### Root Cause
`TaskFormPage` calls `createTask()` without setting `assignedTo`. The `TaskNotifier.createTask()` passes `assignedTo` as an optional parameter — it can be null or even the current user's own ID.

### Architecture Decision
**The `assignedTo` field must ALWAYS be the OTHER user in the pair.** This is a domain invariant, not a UI concern.

### Changes Required

#### 1.1 — Domain Layer: Enforce assignedTo in TaskEntity creation
- **File:** `lib/domain/entities/task_entity.dart`
- **Change:** `assignedTo` becomes `required String` (non-nullable)
- **Rationale:** Every task MUST have an explicit executor. The domain model must not allow null.

#### 1.2 — Domain Layer: Helper on PairEntity
- **File:** `lib/domain/entities/pair_entity.dart`
- **Change:** Add `String getOtherUserId(String myUserId)` method
- **Returns:** `user1Id` if `myUserId == user2Id`, else `user2Id`
- **Used by:** TaskNotifier, TaskFormPage, providers

#### 1.3 — Presentation: TaskNotifier auto-sets assignedTo
- **File:** `lib/features/tasks/presentation/providers/task_provider.dart`
- **Change:** In `createTask()`, remove `assignedTo` parameter. Auto-compute:
  ```
  final assignedTo = currentPair.getOtherUserId(currentUser.id);
  ```
- **Effect:** The requester (createdBy) is always the logged-in user; the executor (assignedTo) is always the other pair member.

#### 1.4 — Presentation: TaskFormPage — remove any assignedTo field  
- **File:** `lib/features/tasks/presentation/pages/task_form_page.dart`
- **Change:** No assignedTo input needed. The form stays as-is (it already doesn't have one). But task creation MUST now require a selected pair context.

#### 1.5 — Presentation: TaskFormPage needs pair context
- **File:** `lib/features/tasks/presentation/pages/task_form_page.dart`  
- **Change:** Task form must know WHICH pair the task is for. Receives `pairId` as route parameter OR uses `selectedPairProvider`.

#### 1.6 — Data Layer: TaskOccurrenceEntity.assignedTo enforcement
- **File:** `lib/domain/entities/task_occurrence_entity.dart`
- **Change:** `assignedTo` becomes `required String` (non-nullable)
- **Rationale:** Occurrences inherit assignedTo from the parent task. Must always be set.

---

## Problem 2: Multi-Pair Support (prerequisite for Problems 2 & 3)

### Root Cause
`UserEntity.pairId` is a single string. The entire provider tree funnels through `currentPairProvider` which loads ONE pair.

### Architecture Decision
**Replace single `pairId` with a query-based approach.** Users find their pairs via Firestore queries on the `pairs` collection (`user1Id == uid OR user2Id == uid`).

### Changes Required

#### 2.1 — Domain Layer: Remove pairId from UserEntity
- **File:** `lib/domain/entities/user_entity.dart`
- **Change:** Remove `pairId` field entirely
- **Migration:** Existing `pairId` values become irrelevant; pairs collection already has `user1Id`/`user2Id` which is the source of truth
- **Impact:** `UserRepository.updatePairId()` is removed

#### 2.2 — Domain Layer: Add watchPairsByUserId to PairRepository
- **File:** `lib/domain/repositories/pair_repository.dart`
- **Change:** Add:
  ```dart
  Stream<List<PairEntity>> watchPairsByUserId(String userId);
  ```

#### 2.3 — Data Layer: Implement watchPairsByUserId
- **File:** `lib/data/repositories/pair_repository_impl.dart`
- **Change:** Implement with TWO Firestore queries combined via `Rx.combineLatest2`:
  ```dart
  // Query 1: pairs where user1Id == userId
  // Query 2: pairs where user2Id == userId
  // Merge and deduplicate by pair ID
  ```
- **Note:** Firestore doesn't support OR queries across different fields in rules. Two queries merged client-side is the standard pattern.

#### 2.4 — Presentation: Replace currentPairProvider with myPairsProvider
- **File:** `lib/features/pairs/presentation/providers/pair_provider.dart`
- **Changes:**
  - **NEW** `myPairsProvider` — `StreamProvider<List<PairEntity>>` — watches ALL pairs the user belongs to
  - **NEW** `selectedPairIdProvider` — `StateProvider<String?>` — the currently selected pair ID (for task creation context)
  - **NEW** `selectedPairProvider` — `Provider<PairEntity?>` — derived from myPairsProvider + selectedPairIdProvider
  - **KEEP** `currentPairProvider` as an alias for `selectedPairProvider` during migration (to avoid breaking everything at once)

#### 2.5 — Presentation: Pair selector in navigation
- The dashboard/app shell needs a way to select which pair context you're working in
- This is handled by the new dashboard tabs (see Problem 3)

#### 2.6 — Firestore Rules: No changes needed
- The rules already use `isPairMember(pairId)` which checks `user1Id/user2Id` on the pair doc
- Multi-pair queries work because Firestore rules are evaluated per-document

#### 2.7 — Domain: Remove UserRepository.updatePairId
- **File:** `lib/domain/repositories/user_repository.dart`
- **Change:** Remove `updatePairId(String userId, String? pairId)`
- **File:** `lib/data/repositories/user_repository_impl.dart`
- **Change:** Remove implementation
- **Impact:** `PairNotifier.acceptInvite` must stop calling `updatePairId`. Pair creation alone (adding user IDs to the pair doc) is sufficient.

#### 2.8 — Data Model: Remove pairId from Firestore users collection
- **File:** `lib/data/models/user_model.dart`
- **Change:** Remove `pairId` from serialization/deserialization
- No Firestore migration needed — the field simply becomes unused

---

## Problem 3: Executor Discovery — "My Pending Tasks"

### Root Cause
There is no provider or page that shows occurrences assigned to the current user. The only entry point to `TaskExecutionPage` is via `/execute/:occurrenceId` but no UI navigates there.

### Architecture Decision
**Create a "My Tasks" (executor) view that queries occurrences where `assignedTo == currentUser.id`.**

### Changes Required

#### 3.1 — Domain Layer: Add query method to TaskOccurrenceRepository
- **File:** `lib/domain/repositories/task_occurrence_repository.dart`
- **Change:** Add:
  ```dart
  Stream<List<TaskOccurrenceEntity>> watchOccurrencesByAssignedTo(String userId);
  ```

#### 3.2 — Data Layer: Implement Firestore query
- **File:** `lib/data/repositories/task_occurrence_repository_impl.dart`
- **Change:** Implement query: `taskOccurrences.where('assignedTo', isEqualTo: userId).where('status', isEqualTo: 'pending')`
- **Note:** Requires Firestore composite index on `(assignedTo, status)`

#### 3.3 — Presentation: New provider
- **File:** `lib/features/execution/presentation/providers/execution_provider.dart`
- **Change:** Add:
  ```dart
  /// All pending occurrences assigned to the current user across ALL pairs
  final myPendingOccurrencesProvider = StreamProvider<List<TaskOccurrenceEntity>>((ref) {
    final user = ref.watch(currentUserEntityProvider).value;
    if (user == null) return Stream.value([]);
    return ref.watch(taskOccurrenceRepositoryProvider)
        .watchOccurrencesByAssignedTo(user.id);
  });
  ```

#### 3.4 — Firestore: Add composite index
- **File:** `firebase/firestore.indexes.json`
- **Change:** Add composite index:
  ```json
  {
    "collectionGroup": "taskOccurrences",
    "queryScope": "COLLECTION",
    "fields": [
      { "fieldPath": "assignedTo", "order": "ASCENDING" },
      { "fieldPath": "status", "order": "ASCENDING" },
      { "fieldPath": "dueDate", "order": "ASCENDING" }
    ]
  }
  ```

---

## Problem 4: Dashboard Redesign

### Root Cause
Dashboard shows a single thermometer for "the pair". It doesn't distinguish the two perspectives (executor vs requester).

### Architecture Decision
**Replace the single dashboard view with a TabBar containing two tabs:**

1. **"Tarefas que faço"** (Tasks I execute) — I am the `assignedTo`
2. **"Tarefas que solicito"** (Tasks I request) — I am the `createdBy`

### Tab 1: "Tarefas que faço" (Executor View)

**Data needed:**
- All pairs where user has tasks assigned to them (derived from myPairsProvider)
- Per pair: pending occurrences assigned to current user
- Per pair: user's score → thermometer

**Provider structure:**
```
myExecutorPairsProvider → List<PairEntity>
  (pairs where user has at least one task with assignedTo == user.id)
  
myOccurrencesByPairProvider(pairId) → List<TaskOccurrenceEntity>
  (occurrences for this pair where assignedTo == user.id)

myScoreForPairProvider(pairId) → ScoreEntity?
  (user's score in this pair)

thermometerForPairProvider(pairId) → double
  (myScoreForPair / pair.scoreTarget)
```

**UI components:**
- List of pair cards, each showing:
  - Pair name + requester name
  - Mini thermometer (my score / scoreTarget)
  - Count of pending occurrences
- Tapping a pair expands/navigates to show:
  - Full thermometer
  - List of pending occurrences with "Execute" button → `/execute/:occurrenceId`
  - List of completed occurrences (today/this period)

**New files:**
- `lib/features/dashboard/presentation/widgets/executor_tab.dart`
- `lib/features/dashboard/presentation/widgets/pair_executor_card.dart`

### Tab 2: "Tarefas que solicito" (Requester View)

**Data needed:**
- All pairs where user has created tasks (derived from myPairsProvider)
- Per pair: tasks created by current user
- Per pair: occurrence statuses for those tasks
- NO thermometer

**Provider structure:**
```
myRequesterPairsProvider → List<PairEntity>
  (pairs where user has at least one task with createdBy == user.id)

myCreatedTasksByPairProvider(pairId) → List<TaskEntity>
  (tasks in this pair where createdBy == user.id)

occurrencesForMyTasksByPairProvider(pairId) → List<TaskOccurrenceEntity>
  (occurrences for tasks I created in this pair)
```

**UI components:**
- List of pair cards, each showing:
  - Pair name + executor name
  - Task count, pending/executed/validated counts
- Tapping a pair expands/navigates to show:
  - List of tasks with status icons
  - "Add Task" button → `/tasks/new?pairId=xxx`
  - "Edit/Delete" per task
  - "Validate" button on executed occurrences → `/validate/:executionId`
  - "Rewards" button → `/rewards?pairId=xxx`

**New files:**
- `lib/features/dashboard/presentation/widgets/requester_tab.dart`
- `lib/features/dashboard/presentation/widgets/pair_requester_card.dart`

---

## New Provider Map (complete)

### Pairs feature (`lib/features/pairs/presentation/providers/pair_provider.dart`)

| Provider | Type | Description |
|---|---|---|
| `myPairsProvider` | `StreamProvider<List<PairEntity>>` | All pairs user belongs to |
| `selectedPairIdProvider` | `StateProvider<String?>` | Currently selected pair (for task creation) |
| `selectedPairProvider` | `Provider<PairEntity?>` | Derived: selected pair entity |
| `pairPartnerNameProvider(pairId)` | `FutureProvider.family<String, String>` | Display name of the other user in a pair |

### Dashboard feature (`lib/features/dashboard/presentation/providers/dashboard_provider.dart`)

| Provider | Type | Description |
|---|---|---|
| `myExecutorTasksProvider` | `StreamProvider<List<TaskEntity>>` | Tasks across all pairs where `assignedTo == me` |
| `myRequesterTasksProvider` | `StreamProvider<List<TaskEntity>>` | Tasks across all pairs where `createdBy == me` |
| `executorPairsProvider` | `Provider<List<PairEntity>>` | Pairs where I have executor tasks (derived) |
| `requesterPairsProvider` | `Provider<List<PairEntity>>` | Pairs where I have requester tasks (derived) |

### Execution feature (`lib/features/execution/presentation/providers/execution_provider.dart`)

| Provider | Type | Description |
|---|---|---|
| `myPendingOccurrencesProvider` | `StreamProvider<List<TaskOccurrenceEntity>>` | Pending occurrences assigned to me across all pairs |

### Score feature (`lib/features/score/presentation/providers/score_provider.dart`)

| Provider | Type | Description |
|---|---|---|
| `myScoreForPairProvider(pairId)` | `Provider.family<ScoreEntity?, String>` | My score in a specific pair |
| `thermometerForPairProvider(pairId)` | `Provider.family<double, String>` | Thermometer progress for a specific pair |

### Task feature (`lib/features/tasks/presentation/providers/task_provider.dart`)

| Provider | Type | Description |
|---|---|---|
| `tasksByPairProvider(pairId)` | `StreamProvider.family<List<TaskEntity>, String>` | All tasks for a specific pair |
| `myCreatedTasksForPairProvider(pairId)` | `Provider.family<List<TaskEntity>, String>` | Tasks I created in a specific pair |

### Recurrence feature (`lib/features/recurrence/presentation/providers/recurrence_provider.dart`)

| Provider | Type | Description |
|---|---|---|
| `occurrencesByPairProvider(pairId)` | `StreamProvider.family<List<TaskOccurrenceEntity>, String>` | All occurrences for a pair |
| `myOccurrencesForPairProvider(pairId)` | `Provider.family<List<TaskOccurrenceEntity>, String>` | Occurrences assigned to me in a pair |

---

## New Route Structure

| Route | Page | Purpose |
|---|---|---|
| `/dashboard` | `DashboardPage` (modified) | TabBar with executor/requester tabs |
| `/dashboard/executor/:pairId` | `ExecutorPairDetailPage` (NEW) | Full thermometer + my pending occurrences for a pair |
| `/dashboard/requester/:pairId` | `RequesterPairDetailPage` (NEW) | Task management for a pair |
| `/tasks/new?pairId=xxx` | `TaskFormPage` (modified) | Create task with pair context |
| `/execute/:occurrenceId` | `TaskExecutionPage` (existing) | No changes |
| `/validate/:executionId` | `ValidationPage` (existing) | No changes |

---

## Repository Interface Changes

### PairRepository — ADD:
```dart
Stream<List<PairEntity>> watchPairsByUserId(String userId);
```

### TaskRepository — ADD:
```dart
Stream<List<TaskEntity>> watchTasksByAssignedTo(String userId);
Stream<List<TaskEntity>> watchTasksByCreatedBy(String userId);
Stream<List<TaskEntity>> watchTasksByPairId(String pairId); // exists
```

### TaskOccurrenceRepository — ADD:
```dart
Stream<List<TaskOccurrenceEntity>> watchOccurrencesByAssignedTo(String userId);
```

### ScoreRepository — ADD:
```dart
Stream<ScoreEntity?> watchScoreByUserAndPair(String userId, String pairId);
```

### UserRepository — REMOVE:
```dart
Future<void> updatePairId(String userId, String? pairId);  // DELETE
```

---

## Entity Changes Summary

| Entity | Field | Change |
|---|---|---|
| `UserEntity` | `pairId` | **REMOVE** — pairs are discovered via query |
| `TaskEntity` | `assignedTo` | **REQUIRED** — `String?` → `String` |
| `TaskOccurrenceEntity` | `assignedTo` | **REQUIRED** — `String?` → `String` |

---

## Firestore Rules Changes

**No structural changes needed.** Existing rules already use `isPairMember(pairId)` which checks the pair doc's `user1Id`/`user2Id`. Multi-pair queries work because Firestore evaluates rules per-document.

**Optional tightening for task creation:**
```
// In tasks collection, enforce assignedTo is the OTHER pair member
allow create: if isAuthenticated() 
  && isPairMember(request.resource.data.pairId)
  && request.resource.data.createdBy == request.auth.uid
  && request.resource.data.assignedTo != request.auth.uid
  && (request.resource.data.assignedTo == getPairData(request.resource.data.pairId).user1Id
      || request.resource.data.assignedTo == getPairData(request.resource.data.pairId).user2Id);
```

---

## Firestore Index Changes

**File:** `firebase/firestore.indexes.json`

Add these composite indexes:

```json
[
  {
    "collectionGroup": "taskOccurrences",
    "queryScope": "COLLECTION",
    "fields": [
      { "fieldPath": "assignedTo", "order": "ASCENDING" },
      { "fieldPath": "status", "order": "ASCENDING" },
      { "fieldPath": "dueDate", "order": "ASCENDING" }
    ]
  },
  {
    "collectionGroup": "tasks",
    "queryScope": "COLLECTION",
    "fields": [
      { "fieldPath": "assignedTo", "order": "ASCENDING" },
      { "fieldPath": "isActive", "order": "ASCENDING" }
    ]
  },
  {
    "collectionGroup": "tasks",
    "queryScope": "COLLECTION",
    "fields": [
      { "fieldPath": "createdBy", "order": "ASCENDING" },
      { "fieldPath": "isActive", "order": "ASCENDING" }
    ]
  }
]
```

---

## New Files to Create

```
lib/features/dashboard/presentation/widgets/executor_tab.dart          # Tab 1 widget
lib/features/dashboard/presentation/widgets/requester_tab.dart         # Tab 2 widget
lib/features/dashboard/presentation/widgets/pair_executor_card.dart    # Pair card for executor view
lib/features/dashboard/presentation/widgets/pair_requester_card.dart   # Pair card for requester view
lib/features/dashboard/presentation/pages/executor_pair_detail_page.dart  # Drill-down: my tasks in a pair
lib/features/dashboard/presentation/pages/requester_pair_detail_page.dart # Drill-down: manage tasks in a pair
```

## Files to Modify

```
lib/domain/entities/user_entity.dart                     # Remove pairId
lib/domain/entities/task_entity.dart                     # assignedTo required
lib/domain/entities/task_occurrence_entity.dart           # assignedTo required
lib/domain/entities/pair_entity.dart                     # Add getOtherUserId()
lib/domain/repositories/pair_repository.dart             # Add watchPairsByUserId
lib/domain/repositories/task_repository.dart             # Add watchTasksByAssignedTo/CreatedBy
lib/domain/repositories/task_occurrence_repository.dart  # Add watchOccurrencesByAssignedTo
lib/domain/repositories/score_repository.dart            # Add watchScoreByUserAndPair
lib/domain/repositories/user_repository.dart             # Remove updatePairId
lib/data/repositories/pair_repository_impl.dart          # Implement watchPairsByUserId
lib/data/repositories/task_repository_impl.dart          # Implement new queries
lib/data/repositories/task_occurrence_repository_impl.dart # Implement new query
lib/data/repositories/score_repository_impl.dart         # Implement new query
lib/data/repositories/user_repository_impl.dart          # Remove updatePairId
lib/data/models/user_model.dart                          # Remove pairId
lib/features/pairs/presentation/providers/pair_provider.dart      # Multi-pair providers
lib/features/dashboard/presentation/providers/dashboard_provider.dart # New provider structure
lib/features/dashboard/presentation/pages/dashboard_page.dart   # TabBar layout
lib/features/dashboard/presentation/widgets/thermometer_widget.dart # Accept pair-specific data
lib/features/tasks/presentation/providers/task_provider.dart     # Pair-scoped + new providers
lib/features/tasks/presentation/pages/task_form_page.dart        # Pair context param
lib/features/tasks/presentation/pages/task_list_page.dart        # Filter by role
lib/features/execution/presentation/providers/execution_provider.dart # myPendingOccurrencesProvider
lib/features/score/presentation/providers/score_provider.dart    # Pair-family providers
lib/features/recurrence/presentation/providers/recurrence_provider.dart # Pair-family occurrences
lib/routes/app_router.dart                               # New routes
firebase/firestore.indexes.json                          # New indexes
firebase/firestore.rules                                 # Tighten task creation
```

---

## Implementation Order (for other agents)

1. **Domain Agent:** Entity changes (PairEntity helper, TaskEntity/TaskOccurrenceEntity required assignedTo, UserEntity remove pairId)
2. **Domain Agent:** Repository interface changes (new methods)
3. **Firebase Agent:** Repository implementations + Firestore indexes + Rules tightening
4. **Domain Agent / Firebase Agent:** Remove `updatePairId` flow from `PairNotifier.acceptInvite`
5. **Flutter UI Agent:** Provider restructuring (multi-pair, dashboard providers)
6. **Flutter UI Agent:** Dashboard page rewrite (TabBar + two tabs)
7. **Flutter UI Agent:** New detail pages (executor pair detail, requester pair detail)
8. **Flutter UI Agent:** Task form pair context
9. **Flutter UI Agent:** Route updates
10. **Testing Agent:** Update tests
11. **i18n:** Add new ARB keys for tab labels and view titles

---

## i18n Keys to Add

```
tasksIExecute        → "Tarefas que faço" / "Tasks I execute"
tasksIRequest        → "Tarefas que solicito" / "Tasks I request"  
selectPair           → "Selecionar par" / "Select pair"
myThermometerForPair → "Meu termômetro - {pairName}" / "My thermometer - {pairName}"
pendingExecution     → "Pendente de execução" / "Pending execution"
noPairsYet           → "Você ainda não tem pares" / "You don't have any pairs yet"
executorOf           → "Executor de {name}" / "Executor of {name}"
requesterOf          → "Solicitante de {name}" / "Requester of {name}"
```
