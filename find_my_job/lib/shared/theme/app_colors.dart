import 'package:flutter/material.dart';

/// FindMyJob colour palette.
/// All colours are defined here. No hardcoded hex values elsewhere.
abstract class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────
  /// Primary: deep violet-blue — professional, trustworthy
  static const primary = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF3730A3);
  static const primaryContainer = Color(0xFFEEF2FF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF3730A3);

  /// Secondary: emerald green — growth, opportunity
  static const secondary = Color(0xFF059669);
  static const secondaryLight = Color(0xFF34D399);
  static const secondaryDark = Color(0xFF047857);
  static const secondaryContainer = Color(0xFFD1FAE5);
  static const onSecondary = Color(0xFFFFFFFF);

  /// Accent: amber — highlights, CTAs
  static const accent = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFBBF24);
  static const accentContainer = Color(0xFFFEF3C7);

  // ── Neutrals ───────────────────────────────────────────────────────
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF8FAFC);
  static const surfaceContainerLow = Color(0xFFF1F5F9);
  static const surfaceContainer = Color(0xFFE2E8F0);

  static const outline = Color(0xFFCBD5E1);
  static const outlineVariant = Color(0xFFE2E8F0);

  static const onSurface = Color(0xFF0F172A);       // near-black
  static const onSurfaceVariant = Color(0xFF475569); // slate-600
  static const onSurfaceSubtle = Color(0xFF94A3B8);  // slate-400

  // ── Background ─────────────────────────────────────────────────────
  static const background = Color(0xFFF8FAFC);
  static const onBackground = Color(0xFF0F172A);

  // ── Status ─────────────────────────────────────────────────────────
  static const error = Color(0xFFDC2626);
  static const errorContainer = Color(0xFFFEE2E2);
  static const onError = Color(0xFFFFFFFF);
  static const onErrorContainer = Color(0xFF991B1B);

  static const success = Color(0xFF059669);
  static const successContainer = Color(0xFFD1FAE5);

  static const warning = Color(0xFFF59E0B);
  static const warningContainer = Color(0xFFFEF3C7);

  // ── Application status colours ─────────────────────────────────────
  static const statusSent = Color(0xFF6366F1);        // indigo
  static const statusViewed = Color(0xFFF59E0B);      // amber
  static const statusEvaluating = Color(0xFF3B82F6);  // blue
  static const statusInterview = Color(0xFF8B5CF6);   // violet
  static const statusAccepted = Color(0xFF059669);    // emerald
  static const statusRejected = Color(0xFFDC2626);    // red

  // ── Dark mode equivalents ──────────────────────────────────────────
  static const surfaceDark = Color(0xFF0F172A);
  static const surfaceVariantDark = Color(0xFF1E293B);
  static const surfaceContainerDark = Color(0xFF1E293B);
  static const onSurfaceDark = Color(0xFFF1F5F9);
  static const onSurfaceVariantDark = Color(0xFF94A3B8);
  static const backgroundDark = Color(0xFF0F172A);
  static const outlineDark = Color(0xFF334155);
}
