import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'gurme_icons.dart';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../theme/gurme_colors.dart';
import '../theme/gurme_space.dart';

export '../theme/gurme_space.dart';

/// Expo uygulamasındaki `components/Editorial.tsx` bileşenlerinin karşılığı.

/// Kaydırılabilir sayfa: üstte [Masthead], altında `Space.l` kenar boşluklu içerik.
class GurmePage extends StatelessWidget {
  const GurmePage({super.key, required this.children, this.masthead});

  final List<Widget> children;
  final Masthead? masthead;

  /// Satırların rahat okunduğu en geniş içerik.
  static const readableWidth = 640.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, box) {
            // iPad'de ve yatay ekranda içerik okunur genişlikte ortalanır.
            final side = Space.l + max(0.0, (box.maxWidth - readableWidth) / 2);
            return CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(child: masthead ?? const Masthead()),
                // Satırlar göründükçe çizilir; uzun arşivde hepsi bir
                // anda kurulmaz.
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(side, 0, side, Space.xxxl),
                  sliver: SliverList.list(children: children),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Ortada "GURME" yazan üst şerit; isteğe bağlı geri ve sağ düğme.
class Masthead extends StatelessWidget {
  const Masthead({
    super.key,
    this.back = false,
    this.rightIcon,
    this.rightFilled = false,
    this.rightTooltip,
    this.onRight,
    this.logo = true,
  });

  final bool back;

  /// "GURME" yazısı. Liste–ayrıntı düzeninin ayrıntı sütununda yazılmaz;
  /// ekranda logo bir kez durur.
  final bool logo;
  final GurmeGlyph? rightIcon;

  /// Sağdaki simge dolu çizilir: açık/kapalı bir durumun "açık" hali
  /// (ör. kaydedilmiş liste).
  final bool rightFilled;
  final String? rightTooltip;
  final VoidCallback? onRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(bottom: Space.l),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.line)),
      ),
      // Çizgi tam genişlikte; düğmeler içerik sütununun kenarlarında
      // (iPad'de ekran kenarına kaçmaz).
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: GurmePage.readableWidth),
        // Tam genişlik: Stack logo kadar daralmaz, düğmeler kenarda kalır.
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Logo bir yazı değil işarettir; sistem yazı boyutuyla büyümez.
              if (logo)
                Text(
                  'GURME',
                  style: Theme.of(context).textTheme.titleLarge,
                  textScaler: TextScaler.noScaling,
                ),
              if (back)
                Positioned(
                  left: 10,
                  child: IconButton(
                    tooltip: 'Geri',
                    // iOS'ta platformun alıştığı köşeli işaret, Android'de ok.
                    icon: GurmeIcon(
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? GurmeGlyph.backChevron
                          : GurmeGlyph.back,
                      size: 21,
                    ),
                    // maybePop sayfanın PopScope kararına uyar (kaydedilmemiş
                    // form uyarısı); düz pop onu atlar.
                    onPressed: () => context.canPop()
                        ? Navigator.of(context).maybePop()
                        : context.go('/'),
                  ),
                ),
              if (rightIcon != null)
                Positioned(
                  right: 10,
                  child: IconButton(
                    tooltip: rightTooltip,
                    icon: GurmeIcon(rightIcon!, size: 22, filled: rightFilled),
                    onPressed: onRight,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Küçük etiket: alan adı ya da üst bilgi ("Moda · Kahve"). Cümle
/// düzeninde ve soluk; bölüm başlığı için [SectionTitle] kullanılır.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall!;
    return Text(
      text,
      style: color == null ? style : style.copyWith(color: color),
    );
  }
}

/// Kelime ortasından bölünmeyen başlık. En uzun kelime satıra sığmıyorsa
/// (büyük yazıda "Lahmacuncusu") yazı o kelime sığacak kadar küçülür;
/// sığıyorsa olduğu gibi çizilir.
class WordSafeText extends StatelessWidget {
  const WordSafeText(
    this.data, {
    super.key,
    required this.style,
    this.maxLines,
    this.textAlign,
  });

