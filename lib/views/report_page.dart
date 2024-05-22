import 'package:fitrack/view_models/report.dart';
import 'package:flutter/material.dart';
import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/utils/customs/card_history.dart';
import 'package:fitrack/utils/customs/top_nav.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ActivityDataPage extends StatelessWidget {
  final ActivityDataViewModel viewModel = ActivityDataViewModel();

  ActivityDataPage({Key? key}) : super(key: key);

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
                child: FutureBuilder<Map<String, dynamic>>(
                  future: viewModel.fetchActivityData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final data = snapshot.data;
                    final activityData = data?['activityData'] ?? [];
                    final maxStepsCount = (data?['maxStepsCount'] ?? 0) + 1000.0;
                    if (activityData.isEmpty) {
                      return Center(child: Text('No activity data found.'));
                    }
                    return SfCartesianChart(
                      primaryXAxis: const CategoryAxis(),
                      primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: maxStepsCount,
                        interval: 1000,
                      ),
                      series: <CartesianSeries>[
                        ColumnSeries<Map<String, dynamic>, String>(
                          dataSource: activityData,
                          xValueMapper: (data, _) => data['day'],
                          yValueMapper: (data, _) => (data['stepsCount'] as int).toDouble(),
                          name: 'Challenge Progress',
                          color: FitColors.primary30,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
            FutureBuilder<Map<String, dynamic>>(
              future: viewModel.fetchActivityData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final data = snapshot.data;
                final activityData = data?['activityData'] ?? [];
                if (activityData.isEmpty) {
                  return Center(child: Text('No activity data found.'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activityData.length,
                  itemBuilder: (context, index) {
                    final activity = activityData[index];
                    return CustomHistoryCard(
                      cal: activity['caloriesBurned'].toStringAsFixed(2),
                      date: activity['date'],
                      day: activity['day'],
                      steps: activity['stepsCount'].toStringAsFixed(2),
                      kcal: activity['caloriesBurned'].toStringAsFixed(2),
                      time: viewModel.stringToTimeOfDay(activity['activeTime']),
                      distance: activity['distanceTraveled'].toStringAsFixed(2),
                      challGoal: activity['challGoal'],
                      progress: 100,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
