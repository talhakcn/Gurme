import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/text/turkish.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../../../core/widgets/motion.dart';
import '../data/journal_models.dart';
import 'place_widgets.dart';

/// 1–5 arası puan kutuları; seçili kutuya yeniden dokununca puan kalkar
/// ([onTap] 0 alır). Karnedeki kutularla aynı ölçü: 36 + kenar, 44 pt.
class ScoreBoxes extends StatelessWidget {
  const ScoreBoxes({
    super.key,
    required this.label,
    required this.score,
    required this.onChanged,
  });

  final String label;
  final int score;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var n = 1; n <= 5; n++)
          Semantics(
            button: true,
            selected: score == n,
            label: '$label $n / 5',
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(score == n ? 0 : n);
              },
              child: Padding(
                padding: const EdgeInsets.all(Space.xs),
                child: AnimatedContainer(
                  duration: Motion.short,
                  curve: Motion.curve,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: n <= score ? colors.mark : Colors.transparent,
                    border: Border.all(
                      color: n <= score ? colors.mark : colors.control,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Kapalı kartın tek satırlık özeti: "Burger · 4 / 5 · 3 bileşen
/// işaretli". Bileşenlerin ayrıntısı kart açılınca görünür.
String dishSummaryLine(TastedDish d) {
  final marked = d.parts.where((p) => p.verdict != null).length;
  return [
    d.kind.label,
    if (d.score > 0) '${d.score} / 5',
    if (marked > 0) '$marked bileşen işaretli',
    if (d.never) 'Bir daha söyleme',
  ].join(' · ');
}

/// Deneyim formundaki tabak kartı. Açıkken bütün ayrıntıyı düzenletir,
/// kapalıyken tek satırlık özet gösterir.
class DishCard extends StatefulWidget {
  const DishCard({
    super.key,
    required this.dish,
    required this.expanded,
    required this.onToggle,
    required this.onChanged,
    required this.onRemove,
  });

  final TastedDish dish;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<TastedDish> onChanged;
  final VoidCallback onRemove;

  @override
  State<DishCard> createState() => _DishCardState();
}

class _DishCardState extends State<DishCard> {
  late final _note = TextEditingController(text: widget.dish.note);

  /// Bileşenler bir bağlantının arkasında; işaretlenmiş olan varsa açık.
  late var _showParts = widget.dish.parts.any((p) => p.verdict != null);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  TastedDish get _dish => widget.dish;

  void _setVerdict(int index, DishVerdict verdict) {
    final parts = [..._dish.parts];
    final current = parts[index];
    parts[index] = DishPart(
      current.name,
      current.verdict == verdict ? null : verdict,
    );
    widget.onChanged(_dish.copyWith(parts: parts));
  }

  Future<void> _addPart() async {
    final name = await _askPartName(context);
    if (name == null || !mounted) return;
    setState(() => _showParts = true);
    widget.onChanged(_dish.copyWith(parts: [..._dish.parts, DishPart(name)]));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final title = Text(
      _dish.name,
      style: text.headlineSmall!.copyWith(fontStyle: FontStyle.italic),
    );
    final header = Semantics(
      button: true,
      expanded: widget.expanded,
      child: InkWell(
        onTap: widget.onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.m),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    Text(
                      widget.expanded
                          ? _dish.kind.label
                          : dishSummaryLine(_dish),
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Space.s),
              AnimatedRotation(
                turns: widget.expanded ? 0.5 : 0,
                duration: Motion.short,
                curve: Motion.curve,
                child: GurmeIcon(GurmeGlyph.expand, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.ink, width: 2),
          bottom: widget.expanded
              ? BorderSide.none
              : BorderSide(color: colors.line),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          if (widget.expanded) ...[
            Container(
              padding: const EdgeInsets.only(bottom: Space.xs),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tabak geneli',
                      style: text.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ScoreBoxes(
                    label: '${_dish.name} geneli',
                    score: _dish.score,
                    onChanged: (n) =>
                        widget.onChanged(_dish.copyWith(score: n)),
                  ),
                ],
              ),
            ),
            if (!_showParts && _dish.parts.isNotEmpty)
              LinkLabel(
                'Bileşenleri işaretle (${_dish.parts.length})',
                onTap: () => setState(() => _showParts = true),
              ),
            if (_showParts && _dish.parts.isNotEmpty)
              VerdictTable(
                parts: _dish.parts,
                onSelected: (i, v) => _setVerdict(i, v),
              ),
            if (_showParts || _dish.parts.isEmpty)
              LinkLabel('Bileşen ekle', onTap: _addPart),
            const SizedBox(height: Space.m),
            Field(
              label: 'Bu tabağa not',
              controller: _note,
              placeholder: 'Köfte kuruydu, ekmek tazeydi…',
              onChanged: (v) => widget.onChanged(_dish.copyWith(note: v)),
            ),
            CheckRow(
              label: 'Bir daha söyleme',
              detail: 'Bu mekâna yeniden deneyim eklerken hatırlatılır.',
              checked: _dish.never,
              onTap: () =>
                  widget.onChanged(_dish.copyWith(never: !_dish.never)),
            ),
            RemoveLink('Tabağı çıkar', onPressed: widget.onRemove),
            const SizedBox(height: Space.m),
          ],
        ],
      ),
    );
  }
}

