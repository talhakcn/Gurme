import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/gurme_icons.dart';

import '../../features/account/screens/account_screen.dart';
import '../../features/activity/activity_screens.dart';
import '../../features/journal/screens/archive_screen.dart';
import '../../features/journal/data/dish_models.dart';
import '../../features/journal/screens/discover_screen.dart';
import '../../features/journal/screens/dish_ranking_screen.dart';
import '../../features/journal/screens/place_detail_screen.dart';
import '../../features/journal/screens/place_edit_screen.dart';
import '../../features/journal/screens/visit_edit_screen.dart';
import '../../features/lists/screens/list_cover_screen.dart';
import '../../features/lists/screens/list_detail_screen.dart';
import '../../features/lists/screens/list_edit_screen.dart';
import '../../features/lists/screens/lists_screen.dart';
import '../../features/lists/screens/shared_list_screen.dart';
import '../../features/profile/profile_screens.dart';
import '../../features/moderation/admin_screen.dart';
import '../../features/moderation/admin_user_screen.dart';
import '../../features/profile/month_summary_screen.dart';
import '../../features/profile/year_summary_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/search/screens/venue_screen.dart';
import '../../features/settings/guide_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/home_shell.dart';

/// Alt sekmeler; sıra ve adlar Expo uygulamasındaki `app/(tabs)/_layout.tsx` ile aynı.
const homeTabs = [
  HomeTab(path: '/', label: 'Keşfet', icon: GurmeGlyph.discover),
  HomeTab(path: '/search', label: 'Arama', icon: GurmeGlyph.search),
  HomeTab(path: '/archive', label: 'Arşivim', icon: GurmeGlyph.archive),
  HomeTab(path: '/lists', label: 'Listelerim', icon: GurmeGlyph.lists),
  HomeTab(path: '/profile', label: 'Profil', icon: GurmeGlyph.profile),
];

/// Sayfa türü açıkça verilir. go_router uygulamanın türünü kendisi
/// algılayamadığında geçişsiz sayfa (NoTransitionPage) kullanıyordu; o
/// zaman iOS'ta kenardan kaydırarak geri gitme ve kayma geçişi çalışmıyordu.
/// MaterialPage iOS'ta Cupertino geçişini ve geri hareketini kullanır.
GoRoute _page(String path, GoRouterWidgetBuilder builder) => GoRoute(
  path: path,
  pageBuilder: (context, state) => MaterialPage<void>(
    key: state.pageKey,
    name: state.name ?? state.path,
    arguments: state.extra,
    restorationId: state.pageKey.value,
    child: builder(context, state),
  ),
);

GoRoute _tab(String path, GoRouterWidgetBuilder builder) =>
    _page(path, builder);

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    // Tanınmayan bir adres gelirse (örneğin bir dış bağlantı) hata sayfası
    // yerine Keşfet açılır.
    onException: (context, state, router) => router.go('/'),
    routes: [
      StatefulShellRoute(
        builder: (context, state, shell) =>
            HomeShell(shell: shell, tabs: homeTabs),
        // Sekmeler arka planda açık kalır; kapak geçişi (Hero) yalnızca
        // görünen sekmede çalışsın, yoksa aynı mekânın kapağı iki sekmede
        // bulunup geçişi bozar.
        navigatorContainerBuilder: (context, shell, children) => IndexedStack(
          index: shell.currentIndex,
          children: [
            for (final (i, child) in children.indexed)
              // Arka plandaki sekmenin animasyonları da durur.
              TickerMode(
                enabled: i == shell.currentIndex,
                child: HeroMode(enabled: i == shell.currentIndex, child: child),
              ),
          ],
        ),
        branches: [
          StatefulShellBranch(
            routes: [_tab('/', (context, state) => const DiscoverScreen())],
          ),
          StatefulShellBranch(
            routes: [_tab('/search', (context, state) => const SearchScreen())],
          ),
          StatefulShellBranch(
            routes: [
              _tab('/archive', (context, state) => const ArchiveScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              _tab(
                '/lists',
                (context, state) => ListsScreen(
                  initialTab: listsTabFromQuery(
                    state.uri.queryParameters['tab'],
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              _tab('/profile', (context, state) => const ProfileScreen()),
            ],
          ),
        ],
      ),
      // Sekme çubuğunun üstünde açılan sayfalar.
      _page(
        '/place/new',
        (context, state) => PlaceEditScreen(draft: state.extra as PlaceDraft?),
      ),
      _page(
        '/place/:id',
        (context, state) =>
            PlaceDetailScreen(placeId: state.pathParameters['id']!),
      ),
      _page(
        '/place/:id/edit',
        (context, state) =>
            PlaceEditScreen(placeId: state.pathParameters['id']),
      ),
      _page(
        '/place/:id/visit/new',
        (context, state) =>
            VisitEditScreen(placeId: state.pathParameters['id']!),
      ),
      _page(
        '/place/:id/visit/:visitId',
        (context, state) => VisitEditScreen(
          placeId: state.pathParameters['id']!,
          visitId: state.pathParameters['visitId'],
        ),
      ),
      _page('/guide', (context, state) => const GuideScreen()),
      _page(
        '/dishes/:kind',
        (context, state) => DishRankingScreen(
          kind: DishKind.byName(state.pathParameters['kind']),
        ),
      ),
      _page('/list/new', (context, state) => const ListEditScreen()),
      _page(
        '/list/:id',
        (context, state) =>
            ListDetailScreen(listId: state.pathParameters['id']!),
      ),
      _page(
        '/list/:id/cover',
        (context, state) =>
            ListCoverScreen(listId: state.pathParameters['id']!),
      ),
      _page(
        '/list/:id/edit',
        (context, state) => ListEditScreen(listId: state.pathParameters['id']),
      ),
      _page(
        '/shared/:id',
        (context, state) =>
            SharedListScreen(remoteId: state.pathParameters['id']!),
      ),
      _page(
        '/venue/:placeId',
        (context, state) =>
            VenueScreen(placeId: state.pathParameters['placeId']!),
      ),
      _page('/account', (context, state) => const AccountScreen()),
      _page('/admin', (context, state) => const AdminScreen()),
      _page(
        '/admin/user/:id',
        (context, state) =>
            AdminUserScreen(userId: state.pathParameters['id']!),
      ),
      _page('/activity', (context, state) => const ActivityScreen()),
      _page('/settings', (context, state) => const SettingsScreen()),
      _page('/profile/month', (context, state) => const MonthSummaryScreen()),
      _page('/profile/year', (context, state) => const YearSummaryScreen()),
      _page('/profile/edit', (context, state) => const ProfileEditScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
