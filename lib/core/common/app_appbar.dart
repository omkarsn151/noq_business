import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../utils/app_colors.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onLeadingPressed;
  final IconData leadingIcon;
  final List<Widget>? actions;

  const AppAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.onLeadingPressed,
    this.leadingIcon = Icons.arrow_back_rounded,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 14.w,
      leading: Padding(
        padding: EdgeInsets.only(left: 3.w),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(leadingIcon, size: 18.sp, color: AppColors.primary),
            onPressed: onLeadingPressed ?? () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (title != null)
            Text(title!, style: Theme.of(context).appBarTheme.titleTextStyle),
          if (subtitle != null)
            Text(
              subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
