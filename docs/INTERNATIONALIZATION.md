# Especificação de Requisitos — Internacionalização (i18n)

## Feature: Internacionalização / Localização

---

## 1. Visão Geral

O aplicativo Task Pair App deve suportar **múltiplos idiomas**, permitindo que usuários de diferentes regiões utilizem o sistema em seu idioma nativo. A implementação segue o padrão oficial do Flutter para internacionalização usando o pacote `flutter_localizations` com arquivos ARB (Application Resource Bundle).

---

## 2. Idiomas Suportados

| Idioma                | Código Locale | Status  |
| --------------------- | ------------- | ------- |
| Português (Brasil)    | `pt_BR`       | Padrão  |
| Inglês (Estados Unidos) | `en`        | Suportado |

---

## 3. Requisitos Funcionais

### RF200 – Detecção Automática de Idioma

O sistema **deve detectar automaticamente** o idioma atual do sistema operacional/dispositivo em que a aplicação está sendo executada e configurar o idioma da interface de acordo.

**Regras:**
- Se o idioma do sistema for `pt` ou `pt_BR`, utilizar Português (Brasil)
- Se o idioma do sistema for `en` ou qualquer variante de inglês (`en_US`, `en_GB`, etc.), utilizar Inglês
- Se o idioma do sistema não for nenhum dos suportados, utilizar **Português (Brasil)** como fallback padrão

### RF201 – Troca Manual de Idioma

O usuário **deve poder trocar o idioma** manualmente a qualquer momento, independente do idioma do sistema.

**Regras:**
- A troca de idioma deve ser acessível via tela de perfil/configurações
- A troca deve ser imediata, sem necessidade de reiniciar o aplicativo
- A preferência de idioma do usuário deve ser persistida localmente (SharedPreferences)
- A preferência salva deve ter prioridade sobre a detecção automática do sistema

### RF202 – Textos Localizados

Todos os textos visíveis na interface do usuário devem ser traduzidos, incluindo:

| Categoria                | Exemplos                                              |
| ------------------------ | ----------------------------------------------------- |
| Labels de formulários    | Nome, Email, Senha, Título da Tarefa                  |
| Botões                   | Salvar, Cancelar, Login, Registrar                    |
| Mensagens de validação   | "Campo obrigatório", "Email inválido"                 |
| Mensagens de feedback    | "Tarefa criada com sucesso", "Erro ao salvar"         |
| Títulos de tela          | Dashboard, Tarefas, Pares, Relatórios                 |
| Textos de status         | Pendente, Executado, Validado, Não cumprido           |
| Diálogos de confirmação  | "Tem certeza que deseja excluir?"                     |
| Mensagens de erro        | "Sem conexão", "Usuário não encontrado"               |
| Rótulos de navegação     | Itens de menu, abas, breadcrumbs                      |
| Datas e números          | Formatação regional (dd/MM/yyyy vs MM/dd/yyyy)        |
| Textos de recompensas    | Títulos e descrições de recompensas do sistema        |
| Textos do termômetro     | Labels de progresso e metas                           |

### RF203 – Formatação Regional

O sistema deve respeitar as convenções regionais de cada idioma:

| Aspecto            | pt_BR                  | en                      |
| ------------------ | ---------------------- | ----------------------- |
| Data               | dd/MM/yyyy             | MM/dd/yyyy              |
| Hora               | HH:mm                  | h:mm a (AM/PM)          |
| Separador decimal  | vírgula (,)            | ponto (.)               |
| Separador milhar   | ponto (.)              | vírgula (,)             |
| Moeda (futuro)     | R$                     | $                       |

### RF204 – Conteúdo Gerado pelo Usuário

Conteúdo criado pelo usuário (nomes de tarefas, descrições, notas, feedback) **não é traduzido** automaticamente. Apenas strings da interface do sistema são localizadas.

---

## 4. Requisitos Não Funcionais

### RNF200 – Performance

- A troca de idioma não deve causar recarregamento completo do aplicativo
- Os arquivos de tradução devem ser carregados sob demanda com impacto mínimo no startup

### RNF201 – Manutenibilidade

- Todas as strings traduzíveis devem estar centralizadas em arquivos ARB
- Nenhuma string de interface deve estar hardcoded no código Dart
- Novas strings devem ser adicionadas em **ambos** os arquivos ARB simultaneamente

### RNF202 – Acessibilidade

