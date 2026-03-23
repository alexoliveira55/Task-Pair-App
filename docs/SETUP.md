# Guia de Configuração do Desenvolvedor — Task Pair App

## Índice

- [Pré-requisitos](#pré-requisitos)
- [Clonando e Instalando](#clonando-e-instalando)
- [Configuração do Firebase](#configuração-do-firebase)
- [Executando o Aplicativo](#executando-o-aplicativo)
- [Executando Testes](#executando-testes)
- [Visão Geral da Estrutura do Projeto](#visão-geral-da-estrutura-do-projeto)

---

## Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas:

| Ferramenta         | Versão Mínima | Instalação                                         |
| ------------------ | ------------- | -------------------------------------------------- |
| Flutter SDK        | 3.0.0+        | https://docs.flutter.dev/get-started/install        |
| Dart SDK           | 3.0.0+        | Incluso com Flutter                                 |
| Firebase CLI       | 12.0+         | `npm install -g firebase-tools`                     |
| FlutterFire CLI    | 1.0+          | `dart pub global activate flutterfire_cli`           |
| Node.js            | 18+           | https://nodejs.org                                  |
| Git                | 2.0+          | https://git-scm.com                                 |
| Android Studio     | —             | Para desenvolvimento Android (emulador + SDK)       |
| Xcode              | —             | Para desenvolvimento iOS/macOS (somente macOS)      |
| Visual Studio 2022 | —             | Para desenvolvimento Windows (Desktop C++ workload) |
| Chrome             | —             | Para desenvolvimento Web                            |

### Verificando instalação do Flutter

```bash
flutter doctor -v
```

Todos os itens necessários devem estar com ✓.

---

## Clonando e Instalando

### 1. Clone o repositório

```bash
git clone <URL_DO_REPOSITORIO>
cd task_pair_app
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. (Opcional) Gere código com build_runner

Se precisar regenerar código do Freezed/Riverpod:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Configuração do Firebase

### 1. Faça login no Firebase

```bash
firebase login
```

### 2. Crie um projeto no Firebase Console

1. Acesse https://console.firebase.google.com
2. Crie um novo projeto
3. Ative os seguintes serviços:
   - **Authentication** → Ative o provedor Email/Senha
   - **Cloud Firestore** → Crie o banco em modo produção
   - **Firebase Storage** → Ative o storage
   - **Cloud Messaging** → Ative o FCM

### 3. Configure o FlutterFire

```bash
flutterfire configure
```

Selecione o projeto Firebase e as plataformas desejadas (Android, iOS, Web, macOS, Windows).

Isso vai gerar o arquivo `lib/firebase_options.dart`.

### 4. Deploy das regras de segurança e índices

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

Os arquivos de configuração estão em:
- `firebase/firestore.rules` — Regras de segurança do Firestore
- `firebase/firestore.indexes.json` — Índices compostos

### 5. Configuração do Android

Certifique-se que o arquivo `google-services.json` está em `android/app/`.

No `android/build.gradle`, o plugin do Google Services deve estar configurado.

### 6. Configuração do iOS/macOS

O arquivo `GoogleService-Info.plist` deve estar em `ios/Runner/` e `macos/Runner/`.

---

## Executando o Aplicativo

### Web (Chrome)

```bash
flutter run -d chrome
```

### Android (Emulador ou dispositivo)

```bash
flutter run -d android
```

### iOS (Somente macOS)

```bash
flutter run -d ios
```

### Windows

```bash
flutter run -d windows
```

### macOS

```bash
flutter run -d macos
```

### Linux

```bash
flutter run -d linux
```

### Modo Debug com Hot Reload

```bash
flutter run
```

Pressione `r` para hot reload ou `R` para hot restart.

### Build de Produção

```bash
# Web
flutter build web

# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios

# Windows
flutter build windows
```

---

## Executando Testes

### Todos os testes

```bash
flutter test
```

### Testes unitários

```bash
flutter test test/unit/
```

### Testes de widget

```bash
flutter test test/widget/
```

### Testes com cobertura

```bash
flutter test --coverage
```

O relatório de cobertura será gerado em `coverage/lcov.info`.

### Estrutura dos testes

```
test/
├── mocks/                  # Mocks compartilhados (Mocktail)
├── unit/
│   ├── core/               # Testes de utils, extensions, constants
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── extensions/
│   │   └── utils/
│   └── domain/
│       ├── entities/        # Testes das entidades de domínio
│       └── usecases/        # Testes dos use cases
├── widget/
│   ├── dashboard_page_test.dart
│   └── login_page_test.dart
└── widget_test.dart
```

---

## Visão Geral da Estrutura do Projeto

```
task_pair_app/
├── lib/
│   ├── main.dart               # Ponto de entrada + inicialização Firebase
│   ├── app.dart                # Widget raiz (MaterialApp.router)
│   ├── core/                   # Infraestrutura compartilhada
│   │   ├── constants/          # Constantes (Firestore, App)
│   │   ├── errors/             # Classes de exceção customizadas
│   │   ├── extensions/         # Extensões de String
│   │   └── utils/              # Utilitários de data
│   ├── data/                   # Camada de dados
│   │   ├── models/             # Modelos de dados (fromMap/toMap)
│   │   └── repositories/      # Implementações de repositórios
│   ├── domain/                 # Camada de domínio (puro Dart)
│   │   ├── entities/           # Entidades Equatable
│   │   ├── repositories/       # Interfaces de repositórios (abstract)
│   │   └── usecases/           # Casos de uso
│   ├── features/               # Features organizadas por módulo
│   │   ├── auth/               # Autenticação
│   │   ├── dashboard/          # Dashboard principal
│   │   ├── execution/          # Execução de tarefas
│   │   ├── pairs/              # Gerenciamento de pares
│   │   ├── recurrence/         # Motor de recorrência
│   │   ├── reports/            # Relatórios
│   │   ├── rewards/            # Recompensas
│   │   ├── score/              # Pontuação
│   │   ├── tasks/              # Gerenciamento de tarefas
│   │   └── validation/         # Validação de tarefas
│   ├── routes/                 # Configuração GoRouter
│   ├── services/               # Serviços Firebase
│   │   ├── firebase_auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── storage_service.dart
│   │   └── fcm_service.dart
│   └── shared/                 # Componentes compartilhados
│       ├── themes/             # Temas Material 3
│       └── widgets/            # Widgets reutilizáveis
├── firebase/                   # Configuração Firebase
│   ├── firestore.rules         # Regras de segurança
│   └── firestore.indexes.json  # Índices compostos
├── prototypes/                 # Protótipos HTML interativos
├── docs/                       # Documentação
├── test/                       # Testes automatizados
├── android/                    # Configuração Android
├── ios/                        # Configuração iOS
├── web/                        # Configuração Web
├── windows/                    # Configuração Windows
├── linux/                      # Configuração Linux
├── macos/                      # Configuração macOS
└── pubspec.yaml                # Dependências
```

---

## Variáveis de Ambiente

Nenhuma variável de ambiente adicional é necessária. As configurações do Firebase são geradas automaticamente pelo FlutterFire CLI no arquivo `lib/firebase_options.dart`.

---

## Resolução de Problemas

### Flutter doctor reporta problemas

```bash
flutter doctor -v
```

Siga as instruções apresentadas para resolver cada item.

### Dependências não resolvidas

```bash
flutter clean
flutter pub get
```

### Firebase não inicializa

1. Verifique se `firebase_options.dart` existe em `lib/`
2. Verifique se os arquivos de configuração da plataforma estão corretos
3. Execute `flutterfire configure` novamente

### Build do Windows falha

Certifique-se de que o Visual Studio 2022 está instalado com o workload "Desktop development with C++".

### Erros de código gerado

```bash
dart run build_runner build --delete-conflicting-outputs
```
