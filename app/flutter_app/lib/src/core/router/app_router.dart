import 'package:go_router/go_router.dart';

import '../../features/divination/presentation/home_screen.dart';
import '../../features/divination/presentation/reading_result_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/subscription/presentation/subscription_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
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
  ],
);
