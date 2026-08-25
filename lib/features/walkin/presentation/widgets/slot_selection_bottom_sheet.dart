import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Placeholder for the slot picker - returns the selected slot label.
// TODO: build the real slot selection once the availability API is ready.
class SlotSelectionBottomSheet {
  SlotSelectionBottomSheet._();

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.13.w)),
      ),
      builder: (_) => const _SlotSelectionBody(),
    );
  }
}

class _SlotSelectionBody extends StatelessWidget {
  const _SlotSelectionBody();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.sh,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.62.w, 1.42.h, 4.62.w, 2.13.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 10.26.w,
                height: 0.47.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(0.51.w),
                ),
              ),
            ),
            SizedBox(height: 1.9.h),
            Text('Select Slot', style: Theme.of(context).textTheme.titleMedium),
            const Expanded(
              child: Center(child: Text('Slot selection coming soon')),
            ),
          ],
        ),
      ),
    );
  }
}
