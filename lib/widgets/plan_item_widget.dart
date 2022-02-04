import 'dart:ui';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import '../providers/plan.dart';

class PlanItemWidget extends StatelessWidget {
  final PlanItem item;
  final deletePlan;
  final editPlan;
  PlanItemWidget(
      {@required this.item,
      @required this.deletePlan,
      @required this.editPlan});
  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    final _containerHeight = item.done ? 120.0 : 100.0;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      height: _containerHeight,
      child: Row(
        children: [
          Container(
            width: 75,
            padding: const EdgeInsets.all(8.0),
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    DateFormat.jm().format(
                      DateTime(DateTime.now().hour, DateTime.now().month,
                          DateTime.now().day, item.startTimeH, item.startTimeM),
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Icon(Icons.arrow_downward_rounded),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    DateFormat.jm().format(
                      DateTime(DateTime.now().hour, DateTime.now().month,
                          DateTime.now().day, item.endTimeH, item.endTimeM),
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Card(
              elevation: 8.0,
              child: Container(
                padding: const EdgeInsets.all(0),
                // width: width,
                height: _containerHeight,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "• " + toBeginningOfSentenceCase(item.category),
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 10.0),
                          child: Text(
                            "Priority : " +
                                toBeginningOfSentenceCase(item.priority),
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 10),
                        Expanded(
                          // width: 100,
                          // child: FittedBox(
                          // fit: BoxFit.fitWidth,
                          child: Text(
                            item.task,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 20),
                            // ),
                          ),
                        ),
                        Wrap(
                          spacing: -10.0,
                          children: [
                            IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  editPlan(item);
                                }),
                            IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.red.shade700,
                                onPressed: () {
                                  deletePlan(item);
                                }),
                          ],
                        )
                      ],
                    ),
                    if (item.done)
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.green.shade400,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                            ),
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.all(3.0),
                            child: Text("Completed",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white),
                                textAlign: TextAlign.center),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
