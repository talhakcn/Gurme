import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/platform/external.dart';
import '../../../core/theme/gurme_colors.dart';
import '../../../core/widgets/editorial.dart';
import '../../../core/widgets/gurme_icons.dart';
import '../data/journal_models.dart';
import '../data/journal_notifier.dart';
import 'taste_mark.dart';
import '../../../core/widgets/motion.dart';

/// Defterdeki bir fotoğraf. Dosya kaybolduysa boş bir yüzey gösterir.
/// Testler için: verilirse fotoğraf dosyadan okunmaz, bu kaynaktan gelir.
/// Widget testlerinde dosyadan yükleme "sahte zaman" içinde hiç bitmediği
/// için ekran görüntüsü testleri önceden çözülmüş görselleri buradan verir.
final photoImageOverrideProvider =
    Provider<ImageProvider Function(String path)?>((ref) => null);

/// Liste–ayrıntı düzeni: altındaki mekân satırları dokununca sayfa açmaz,
/// mekânı yandaki sütunda seçer.
class PlaceSelection extends InheritedWidget {
  const PlaceSelection({
    super.key,
    required this.selectedId,
    required this.onSelect,
    required super.child,
  });

  final String? selectedId;
  final ValueChanged<String> onSelect;

  static PlaceSelection? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PlaceSelection>();

  @override
  bool updateShouldNotify(PlaceSelection old) =>
      old.selectedId != selectedId || old.onSelect != onSelect;
}

/// Gece fotoğrafların üstüne binen hafif karartma; gündüz `null`.
Color? nightPhotoDim(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0x24000000)
    : null;

class JournalPhoto extends ConsumerWidget {
  const JournalPhoto(this.path, {super.key, this.height, this.width});

  final String path;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget broken(BuildContext context, Object error, StackTrace? stack) =>
        Container(
          height: height,
          width: width ?? double.infinity,
          color: context.colors.wash,
          alignment: Alignment.center,
          child: GurmeIcon(GurmeGlyph.image, color: context.colors.muted),
        );
    // Gece fotoğraf biraz kısılır; koyu zeminde parlak bir delik olmaz.
    final dim = nightPhotoDim(context);
    if (ref.watch(photoImageOverrideProvider) case final override?) {
      return Image(
        image: override(path),
        color: dim,
        colorBlendMode: BlendMode.srcATop,
        height: height,
        width: width ?? double.infinity,
        fit: BoxFit.cover,
        errorBuilder: broken,
      );
    }
    return Image.file(
      ref.watch(photoStoreProvider).resolve(path),
      color: dim,
      colorBlendMode: BlendMode.srcATop,
      height: height,
      width: width ?? double.infinity,
      fit: BoxFit.cover,
      // Gösterildiği boyutta çözülür; 64 pt'lik satır fotoğrafı için
      // tam boy görsel belleğe alınmaz.
      cacheWidth:
          ((width ?? MediaQuery.sizeOf(context).width) *
                  MediaQuery.devicePixelRatioOf(context))
              .round(),
      errorBuilder: broken,
    );
  }
}

/// Mekân satırı; dokununca mekân sayfası açılır. Karnesi varsa adın
/// yanında küçük lezzet izi, fotoğrafı varsa sağda küçük hali görünür.
/// [index] yalnızca sırayla belirme içindir.
class PlaceRow extends ConsumerWidget {
  const PlaceRow({
    super.key,
    required this.place,
    this.index = 1,
    this.onTap,
    this.meta,
    this.footer,
  });

  final Place place;
  final int index;
  final VoidCallback? onTap;

  /// Satırın altındaki küçük bilgi ("Gidildi · 2 deneyim").
  final String? meta;

