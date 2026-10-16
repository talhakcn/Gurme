import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Şimdiki zaman; testlerde sabitlenir.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
