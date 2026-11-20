import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

    // Top-level modal/push routes
    GoRoute(
      path: '/search',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/category/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        final name = state.extra as String?;
        return CategoryWebsitesScreen(
          categoryId: id,
          categoryName: name,
        );
      },
    ),
    GoRoute(
      path: '/website/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        final website = state.extra as WebsiteEntity?;
        return WebsiteDetailsScreen(
          websiteId: id,
          initialWebsite: website,
        );
      },
    ),
    GoRoute(
      path: '/add-website',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        if (state.extra is Map<String, dynamic>) {
          final map = state.extra as Map<String, dynamic>;
          return AddWebsiteScreen(
            initialCategoryId: map['categoryId'] as int?,
            initialUrl: map['url'] as String?,
            initialName: map['name'] as String?,
          );
        }
        final categoryId = state.extra as int?;
        final urlQuery = state.uri.queryParameters['url'];
        final nameQuery = state.uri.queryParameters['name'];
        return AddWebsiteScreen(
          initialCategoryId: categoryId,
          initialUrl: urlQuery,
          initialName: nameQuery,
        );
      },
    ),
    GoRoute(
      path: '/edit-website',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final website = state.extra as WebsiteEntity;
        return AddWebsiteScreen(websiteToEdit: website);
      },
    ),
    GoRoute(
      path: '/browser',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        final url = extra['url'] ?? '';
        final title = extra['title'] ?? 'FreeHub Browser';
        return InAppBrowserScreen(url: url, title: title);
      },
    ),
  ],
);
