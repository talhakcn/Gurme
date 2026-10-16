import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/gurme_colors.dart';
import '../../core/widgets/editorial.dart';
import '../journal/data/journal_notifier.dart';
import '../journal/data/journal_storage.dart';

/// Görülüp kapatılan ipuçlarının cihazdaki kaydı (`hints.json`).
final hintsStorageProvider = Provider<JournalStorage>(
  (ref) =>
      FileJournalStorage(ref.watch(appDirectoryProvider), name: 'hints.json'),
);

final hintsProvider = NotifierProvider<HintsController, Set<String>?>(
  HintsController.new,
);

/// Kapatılan ipuçlarının kimlikleri. Kayıt okunana kadar `null`; bu sırada
/// hiçbir ipucu gösterilmez, böylece kapatılmış bir ipucu bir an bile
/// görünmez.
class HintsController extends Notifier<Set<String>?> {
  @override
  Set<String>? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final raw = await ref.read(hintsStorageProvider).read();
    var seen = <String>{};
    try {
      if (raw != null) seen = {...(jsonDecode(raw) as List).cast<String>()};
    } on Object {
      // Bozuk kayıt: ipuçları yeniden gösterilir, zararı yok.
    }
    state = {...?state, ...seen};
  }

  bool shows(String id) => state != null && !state!.contains(id);

  Future<void> dismiss(String id) async {
    state = {...?state, id};
    await ref.read(hintsStorageProvider).write(jsonEncode([...state!]));
  }
}

/// Bir kez gösterilen, kapatılabilir kısa açıklama. Kapatılınca bir daha
/// görünmez.
class HintNote extends ConsumerWidget {
  const HintNote({super.key, required this.id, required this.text, this.after});

  final String id;
  final String text;

  /// Verilirse bu ipucu, o ipucu kapatılana kadar beklenir; ipuçları üst
  /// üste binmez.
  final String? after;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(hintsProvider);
    final hints = ref.read(hintsProvider.notifier);
    if (!hints.shows(id) || (after != null && hints.shows(after!))) {
      return const SizedBox.shrink();
    }
    final style = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(top: Space.m),
      padding: const EdgeInsets.fromLTRB(Space.m, Space.m, Space.xs, Space.xs),
      color: context.colors.wash,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: Space.s),
            child: Text(text, style: style.bodyMedium),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => hints.dismiss(id),
              child: const Text('Anladım'),
            ),
          ),
        ],
      ),
    );
  }
}
