import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/utils/customs/history_card.dart';
import 'package:fitrack/utils/customs/top_nav.dart';
import 'package:fitrack/view_models/report.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ActivityDataPage extends StatefulWidget {
  const ActivityDataPage({super.key});

  @override
  _ActivityDataPageState createState() => _ActivityDataPageState();
}

class _ActivityDataPageState extends State<ActivityDataPage> {
  final ActivityDataVM _viewModel = ActivityDataVM();
  late Future<Map<String, dynamic>> _activityDataFuture;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _activityDataFuture = _viewModel.fetchActivityData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (!_isLoading) {
      setState(() => _isLoading = true);

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNav(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Text(
              "Week Report",
              style: TextStyles.headlineSmallBold
                  .copyWith(color: FitColors.primary20),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
              child: SizedBox(
                height: 500,
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _activityDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildShimmerChart();
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final data = snapshot.data!;
                    final activityData =
                        data['activityData'] as List<Map<String, dynamic>>;
                    final maxStepsCount = (data['maxStepsCount'] as int) + 1000;
                    if (activityData.isEmpty) {
                      return const Center(
                          child: Text('No activity data found.'));
                    }
                    return SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        labelStyle: TextStyles.bodySmallBold
                            .copyWith(color: FitColors.primary20),
                      ),
                      primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: maxStepsCount.toDouble(),
                        interval: 1000,
                        labelStyle: TextStyles.bodySmall
                            .copyWith(color: FitColors.primary20),
                      ),
                      series: <CartesianSeries>[
                        ColumnSeries<Map<String, dynamic>, String>(
                          dataSource: activityData,
                          xValueMapper: (data, _) => data['day'] as String,
                          yValueMapper: (data, _) =>
                              (data['stepsCount'] as int).toDouble(),
                          name: 'Challenge Progress',
                          color: FitColors.tertiary80,
                          borderColor: FitColors.primary30,
                          borderWidth: 3,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50)),
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
                      style: TextStyles.labelLargeBold
                          .copyWith(color: FitColors.primary20),
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: _activityDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerList();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final data = snapshot.data!;
                final activityData =
                    data['activityData'] as List<Map<String, dynamic>>;
                if (activityData.isEmpty) {
                  return const Center(child: Text('No activity data found.'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activityData.length,
                  itemBuilder: (context, index) {
                    final activity = activityData[index];
                    return CustomHistoryCard(
                      date: DateTime.parse(activity['date'] as String),
                      day: activity['day'] as String,
                      steps: activity['stepsCount'] as int,
                      kcal: activity['caloriesBurned'] as double,
                      time: _viewModel
                          .stringToTimeOfDay(activity['activeTime'] as String),
                      distance: activity['distanceTraveled'] as double,
                      challGoal: activity['challGoal'] as String,
                      progress: (activity['progress'] as num).toDouble(),
                    );
                  },
                );
              },
            ),
            if (_isLoading) _buildShimmerList(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerChart() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: FitColors.tertiary90,
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: FitColors.tertiary90,
                boxShadow: const [
                  BoxShadow(
                    color: FitColors.placeholder,
                    spreadRadius: 0.1,
                    blurRadius: 2,
                    offset: Offset(1, 5),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                  title: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 1,
                            height: 40,
                            color: FitColors.primary30,
                          ),
                          const SizedBox(width: 20),
                          Container(
                            width: 60,
                            height: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 20),
                          Container(
                            width: 60,
                            height: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 20),
                          Container(
                            width: 100,
                            height: 60,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  iconColor: FitColors.primary20,
                  collapsedIconColor: FitColors.primary20,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 100,
                            height: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 25),
                          Container(
                            width: 100,
                            height: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 15),
                          Container(
                            width: 80,
                            height: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 15),
                          Container(
                            width: 80,
                            height: 60,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
