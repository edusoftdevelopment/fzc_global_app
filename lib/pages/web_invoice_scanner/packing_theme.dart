import 'package:flutter/material.dart';
import 'package:fzc_global_app/utils/constants.dart';

/// Shared styles/widgets for the Web Invoice Scanner screens, using the
/// app's existing Constants palette (amber primary, light slate cards).
class PackingTheme {
  PackingTheme._();

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFEFEFEF)),
      );

  // Monospace-ish label for codes / invoice numbers.
  static const TextStyle monoLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Constants.primaryColor,
    letterSpacing: 0.5,
  );

  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      );

  /// Format a quantity: hide the ".0" for whole numbers.
  static String qty(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  /// A stat cell (value + label) used in the invoice cards / headers.
  static Widget stat(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black87)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  /// Small stat chip (used on the detail header).
  static Widget statChip(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: (color ?? Constants.primaryColor).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black87)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  static Widget statusChip(int status) {
    late Color bg, fg;
    late String text;
    switch (status) {
      case 2:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        text = 'Completed';
        break;
      case 1:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        text = 'In Progress';
        break;
      default:
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFFC2410C);
        text = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  static Widget emptyState(IconData icon, String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(icon, size: 90, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Center(
          child: Text(message,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
        ),
      ],
    );
  }

  static Widget errorState(String message, VoidCallback onRetry) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
        const SizedBox(height: 12),
        Center(
          child: Text(message,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton.icon(
            style: primaryButtonStyle,
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}
