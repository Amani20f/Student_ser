import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A global provider to allow feature pages to override the header's back button action.
/// Useful for resetting filters before navigating away.
final backActionProvider = StateProvider<VoidCallback?>((ref) => null);
