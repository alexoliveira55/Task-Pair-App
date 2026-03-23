---
mode: agent
description: Valida a estrutura dos agents do projeto Task Pair App contra os requisitos definidos
tools:
  - read_file
  - list_dir
  - file_search
  - grep_search
---

# Prompt de Validação da Estrutura de Agents

Você é um auditor de arquitetura de sistemas multi-agent.

Seu objetivo é validar se a estrutura de agents definida em `.github/agents/` está **completa, consistente e alinhada** com os requisitos funcionais do projeto Task Pair App.

---

## 1. CARREGAMENTO DE CONTEXTO

Antes de qualquer análise, leia **obrigatoriamente** os seguintes arquivos:

```
.github/copilot-instructions.md
.github/agents/orchestrator.md
.github/agents/architecture_agent.md
.github/agents/domain_agent.md
.github/agents/firebase_agent.md
.github/agents/flutter_ui_agent.md
.github/agents/recurrence_agent.md
.github/agents/score_agent.md
.github/agents/testing_agent.md
.github/agents/documentation_agent.md
.github/agents/html_prototype_agent.md
docs/Requisitos.md
docs/Documentacao_arquitetural.txt
docs/Fluxo_funcional.md
```

---

## 2. CRITÉRIOS DE VALIDAÇÃO

Execute cada checklist abaixo. Para cada item, responda: ✅ OK | ⚠️ PARCIAL | ❌ AUSENTE | 🔴 CONFLITO

---

### 2.1 COBERTURA DE AGENTES

Verifique se existe um agent definido para cada papel necessário no projeto:

| # | Papel | Agent esperado | Status |
|---|-------|---------------|--------|
| 1 | Coordenação e sequenciamento de features | orchestrator | |
| 2 | Definição de arquitetura e estrutura de pastas | architecture_agent | |
| 3 | Entidades de domínio e regras de negócio | domain_agent | |
| 4 | Persistência Firebase e Firestore | firebase_agent | |
| 5 | Telas Flutter e componentes UI | flutter_ui_agent | |
| 6 | Motor de recorrência de tarefas | recurrence_agent | |
| 7 | Sistema de pontuação e recompensas | score_agent | |
| 8 | Testes unitários, widget e integração | testing_agent | |
| 9 | Documentação técnica e de usuário | documentation_agent | |
| 10 | Protótipos HTML interativos | html_prototype_agent | |

---

### 2.2 RESPONSABILIDADES DOS AGENTS

Para cada agent, valide se seu arquivo de definição contém:

- [ ] **Identidade clara** (quem é o agent)
- [ ] **Lista de responsabilidades** (o que faz)
- [ ] **Escopo delimitado** (o que NÃO faz)
- [ ] **Entradas/saídas esperadas** (inputs e artefatos gerados)
- [ ] **Restrições técnicas** (tecnologias, padrões obrigatórios)

---

### 2.3 COBERTURA DAS ENTIDADES DE DOMÍNIO

Verifique se as seguintes entidades estão endereçadas por pelo menos um agent:

| Entidade | Agent responsável (domain) | Agent de persistência (firebase) | Agent de UI (flutter_ui) |
|----------|--------------------------|----------------------------------|--------------------------|
| User | | | |
| Pair | | | |
| PairInvite | | | |
| Task | | | |
| TaskOccurrence | | | |
| TaskExecution | | | |
| TaskValidation | | | |
| Score | | | |
| Reward | | | |

---

### 2.4 COBERTURA DOS REQUISITOS FUNCIONAIS

Mapeie cada grupo de RF do `docs/Requisitos.md` para o(s) agent(s) responsável(is):

| RF Group | Descrição | Agent(s) | Cobertura |
|----------|-----------|----------|-----------|
| RF001-RF009 | Cadastro e autenticação de usuário | | |
| RF010-RF019 | Formação e gestão de pares | | |
| RF020-RF039 | Criação e gestão de tarefas | | |
| RF040-RF059 | Recorrência e ocorrências | | |
| RF060-RF079 | Execução de tarefas | | |
| RF080-RF099 | Validação entre pares | | |
| RF100-RF119 | Sistema de pontuação | | |
| RF120-RF139 | Recompensas e termômetro | | |
| RF140-RF159 | Dashboard e relatórios | | |

---

### 2.5 COBERTURA DAS COLEÇÕES FIRESTORE

Verifique se cada coleção Firestore necessária tem um agent responsável pela sua implementação:

| Coleção | Definida no firebase_agent? | CRUD coberto? |
|---------|---------------------------|---------------|
| users | | |
| pairs | | |
| pairInvites | | |
| tasks | | |
| taskOccurrences | | |
| taskExecutions | | |
| taskValidations | | |
| scores | | |
| rewards | | |