  final String data;
  final TextStyle style;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        var widest = 0.0;
        for (final word in data.split(RegExp(r'\s+'))) {
          final painter = TextPainter(
            text: TextSpan(text: word, style: style),
            textDirection: TextDirection.ltr,
            textScaler: scaler,
            maxLines: 1,
          )..layout();
          if (painter.width > widest) widest = painter.width;
          painter.dispose();
        }
        // Yazı ölçümü ile satır kırma aynı yuvarlamayı yapmıyor: kelime
        // sınırın tam üstüne kurulunca son harf alta düşüyordu ("Kaydedile /
        // n"). Küçültme bir piksel pay bırakır.
        final room = box.maxWidth - 1;
        final fits = !box.maxWidth.isFinite || widest <= room;
        return Text(
          data,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: maxLines == null ? null : TextOverflow.ellipsis,
          textScaler: fits
              ? scaler
              : TextScaler.linear(scaler.scale(1) * room / widest * 0.98),
        );
      },
    );
  }
}

/// Sayfa başlığı: ekran okuyucuda başlık olarak işaretlidir; başlıklar
/// arasında gezinilebilir. Varsayılan stil `headlineLarge`.
class PageTitle extends StatelessWidget {
  const PageTitle(this.data, {super.key, this.style});

  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    // Kendi düğümü: çevresindeki metinle tek bir başlığa karışmaz.
    container: true,
    child: WordSafeText(
      data,
      style: style ?? Theme.of(context).textTheme.headlineLarge!,
    ),
  );
}

/// Bölüm başlığı: Bodoni, solda; sağda isteğe bağlı küçük bir ek.
/// Bölümler arasındaki ayrımı çizgi ya da numara değil, boşluk yapar.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final heading = Semantics(
      header: true,
      container: true,
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
    return Padding(
      padding: const EdgeInsets.only(top: Space.xxxl, bottom: Space.s),
      // Sığmazsa ek alt satıra iner; başlık kelime ortasından bölünmez.
      child: trailing == null
          ? heading
          : SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Space.m,
                children: [heading, trailing!],
              ),
            ),
    );
  }
}

/// Dokunulabilir, mürekkep renkli bağlantı ("Listeye ekle"). Dokunma alanı
/// en az 44 pt.
class LinkLabel extends StatelessWidget {
  const LinkLabel(this.text, {super.key, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          // widthFactor 1: bağlantı yalnızca yazısı kadar yer kaplar.
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1,
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                decoration: TextDecoration.underline,
                // Alt çizgi gece de görünür (control: zeminde en az 3:1).
                decorationColor: context.colors.control,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Formun sonundaki silme eylemi: ana düğmeyle yarışmasın diye küçük,
/// ortalanmış ve hata renginde. Onay penceresi çağıran tarafta açılır.
class DangerLink extends StatelessWidget {
  const DangerLink(this.label, {super.key, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Space.xl),
      child: Center(
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: context.colors.error,
            minimumSize: const Size(0, 44),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: onPressed == null
                  ? context.colors.muted
                  : context.colors.error,
            ),
          ),
        ),
      ),
    );
  }
}

/// Formun içindeki bir parçayı çıkaran eylem ("Fotoğrafı kaldır", "Tabağı
/// çıkar"): sola yaslı, `error` renkli; dokunma alanı 44 pt. Formun
/// tamamını silen eylem ortalanmış [DangerLink]'tir.
class RemoveLink extends StatelessWidget {
  const RemoveLink(this.label, {super.key, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: context.colors.error,
          minimumSize: const Size(0, 44),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge!
              .copyWith(color: context.colors.error),
        ),
      ),
    );
  }
}

class Rule extends StatelessWidget {
  const Rule({super.key, this.space = Space.xl});

  final double space;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: space),
      child: Container(
        height: 1,
        color: context.colors.line.withValues(alpha: 0.75),
      ),
    );
  }
}

/// Altın (birincil) ya da çerçeveli (ikincil) düğme; yazı cümle düzeninde.
class ActionButton extends StatelessWidget {
  const ActionButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon,
    this.brandIcon,
    this.secondary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final GurmeGlyph? icon;

