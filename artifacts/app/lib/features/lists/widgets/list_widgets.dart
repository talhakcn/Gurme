import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gurme_client/gurme_client.dart';

import '../../../core/text/turkish.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../journal/data/journal_models.dart';

const visibilityOptions = [
  (ListVisibility.private, 'Özel'),
  (ListVisibility.unlisted, 'Bağlantıyla'),
  (ListVisibility.public, 'Herkese açık'),
];

String visibilityHint(ListVisibility v) => switch (v) {
  ListVisibility.public => 'Keşfet ekranında herkes görebilir.',
  ListVisibility.unlisted => 'Yalnızca bağlantıya sahip kişiler görebilir.',
  ListVisibility.private =>
    'Bu liste yalnızca sende kalır; paylaşım bağlantısı oluşturulmaz.',
};

/// Liste satırlarının ortak çerçevesi.
class ListTileFrame extends StatelessWidget {
  const ListTileFrame({super.key, required this.onTap, required this.children});

  final VoidCallback onTap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: Space.xl),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.colors.line)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

/// Sunucudaki (topluluk ya da kaydedilen) bir liste satırı.
class RemoteListRow extends StatelessWidget {
  const RemoteListRow({super.key, required this.list});

  final GurmeList list;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListTileFrame(
      onTap: () => context.push('/shared/${list.id}'),
      children: [
        Eyebrow(
          '${list.visibility == GurmeListVisibility.public ? 'Herkese açık liste' : 'Kaydedilen liste'}'
          ' · ${list.authorName}',
        ),
        const SizedBox(height: Space.s),
        Text(list.title, style: text.headlineMedium),
        if (list.description.isNotEmpty) ...[
          const SizedBox(height: Space.s),
          Text(
            list.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall,
          ),
        ],
        const SizedBox(height: Space.m),
        Eyebrow('${list.items.length} mekân · ${formatDateTr(list.updatedAt)}'),
      ],
    );
  }
}