- Textos de acessibilidade (semantics, tooltips) devem ser localizados
- O atributo `textDirection` deve ser respeitado (LTR para ambos os idiomas)

### RNF203 – Testabilidade

- Testes de widget devem poder executar em qualquer locale
- Deve existir teste unitário validando que todas as chaves existem em ambos os idiomas

---

## 5. Arquitetura Técnica

### 5.1 Tecnologia

| Componente                   | Tecnologia                          |
| ---------------------------- | ----------------------------------- |
| Framework i18n               | `flutter_localizations` (SDK)       |
| Geração de código            | `flutter gen-l10n` (nativo)         |
| Formato de tradução          | ARB (Application Resource Bundle)   |
| Persistência de preferência  | `SharedPreferences`                 |
| Formatação de datas/números  | `intl` (já no projeto)              |
| Gerenciamento de estado      | Riverpod (provider de locale)       |

### 5.2 Estrutura de Arquivos

```
lib/
  l10n/
    app_en.arb                  # Traduções em inglês
    app_pt_BR.arb               # Traduções em português (Brasil)
  core/
    providers/
      locale_provider.dart      # Provider Riverpod para locale
  features/
    settings/
      pages/
        settings_page.dart      # Tela de configurações com seletor de idioma
      widgets/
        language_selector.dart  # Widget de seleção de idioma
      providers/
        settings_provider.dart  # Provider de configurações do usuário
```

### 5.3 Configuração do `l10n.yaml`

```yaml
arb-dir: lib/l10n
template-arb-file: app_pt_BR.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
synthetic-package: true
nullable-getter: false
```

> O template principal é o `app_pt_BR.arb` pois Português (Brasil) é o idioma padrão de fallback.

### 5.4 Configuração no `MaterialApp.router`

```dart
MaterialApp.router(
  // Localizations
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: localeOverride, // null = detecção automática do sistema
  // ...
);
```

### 5.5 Provider de Locale (Riverpod)

```dart
/// Provider que gerencia o locale do app.
/// - null = usar idioma do sistema (detecção automática)
/// - Locale específico = idioma escolhido pelo usuário
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(),
);
```

### 5.6 Uso nos Widgets

```dart
// Acessar tradução em qualquer widget
final l10n = AppLocalizations.of(context);
Text(l10n.dashboardTitle); // "Dashboard" ou "Painel"
```

---

## 6. Categorias de Strings (Chaves ARB)

### 6.1 Geral / Comum

| Chave                    | pt_BR                         | en                           |
| ------------------------ | ----------------------------- | ---------------------------- |
| `appName`                | Task Pair App                 | Task Pair App                |
| `save`                   | Salvar                        | Save                         |
| `cancel`                 | Cancelar                      | Cancel                       |
| `delete`                 | Excluir                       | Delete                       |
| `edit`                   | Editar                        | Edit                         |
| `confirm`                | Confirmar                     | Confirm                      |
| `back`                   | Voltar                        | Back                         |
| `loading`                | Carregando...                 | Loading...                   |
| `error`                  | Erro                          | Error                        |
| `success`                | Sucesso                       | Success                      |
| `yes`                    | Sim                           | Yes                          |
| `no`                     | Não                           | No                           |
| `requiredField`          | Campo obrigatório             | Required field               |
| `noData`                 | Nenhum dado encontrado        | No data found                |
| `retry`                  | Tentar novamente              | Retry                        |

### 6.2 Autenticação

| Chave                    | pt_BR                         | en                           |
| ------------------------ | ----------------------------- | ---------------------------- |
| `login`                  | Entrar                        | Sign In                      |
| `register`               | Cadastrar                     | Sign Up                      |
| `logout`                 | Sair                          | Sign Out                     |
| `email`                  | Email                         | Email                        |
| `password`               | Senha                         | Password                     |
| `confirmPassword`        | Confirmar senha               | Confirm password             |
| `forgotPassword`         | Esqueceu a senha?             | Forgot password?             |
| `resetPassword`          | Redefinir senha               | Reset password               |
| `displayName`            | Nome de exibição              | Display name                 |
| `invalidEmail`           | Email inválido                | Invalid email                |
| `weakPassword`           | Senha fraca                   | Weak password                |
| `emailInUse`             | Email já cadastrado           | Email already in use         |
| `userNotFound`           | Usuário não encontrado        | User not found               |
| `wrongPassword`          | Senha incorreta               | Wrong password               |

### 6.3 Pares

