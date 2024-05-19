import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/utils/customs/card_history.dart';
import 'package:fitrack/utils/customs/top_nav.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class history extends StatefulWidget {
  const history({super.key});

  @override
  State<history> createState() => _historyState();
}

class _historyState extends State<history> {
  late List<_ChartData> data;
  late TooltipBehavior _tooltip;

  void initState() {
    data = [
      _ChartData('Mon', 12500),
      _ChartData('Tue', 14800),
      _ChartData('Wed', 10300),
      _ChartData('Thu', 15600),
      _ChartData('Fri', 9400),
      _ChartData('Sat', 13200),
      _ChartData('Sun', 15100),
    ];
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNav(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Week Report", style: TextStyles.headlineSmallBold),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 500,
                child: SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  primaryYAxis: const NumericAxis(
                      minimum: 0, maximum: 17000, interval: 1000),
                  tooltipBehavior: _tooltip,
                  series: <CartesianSeries<_ChartData, String>>[
                    ColumnSeries<_ChartData, String>(
                      dataSource: data,
                      xValueMapper: (_ChartData data, _) => data.x,
                      yValueMapper: (_ChartData data, _) => data.y,
                      name: 'challenge progress',
                      color: FitColors.primary30,
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8.0, top: 0.0, bottom: 0.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'History',
                      style: TextStyles.labelLargeBold,
                    ),
                  ),
                ],
              ),
            ),
            const CustomHistoryCard(
              cal: 1000,
              date: 24,
              day: 'Mon',
              steps: 12500,
              kcal: 279,
              time: TimeOfDay(hour: 1, minute: 25),
              distance: 8,
              challGoal: '8KM-Walking',
              progress: 100,
            ),
            const CustomHistoryCard(
              cal: 1000,
              date: 25,
              day: 'Tue',
              steps: 14800,
              kcal: 336,
              time: TimeOfDay(hour: 1, minute: 45),
              distance: 8,
              challGoal: '8KM-Walking',
              progress: 100,
            ),
            const CustomHistoryCard(
              cal: 1000,
              date: 26,
              day: 'Wed',
              steps: 10200,
              kcal: 228,
              time: TimeOfDay(hour: 1, minute: 10),
              distance: 8,
              challGoal: '8KM-Walking',
              progress: 100,
            ),
            const CustomHistoryCard(
              cal: 1000,
              date: 27,
              day: 'Thu',
              steps: 15300,
              kcal: 336,
              time: TimeOfDay(hour: 2, minute: 00),
              distance: 8,
              challGoal: '8KM-Walking',
              progress: 100,
            ),
            const CustomHistoryCard(
              cal: 1000,
              date: 28,
              day: 'Fri',
              steps: 9700,
              kcal: 219,
              time: TimeOfDay(hour: 1, minute: 12),
              distance: 8,
              challGoal: '8KM-Walking',
              progress: 100,
            ),
            const CustomHistoryCard(
              cal: 1000,
              date: 29,
              day: 'Sat',
              steps: 13600,
              kcal: 306,
              time: TimeOfDay(hour: 1, minute: 33),
              distance: 8,
              challGoal: '8KM-Walking',
              progress: 100,
            ),
            const CustomHistoryCard(
              cal: 1000,
              date: 30,
              day: 'Sun',
              steps: 15200,
              kcal: 342,
              time: TimeOfDay(hour: 1, minute: 55),
              distance: 8,
              challGoal: '8KM-Walking',
              progress: 100,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
