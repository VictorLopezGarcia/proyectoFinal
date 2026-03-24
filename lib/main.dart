import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'core/config/emulator_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (EmulatorConfig.shouldUseEmulators) {
    FirebaseFirestore.instance.useFirestoreEmulator(
      EmulatorConfig.firestoreHost,
      EmulatorConfig.firestorePort,
    );
    await FirebaseAuth.instance.useAuthEmulator(
      EmulatorConfig.authHost,
      EmulatorConfig.authPort,
    );
  }

  runApp(const ProviderScope(child: RentMyStuffApp()));
}

class RentMyStuffApp extends ConsumerWidget {
  const RentMyStuffApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'RentMyStuff',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
