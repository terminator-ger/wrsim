/// Safe helpers for converting `double` to `int`.
///
/// The Dart VM throws `UnsupportedError("Infinity or NaN toInt")` when
/// calling `toInt()` on `double.infinity`, `-double.infinity`, or `double.nan`.
/// Use these helpers to avoid that exception and control fallback behavior.

extension DoubleToIntHelpers on double {
  /// Returns `this.toInt()` when finite, otherwise `null`.
  ///
  /// Useful when you want to ignore non-finite values.
  int? toIntOrNull() => isFinite ? toInt() : null;

  /// Returns `this.toInt()` when finite, otherwise returns [defaultValue].
  ///
  /// Example: `value.toIntOrDefault(0)` will map `NaN` and `Infinity` to `0`.
  int toIntOrDefault(int defaultValue) => isFinite ? toInt() : defaultValue;

  /// Convert to an `int` with custom handlers for `NaN` and `Infinity`.
  ///
  /// - If `this` is `NaN`, returns [onNaN] if provided; otherwise throws
  ///   `UnsupportedError` (same behavior as `toInt()` today).
  /// - If `this` is infinite, returns [onInfinite] if provided; otherwise
  ///   throws `UnsupportedError`.
  /// - Otherwise returns `this.toInt()`.
  int toIntSafe({int? onNaN, int? onInfinite}) {
    if (isNaN) {
      if (onNaN != null) return onNaN;
      throw UnsupportedError('NaN toInt');
    }
    if (isInfinite) {
      if (onInfinite != null) return onInfinite;
      throw UnsupportedError('Infinity toInt');
    }
    return toInt();
  }
}

// Usage examples (copy into your code where appropriate):
//
// import 'package:your_package/src/double_extensions.dart';
//
// double v = ...;
// int? maybe = v.toIntOrNull();
// int safe = v.toIntOrDefault(0);
// int handled = v.toIntSafe(onNaN: 0, onInfinite: v.isNegative ? -9223372036854775808 : 9223372036854775807);
