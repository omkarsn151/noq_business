import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/core/common/app_button.dart';
import 'package:noq_business/core/common/app_snackbar.dart';
import 'package:noq_business/core/common/app_text_field.dart';
import 'package:noq_business/core/utils/app_colors.dart';
import 'package:noq_business/features/service/data/service_model.dart';
import 'package:noq_business/features/service/presentation/widgets/service_selection_bottom_sheet.dart';
import 'package:noq_business/features/walkin/bloc/create_walkin_bloc.dart';
import 'package:noq_business/features/walkin/bloc/create_walkin_event.dart';
import 'package:noq_business/features/walkin/bloc/create_walkin_state.dart';
import 'package:noq_business/features/walkin/bloc/todays_bookings_bloc.dart';
import 'package:noq_business/features/walkin/bloc/todays_bookings_event.dart';
import 'package:noq_business/features/walkin/bloc/todays_bookings_state.dart';
import 'package:noq_business/features/walkin/data/walkin_slot_selection.dart';
import 'package:noq_business/features/walkin/presentation/widgets/slot_selection_bottom_sheet.dart';
import 'package:noq_business/features/walkin/presentation/widgets/todays_bookings_card.dart';

class WalkinScreen extends StatefulWidget {
  const WalkinScreen({super.key});

  @override
  State<WalkinScreen> createState() => _WalkinScreenState();
}

class _WalkinScreenState extends State<WalkinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _servicesController = TextEditingController();
  final _slotController = TextEditingController();

  List<ServiceModel> _selectedServices = [];
  WalkinSlotSelection? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _loadTodaysBookings();
  }

  void _loadTodaysBookings() {
    context.read<TodaysBookingsBloc>().add(const TodaysBookingsRequested());
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
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
      // A different service set means a different visit length, so the chips
      // picked for the old one no longer apply.
      _clearSlot();
    });
  }

  Future<void> _pickSlot() async {
    if (_selectedServices.isEmpty) {
      AppSnackbar.error(context, 'Select at least one service first');
      return;
    }

    final result = await SlotSelectionBottomSheet.show(
      context,
      services: _selectedServices,
    );
    if (result == null) return;
    setState(() {
      _selectedSlot = result;
      _slotController.text = result.label;
    });
  }

  void _clearSlot() {
    _selectedSlot = null;
    _slotController.clear();
  }

  void _addToQueue() {
    if (!_formKey.currentState!.validate()) return;

    final slot = _selectedSlot;
    if (slot == null) return;

    final phone = _customerPhoneController.text.trim();
    context.read<CreateWalkinBloc>().add(
      CreateWalkinSubmitted(
        customerName: _customerNameController.text,
        customerPhone: phone.isEmpty ? null : phone,
        serviceIds: _selectedServices.map((s) => s.id).toList(),
        slotStarts: slot.starts,
      ),
    );
  }

  void _onCreated(BuildContext context, CreateWalkinState state) {
    if (state is CreateWalkinSuccess) {
      AppSnackbar.success(
        context,
        'Walk-in confirmed - ${state.booking.reference}',
      );
      _formKey.currentState?.reset();
      setState(() {
        _customerNameController.clear();
        _customerPhoneController.clear();
        _servicesController.clear();
        _selectedServices = [];
        _clearSlot();
      });
      _loadTodaysBookings();
      return;
    }

    if (state is CreateWalkinFailure) {
      AppSnackbar.error(context, state.message);
      // These starts can never succeed on a retry - make the clerk pick again.
      if (state.isSlotStale) setState(_clearSlot);
    }
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
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => _loadTodaysBookings(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    labelText: 'Customer Name',
                    hintText: 'Enter customer name',
                    controller: _customerNameController,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) =>
                        _requiredValidator(value, 'Customer name'),
                  ),
                  SizedBox(height: 1.5.h),
                  AppTextField(
                    labelText: 'Customer Phone (optional)',
                    hintText: 'Enter customer phone',
                    controller: _customerPhoneController,
                    keyboardType: TextInputType.phone,
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
                    labelText: 'Closest Available slot',
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
                  BlocConsumer<CreateWalkinBloc, CreateWalkinState>(
                    listener: _onCreated,
                    builder: (context, state) {
                      return AppButton(
                        label: 'Add to queue',
                        isLoading: state is CreateWalkinLoading,
                        onPressed: _addToQueue,
                      );
                    },
                  ),
                  SizedBox(height: 4.h),
                  BlocBuilder<TodaysBookingsBloc, TodaysBookingsState>(
                    builder: (context, state) {
                      if (state.status == TodaysBookingsStatus.loading &&
                          state.model.bookings.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.status == TodaysBookingsStatus.failure &&
                          state.model.bookings.isEmpty) {
                        return Center(
                          child: Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        );
                      }

                      return TodaysBookingsCard(
                        model: state.model,
                        onViewAll: () => context.push('/bookings'),
                        onBookingTap: (id) => context.push('/bookings/$id'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
