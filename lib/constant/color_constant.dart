import 'package:flutter/cupertino.dart';

import 'package:doctro/theme/ayureze_theme.dart';

// Ayureze-inspired palette.
//
// This file used to duplicate a light-only copy of several AyurezeTheme
// tokens under different names - cardColor/scaffoldBg/cardBorder/
// imageBorder/colorButton/card/deepPurple/back/black/grey/
// ForgotPasswordScreen all had zero real usages anywhere in the app and
// have been removed outright. The remaining identifiers that represent
// body text, dividers or surfaces (not a self-contained foreground-on-
// gradient or foreground-on-tint pair, which stays correct in both
// themes per AyurezeTheme's own documented convention) are now getters
// forwarding to AyurezeTheme's dark-aware tokens, so every existing call
// site - still written as a bare identifier, e.g. `color: text` - gets
// dark-mode support for free with no per-file changes.

// Foreground-on-gradient/foreground-on-tint - correct in both themes as-is.
const Color colorWhite = Color(0xFFFFFFFF);
const Color colorBlack = Color(0xFF203126);

// Body text - was a fixed near-black, now follows the active theme.
Color get hintColor => AyurezeTheme.textPrimary;
Color get cardText => AyurezeTheme.textPrimary;
Color get text => AyurezeTheme.textPrimary;

// Secondary/muted text.
Color get subheading => AyurezeTheme.textSecondary;
Color get passwordVisibility => AyurezeTheme.textSecondary;
Color get darkGrey => AyurezeTheme.textSecondary;

// Divider lines and a muted surface fill - both were fixed light colors.
Color get divider => AyurezeTheme.border;
Color get tabBar => AyurezeTheme.surfaceMuted;

// Brand CTA color (icon/label foreground, e.g. primaryColor/foregroundColor
// on a button or theme). Keeps its exact light-mode value - only the
// dark-mode counterpart is new, since nothing here was dark-aware before.
Color get loginButton =>
    AyurezeTheme.isDark ? const Color(0xFFFFFFFF) : const Color(0xFF24382C);

// Status/semantic indicator colors - self-contained accents (small
// badges, switch tracks), readable in both themes as-is; left as plain
// constants rather than theme-following surfaces.
const Color status = Color(0xFF5F8D46);
const Color statusCancel = Color(0xFFD95C4E);
const Color red = Color(0xFFD95C4E);
const Color orange = Color(0xFFF0A534);
const Color green = Color(0xFF5F8D46);

// Astra AI branding accent (intentionally not AyurezeTheme.purple, a
// different violet used elsewhere - this sage-green tone is this app's
// own "Astra AI" section color, see astra_fill_display.dart).
const Color purple = Color(0xFF70836F);

const Color tealAccent = Color(0xFFB5F36B);

const Color blackOpacity = Color(0x54000000);
const Color transparent = Color(0x00000000);