---

### 2.6 COBERTURA DAS TELAS (Flutter UI Agent)

Verifique se cada tela obrigatória está listada no `flutter_ui_agent.md`:

| Tela | Presente no agent? | Responsiva (mobile/web/desktop)? |
|------|--------------------|----------------------------------|
| Login | | |
| Cadastro | | |
| Dashboard (termômetro) | | |
| Lista de Pares | | |
| Convites de Par | | |
| Lista de Tarefas | | |
| Criar Tarefa | | |
| Detalhes da Tarefa | | |
| Execução da Tarefa | | |
| Validação da Tarefa | | |
| Recompensas | | |
| Relatórios | | |
| Perfil | | |

---

### 2.7 CONSISTÊNCIA DO FLUXO DE TRABALHO

Verifique se o `orchestrator.md` define explicitamente a ordem dos agents que corresponde ao workflow em `copilot-instructions.md`:

Ordem esperada:
1. Orchestrator → define feature
2. Architecture Agent → estrutura
3. Domain Agent → entidades
4. Firebase Agent → persistência
5. Flutter UI Agent → telas
6. Recurrence Agent → recorrência
7. Score Agent → pontuação
8. Testing Agent → testes
9. Documentation Agent → documentação
10. HTML Prototype Agent → protótipos

- [ ] O orchestrator lista todos os 10 passos?
- [ ] A ordem é consistente entre `copilot-instructions.md` e `orchestrator.md`?
- [ ] Há conflito de responsabilidades entre agents?

---

### 2.8 DETECÇÃO DE LACUNAS CRÍTICAS

Verifique se os seguintes aspectos **transversais** estão cobertos por algum agent:

| Aspecto transversal | Agent responsável | Observação |
|--------------------|-------------------|------------|
| Gerenciamento de estado (Riverpod) | | |
| Navegação (GoRouter) | | |
| Offline persistence | | |
| Real-time updates (Firestore streams) | | |
| Push notifications (FCM) | | |
| Upload de foto de perfil (Storage) | | |
| Layout responsivo (mobile/web/desktop) | | |
| Regras de segurança do Firestore | | |
| Tratamento de erros e edge cases | | |
| Internacionalização (se aplicável) | | |

---

## 3. FORMATO DO RELATÓRIO DE VALIDAÇÃO

Após concluir todas as verificações, gere um relatório estruturado com:

```
# RELATÓRIO DE VALIDAÇÃO DE AGENTS – Task Pair App
Data: {{data atual}}

## RESUMO EXECUTIVO
- Total de agents: X
- Agents completos: X ✅
- Agents parciais: X ⚠️
- Agents ausentes: X ❌
- Conflitos detectados: X 🔴

## PONTUAÇÃO GERAL: XX/100

## PROBLEMAS CRÍTICOS (bloqueantes)
1. [descrição]

## PROBLEMAS MODERADOS (degradantes)
1. [descrição]

## RECOMENDAÇÕES
1. [ação corretiva específica]

## LACUNAS POR AGENT
### [nome do agent]
- Status: ✅ | ⚠️ | ❌
- Problemas: [lista]
- Sugestão: [correção]

## MAPA DE COBERTURA
[tabela resumo de cobertura dos RFs]
```

---

## 4. REGRAS DE AVALIAÇÃO DA PONTUAÇÃO

| Critério | Peso | Pontos máximos |
|----------|------|---------------|
| Todos os 10 agents existem | 10% | 10 |
| Cada agent tem identidade clara | 10% | 10 |
| Cobertura completa das entidades | 15% | 15 |
| Cobertura completa dos RFs | 20% | 20 |
| Cobertura das coleções Firestore | 10% | 10 |
| Cobertura das telas Flutter | 10% | 10 |
| Consistência do workflow | 15% | 15 |
| Lacunas transversais cobertas | 10% | 10 |
| **TOTAL** | **100%** | **100** |

Pontuação < 70: ❌ Estrutura de agents **inadequada** — refatoração necessária  
Pontuação 70–89: ⚠️ Estrutura **parcialmente adequada** — melhorias recomendadas  
Pontuação ≥ 90: ✅ Estrutura **adequada** para o projeto  

---

## 5. AÇÃO FINAL

Após o relatório, se houver problemas:

1. Para cada agent com problemas identificados, **propor o conteúdo corrigido** do arquivo `.github/agents/<agent>.md`
2. Se um agent estiver **ausente**, criar o arquivo com o conteúdo mínimo necessário
3. Se houver **conflito de responsabilidades**, propor redistribuição clara entre os agents envolvidos
4. Atualizar o `copilot-instructions.md` se o workflow precisar de ajustes

Seja específico, técnico e acionável em todas as suas recomendações.
