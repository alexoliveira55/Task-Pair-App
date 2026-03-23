import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Captura erros do framework Flutter (ex: erros em build de widgets)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Erro Flutter: ${details.exceptionAsString()}');
  };

  // Captura erros assíncronos não tratados fora do contexto Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Erro não tratado: $error\n$stack');
    return true; // retorna true para indicar que o erro foi tratado
  };

  // Define um widget de erro amigável para falhas de build de widgets
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return _FriendlyErrorWidget(
      message: details.exceptionAsString(),
    );
  };

  await runZonedGuarded(
    () async {
      String? initializationError;

      try {
        await Firebase.initializeApp();
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      } catch (e, stack) {
        debugPrint('Erro ao inicializar Firebase: $e\n$stack');
        initializationError =
            'Não foi possível conectar aos serviços do aplicativo.\n'
            'Verifique sua conexão com a internet e tente novamente.\n\n'
            'Detalhes técnicos: $e';
      }

      runApp(
        ProviderScope(
          child: initializationError != null
              ? _ErrorApp(message: initializationError)
              : const App(),
        ),
      );
    },
    (error, stack) {
      debugPrint('Erro assíncrono não tratado: $error\n$stack');
    },
  );
}

/// Tela de erro exibida quando a inicialização do app falha.
class _ErrorApp extends StatelessWidget {
  final String message;

  const _ErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Pair App',
      home: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 72,
                    color: Color(0xFF6750A4),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ops! Algo deu errado',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1B1F),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF625B71),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () {
                      // Reinicia o processo de inicialização
                      main();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6750A4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget de erro amigável exibido quando um widget falha ao ser construído.
class _FriendlyErrorWidget extends StatelessWidget {
  final String message;

  const _FriendlyErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF3F3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFF44336),
              size: 40,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ocorreu um erro nesta tela',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1C1B1F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(fontSize: 12, color: Color(0xFF625B71)),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
