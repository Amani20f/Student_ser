import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

/// Current app locale — defaults to English, can be toggled to Arabic.
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