/// Bileşenlerin yargı tablosu. Sığarsa karne gibi: seçenek adları bir kez
/// sütun başlığı olarak yazılır, satırlarda yalnızca kutular durur (seçili
/// kutu dolu ve onaylı). Büyük yazıda ya da dar ekranda her bileşenin adı
/// üstte, seçenekleri altta tam genişlikte.
class VerdictTable extends StatelessWidget {
  const VerdictTable({
    super.key,
    required this.parts,
    required this.onSelected,
  });

  final List<DishPart> parts;
  final void Function(int index, DishVerdict verdict) onSelected;

  static TextStyle _headStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!
          .copyWith(fontWeight: FontWeight.w600);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, box) {
        // Sütun genişliği en uzun başlık kadar, en az dokunma alanı (44).
        var column = 44.0;
        for (final v in DishVerdict.values) {
          final painter = TextPainter(
            text: TextSpan(text: v.label, style: _headStyle(context)),
            textDirection: TextDirection.ltr,
            textScaler: MediaQuery.textScalerOf(context),
            maxLines: 1,
          )..layout();
          if (painter.width + Space.s > column) {
            column = painter.width + Space.s;
          }
          painter.dispose();
        }
        final inline =
            !largeText(context) &&
            box.maxWidth - DishVerdict.values.length * column >= 80;
        Widget row(Widget child) => Container(
          padding: const EdgeInsets.symmetric(vertical: Space.s),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.line)),
          ),
          child: child,
        );
        if (!inline) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, part) in parts.indexed)
                row(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(part.name, style: text.bodyMedium),
                      const SizedBox(height: Space.s),
                      SegmentRow<DishVerdict>(
                        options: [
                          for (final v in DishVerdict.values) (v, v.label),
                        ],
                        selected: part.verdict,
                        onSelected: (v) => onSelected(i, v),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }
        // Başlıklar ekran okuyucuda tekrarlanmaz; her kutu kendi etiketini
        // taşır ("Köfte: Beğenmedim"). Uzun tabloda her beş satırda bir
        // yinelenir: aşağı inince sütunların ne olduğu kaybolmaz.
        final heading = ExcludeSemantics(
          child: Row(
            children: [
              const Spacer(),
              for (final v in DishVerdict.values)
                SizedBox(
                  width: column,
                  child: Text(
                    v.label,
                    textAlign: TextAlign.center,
                    style: _headStyle(context).copyWith(color: colors.muted),
                  ),
                ),
            ],
          ),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            for (final (i, part) in parts.indexed) ...[
              if (i > 0 && i % 5 == 0) ...[
                const SizedBox(height: Space.s),
                heading,
              ],
              row(
                Row(
                  children: [
                    // Seçilen karar adın altında yazar: başlıklar kaydırınca
                    // görünmese de satır kendini anlatır.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(part.name, style: text.bodyMedium),
                          if (part.verdict case final v?)
                            Text(v.label, style: text.bodySmall),
                        ],
                      ),
                    ),
                    for (final v in DishVerdict.values)
                      SizedBox(
                        width: column,
                        child: Center(
                          child: _VerdictBox(
                            label: '${part.name}: ${v.label}',
                            selected: part.verdict == v,
                            onTap: () => onSelected(i, v),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Tablodaki tek kutu: karne kutusuyla aynı ölçü (36 + kenar, 44 pt).
class _VerdictBox extends StatelessWidget {
  const _VerdictBox({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(Space.xs),
          child: AnimatedContainer(
            duration: Motion.short,
            curve: Motion.curve,
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? colors.mark : Colors.transparent,
              border: Border.all(
                color: selected ? colors.mark : colors.control,
              ),
            ),
            child: selected
                ? GurmeIcon(GurmeGlyph.check, size: 18, color: colors.paper)
                : null,
          ),
        ),
      ),
    );
  }
}

/// Bileşen adı sorar; boş ya da vazgeçilirse `null`.
Future<String?> _askPartName(BuildContext context) =>
    textInputDialog(context, title: 'Bileşen ekle', hint: 'Örn. turşu');

/// "Tabak ekle" alt sayfası. [kinds] mekânın türüne göre gelen tabak
/// türleri; [previous] bu mekânda daha önce tadılanlar (en son hâliyle);
/// [highlights] yorum analizinde öne çıkan ürünler (aramadan gelindiyse).
Future<TastedDish?> showAddDishSheet(
  BuildContext context, {
  required List<DishKind> kinds,
  List<TastedDish> previous = const [],
  List<String> highlights = const [],
}) => showModalBottomSheet<TastedDish>(
  useRootNavigator: true,
  context: context,
  isScrollControlled: true,
  backgroundColor: context.colors.paper,
  barrierColor: context.colors.scrim,
  shape: Border(top: BorderSide(color: context.colors.ink, width: 2)),
  builder: (_) =>
      _AddDishSheet(kinds: kinds, previous: previous, highlights: highlights),
);

class _AddDishSheet extends StatefulWidget {
  const _AddDishSheet({
    required this.kinds,
    required this.previous,
    required this.highlights,
  });

  final List<DishKind> kinds;
  final List<TastedDish> previous;
  final List<String> highlights;

  @override
  State<_AddDishSheet> createState() => _AddDishSheetState();
}

class _AddDishSheetState extends State<_AddDishSheet> {
  final _name = TextEditingController();
  late DishKind _kind = widget.kinds.first;
  late List<String> _parts = [..._kind.parts];

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Türler: mekânın türlerine, daha önce burada tadılanların türü de
  /// eklenir (burgercide tatlı yemişsen tatlı da çıkar).
  List<DishKind> get _kinds {
    final extra = [
      for (final d in widget.previous)
        if (!widget.kinds.contains(d.kind)) d.kind,
    ];
    final all = [...widget.kinds.where((k) => k != DishKind.other), ...extra];
    return [
      ...{...all},
      DishKind.other,
    ];
  }

  void _pickKind(DishKind kind) => setState(() {
    _kind = kind;
    _parts = [...kind.parts];
  });

  /// Daha önce tadılan tabak seçilince türü ve bileşenleri de gelir.
  void _pickPrevious(TastedDish d) => setState(() {
    _name.text = d.name;
    _kind = d.kind;
    _parts = [for (final p in d.parts) p.name];
  });

  void _pickHighlight(String name) => setState(() => _name.text = name);

  Future<void> _addPart() async {
    final name = await _askPartName(context);
    if (name != null) setState(() => _parts = [..._parts, name]);
  }

  void _submit() => Navigator.of(context).pop(
    TastedDish(
      name: _name.text.trim(),
      kind: _kind,
      parts: [for (final p in _parts) DishPart(p)],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = context.colors;
    final previousKeys = {for (final d in widget.previous) d.key};
    final highlights = [
      for (final h in widget.highlights)
        if (!previousKeys.contains(normalizeForMatch(h))) h,
    ];

    Widget chips(List<(String, bool, VoidCallback)> items) => Wrap(
      spacing: Space.s,
      runSpacing: Space.s,
      children: [
        for (final (label, selected, onTap) in items)
          ChoiceBox(label: label, selected: selected, onTap: onTap),
      ],
    );

    final typed = normalizeForMatch(_name.text);
    return Padding(
      // Klavye açılınca sayfa yukarı kalkar.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Space.l,
            Space.xl,
            Space.l,
            Space.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Tabak ekle', style: text.headlineMedium),
              const SizedBox(height: Space.xl),
              Field(
                label: 'Tabağın adı',
                controller: _name,
                placeholder: 'Örn. klasik burger',
              ),
              if (widget.previous.isNotEmpty) ...[
                const Eyebrow('Burada daha önce tattıkların'),
                const SizedBox(height: Space.s),
                chips([
                  for (final d in widget.previous)
                    (d.name, d.key == typed, () => _pickPrevious(d)),
                ]),
                const SizedBox(height: Space.l),
              ],
              if (highlights.isNotEmpty) ...[
                const Eyebrow('Yorumlarda öne çıkanlar'),
                const SizedBox(height: Space.s),
                chips([
                  for (final h in highlights)
                    (h, normalizeForMatch(h) == typed, () => _pickHighlight(h)),
                ]),
                const SizedBox(height: Space.l),
              ],
              const SizedBox(height: Space.s),
              const Eyebrow('Türü'),
              Text(
                'Türe göre bileşenler hazır gelir; istediğini çıkarır, '
                'kendininkini eklersin.',
                style: text.bodySmall,
              ),
              const SizedBox(height: Space.m),
              chips([
                for (final k in _kinds)
                  (k.label, k == _kind, () => _pickKind(k)),
              ]),
              const SizedBox(height: Space.xl),
              const Eyebrow('Puanlayacağın bileşenler'),
              if (_parts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Space.s),
                  child: Text(
                    'Bileşen yok; yalnızca tabağın geneli puanlanır.',
                    style: text.bodySmall,
                  ),
                ),
              for (final (i, part) in _parts.indexed)
                Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: colors.line)),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(part, style: text.bodyMedium)),
                      IconButton(
                        tooltip: '$part bileşenini çıkar',
                        onPressed: () =>
                            setState(() => _parts = [..._parts]..removeAt(i)),
                        icon: GurmeIcon(
                          GurmeGlyph.close,
                          size: 16,
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              LinkLabel('Kendi bileşenini ekle', onTap: _addPart),
              const SizedBox(height: Space.l),
              SaveButton(
                'Tabağı ekle',
                onPressed: _submit,
                missing: _name.text.trim().isEmpty
                    ? 'Tabağın adını yaz.'
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