  /// Marka simgesi (Apple, Google); kendi setimizde yoktur.
  final IconData? brandIcon;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final role = Theme.of(context).textTheme.labelLarge!;
    final text = Text(
      label,
      // Renk düğmeden gelir (altın zeminde koyu, devre dışıyken soluk);
      // bu yüzden rolün yalnızca yazı tipi alınır, rengi alınmaz.
      style: TextStyle(
        fontFamily: role.fontFamily,
        fontSize: role.fontSize,
        fontWeight: role.fontWeight,
        height: role.height,
        fontFeatures: role.fontFeatures,
      ),
    );
    final child = icon == null && brandIcon == null
        ? text
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                GurmeIcon(
                  icon!,
                  size: MediaQuery.textScalerOf(context).scale(20),
                )
              else
                Icon(
                  brandIcon,
                  size: MediaQuery.textScalerOf(context).scale(18),
                ),
              const SizedBox(width: Space.s),
              Flexible(child: text),
            ],
          );
    return secondary
        ? OutlinedButton(onPressed: onPressed, child: child)
        : FilledButton(onPressed: onPressed, child: child);
  }
}

/// Formun kayıt düğmesi. [missing] verilirse (eksik gerekli alan) düğme
/// pasiftir ve altında nedeni yazar; hata, uyarı penceresine düşmeden
/// önlenir.
class SaveButton extends StatelessWidget {
  const SaveButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.missing,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? missing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionButton(label, onPressed: missing == null ? onPressed : null),
        if (missing != null) ...[
          const SizedBox(height: Space.s),
          Text(
            missing!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// Başlıklı, alt çizgili metin alanı.
class Field extends StatelessWidget {
  const Field({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.multiline = false,
    this.onChanged,
    this.footer,
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final bool multiline;
  final ValueChanged<String>? onChanged;

  /// Alanın hemen altında: öneriler ya da kısa bir uyarı.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Eyebrow(label),
          TextField(
            controller: controller,
            onChanged: onChanged,
            minLines: multiline ? 3 : 1,
            maxLines: multiline ? 8 : 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: placeholder,
              // Örnek italik: girilmiş metinle karışmaz.
              hintStyle: TextStyle(
                color: context.colors.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (footer case final footer?) ...[
            const SizedBox(height: Space.s),
            footer,
          ],
        ],
      ),
    );
  }
}

/// Boş durum: altın çizgi, başlık, açıklama ve isteğe bağlı düğme.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.detail,
    this.action,
    this.onPressed,
    this.icon = GurmeGlyph.add,
    this.secondary = false,
  });

  final String title;
  final String detail;
  final String? action;
  final VoidCallback? onPressed;

  /// Düğme simgesi; "Tekrar dene" gibi ekleme olmayan eylemlerde `null`.
  final GurmeGlyph? icon;

