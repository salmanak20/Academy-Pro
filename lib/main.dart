import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with timeout to prevent indefinite hang on web
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw TimeoutException('Firebase initialization timed out. Check your internet connection.');
      },
    );

    debugPrint("Firebase initialized successfully");
    
    // Auth persistence
    if (!kIsWeb) {
      try {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      } catch (e) {
        debugPrint("Auth persistence error: $e");
      }
    }

    // Firestore config
    await _configureFirestore();

    runApp(
      const ProviderScope(
        child: AcademyProApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint("Startup error: $e");
    debugPrint(stackTrace.toString());

    runApp(
      FirebaseStartupErrorApp(error: e),
    );
  }
}

Future<void> _configureFirestore() async {
  final firestore = FirebaseFirestore.instance;

  if (kIsWeb) {
    // Disable persistence on web to avoid offline cache issues
    firestore.settings = const Settings(
      persistenceEnabled: false,
      sslEnabled: true,
    );

    debugPrint("Firestore configured for WEB");
  } else {
    firestore.settings = const Settings(
      persistenceEnabled: true,
      sslEnabled: true,
    );

    debugPrint("Firestore configured for MOBILE");
  }
}

class AcademyProApp extends ConsumerWidget {
  const AcademyProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Academy Pro',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      routerConfig: router,
    );
  }
}

class FirebaseStartupErrorApp extends StatelessWidget {
  final Object error;

  const FirebaseStartupErrorApp({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Academy Pro',

      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 520,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off,
                    size: 60,
                    color: Colors.red,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Academy Pro could not connect to Firebase',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black54,
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