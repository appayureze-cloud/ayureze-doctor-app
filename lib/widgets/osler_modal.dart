import 'package:flutter/material.dart';
import 'package:doctro/theme/ayureze_theme.dart';
import 'package:doctro/widgets/osler_button.dart';

class OslerModal extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? content;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final bool showCloseButton;
  final IconData? icon;
  final Color? iconColor;

  const OslerModal({
    super.key,
    required this.title,
    this.subtitle,
    this.content,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.showCloseButton = true,
    this.icon,
    this.iconColor,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? content,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool showCloseButton = true,
    IconData? icon,
    Color? iconColor,
    bool barrierDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      barrierDismissible: barrierDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => OslerModal(
        title: title,
        subtitle: subtitle,
        content: content,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        showCloseButton: showCloseButton,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AyurezeTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AyurezeTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              if (showCloseButton)
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AyurezeTheme.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.close, color: AyurezeTheme.textSecondary, size: 20),
                    ),
                  ),
                ),
              if (icon != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AyurezeTheme.healingGreen50).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor ?? AyurezeTheme.healingGreen50, size: 32),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AyurezeTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: TextStyle(fontSize: 14, color: AyurezeTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
              if (content != null) ...[
                const SizedBox(height: 24),
                content!,
              ],
              if (primaryButtonText != null || secondaryButtonText != null) ...[
                const SizedBox(height: 24),
                Column(
                  children: [
                    if (primaryButtonText != null)
                      OslerButton(
                        text: primaryButtonText!,
                        onPressed: () {
                          onPrimaryPressed?.call();
                          Navigator.pop(context);
                        },
                      ),
                    if (secondaryButtonText != null) ...[
                      const SizedBox(height: 12),
                      OslerButton(
                        text: secondaryButtonText!,
                        style: OslerButtonStyle.secondary,
                        onPressed: () {
                          onSecondaryPressed?.call();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}