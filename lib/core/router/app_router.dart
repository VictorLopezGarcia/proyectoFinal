import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/recover_password_screen.dart';
import '../../features/items/presentation/create_item_screen.dart';
import '../../features/items/presentation/item_detail_screen.dart';
import '../../features/reservations/presentation/request_reservation_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../layout/home_shell.dart';

const _authRoutes = [
  '/login',
  '/register',
  '/recover',
];

class AuthNotifierForRouter extends ChangeNotifier {
  AuthNotifierForRouter(Ref ref) {
    _subscription = ref.listen<AsyncValue<dynamic>>(
      authStateProvider,
      (_, _) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AsyncValue<dynamic>> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier = AuthNotifierForRouter(ref);

  ref.onDispose(() => authChangeNotifier.dispose());

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authChangeNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = _authRoutes.contains(state.matchedLocation);

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/recover',
        builder: (context, state) => const RecoverPasswordScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomeShell()),
      GoRoute(
        path: '/items/create',
        builder: (context, state) => const CreateItemScreen(),
      ),
      GoRoute(
        path: '/items/:id',
        builder: (context, state) =>
            ItemDetailScreen(itemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/items/:id/reserve',
        builder: (context, state) =>
            RequestReservationScreen(itemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chats/:id',
        builder: (context, state) => ChatScreen(
          chatId: state.pathParameters['id']!,
          otherUserId: state.uri.queryParameters['otherUserId'] ?? '',
        ),
      ),
    ],
  );
});
