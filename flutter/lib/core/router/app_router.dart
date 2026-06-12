import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/conversation_list_screen.dart';
import '../../features/documents/presentation/screens/document_list_screen.dart';
import '../../features/documents/presentation/screens/document_upload_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  redirect: (context, state) {
    final isLoggedIn = false;
    final isAuthRoute = state.matchedLocation.startsWith('/login') ||
        state.matchedLocation.startsWith('/register');
    if (!isLoggedIn && !isAuthRoute) {
      return AppRoutes.login;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Home - Coming Soon')),
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) => const ConversationListScreen(),
    ),
    GoRoute(
      path: AppRoutes.chatConversation,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ChatScreen(conversationId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.documents,
      builder: (context, state) => const DocumentListScreen(),
    ),
    GoRoute(
      path: AppRoutes.documentUpload,
      builder: (context, state) => const DocumentUploadScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