  /// Satırın içinde, ayırıcı çizginin üstünde duran ek (durak notu).
  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final visits = ref.watch(journalDataProvider).visitsFor(place.id);
    final mark = TastingScores.averageOf([for (final v in visits) v.scores]);
    final averages = [for (final v in visits) ?v.scores.average];
    final average = averages.isEmpty
        ? null
        : averages.reduce((a, b) => a + b) / averages.length;
    final where = [
      place.district,
      place.category,
    ].where((s) => s.isNotEmpty).join(' · ');
    final selection = PlaceSelection.maybeOf(context);
    final selected = selection?.selectedId == place.id;
    return Reveal(
      index: index - 1,
      child: Semantics(
        selected: selection == null ? null : selected,
        child: InkWell(
          onTap:
              onTap ??
              (selection != null
                  ? () => selection.onSelect(place.id)
                  : () => context.push('/place/${place.id}')),
          onLongPress: () => showPlaceActions(context, place),
          child: Container(
            // Satır, içeriği kısa olsa da tam genişlikte: alt çizgi yarıda
            // kalmaz.
            width: double.infinity,
            // Liste–ayrıntı düzeninde seçili satır soluk zeminle ve solda
            // mürekkep çizgiyle belli olur; yazı kaymasın diye her satır aynı
            // iç boşluğu taşır.
            padding: selection == null
                ? const EdgeInsets.symmetric(vertical: Space.l)
                : const EdgeInsets.fromLTRB(Space.m, Space.l, Space.s, Space.l),
            decoration: BoxDecoration(
              color: selected ? context.colors.wash : null,
              border: Border(
                bottom: BorderSide(color: context.colors.line),
                left: selection == null
                    ? BorderSide.none
                    : BorderSide(
                        color: selected
                            ? context.colors.ink
                            : Colors.transparent,
                        width: 3,
                      ),
              ),
            ),
            // Satırda kapak yok: liste ad ve izle taranır, görsel mekân
            // sayfasında.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Uzun basma görünmez; aynı menü satırdaki düğmeyle de açılır.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: WordSafeText(
                        place.name,
                        style: text.headlineSmall!,
                      ),
                    ),
                    SizedBox.square(
                      dimension: 44 * iconScale(context),
                      child: IconButton(
                        tooltip: 'Diğer eylemler',
                        padding: EdgeInsets.zero,
                        onPressed: () => showPlaceActions(context, place),
                        icon: GurmeIcon(
                          GurmeGlyph.more,
                          size: 20,
                          color: context.colors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
                // İz ve puan adın altında, hep aynı yerde: ad iki satıra
                // inse de kaymaz. Puan ölçeğiyle yazılır.
                if (!mark.isEmpty || where.isNotEmpty)
                  Wrap(
                    spacing: Space.s,
                    runSpacing: Space.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (!mark.isEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Kesin ortalamalar: ipucu ve ekran okuyucu mekân
                            // sayfasıyla aynı sayıyı söyler ("Servis 2,5").
                            TasteMark(
                              mark,
                              exact: TastingScores.meansOf([
                                for (final v in visits) v.scores,
                              ]),
                            ),
                            if (average != null) ...[
                              const SizedBox(width: Space.xs),
                              // İz küçük; bilgiyi yanındaki metin taşır.
                              // Sığmazsa alt satıra iner.
                              Flexible(
                                child: Text(
                                  [
                                    '${formatScore(average)} / 5',
                                    if (mark.strongest case final s?)
                                      'en iyi: $s',
                                  ].join(' · '),
                                  style: text.bodySmall,
                                ),
                              ),
                            ],
                          ],
                        ),
                      if (where.isNotEmpty) Eyebrow(where),
                    ],
                  ),
                if (place.description.isNotEmpty) ...[
                  const SizedBox(height: Space.s),
                  Text(
                    place.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium,
                  ),
                ],
                if (meta case final meta?) ...[
                  const SizedBox(height: Space.xs),
                  Text(meta, style: text.bodySmall),
                ],
                ?footer,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mekân satırına uzun basınca açılan kısa menü.
Future<void> showPlaceActions(BuildContext context, Place place) {
  HapticFeedback.mediumImpact();
  final router = GoRouter.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final where = place.address.isNotEmpty
      ? place.address
      : [place.name, place.area].where((s) => s.isNotEmpty).join(', ');
  return showModalBottomSheet<void>(
    // Kök gezginde: perde sekme çubuğunu da örter.
    useRootNavigator: true,
    // Büyük yazıda ekranın yarısını aşarsa kaydırılır.
    isScrollControlled: true,
    context: context,
    backgroundColor: context.colors.paper,
    barrierColor: context.colors.scrim,
    shape: Border(top: BorderSide(color: context.colors.ink, width: 2)),
    builder: (sheet) {
      final text = Theme.of(sheet).textTheme;
      Widget action(
        GurmeGlyph icon,
        String label,
        VoidCallback run, {
        Color? color,
      }) => ListTile(
        leading: GurmeIcon(icon, size: 22, color: color ?? context.colors.ink),
        title: Text(label, style: text.bodyLarge!.copyWith(color: color)),
        minTileHeight: 52,
        onTap: () {
          Navigator.of(sheet).pop();
          run();
        },
      );
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: Space.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.l,
                  Space.s,
                  Space.l,
                  Space.s,
                ),
                child: Text(place.name, style: text.headlineSmall),
              ),
              action(
                GurmeGlyph.write,
                'Deneyim ekle',
                () => router.push('/place/${place.id}/visit/new'),
              ),
              action(
                GurmeGlyph.listAdd,
                'Listeye ekle',
                () => showListPicker(context, place),
              ),
              action(GurmeGlyph.map, 'Haritada aç', () async {
                if (!await openInMaps(where)) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Harita açılamadı.')),
                  );
                }
              }),
              action(
                GurmeGlyph.edit,
                'Mekânı düzenle',
                () => router.push('/place/${place.id}/edit'),
              ),
              // Kaydırmanın yaptıkları burada da görünür: hareket bilinmese
              // de eylem bulunur.
              action(
                GurmeGlyph.check,
                place.status == PlaceStatus.went
                    ? 'Gideceğim olarak işaretle'
                    : 'Gittim olarak işaretle',
                () => togglePlaceStatus(context, place),
              ),
              action(GurmeGlyph.close, 'Sil', () async {
                if (await confirmPlaceDelete(context, place) &&
                    context.mounted) {
                  deletePlaceWithUndo(context, place);
                }
              }, color: context.colors.error),
              // Açık bir çıkış: perdeye dokunmayı ya da aşağı çekmeyi
              // bilmeyen de menüyü kapatır.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.l,
                  Space.s,
                  Space.l,
                  0,
                ),
                child: ActionButton(
                  'Vazgeç',
                  secondary: true,
                  onPressed: () => Navigator.of(sheet).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Mekânı listelere ekleyip çıkaran alttan açılan sayfa.
Future<void> showListPicker(BuildContext context, Place place) =>
    showModalBottomSheet<void>(
      // Kök gezginde: perde sekme çubuğunu da örter.
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.paper,
      barrierColor: context.colors.scrim,
      shape: Border(top: BorderSide(color: context.colors.ink, width: 2)),
      builder: (_) => _ListPicker(place: place),
    );

class _ListPicker extends ConsumerWidget {
  const _ListPicker({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(journalDataProvider).lists;
    final journal = ref.read(journalProvider.notifier);
    final text = Theme.of(context).textTheme;
    // Sayfa kapanmadan önce alınır; kapandıktan sonra bağlam kullanılamaz.
    final router = GoRouter.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.l, Space.l, Space.l, Space.m),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Listeye ekle', style: text.headlineSmall),
            Text(place.name, style: text.bodySmall),
            const SizedBox(height: Space.s),
            if (lists.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.m),
                child: Text('Henüz listen yok.', style: text.bodyMedium),
              ),
            for (final l in lists)
              CheckRow(
                label: l.title,
                checked: l.contains(place.id),
                detail: l.isPublished
                    ? 'Paylaşılan liste: düzenle ve sunucuyla eşitle'
                    : null,
                onTap: () {
                  if (l.isPublished) {
                    Navigator.of(context).pop();
                    router.push('/list/${l.id}/edit');
                  } else {
                    journal.togglePlaceInList(l.id, place.id);
                  }
                },
              ),
            LinkLabel(
              'Yeni liste oluştur',
              onTap: () {
                Navigator.of(context).pop();
                router.push('/list/new');
              },
            ),
          ],
        ),
      ),
    );
  }
}

