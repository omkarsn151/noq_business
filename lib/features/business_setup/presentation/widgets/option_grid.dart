import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/features/business_setup/presentation/widgets/option_chip.dart';

class OptionGrid extends StatelessWidget {
  const OptionGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<(String, int)> options;
  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < options.length; i += 2) ...[
          Row(
            children: [
              Expanded(
                child: OptionChip(
                  label: options[i].$1,
                  isSelected: options[i].$2 == selected,
                  onTap: () => onSelected(options[i].$2),
                ),
              ),
              if (i + 1 < options.length) ...[
                SizedBox(width: 2.56.w),
                Expanded(
                  child: OptionChip(
                    label: options[i + 1].$1,
                    isSelected: options[i + 1].$2 == selected,
                    onTap: () => onSelected(options[i + 1].$2),
                  ),
                ),
              ],
            ],
          ),
          if (i + 2 < options.length) SizedBox(height: 1.18.h),
        ],
      ],
    );
  }
}
