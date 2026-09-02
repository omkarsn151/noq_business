import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:noq_business/features/dashboard/data/dashboard_model.dart';

const _busyMorning = '''
{"success":true,"message":"Dashboard loaded.","data":{
 "header":{"business_id":"0198f7af","business_name":"Revive Saloon","date":"2026-08-31","timezone":"Asia/Kolkata"},
 "summary":{"todays_bookings":{"count":12,"change_vs_yesterday":3},
            "revenue":{"amount":"450.00","currency_code":"INR","change_percent_vs_yesterday":"18.00"},
            "pending_bookings":{"count":4}},
 "staff":{"total":14,"items":[
   {"id":"s1","name":"Sara","photo_url":"https://x/f","booked_count":4},
   {"id":"s2","name":"James","booked_count":2}]},
 "upcoming_bookings":[
   {"id":"b1","customer_name":"Sarvam Prasad","services":["Haircut"],"duration_minutes":30,
    "staff_name":"Sarangapani","scheduled_start":"2026-08-31T03:30:00Z","status":"confirmed"},
   {"id":"b2","customer_name":"Anita Desai","services":["Manicure","Hair Spa"],"duration_minutes":45,
    "staff_name":null,"scheduled_start":"2026-08-31T04:00:00Z","status":"pending"}]}}
''';

const _brandNew = '''
{"success":true,"message":"Dashboard loaded.","data":{
 "header":{"business_id":"0198f7af","business_name":"Revive Saloon","date":"2026-08-31","timezone":"Asia/Kolkata"},
 "summary":{"todays_bookings":{"count":0,"change_vs_yesterday":0},
            "revenue":{"amount":"0.00","currency_code":"INR"},
            "pending_bookings":{"count":0}},
 "staff":{"total":0,"items":[]},
 "upcoming_bookings":[]}}
''';

DashboardModel _parse(String source) =>
    DashboardModel.fromJson(jsonDecode(source) as Map<String, dynamic>);

void main() {
  test('busy morning', () {
    final d = _parse(_busyMorning);

    expect(d.header.businessName, 'Revive Saloon');
    expect(d.summary.todaysBookings.countLabel, '12');
    expect(d.summary.todaysBookings.comparisonLabel, '+3 vs yesterday');
    expect(d.summary.revenue.valueLabel, '₹450');
    expect(d.summary.revenue.growthLabel, '18%');
    expect(d.summary.revenue.isPositive, isTrue);
    expect(d.summary.pendingBookings.countLabel, '04');

    expect(d.staff.total, 14);
    expect(d.staff.items.map((s) => s.name), ['Sara', 'James']);
    expect(d.staff.items[0].photoUrl, 'https://x/f');
    expect(d.staff.items[1].photoUrl, isNull);

    expect(d.upcomingBookings[0].serviceLabel, 'Haircut');
    expect(d.upcomingBookings[0].durationLabel, '30min');
    expect(d.upcomingBookings[0].staffLabel, 'Sarangapani');

    // The null staff_name case.
    expect(d.upcomingBookings[1].serviceLabel, 'Manicure + Hair Spa');
    expect(d.upcomingBookings[1].staffLabel, 'Any staff');
  });

  test('brand new shop', () {
    final d = _parse(_brandNew);

    expect(d.summary.todaysBookings.countLabel, '0');
    expect(d.summary.todaysBookings.comparisonLabel, 'Same as yesterday');
    expect(d.summary.revenue.valueLabel, '₹0');
    expect(d.summary.revenue.growthLabel, isNull); // pill hidden
    expect(d.summary.pendingBookings.countLabel, '00');
    expect(d.staff.items, isEmpty);
    expect(d.upcomingBookings, isEmpty);
  });

  test('negative changes', () {
    final d = _parse(
      _busyMorning
          .replaceAll('"change_vs_yesterday":3', '"change_vs_yesterday":-2')
          .replaceAll('"18.00"', '"-5.50"'),
    );

    expect(d.summary.todaysBookings.comparisonLabel, '-2 vs yesterday');
    expect(d.summary.revenue.growthLabel, '5.5%');
    expect(d.summary.revenue.isPositive, isFalse);
  });

  test('missing sections degrade to zeros instead of throwing', () {
    final d = _parse('{"success":true,"data":{}}');

    expect(d.header.businessName, '');
    expect(d.summary.todaysBookings.countLabel, '0');
    expect(d.summary.revenue.growthLabel, isNull);
    expect(d.staff.items, isEmpty);
    expect(d.upcomingBookings, isEmpty);
  });
}
