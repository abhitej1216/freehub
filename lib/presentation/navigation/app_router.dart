import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:freehub/core/theme/app_motion.dart';
import 'package:freehub/domain/entities/website_entity.dart';
import 'package:freehub/presentation/screens/add_website/add_website_screen.dart';
import 'package:freehub/presentation/screens/bookmarks/bookmarks_screen.dart';
import 'package:freehub/presentation/screens/browser/in_app_browser_screen.dart';
import 'package:freehub/presentation/screens/categories/categories_screen.dart';
import 'package:freehub/presentation/screens/categories/category_websites_screen.dart';
import 'package:freehub/presentation/screens/home/home_screen.dart';
import 'package:freehub/presentation/screens/home/search_screen.dart';
import 'package:freehub/presentation/screens/my_collection/my_collection_screen.dart';
import 'package:freehub/presentation/screens/settings/settings_screen.dart';
import 'package:freehub/presentation/screens/website_details/website_details_screen.dart';
import 'package:freehub/presentation/widgets/main_scaffold.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Emil Kowalski's smooth route transition:
/// Never scale from 0. Starts with scale(0.96) + opacity: 0 + translateY(4%)
/// Settles with custom strong ease-out (240ms) and exits fast (180ms).
Page<dynamic> buildEmilPageTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppMotion.durationStandard,
    reverseTransitionDuration: AppMotion.durationFast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: AppMotion.easeOut,
        reverseCurve: AppMotion.easeOut,
      );
      final fade =
          Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);
      final scale =
          Tween<double>(begin: 0.96, end: 1.0).animate(curvedAnimation);
      final slide = Tween<Offset>(
        begin: const Offset(0.0, 0.03),
        end: Offset.zero,
      ).animate(curvedAnimation);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: ScaleTransition(
            scale: scale,
            child: child,
          ),
        ),
      );
    },
  );
}

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Bottom Navigation Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Tab 2: Categories
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/categories',
              builder: (context, state) => const CategoriesScreen(),
            ),
          ],
        ),

        // Tab 3: Bookmarks
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bookmarks',
              builder: (context, state) => const BookmarksScreen(),
            ),
          ],
        ),

        // Tab 4: My Collection
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my-collection',
              builder: (context, state) => const MyCollectionScreen(),
            ),
          ],
        ),

        // Tab 5: Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),

    // Top-level modal/push routes with Emil transitions
    GoRoute(
      path: '/search',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => buildEmilPageTransition(
        state: state,
        child: const SearchScreen(),
      ),
    ),
    GoRoute(
      path: '/category/:id',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        final name = state.extra as String? ?? '';
        return buildEmilPageTransition(
          state: state,
          child: CategoryWebsitesScreen(
            categoryId: id,
            categoryName: name,
          ),
        );
      },
    ),
    GoRoute(
      path: '/website/:id',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        final website = state.extra as WebsiteEntity?;
        return buildEmilPageTransition(
          state: state,
          child: WebsiteDetailsScreen(
            websiteId: id,
            initialWebsite: website,
          ),
        );
      },
    ),
    GoRoute(
      path: '/add-website',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        if (state.extra is Map<String, dynamic>) {
          final map = state.extra as Map<String, dynamic>;
          return buildEmilPageTransition(
            state: state,
            child: AddWebsiteScreen(
              initialCategoryId: map['categoryId'] as int?,
              initialUrl: map['url'] as String?,
              initialName: map['name'] as String?,
            ),
          );
        }
        final categoryId = state.extra as int?;
        final urlQuery = state.uri.queryParameters['url'];
        final nameQuery = state.uri.queryParameters['name'];
        return buildEmilPageTransition(
          state: state,
          child: AddWebsiteScreen(
            initialCategoryId: categoryId,
            initialUrl: urlQuery,
            initialName: nameQuery,
          ),
        );
      },
    ),
    GoRoute(
      path: '/edit-website',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        final website = state.extra as WebsiteEntity;
        return buildEmilPageTransition(
          state: state,
          child: AddWebsiteScreen(websiteToEdit: website),
        );
      },
    ),
    GoRoute(
      path: '/browser',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        final url = extra['url'] ?? '';
        final title = extra['title'] ?? 'FreeHub Browser';
        return buildEmilPageTransition(
          state: state,
          child: InAppBrowserScreen(url: url, title: title),
        );
      },
    ),
  ],
);
