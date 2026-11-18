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

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
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
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/category/:id',
      parentNavigatorKey: _rootNavigatorKey,
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
      parentNavigatorKey: _rootNavigatorKey,
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
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final categoryId = state.extra as int?;
        return AddWebsiteScreen(initialCategoryId: categoryId);
      },
    ),
    GoRoute(
      path: '/edit-website',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final website = state.extra as WebsiteEntity;
        return AddWebsiteScreen(websiteToEdit: website);
      },
    ),
    GoRoute(
      path: '/browser',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        final url = extra['url'] ?? '';
        final title = extra['title'] ?? 'FreeHub Browser';
        return InAppBrowserScreen(url: url, title: title);
      },
    ),
  ],
);