String placeStatusLabel(Place place) {
  final status = switch (place.status) {
    PlaceStatus.want => 'Gideceğim',
    PlaceStatus.went => 'Gittim',
    null => 'İşaretlenmedi',
  };
  return place.recommended ? '$status · Öneriyorum' : status;
}

/// İşaret kutulu seçim satırı (liste seçimi).
class CheckRow extends StatelessWidget {
  const CheckRow({
    super.key,
    required this.label,
    required this.checked,
    required this.onTap,
    this.detail,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    // Ekran okuyucu "işaretli / işaretsiz" diye duyurur.
    return MergeSemantics(
      child: Semantics(
        checked: checked,
        button: true,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: Space.m),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: context.colors.line)),
            ),
            child: Row(
              children: [
                GurmeIcon(
                  checked ? GurmeGlyph.checkboxOn : GurmeGlyph.checkboxOff,
                  size: MediaQuery.textScalerOf(context).scale(22),
                  // İşaretli kutu öteki seçili öğelerle aynı renk (gece
                  // turkuaz, gündüz mürekkep).
                  color: checked ? context.colors.mark : null,
                ),
                const SizedBox(width: Space.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: text.bodyMedium),
                      if (detail != null) Text(detail!, style: text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mekân satırında kaydırma: sağa "Gittim" / "Gideceğim", sola "Sil".
/// İkisi de alttaki "Geri al" ile geri alınır.
/// Mekânı gittiklerine ya da gideceklerine taşır; "Geri al" sunar.
/// Kaydırma, uzun basma menüsü ve ekran okuyucu aynı yolu kullanır.
void togglePlaceStatus(BuildContext context, Place place) {
  final went = place.status == PlaceStatus.went;
  showUndo(
    ScaffoldMessenger.of(context),
    went
        ? '${place.name} gideceklerine taşındı.'
        : '${place.name} gittiklerine taşındı.',
    ProviderScope.containerOf(context, listen: false)
        .read(journalProvider.notifier)
        .setStatus(place.id, went ? PlaceStatus.want : PlaceStatus.went),
  );
}

/// Silmeden önceki denetim. Yayınlanmış bir listedeki mekân silinmez; önce
/// uyarılır. Deneyim yazılmış mekân onayla silinir; kaydırma kazara olabilir
/// ve deneyimler de gider. Boş kayıt onaysız silinir.
Future<bool> confirmPlaceDelete(BuildContext context, Place place) async {
  final data = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(journalDataProvider);
  if (data.lists.any((l) => l.isPublished && l.contains(place.id))) {
    await infoDialog(
      context,
      title: 'Önce paylaşılan listeden kaldır',
      message:
          'Bu mekân yayınlanmış bir listede yer alıyor. Önce listeyi '
          'düzenleyip eşitle, sonra mekânı sil.',
    );
    return false;
  }
  final visits = data.visitsFor(place.id).length;
  if (visits > 0) {
    return confirmDialog(
      context,
      title: 'Mekân silinsin mi?',
      message:
          '$visits deneyimi ve listelerdeki kaydı da silinecek. Hemen '
          'ardından geri alabilirsin.',
    );
  }
  return true;
}

void deletePlaceWithUndo(BuildContext context, Place place) => showUndo(
  ScaffoldMessenger.of(context),
  '${place.name} silindi.',
  ProviderScope.containerOf(
    context,
    listen: false,
  ).read(journalProvider.notifier).deletePlace(place.id),
);

class SwipeablePlaceRow extends ConsumerWidget {
  const SwipeablePlaceRow({
    super.key,
    required this.place,
    required this.child,
    this.peek = false,
  });

  final Place place;
  final Widget child;

  /// Satır bir kez hafifçe sağa kayıp geri döner: kaydırılabildiği
  /// görülür (yalnızca ilk satır, hareket ipucu kapatılana kadar).
  final bool peek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final went = place.status == PlaceStatus.went;
    final text = Theme.of(context).textTheme;

    Widget background(
      Color color,
      Color foreground,
      String label,
      Alignment alignment,
    ) => Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: Space.xl),
      child: Text(label, style: text.labelLarge!.copyWith(color: foreground)),
    );

    void toggleStatus() => togglePlaceStatus(context, place);
    Future<bool> canDelete() => confirmPlaceDelete(context, place);
    void delete() => deletePlaceWithUndo(context, place);

    // Kaydırma görmeyen ekran okuyucu için aynı eylemler özel eylem olarak.
    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(
          label: went ? 'Gideceğim olarak işaretle' : 'Gittim olarak işaretle',
        ): toggleStatus,
        const CustomSemanticsAction(label: 'Sil'): () async {
          if (await canDelete()) delete();
        },
      },
      child: Dismissible(
        key: ValueKey('swipe-${place.id}'),
        // Gece de koyu kalır; mürekkep gece açık renktir.
        background: background(
          context.colors.raised,
          context.colors.onRaised,
          went ? 'Gideceğim' : 'Gittim',
          Alignment.centerLeft,
        ),
        secondaryBackground: background(
          context.colors.error,
          context.colors.paper,
          'Sil',
          Alignment.centerRight,
        ),
        confirmDismiss: (direction) async {
          HapticFeedback.mediumImpact();
          if (direction == DismissDirection.startToEnd) {
            toggleStatus();
            return false; // Satır yerinde kalır, yalnızca durumu değişir.
          }
          return canDelete();
        },
        onDismissed: (_) => delete(),
        child: peek
            ? _SwipePeek(
                background: background(
                  context.colors.raised,
                  context.colors.onRaised,
                  went ? 'Gideceğim' : 'Gittim',
                  Alignment.centerLeft,
                ),
                child: child,
              )
            : child,
      ),
    );
  }
}

