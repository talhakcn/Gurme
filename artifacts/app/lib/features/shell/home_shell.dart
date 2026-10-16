import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/gurme_colors.dart';
import '../../core/widgets/editorial.dart';
import '../../core/widgets/gurme_icons.dart';

class HomeTab {
  const HomeTab({required this.path, required this.label, required this.icon});

  final String path;
  final String label;
  final GurmeGlyph icon;
}

/// Yan menünün açıldığı en dar genişlik: iPad ve yatay telefon. Daha
/// darda sekmeler altta.
const sideMenuWidth = 600.0;

/// Alt sekme çubuğu ya da geniş ekranda yan menü; her sekme kendi gezinme
/// yığınını korur.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell, required this.tabs});

  final StatefulNavigationShell shell;
  final List<HomeTab> tabs;

  // Etkin sekmeye yeniden dokunulunca o sekmenin başına dön.
  void _select(int index) =>
      shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= sideMenuWidth) {
      return Scaffold(
        body: Row(
          children: [
            // Çizgi durum çubuğunun altından başlar; saatin içinden geçmez.
            SafeArea(
              right: false,
              child: DecoratedBox(
                // Önde: menünün kendi zemini çizgiyi örtmesin.
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: context.colors.line)),
                ),
                child: NavigationRail(
                  selectedIndex: shell.currentIndex,
                  onDestinationSelected: _select,
                  labelType: NavigationRailLabelType.all,
                  // Menü, sayfanın "GURME" şeridinin altından başlar.
                  groupAlignment: -1,
                  leading: const SizedBox(height: Space.xl),
                  destinations: [
                    for (final tab in tabs)
                      NavigationRailDestination(
                        icon: GurmeIcon(tab.icon),
                        selectedIcon: GurmeIcon(tab.icon, filled: true),
                        label: Text(tab.label),
                        padding: const EdgeInsets.only(bottom: Space.s),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(child: shell),
          ],
        ),
      );
    }
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.colors.line)),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _select,
          destinations: [
            for (final tab in tabs)
              NavigationDestination(
                icon: GurmeIcon(tab.icon),
                selectedIcon: GurmeIcon(tab.icon, filled: true),
                label: tab.label,
              ),
          ],
        ),
      ),
    );
  }
}
