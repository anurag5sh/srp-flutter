import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/plan.dart';

class ViewPlanItem extends StatelessWidget {
  // const ViewPlanItem({ Key? key }) : super(key: key);
  final PlanItem item;
  final disabled;
  final rearranged;
  final markPlan;
  ViewPlanItem({
    this.item,
    this.disabled = false,
    this.rearranged = false,
    this.markPlan,
  });

  final categoryIcon = {
    'work': Icons.work_rounded,
    'fitness': Icons.fitness_center_rounded,
    'hobby': IconData(0xe800, fontFamily: 'InterestsIcon', fontPackage: null),
    'leisure': Icons.self_improvement_rounded,
    'chores': Icons.home_work_rounded,
    'sleep': Icons.hotel_rounded,
    'refreshment': Icons.flash_on_rounded,
    'social': Icons.groups_rounded,
    'others': Icons.pending_actions_rounded,
  };

  @override
  Widget build(BuildContext context) {
    var planColor = item.priority == 'high'
        ? Colors.orange.shade500
        : Color.fromRGBO(1, 87, 155, 1);

    planColor = disabled ? Colors.grey.shade500 : planColor;
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
          side: BorderSide(color: planColor, width: 2.0)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(color: planColor),
            child: DefaultTextStyle(
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w500),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat.jm().format(
                          DateTime(
                              DateTime.now().hour,
                              DateTime.now().month,
                              DateTime.now().day,
                              item.startTimeH,
                              item.startTimeM),
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Icon(
                        Icons.arrow_right_alt_rounded,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        DateFormat.jm().format(
                          DateTime(DateTime.now().hour, DateTime.now().month,
                              DateTime.now().day, item.endTimeH, item.endTimeM),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          "Priority: ${toBeginningOfSentenceCase(item.priority)}")
                    ],
                  ),
                ],
              ),
            ),
          ),
          ListTile(
              horizontalTitleGap: 32,
              leading: Icon(
                categoryIcon[item.category],
                size: 35,
                color: disabled
                    ? Colors.grey.shade500
                    : Theme.of(context).primaryColor,
              ),
              title: Text(toBeginningOfSentenceCase(item.task)),
              subtitle: Text(toBeginningOfSentenceCase(item.category)),
              trailing: Checkbox(
                value: item.done,
                onChanged: disabled
                    ? null
                    : (val) {
                        markPlan(item: item, tick: val);
                      },
              )),
          if (disabled)
            Container(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.all(3.0),
                  child: Text("Removed",
                      style: TextStyle(fontSize: 10, color: Colors.white),
                      textAlign: TextAlign.center),
                ),
              ),
            ),
          if (rearranged)
            Container(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.all(3.0),
                  child: Text("Rearranged",
                      style: TextStyle(fontSize: 10, color: Colors.white),
                      textAlign: TextAlign.center),
                ),
              ),
            )
        ],
      ),
    );
  }
}
