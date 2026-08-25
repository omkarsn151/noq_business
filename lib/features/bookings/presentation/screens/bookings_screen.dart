import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:noq_business/core/common/app_appbar.dart';
import 'package:noq_business/features/bookings/data/booking_status.dart';
import 'package:noq_business/features/bookings/presentation/widgets/booking_card.dart';
import 'package:noq_business/features/bookings/presentation/widgets/booking_status_tab_bar.dart';

typedef _Booking = ({
  String customerName,
  String serviceName,
  String duration,
  String startTime,
  String endTime,
});

// TODO: replace the hardcoded data below once the bookings API is wired up.
const _bookings = <_Booking>[
  (
    customerName: 'Sarah . M',
    serviceName: 'Coloring',
    duration: '45 min',
    startTime: 'Today, 4:00 PM',
    endTime: 'Today, 6:00 PM',
  ),
  (
    customerName: 'Diana',
    serviceName: 'Haircut',
    duration: '45 min',
    startTime: 'Today, 6:00 PM',
    endTime: 'Today, 8:00 PM',
  ),
  (
    customerName: 'Johnson',
    serviceName: 'Pedicure',
    duration: '45 min',
    startTime: 'Tomorrow, 4:00 PM',
    endTime: 'Jul 01, 6:00 PM',
  ),
];

const _tabStatuses = [
  BookingStatus.pending,
  BookingStatus.approved,
  BookingStatus.rejected,
  BookingStatus.cancelled,
];

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: _tabStatuses.length,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_Booking> _bookingsFor(BookingStatus status) =>
      status == BookingStatus.cancelled ? const [] : _bookings;

  String _tabLabel(BookingStatus status) {
    if (status == BookingStatus.cancelled) return 'Cancellations';
    return '${status.label} ${_bookingsFor(status).length}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        showLeading: false,
        title: 'Bookings',
        subtitle: 'Check your bookings, requests and rejected details',
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            BookingStatusTabBar(
              controller: _tabController,
              labels: [for (final status in _tabStatuses) _tabLabel(status)],
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  for (final status in _tabStatuses)
                    _BookingsList(
                      bookings: _bookingsFor(status),
                      status: status,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final List<_Booking> bookings;
  final BookingStatus status;

  const _BookingsList({required this.bookings, required this.status});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(
          'No ${status.label.toLowerCase()} bookings',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return BookingCard(
          customerName: booking.customerName,
          serviceName: booking.serviceName,
          duration: booking.duration,
          startTime: booking.startTime,
          endTime: booking.endTime,
          status: status,
          onReject: () {},
          onApprove: () {},
        );
      },
    );
  }
}
