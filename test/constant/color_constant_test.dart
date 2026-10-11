import 'package:doctro/constant/color_constant.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    // These getters read AyurezeTheme's shared static dark-mode flag -
    // reset it so one test's setting can't leak into the next.
    AyurezeTheme.updateThemeMode(false);
  });

  group('color_constant.dart dark-aware getters', () {
    test('hintColor/cardText/text follow AyurezeTheme.textPrimary', () {
      AyurezeTheme.updateThemeMode(false);
      expect(hintColor, AyurezeTheme.textPrimary);
      expect(cardText, AyurezeTheme.textPrimary);
      expect(text, AyurezeTheme.textPrimary);

      AyurezeTheme.updateThemeMode(true);
      expect(hintColor, AyurezeTheme.textPrimary);
      expect(cardText, AyurezeTheme.textPrimary);
      expect(text, AyurezeTheme.textPrimary);
    });

    test('subheading/passwordVisibility/darkGrey follow textSecondary', () {
      AyurezeTheme.updateThemeMode(false);
      expect(subheading, AyurezeTheme.textSecondary);
      expect(passwordVisibility, AyurezeTheme.textSecondary);
      expect(darkGrey, AyurezeTheme.textSecondary);

      AyurezeTheme.updateThemeMode(true);
      expect(subheading, AyurezeTheme.textSecondary);
      expect(passwordVisibility, AyurezeTheme.textSecondary);
      expect(darkGrey, AyurezeTheme.textSecondary);
    });

    test('divider/tabBar follow border/surfaceMuted', () {
      AyurezeTheme.updateThemeMode(false);
      expect(divider, AyurezeTheme.border);
      expect(tabBar, AyurezeTheme.surfaceMuted);

      AyurezeTheme.updateThemeMode(true);
      expect(divider, AyurezeTheme.border);
      expect(tabBar, AyurezeTheme.surfaceMuted);
    });

    test(
        'loginButton keeps its light-mode value and turns white in dark '
        'mode', () {
      AyurezeTheme.updateThemeMode(false);
      expect(loginButton, const Color(0xFF24382C));

      AyurezeTheme.updateThemeMode(true);
      expect(loginButton, const Color(0xFFFFFFFF));
    });
  });
}
