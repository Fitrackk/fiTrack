import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationsCard extends StatefulWidget {
  final Widget icon;
  final String text;
  final String time;
  final int? daysAgo;

  NotificationsCard({super.key,
    required this.icon,
    required this.text,
    required this.time,
    this.daysAgo,
  });

  @override
  State<NotificationsCard> createState() => _NotificationsCardState();
}



class _NotificationsCardState extends State<NotificationsCard> {
  @override
  Widget build(BuildContext context) {
    return  Container(
      margin: EdgeInsets.only(left: 30),
      child: Row(
        children: [
          widget.icon,
          SizedBox(width: 20,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.text,style: TextStyles.labelLarge.copyWith(color: FitColors.text20),),
              SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,color: FitColors.text20,),
                    SizedBox(width: 10,),
                    if(widget.daysAgo != null)Text("${widget.daysAgo} day ago - ",style: TextStyles.bodySmall.copyWith(color: FitColors.text20)),
                    Text(widget.time,style: TextStyles.bodySmall.copyWith(color: FitColors.text20)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