| Chave                    | pt_BR                         | en                           |
| ------------------------ | ----------------------------- | ---------------------------- |
| `pairs`                  | Pares                         | Pairs                        |
| `createPair`             | Criar Par                     | Create Pair                  |
| `inviteUser`             | Convidar Usuário              | Invite User                  |
| `pendingInvites`         | Convites Pendentes            | Pending Invites              |
| `acceptInvite`           | Aceitar Convite               | Accept Invite                |
| `declineInvite`          | Recusar Convite               | Decline Invite               |
| `leavePair`              | Sair do Par                   | Leave Pair                   |
| `pairName`               | Nome do Par                   | Pair Name                    |
| `scoreTarget`            | Meta de Pontuação             | Score Target                 |
| `inviteSent`             | Convite enviado com sucesso   | Invite sent successfully     |
| `inviteAccepted`         | Convite aceito                | Invite accepted              |
| `inviteDeclined`         | Convite recusado              | Invite declined              |

### 6.4 Tarefas

| Chave                    | pt_BR                         | en                           |
| ------------------------ | ----------------------------- | ---------------------------- |
| `tasks`                  | Tarefas                       | Tasks                        |
| `createTask`             | Criar Tarefa                  | Create Task                  |
| `editTask`               | Editar Tarefa                 | Edit Task                    |
| `deleteTask`             | Excluir Tarefa                | Delete Task                  |
| `taskTitle`              | Título da Tarefa              | Task Title                   |
| `taskDescription`        | Descrição                     | Description                  |
| `assignedTo`             | Atribuído a                   | Assigned to                  |
| `points`                 | Pontos                        | Points                       |
| `recurrence`             | Recorrência                   | Recurrence                   |
| `daily`                  | Diário                        | Daily                        |
| `weekly`                 | Semanal                       | Weekly                       |
| `monthly`                | Mensal                        | Monthly                      |
| `once`                   | Única                         | Once                         |
| `startDate`              | Data de Início                | Start Date                   |
| `endDate`                | Data de Fim                   | End Date                     |
| `active`                 | Ativa                         | Active                       |
| `inactive`               | Inativa                       | Inactive                     |

### 6.5 Execução

| Chave                    | pt_BR                         | en                           |
| ------------------------ | ----------------------------- | ---------------------------- |
| `execute`                | Executar                      | Execute                      |
| `execution`              | Execução                      | Execution                    |
| `startExecution`         | Iniciar Execução              | Start Execution              |
| `finishExecution`        | Finalizar Execução            | Finish Execution             |
| `executionNotes`         | Observações da Execução       | Execution Notes              |
| `attachPhoto`            | Anexar Foto                   | Attach Photo                 |
| `executionCompleted`     | Execução concluída            | Execution completed          |

### 6.6 Validação

| Chave                    | pt_BR                         | en                           |
| ------------------------ | ----------------------------- | ---------------------------- |
| `validate`               | Validar                       | Validate                     |
| `validation`             | Validação                     | Validation                   |
| `approved`               | Aprovado                      | Approved                     |
| `rejected`               | Reprovado                     | Rejected                     |
| `feedback`               | Feedback                      | Feedback                     |
| `pendingValidation`      | Validação Pendente            | Pending Validation           |
| `validationCompleted`    | Validação concluída           | Validation completed         |

### 6.7 Pontuação e Recompensas

| Chave                    | pt_BR                         | en                           |
| ------------------------ | ----------------------------- | ---------------------------- |
| `score`                  | Pontuação                     | Score                        |
| `totalPoints`            | Pontos Totais                 | Total Points                 |
| `periodPoints`           | Pontos do Período             | Period Points                |
| `thermometer`            | Termômetro                    | Thermometer                  |
| `progress`               | Progresso                     | Progress                     |
| `rewards`                | Recompensas                   | Rewards                      |
| `createReward`           | Criar Recompensa              | Create Reward                |
| `requiredPoints`         | Pontos Necessários            | Required Points              |
| `unlocked`               | Desbloqueada                  | Unlocked                     |
| `locked`                 | Bloqueada                     | Locked                       |

### 6.8 Dashboard e Relatórios

