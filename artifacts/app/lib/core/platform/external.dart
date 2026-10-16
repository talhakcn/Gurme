import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sistem paylaşım penceresini açar. iPad'de pencere [context] öğesinin
/// yanında açılır.
Future<void> shareLink(BuildContext context, String url, String title) async {
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(
    ShareParams(
      text: url,
      subject: title,
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}

/// Adresi Google Haritalar'da açar. Açılamazsa `false`.
Future<bool> openInMaps(String address) => launchUrl(
  Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': address}),
  mode: LaunchMode.externalApplication,
);

/// [boundary] altındaki görüntüyü [width] piksel genişliğinde PNG olarak
/// [file] dosyasına yazar ve sistem paylaşım penceresine verir.
Future<void> shareBoundaryImage({
  required BuildContext origin,
  required GlobalKey boundary,
  required File file,
  required double width,
  String? text,
}) => shareBoundaryImages(
  origin: origin,
  images: [(boundary, file)],
  width: width,
  text: text,
);

/// Birden çok görüntüyü sırasıyla PNG olarak yazar ve tek paylaşımda verir.
/// Instagram ve WhatsApp gibi uygulamalar görselleri bu sırayla alır
/// (hikâye ya da çoklu gönderi).
Future<void> shareBoundaryImages({
  required BuildContext origin,
  required List<(GlobalKey, File)> images,
  required double width,
  String? text,
}) async {
  final box = origin.findRenderObject() as RenderBox?;
  final files = <XFile>[];
  for (final (boundary, file) in images) {
    await writeBoundaryPng(boundary, file, width);
    files.add(XFile(file.path, mimeType: 'image/png'));
  }
  await SharePlus.instance.share(
    ShareParams(
      files: files,
      text: text,
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}

/// [boundary] altındaki görüntüyü [width] piksel genişliğinde PNG yazar.
Future<void> writeBoundaryPng(
  GlobalKey boundary,
  File file,
  double width,
) async {
  final render =
      boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await render.toImage(pixelRatio: width / render.size.width);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
}
