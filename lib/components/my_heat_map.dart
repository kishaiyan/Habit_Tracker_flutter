import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class MyHeatMap extends StatelessWidget {
  final DateTime startTime;
  final Map<DateTime, int>? datasets;
  const MyHeatMap({super.key, required this.startTime, required this.datasets});

  @override
  Widget build(BuildContext context) {
    return HeatMap(
        startDate: startTime,
        endDate: DateTime.now(),
        datasets: datasets,
        colorMode: ColorMode.color,
        defaultColor: Theme.of(context).colorScheme.secondary,
        textColor: Colors.white,
        showColorTip: false,
        showText: true,
        scrollable: true,
        size: 30,
        colorsets: {
          1: Colors.green.shade100,
          2: Colors.green.shade200,
          3: Colors.green.shade300,
          4: Colors.green.shade400,
          5: Colors.green.shade500,
          6: Colors.green.shade600,
        });
  }
}
