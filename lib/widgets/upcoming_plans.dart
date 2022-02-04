import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/view_plan_item_widget.dart';
import '../providers/plan.dart';

class UpcomingPlans extends StatelessWidget {
  // const UpcomingPlans({ Key? key }) : super(key: key);
  final List<PlanItem> todaysPlan;
  UpcomingPlans({this.todaysPlan});

  List<PlanItem> getPlans() {
    DateTime now = DateTime.now();
    var index;

    for (var i = 0; i < todaysPlan.length; i++) {
      if (todaysPlan[i].endTimeH > now.hour ||
          todaysPlan[i].endTimeH == now.hour &&
              todaysPlan[i].endTimeM >= now.minute) {
        index = i;
        break;
      }
    }

    if (index == null) return [];

    var end = (todaysPlan.length - index) >= 3 ? 3 : todaysPlan.length - index;

    return todaysPlan.sublist(index, index + end);
  }

  @override
  Widget build(BuildContext context) {
    var plans = getPlans();
    void markTodaysPlan({@required bool tick, @required PlanItem item}) async {
      try {
        Provider.of<Plan>(context, listen: false)
            .initEditCompletePlan(todaysPlan);
        Provider.of<Plan>(context, listen: false).setTodaysEditingPlanId();
        await Provider.of<Plan>(context, listen: false)
            .markPlan(isToday: true, item: item, tick: tick);
      } catch (err) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err.toString())));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (plans.isNotEmpty)
          Wrap(
            children: [
              ViewPlanItem(
                item: plans[0],
                markPlan: markTodaysPlan,
              ),
              Opacity(
                opacity: 0.6,
                child: Wrap(
                  children: [
                    ...plans
                        .sublist(1, plans.length)
                        .map((item) => ViewPlanItem(
                              item: item,
                              markPlan: markTodaysPlan,
                            ))
                        .toList(),
                  ],
                ),
              ),
            ],
          )
        else
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('You have completed all your tasks for the day!'),
          )
      ],
    );
  }
}