/// Uygulama açıkken bir kez oynar; her arşiv açılışında tekrarlanmaz.
var _peeked = false;

@visibleForTesting
void resetSwipePeek() => _peeked = false;

class _SwipePeek extends StatefulWidget {
  const _SwipePeek({required this.background, required this.child});

  final Widget background;
  final Widget child;

  @override
  State<_SwipePeek> createState() => _SwipePeekState();
}

class _SwipePeekState extends State<_SwipePeek>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_peeked || Motion.reduced(context)) return;
    _peeked = true;
    // Bekleme de hareketin içinde: ayrı bir zamanlayıcı satır kapanınca
    // ortada kalmaz.
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Önce kısa bekleme, sonra 0 → 72 pt → 0: açılıp kapanan tek hareket.
    final offset = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 35),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 72.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween(72.0), weight: 10),
      TweenSequenceItem(
        tween: Tween(
          begin: 72.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 25,
      ),
    ]).animate(_controller);
    return AnimatedBuilder(
      animation: offset,
      child: widget.child,
      builder: (context, child) => offset.value == 0
          ? child!
          : Stack(
              children: [
                Positioned.fill(child: widget.background),
                Transform.translate(
                  offset: Offset(offset.value, 0),
                  child: ColoredBox(color: context.colors.paper, child: child),
                ),
              ],
            ),
    );
  }
}
