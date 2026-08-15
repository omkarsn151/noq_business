import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leading;
  final Widget? trailing;
  final ButtonStyle? style;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.leading,
    this.trailing,
    this.style,
    this.padding,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Text(label),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style:
          style ??
          ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding:
                padding ??
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
      child: child,
    );
  }
}
