import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider untuk mengontrol selected index pada bottom navigation
final navigationIndexProvider = StateProvider<int>((ref) => 0);