| Chave                    | pt_BR                         | en                           |
| ------------------------ | ----------------------------- | ---------------------------- |
| `dashboard`              | Painel                        | Dashboard                    |
| `todayTasks`             | Tarefas de Hoje               | Today's Tasks                |
| `quickActions`           | Ações Rápidas                 | Quick Actions                |
| `reports`                | Relatórios                    | Reports                      |
| `statistics`             | Estatísticas                  | Statistics                   |
| `totalTasks`             | Total de Tarefas              | Total Tasks                  |
| `executedTasks`          | Tarefas Executadas            | Executed Tasks               |
| `validatedTasks`         | Tarefas Validadas             | Validated Tasks              |
| `pendingTasks`           | Tarefas Pendentes             | Pending Tasks                |
| `missedTasks`            | Tarefas Não Cumpridas         | Missed Tasks                 |
| `filterByPeriod`         | Filtrar por Período           | Filter by Period             |
| `thisWeek`               | Esta Semana                   | This Week                    |
| `thisMonth`              | Este Mês                      | This Month                   |
| `customPeriod`           | Período Personalizado         | Custom Period                |

### 6.9 Configurações

| Chave                    | pt_BR                         | en                           |
| ------------------------ | ----------------------------- | ---------------------------- |
| `settings`               | Configurações                 | Settings                     |
| `language`               | Idioma                        | Language                     |
| `portuguese`             | Português (Brasil)            | Portuguese (Brazil)          |
| `english`                | Inglês                        | English                      |
| `systemDefault`          | Padrão do Sistema             | System Default               |
| `profile`                | Perfil                        | Profile                      |
| `changePhoto`            | Alterar Foto                  | Change Photo                 |
| `about`                  | Sobre                         | About                        |

### 6.10 Status

| Chave                    | pt_BR                         | en                           |
| ------------------------ | ----------------------------- | ---------------------------- |
| `statusPending`          | Pendente                      | Pending                      |
| `statusExecuted`         | Executado                     | Executed                     |
| `statusValidated`        | Validado                      | Validated                    |
| `statusMissed`           | Não Cumprido                  | Missed                       |
| `statusApproved`         | Aprovado                      | Approved                     |
| `statusRejected`         | Reprovado                     | Rejected                     |
| `statusActive`           | Ativo                         | Active                       |
| `statusInactive`         | Inativo                       | Inactive                     |

---

## 7. Strings com Parâmetros (Interpolação)

Algumas strings exigem interpolação de valores dinâmicos:

| Chave                         | pt_BR                                        | en                                         |
| ----------------------------- | -------------------------------------------- | ------------------------------------------ |
| `welcomeUser(name)`           | Olá, {name}!                                 | Hello, {name}!                             |
| `pointsOf(current, target)`   | {current} de {target} pontos                 | {current} of {target} points               |
| `tasksCount(count)`           | {count} tarefa(s)                            | {count} task(s)                            |
| `pendingCount(count)`         | {count} pendência(s)                         | {count} pending item(s)                    |
| `createdAt(date)`             | Criado em {date}                             | Created on {date}                          |
| `confirmDelete(item)`         | Tem certeza que deseja excluir "{item}"?     | Are you sure you want to delete "{item}"?  |
| `scoreProgress(percent)`      | {percent}% concluído                         | {percent}% completed                       |
| `rewardUnlockedMsg(title)`    | Recompensa "{title}" desbloqueada!           | Reward "{title}" unlocked!                 |
| `invitedBy(name)`             | Convidado por {name}                         | Invited by {name}                          |
| `daysRemaining(days)`         | {days} dia(s) restante(s)                    | {days} day(s) remaining                    |

---

## 8. Estratégia de Pluralização

Para strings que variam conforme quantidade, utilizar o sistema ICU do ARB:

```json
{
  "tasksCount": "{count, plural, =0{Nenhuma tarefa} =1{1 tarefa} other{{count} tarefas}}",
  "@tasksCount": {
    "placeholders": {
      "count": { "type": "int" }
    }
  }
}
```

---

## 9. Fluxo de Detecção de Idioma

```
App inicia
    ↓
Verifica SharedPreferences por preferência salva
    ↓
[Se existe preferência salva]
    → Usa locale salvo pelo usuário
    ↓
[Se NÃO existe preferência salva]
    → Detecta locale do sistema (Platform.localeName / window.locale)
    ↓
    [Se pt ou pt_BR] → Português (Brasil)
    [Se en ou en_*]   → Inglês
    [Outros]          → Português (Brasil) — fallback
    ↓
App renderiza com o locale definido
```

---

## 10. Tela de Configurações (Seletor de Idioma)

### Componentes

