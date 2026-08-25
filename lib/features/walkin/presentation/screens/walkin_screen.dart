import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/common/app_text_field.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/service/data/service_model.dart';
import 'package:noq_business/features/service/presentation/widgets/service_selection_bottom_sheet.dart';
import 'package:noq_business/features/walkin/presentation/widgets/slot_selection_bottom_sheet.dart';

class WalkinScreen extends StatefulWidget {
  const WalkinScreen({super.key});

  @override
  State<WalkinScreen> createState() => _WalkinScreenState();
}

class _WalkinScreenState extends State<WalkinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _servicesController = TextEditingController();
  final _slotController = TextEditingController();

  List<ServiceModel> _selectedServices = [];
  String? _selectedSlot;

  @override
  void dispose() {
    _customerNameController.dispose();
    _servicesController.dispose();
    _slotController.dispose();
    super.dispose();
  }

  Future<void> _pickServices() async {
    final result = await ServiceSelectionBottomSheet.show(
      context,
      selected: _selectedServices,
    );
    if (result == null) return;
    setState(() {
      _selectedServices = result;
      _servicesController.text = result.map((s) => s.name).join(', ');
    });
  }

  Future<void> _pickSlot() async {
    final result = await SlotSelectionBottomSheet.show(context);
    if (result == null) return;
    setState(() {
      _selectedSlot = result;
      _slotController.text = result;
    });
  }

  void _addToQueue() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: submit the walk-in request once the API is wired up.
  }

  String? _requiredValidator(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        showLeading: false,
        title: 'Walk In Requests',
        subtitle: 'Check in walk-in requests',
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  labelText: 'Customer Name',
                  hintText: 'Enter your business name',
                  controller: _customerNameController,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      _requiredValidator(value, 'Customer name'),
                ),
                SizedBox(height: 1.5.h),
                AppTextField(
                  labelText: 'Select Service',
                  hintText: 'Select your service',
                  controller: _servicesController,
                  readOnly: true,
                  onTap: _pickServices,
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                  validator: (_) => _selectedServices.isEmpty
                      ? 'Select at least one service'
                      : null,
                ),
                SizedBox(height: 1.5.h),
                AppTextField(
                  labelText: 'Closet Available slot',
                  hintText: 'Select slot',
                  controller: _slotController,
                  readOnly: true,
                  onTap: _pickSlot,
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                  validator: (_) =>
                      _selectedSlot == null ? 'Select a slot' : null,
                ),
                SizedBox(height: 4.h),
                AppButton(label: 'Add to queue', onPressed: _addToQueue),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