  /// Ekranda zaten bir altın ana eylem varsa (ör. "Ara") düğme ikincil
  /// çizilir; ekran başına tek altın düğme.
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.headlineMedium),
          const SizedBox(height: Space.s),
          Text(
            detail,
            style: text.bodyMedium!.copyWith(color: context.colors.muted),
          ),
          if (action != null && onPressed != null) ...[
            const SizedBox(height: Space.xl),
            SizedBox(
              width: double.infinity,
              child: ActionButton(
                action!,
                icon: icon,
                secondary: secondary,
                onPressed: onPressed,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kullanıcı yazıyı belirgin biçimde büyüttüyse `true`; yan yana duran
/// kontroller o zaman alt alta dizilir.
bool largeText(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(10) > 12;

/// Yan yana eşit genişlikte seçenekler; seçili olan koyu zeminli.
class SegmentRow<T> extends StatelessWidget {
  const SegmentRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.isSelected,
  });

  final List<(T, String)> options;
  final T? selected;
  final ValueChanged<T> onSelected;

  /// Varsayılan `value == selected`; birden çok seçim için verilir.
  final bool Function(T value)? isSelected;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        // Önce yan yana. Sığmazsa yine yan yana ama sıkışık: dar kenar ve
        // aralık (telefonda "Beğendim / Fena değil / Beğenmedim" böyle sığar).
        // Yazı büyükse ya da o da sığmazsa alt alta: yazı küçültülmez,
        // kelime bölünmez.
        final large = largeText(context);
        final roomy = !large && _wordsFit(context, box.maxWidth, false);
        final compact =
            !large && !roomy && _wordsFit(context, box.maxWidth, true);
        if (!roomy && !compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, (value, label)) in options.indexed) ...[
                if (index > 0) const SizedBox(height: Space.s),
                ChoiceBox(
                  label: label,
                  selected: isSelected?.call(value) ?? value == selected,
                  onTap: () => onSelected(value),
                ),
              ],
            ],
          );
        }
        // Eşit yükseklik: iki satıra inen seçenek komşularını da uzatır.
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, (value, label)) in options.indexed) ...[
                if (index > 0) SizedBox(width: _gap(compact)),
                Expanded(
                  child: ChoiceBox(
                    label: label,
                    selected: isSelected?.call(value) ?? value == selected,
                    onTap: () => onSelected(value),
                    compact: compact,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Kutular arası boşluk; sıkışık düzende daha dar.
  static double _gap(bool compact) => compact ? Space.xs : Space.s;

  /// Her etiketin en uzun kelimesi, yan yana dizilince kutunun yazı alanına
  /// (kenar boşlukları ve onay işareti düşülmüş) sığıyor mu?
  bool _wordsFit(BuildContext context, double width, bool compact) {
    if (!width.isFinite) return true;
    final scaler = MediaQuery.textScalerOf(context);
    final style = ChoiceBox.labelStyle(context);
    final cell =
        (width - _gap(compact) * (options.length - 1)) / options.length;
    final room = cell - ChoiceBox.chrome(scaler, compact: compact);
    for (final (_, label) in options) {
      for (final word in label.split(' ')) {
        final painter = TextPainter(
          text: TextSpan(text: word, style: style),
          textDirection: TextDirection.ltr,
          textScaler: scaler,
          maxLines: 1,
        )..layout();
        final wide = painter.width;
        painter.dispose();
        if (wide > room) return false;
      }
    }
    return true;
  }
}

/// Tek seçenek kutusu. Seçiliyken mürekkep zemin, kalın kenar ve onay
/// işareti; seçim yalnızca renkle anlatılmaz.
class ChoiceBox extends StatelessWidget {
  const ChoiceBox({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.center = true,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool center;

  /// Dar yer için: kenar boşluğu küçük (telefonda üç seçenek yan yana).
  final bool compact;

  /// Etiketin yazı stili (renksiz); SegmentRow ölçerken de kullanır.
  static TextStyle labelStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!
          .copyWith(fontWeight: FontWeight.w600);

  /// Yazı dışındaki genişlik: kenar boşlukları ve kenar çizgisi.
  static double chrome(TextScaler scaler, {bool compact = false}) =>
      2 * (compact ? Space.xs : Space.m) + 2 * 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Seçili kutu iki temada da `chosen` renkli dolu blok: gündüz mürekkep,
    // gece puan kareleriyle aynı turkuaz. Seçim dolguyla ve yazı rengiyle
    // anlatılır; onay işareti yok.
    final fill = selected ? colors.chosen : colors.paper;
    // Seçili blokta yazı iki temada da kâğıt rengi: gündüz mürekkep üstünde
    // açık, gece turkuaz üstünde koyu.
    final foreground = selected ? colors.paper : colors.ink;
    // Seçili kutu iki temada da dolu bir blok: kenarı zeminiyle aynı renk.
    final edge = selected ? colors.chosen : null;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? Space.xs : Space.m,
            vertical: Space.s,
          ),
          decoration: BoxDecoration(
            color: fill,
            border: edge != null
                ? Border.all(color: edge, width: 2)
                : Border.all(color: context.colors.control),
          ),
          // Sıkı genişlikte (SegmentRow) ortalanır; serbest genişlikte
          // (Wrap, yatay kaydırma) yazı kadar yer kaplar.
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: center
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  // Gece seçili blokta koyu yazı açık zeminde ince görünür;
                  // seçim bir kademe kalın yazılır. Genişlik ölçüsü w600 ile
                  // yapıldığından kalın hâl kutuya yine sığar (Flexible).
                  style: labelStyle(context).copyWith(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w700 : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Yatay kaydırılan seçenek şeridi. Sağda görünmeyen seçenek varsa kenar
/// solar: kesik kutu "devamı var" diye okunur, hata gibi durmaz. Sona
/// gelince solma kalkar.
class ChoiceStrip extends StatefulWidget {
  const ChoiceStrip({super.key, required this.children});

  final List<Widget> children;

  @override
  State<ChoiceStrip> createState() => _ChoiceStripState();
}

class _ChoiceStripState extends State<ChoiceStrip> {
  var _more = false;

  bool _update(ScrollMetrics metrics) {
    final more = metrics.extentAfter > 1;
    if (more != _more) setState(() => _more = more);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final strip = NotificationListener<ScrollMetricsNotification>(
      onNotification: (n) => _update(n.metrics),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) => _update(n.metrics),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final (i, child) in widget.children.indexed) ...[
                if (i > 0) const SizedBox(width: Space.s),
                child,
              ],
            ],
          ),
        ),
      ),
    );
    // Maske her zaman ağaçta kalır, yalnızca rengi değişir. Maske eklenip
    // kaldırılınca kaydırma alanı yeniden kuruluyordu: sürükleme kesiliyor
    // ve şerit başa dönüyordu.
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      // Kenarın son 12 pt'si tamamen saydam, öncesi 64 pt boyunca solar:
      // kesilen kutu harf ortasından sert bir çizgiyle bitmez, yazısı
      // giderek kaybolur ve devamı olduğu anlaşılır.
      shaderCallback: (rect) {
        double at(double pt) => (1 - pt / rect.width).clamp(0.0, 1.0);
        final edge = _more ? Colors.transparent : Colors.black;
        return LinearGradient(
          colors: [Colors.black, Colors.black, edge, edge],
          stops: [0, at(76), at(12), 1],
        ).createShader(rect);
      },
      child: strip,
    );
  }
}

