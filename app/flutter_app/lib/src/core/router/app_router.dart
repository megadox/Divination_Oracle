import 'package:go_router/go_router.dart';

import '../../features/divination/presentation/divination_catalog_screen.dart';
import '../../features/divination/presentation/divination_intro_screen.dart';
import '../../features/divination/presentation/divination_reading_screen.dart';
import '../../features/divination/presentation/home_screen.dart';
import '../../features/divination/presentation/question_input_screen.dart';
import '../../features/divination/presentation/reading_result_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/subscription/presentation/subscription_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) => const DivinationCatalogScreen(),
    ),
    GoRoute(
      path: '/catalog/:code',
      builder: (context, state) {
        return DivinationIntroScreen(
          code: state.pathParameters['code']!,
        );
      },
    ),
    GoRoute(
      path: '/reading/:code',
      redirect: (context, state) => '/reading/${state.pathParameters['code']!}/question',
    ),
    GoRoute(
      path: '/reading/:code/question',
      builder: (context, state) {
        return QuestionInputScreen(
          divinationCode: state.pathParameters['code']!,
        );
      },
    ),
    GoRoute(
      path: '/reading/:code/input',
      builder: (context, state) {
        return DivinationReadingScreen(
          divinationCode: state.pathParameters['code']!,
        );
      },
    ),
    GoRoute(
      path: '/result/:readingId',
      builder: (context, state) {
        return ReadingResultScreen(
          readingId: state.pathParameters['readingId']!,
        );
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/plus',
      builder: (context, state) => const SubscriptionScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
