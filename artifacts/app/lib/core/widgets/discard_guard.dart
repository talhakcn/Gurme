import 'dart:convert';

import 'package:flutter/material.dart';

import 'editorial.dart';

/// Kaydedilmemiş değişiklikle formdan çıkılırken "Değişiklikler kaybolsun
/// mu?" diye sorar. Form değişmemişse geri hareketi (iOS'ta kenardan
/// kaydırma dahil) olduğu gibi çalışır.
///
/// Kullanım: [formValues] formun bütün değerlerini düz bir listede verir;
/// metin alanları [watchFields] ile izlenir, diğer değerler `setState` ile
/// değiştiği için kendiliğinden izlenir. Kaydettikten ya da sildikten sonra
/// sayfa kapanmadan önce [markSaved] çağrılır. Sayfa [guarded] ile sarılır.
mixin DiscardGuard<T extends StatefulWidget> on State<T> {
  /// Formun değerleri: metin, sayı, bool, liste ya da `null`.
  List<Object?> get formValues;

  String? _initial;
  var _saved = false;

  String _encode() => jsonEncode(formValues);

  bool get isDirty => !_saved && _initial != null && _encode() != _initial;

  /// İlk değerler [initState] sonunda kaydedilir.
  void rememberInitialValues() => _initial = _encode();

  /// Metin alanları değişince sayfa yeniden çizilir; böylece geri hareketi
  /// her an güncel duruma göre açılır ya da kapanır.
  void watchFields(List<Listenable> fields) {
    var dirty = false;
    Listenable.merge(fields).addListener(() {
      if (!mounted || isDirty == dirty) return;
      setState(() => dirty = isDirty);
    });
  }

  void markSaved() => _saved = true;

  Widget guarded(Widget child) => PopScope(
    canPop: !isDirty,
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop) return;
      final discard = await confirmDialog(
        context,
        title: 'Değişiklikler kaybolsun mu?',
        message: 'Kaydetmediğin değişiklikler silinecek.',
        confirm: 'Kaydetmeden çık',
        cancel: 'Düzenlemeye dön',
      );
      if (!discard || !mounted) return;
      markSaved();
      Navigator.of(context).pop();
    },
    child: child,
  );
}