/// Yatay kaydırılan filtre seçenekleri; ilki "Tümü" (boş değer).
class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.title,
    required this.choices,
    required this.selected,
    required this.onSelected,
    this.allLabel = 'Tümü',
  });

  final String title;
  final List<String> choices;
  final String selected;
  final ValueChanged<String> onSelected;

  /// Boş değerin etiketi.
  final String allLabel;

  @override
  Widget build(BuildContext context) {
    final all = [('', allLabel), for (final c in choices) (c, c)];
    return Padding(
      padding: const EdgeInsets.only(top: Space.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(title),
          const SizedBox(height: Space.s),
          ChoiceStrip(
            children: [
              for (final (value, label) in all)
                ChoiceBox(
                  label: label,
                  selected: selected == value,
                  onTap: () => onSelected(value),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Defter kenarı: kullanıcının kendi yazdığı metnin solunda, okul
/// defterindeki gibi çift ince altın çizgi. Yalnızca kullanıcının sözleri
/// için kullanılır; uygulamanın kendi metinleri bu çizgiyi taşımaz.
class MarginNote extends StatelessWidget {
  const MarginNote({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 1, color: context.colors.gold),
          const SizedBox(width: 2),
          Container(width: 1, color: context.colors.gold),
          const SizedBox(width: Space.m),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Başlıklı kullanıcı notu ("Neden bu listede?"), defter kenarıyla.
class NoteQuote extends StatelessWidget {
  const NoteQuote({super.key, required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Space.m, bottom: Space.s),
      child: MarginNote(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(title),
            const SizedBox(height: Space.xs),
            Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// Bilgi kutusu: kısa açıklama ve isteğe bağlı tek eylem (ipucu notlarıyla
/// aynı yüzey).
class HintBox extends StatelessWidget {
  const HintBox({super.key, required this.text, this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final hasAction = action != null && onAction != null;
    return Container(
      // Bağlantının kendi dokunma alanı alt boşluğu doldurur.
      padding: EdgeInsets.fromLTRB(
        Space.m,
        Space.m,
        Space.m,
        hasAction ? Space.xs : Space.m,
      ),
      color: context.colors.wash,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
          if (hasAction) LinkLabel(action!, onTap: onAction!),
        ],
      ),
    );
  }
}

/// Boşluklu iki ucu hizalı satır.
class SpacedRow extends StatelessWidget {
  const SpacedRow({super.key, required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: left),
        const SizedBox(width: Space.m),
        right,
      ],
    );
  }
}

/// Yükleniyor yer tutucusu (gri blok).
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({super.key, this.height = 76, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: width,
    margin: const EdgeInsets.only(top: Space.l),
    color: context.colors.wash,
  );
}

/// Alt bilgi çubuğunda kısa bir onay ("Deneyim kaydedildi.").
/// [messenger] sayfa değişmeden önce alınır; çubuk yeni sayfada da görünür.
void showNotice(ScaffoldMessengerState messenger, String message) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Geri alınabilir bir eylemden sonra "Geri al" düğmeli bilgi çubuğu.
void showUndo(
  ScaffoldMessengerState messenger,
  String message,
  VoidCallback onUndo,
) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        // Okuyup karar vermeye yetecek kadar; ekran okuyucu açıkken
        // Flutter çubuğu kendiliğinden kapatmaz.
        duration: const Duration(seconds: 10),
        action: SnackBarAction(label: 'Geri al', onPressed: onUndo),
      ),
    );
}

/// Onay penceresi. Onaylanırsa `true`.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirm = 'Sil',
  String cancel = 'Vazgeç',
  bool destructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      backgroundColor: context.colors.paper,
      shape: const RoundedRectangleBorder(),
      title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      content: Text(message),
      actions: [
        _DialogAction(
          label: cancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        _DialogAction(
          label: confirm,
          destructive: destructive,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Tek düğmeli bilgi penceresi.
Future<void> infoDialog(
  BuildContext context, {
  required String title,
  required String message,
}) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog.adaptive(
    backgroundColor: context.colors.paper,
    shape: const RoundedRectangleBorder(),
    title: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    content: Text(message),
    actions: [
      _DialogAction(
        label: 'Tamam',
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  ),
);

/// Tek satırlık metin soran pencere; vazgeçilir ya da boş bırakılırsa
/// `null`.
Future<String?> textInputDialog(
  BuildContext context, {
  required String title,
  String hint = '',
  String confirm = 'Ekle',
}) async {
  final result = await showDialog<String>(
    context: context,
    builder: (_) =>
        _TextInputDialog(title: title, hint: hint, confirm: confirm),
  );
  final trimmed = result?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

/// Metin denetleyicisi pencerenin kendi durumundadır: pencere kapanış
/// animasyonu bitip ağaçtan kalkınca silinir. Çağıranın silmesi, kapanış
/// sırasında hâlâ çizilen alanı bozar.
class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.hint,
    required this.confirm,
  });

  final String title;
  final String hint;
  final String confirm;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      backgroundColor: context.colors.paper,
      shape: const RoundedRectangleBorder(),
      title: Text(
        widget.title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      // iOS penceresinde de Material metin alanı: Material ata gerekir.
      content: Material(
        type: MaterialType.transparency,
        child: TextField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: context.colors.muted),
          ),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
      ),
      actions: [
        _DialogAction(
          label: 'Vazgeç',
          onPressed: () => Navigator.of(context).pop(),
        ),
        _DialogAction(
          label: widget.confirm,
          onPressed: () => Navigator.of(context).pop(_controller.text),
        ),
      ],
    );
  }
}

/// İki haneli sıra numarası ("01"). Yalnızca sıranın anlam taşıdığı yerde
/// (rota durakları) kullanılır.
String ordinal(int n) => n.toString().padLeft(2, '0');

/// Pencere düğmesi: iOS'ta sistemin kendi düğmesi, Android'de metin düğmesi.
class _DialogAction extends StatelessWidget {
  const _DialogAction({
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return CupertinoDialogAction(
        isDestructiveAction: destructive,
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return TextButton(
      style: destructive
          ? TextButton.styleFrom(foregroundColor: context.colors.error)
          : null,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