| Componente                | Descrição                                                |
| ------------------------- | -------------------------------------------------------- |
| `LanguageSelector`        | Widget dropdown ou radio com opções de idioma            |
| Opção "Padrão do Sistema" | Reseta para detecção automática (remove preferência)     |
| Opção "Português (Brasil)"| Força pt_BR independente do sistema                     |
| Opção "English"           | Força en independente do sistema                         |

### Localização do Seletor

O seletor de idioma deve estar acessível em:
- **Tela de Perfil/Configurações** (`/settings` ou dentro de `/profile`)
- Opcionalmente na tela de **Login** (para novos usuários)

### Comportamento

1. Usuário seleciona idioma
2. App salva preferência em SharedPreferences
3. Provider `localeProvider` atualiza estado
4. `MaterialApp` rebuilda com novo locale
5. Toda a interface atualiza imediatamente

---

## 11. Dependências Necessárias

### pubspec.yaml

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  shared_preferences: ^2.2.0
```

> O pacote `intl` já está no projeto (^0.18.1).

### l10n.yaml (raiz do projeto)

Criar arquivo `l10n.yaml` com configuração do gen-l10n.

---

## 12. Critérios de Aceite

| #   | Critério                                                                         | Status |
| --- | -------------------------------------------------------------------------------- | ------ |
| CA1 | App detecta idioma do sistema e exibe interface no idioma correto               | ⬜     |
| CA2 | App usa pt_BR quando idioma do sistema não é suportado                          | ⬜     |
| CA3 | Usuário pode trocar idioma manualmente via configurações                        | ⬜     |
| CA4 | Preferência de idioma é persistida entre sessões                                | ⬜     |
| CA5 | Troca de idioma é imediata sem reiniciar o app                                  | ⬜     |
| CA6 | Todas as strings de interface estão em arquivos ARB                             | ⬜     |
| CA7 | Nenhuma string de UI está hardcoded no código Dart                              | ⬜     |
| CA8 | Datas são formatadas conforme região (dd/MM/yyyy vs MM/dd/yyyy)                 | ⬜     |
| CA9 | Strings com parâmetros funcionam corretamente em ambos os idiomas               | ⬜     |
| CA10| Pluralização funciona corretamente em ambos os idiomas                          | ⬜     |
| CA11| Testes unitários validam existência de todas as chaves em ambos ARB             | ⬜     |
| CA12| Testes de widget podem executar em qualquer locale                              | ⬜     |

---

## 13. Escopo de Implementação por Agente

| Agente               | Responsabilidade                                                      |
| -------------------- | --------------------------------------------------------------------- |
| Architecture Agent   | Definir estrutura de pastas i18n, l10n.yaml, dependências             |
| Domain Agent         | Nenhuma (i18n é responsabilidade da camada de apresentação)           |
| Firebase Agent       | Nenhuma (preferência é local, não Firestore)                          |
| Flutter UI Agent     | Implementar provider de locale, seletor de idioma, migrar strings     |
| Recurrence Agent     | Nenhuma                                                               |
| Score Agent          | Nenhuma                                                               |
| Testing Agent        | Testes de locale, testes de completude de ARB, testes de widget       |
| Documentation Agent  | Documentar feature de i18n, guia de adição de novas strings           |
| HTML Prototype Agent | Protótipo do seletor de idioma nas configurações                      |

---

## 14. Checklist de Implementação

- [ ] Adicionar `flutter_localizations` e `shared_preferences` ao pubspec.yaml
- [ ] Criar `l10n.yaml` na raiz do projeto
- [ ] Criar `lib/l10n/app_pt_BR.arb` com todas as strings em português
- [ ] Criar `lib/l10n/app_en.arb` com todas as strings em inglês
- [ ] Executar `flutter gen-l10n` para gerar classes de localização
- [ ] Criar `LocaleNotifier` (StateNotifier) com lógica de detecção e persistência
- [ ] Criar `localeProvider` (Riverpod)
- [ ] Atualizar `MaterialApp.router` com delegates e locale do provider
- [ ] Criar tela/seção de configurações com seletor de idioma
- [ ] Migrar todas as strings hardcoded das telas existentes para usar `AppLocalizations`
- [ ] Adicionar formatação regional de datas via `intl`
- [ ] Criar testes unitários para `LocaleNotifier`
- [ ] Criar testes de completude de chaves ARB
- [ ] Criar testes de widget com locale específico
- [ ] Documentar processo de adição de novas strings traduzíveis
