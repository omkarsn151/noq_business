import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/features/business_setup/presentation/widgets/option_chip.dart';

class OptionRow extends StatelessWidget {
  const OptionRow({
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
    return Row(
      children: [
        for (final option in options) ...[
          Expanded(
            child: OptionChip(
              label: option.$1,
              isSelected: option.$2 == selected,
              onTap: () => onSelected(option.$2),
            ),
          ),
          if (option != options.last) SizedBox(width: 2.56.w),
        ],
      ],
    );
  }
}
