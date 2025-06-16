import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';

class DateRangeWidget extends StatefulWidget {
  Function(List<DateTime?>) onChanged;
  DateRangeWidget(
      {super.key, required List<DateTime?> dates, required this.onChanged});

  @override
  State<DateRangeWidget> createState() => _DateRangeWidgetState();
}

class _DateRangeWidgetState extends State<DateRangeWidget> {
  TextEditingController date = TextEditingController();
  List<DateTime?> _dates = [
    DateTime.now().startOfMonth(),
    DateTime.now().endOfMonth()
  ];

  _showDateRanges() async {
    var res = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
          calendarType: CalendarDatePicker2Type.range,
          firstDate: DateTime(1999),
          lastDate: DateTime(3000)),
      dialogSize: const Size(325, 400),
      value: _dates,
      borderRadius: BorderRadius.circular(15),
    );

    if (res != null) {
      _dates = res;
      widget.onChanged(_dates);
      _renderDates();
    }
  }

  _renderDates() {
    date.value = TextEditingValue(
        text:
            '${_dates.first?.format(payload: 'DD/MM/YYYY')} - ${_dates.last?.format(payload: 'DD/MM/YYYY')}');
  }

  @override
  void initState() {
    _renderDates();
    widget.onChanged(_dates);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: date,
      readOnly: true,
      decoration: InputDecoration(
          hintText: 'DD/MM/YYYY',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderSide: BorderSide(style: BorderStyle.none, width: 0)),
          suffixIcon: IconButton(
              onPressed: _showDateRanges, icon: Icon(Icons.calendar_month))),
    );
  }
}
