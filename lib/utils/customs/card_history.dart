import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:flutter/material.dart';

class CustomHistoryCard extends StatefulWidget {
  final int cal;
  final int date;
  final String day;
  final int steps;
  final int kcal;
  final TimeOfDay time;
  final int distance;
  final String challGoal;
  final int progress;
  const CustomHistoryCard({
    super.key,
    required this.cal,
    required this.date,
    required this.day,
    required this.steps,
    required this.kcal,
    required this.time,
    required this.distance,
    required this.challGoal,
    required this.progress,
  });

  @override
  State<CustomHistoryCard> createState() => _CustomHistoryCardState();
}

class _CustomHistoryCardState extends State<CustomHistoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
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
            onExpansionChanged: (value) {
              setState(() {
                _isExpanded = value;
              });
            },
            tilePadding: EdgeInsets.zero,
            title: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Text(
                    '${widget.day}\n${widget.date}',
                    style: TextStyles.bodySmallBold.copyWith(color: FitColors.primary20),
                  ),
                  const SizedBox(width: 20),
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 13.0),
                        child: Image.asset(
                          'assets/images/steps.png',
                          color: FitColors.primary20,
                          width: 20,
                          height: 25,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 22.0, top: 20.0),
                        child: Text(
                          '${widget.steps}',
                          style: TextStyles.bodySmallBold.copyWith(color: FitColors.primary20),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 17.0, bottom: 30),
                        child: Text(
                          'steps',
                          style: TextStyles.bodyXSmall.copyWith(color: FitColors.placeholder),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12.0),
                        child: Image.asset(
                          'assets/images/kcal.png',
                          color: FitColors.primary20,
                          width: 20,
                          height: 25,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 23.0, top: 20.0),
                        child: Text(
                          '${widget.kcal}',
                          style: TextStyles.bodySmallBold.copyWith(color: FitColors.primary20),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 17.0, bottom: 30),
                        child: Text(
                          'Kcal',
                          style: TextStyles.bodyXSmall.copyWith(color: FitColors.placeholder),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6.5),
                        child: Image.asset(
                          'assets/images/clock.png',
                          width: 35,
                          height: 40,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 24.0, top: 20.0),
                        child: Text(
                          ' ${widget.time.hour}:${widget.time.minute}',
                          style: TextStyles.bodySmallBold.copyWith(color: FitColors.primary20),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 17.0, bottom: 30),
                        child: Text(
                          'Active Time',
                          style: TextStyles.bodyXSmall.copyWith(color: FitColors.placeholder),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            iconColor: FitColors.primary20,
            collapsedIconColor: FitColors.primary20,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 12.0),
                          child: Image.asset(
                            'assets/images/distans.png',
                            width: 24,
                            height: 24,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 24.0, top: 20.0),
                          child: Text(
                            '${widget.distance}KM',
                            style:
                            TextStyles.bodySmallBold.copyWith(color: FitColors.primary20),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 17.0, bottom: 30),
                          child: Text(
                            'distance',
                            style:
                            TextStyles.bodyXSmall.copyWith(color: FitColors.placeholder),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 25),
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 14.0),
                          child: Image.asset(
                            'assets/images/challenge.png',
                            color: FitColors.primary20,
                            width: 22,
                            height: 24,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 25.0, top: 20.0),
                          child: Text(
                            '${widget.challGoal} KM',
                            style:
                            TextStyles.bodySmallBold.copyWith(color: FitColors.primary20),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 17.0, bottom: 30),
                          child: Text(
                            '',
                            style:
                            TextStyles.bodyXSmall.copyWith(color: FitColors.placeholder),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 10.0, top: 20.0),
                          child: Text(
                            '${widget.progress}%',
                            style:
                            TextStyles.bodySmallBold.copyWith(color: FitColors.primary20),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 17.0, bottom: 30),
                          child: Text(
                            '',
                            style:
                            TextStyles.bodyXSmall.copyWith(color: FitColors.placeholder),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
