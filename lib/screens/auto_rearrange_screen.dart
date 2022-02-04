import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_routine_planner/models/http_exception.dart';

import '../providers/plan.dart';

import '../widgets/view_plan_item_widget.dart';

class AutoRearrange extends StatefulWidget {
  // const AutoRearrange({ Key? key }) : super(key: key);
  static final routeName = '/auto-rearrange';

  @override
  _AutoRearrangeState createState() => _AutoRearrangeState();
}

class _AutoRearrangeState extends State<AutoRearrange> {
  List<PlanItem> plan = [];
  List<PlanItem> _rearrangedPlans = [];
  List<PlanItem> todaysPlan;
  List<PlanItem> _unfinishedPlans = [];
  List<dynamic> remarks = [];
  Future future;

  @override
  void initState() {
    todaysPlan = Provider.of<Plan>(context, listen: false).todaysPlan;
    future = getRearrangedPlans();
    // getRearrangedPlans();
    super.initState();
  }

  void _sortPlans(List<dynamic> planList) {
    planList.sort((planA, planB) {
      if (planB.startTimeH > planA.endTimeH)
        return -1;
      else if (planB.startTimeH == planA.endTimeH) {
        if (planB.startTimeM > planA.endTimeM)
          return -1;
        else if (planB.startTimeM < planA.endTimeM)
          return 1;
        else
          return 0;
      }

      return 1;
    });
  }

  Future<void> getRearrangedPlans() async {
    try {
      final response =
          await Provider.of<Plan>(context, listen: false).getRearrangedPlan();
      // debugPrint(response.toString(), wrapWidth: 1024);
      // setState(() {
      for (var i = 0; i < response['plan'].length; i++) {
        if (response['plan'][i]['category'] != 'idle')
          plan.add(PlanItem(
              category: response['plan'][i]['category'],
              task: response['plan'][i]['task'],
              priority: response['plan'][i]['priority'],
              done: response['plan'][i]['done'],
              startTimeH: response['plan'][i]['startTimeH'],
              startTimeM: response['plan'][i]['startTimeM'],
              endTimeH: response['plan'][i]['endTimeH'],
              endTimeM: response['plan'][i]['endTimeM']));
      }
      remarks = response['remarks'];
      _sortPlans(plan);
      _findChangedPlans();
      // });
      // _findChangedPlans();
      // debugPrint(response, wrapWidth: 1024);
    } on Exception catch (e) {
      print(e);
    }
  }

  void _showRemarks(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            'Remarks for the plan on ${DateFormat.yMMMMd().format(date)}',
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...remarks.map((item) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• "),
                    Expanded(
                      child: Text(item),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  _findChangedPlans() {
    var indexes = [];
    for (int i = 0; i < todaysPlan.length; i++) {
      if (!plan.any((other) {
        return todaysPlan[i].category == other.category &&
            todaysPlan[i].task == other.task &&
            todaysPlan[i].startTimeH == other.startTimeH &&
            todaysPlan[i].startTimeM == other.startTimeM &&
            todaysPlan[i].endTimeH == other.endTimeH &&
            todaysPlan[i].endTimeM == other.endTimeM &&
            todaysPlan[i].done == other.done;
      })) {
        _unfinishedPlans.add(todaysPlan[i]);
        indexes.add(i);
      }
    }

    for (var item in plan) {
      if (!todaysPlan.any((other) {
        return item.category == other.category &&
            item.task == other.task &&
            item.startTimeH == other.startTimeH &&
            item.startTimeM == other.startTimeM &&
            item.endTimeH == other.endTimeH &&
            item.endTimeM == other.endTimeM &&
            item.done == other.done;
      })) _rearrangedPlans.add(item);
    }
    // for (var i in indexes) {
    //   todaysPlan.removeAt(i);
    // }
    todaysPlan = [...todaysPlan, ..._rearrangedPlans];
    _sortPlans(todaysPlan);
    setState(() {
      todaysPlan = todaysPlan;
    });
    // print(_rearrangedPlans);
    // print(_unfinishedPlans);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  _savePlan() async {
    try {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            'Saving your plan',
            textAlign: TextAlign.center,
          ),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [CircularProgressIndicator()]),
        ),
      );

      final response =
          await Provider.of<Plan>(context, listen: false).savePlan();

      if (response != null) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Plan Saved'),
            content: Text("Your plan was saved successfully!"),
            actions: <Widget>[
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
    } on HttpException catch (error) {
      Navigator.of(context).pop();
      _showErrorDialog(error.message);
    } catch (error) {
      Navigator.of(context).pop();
      _showErrorDialog(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Auto Rearranged Plan"),
      ),
      body: FutureBuilder(
        future: future,
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            style: ButtonStyle(
                                visualDensity: VisualDensity.comfortable),
                            onPressed: () {
                              // var remarks = Provider.of<Plan>(context,
                              //         listen: false)
                              // .todaysRemarks;
                              _showRemarks(context, DateTime.now());
                            },
                            label: Text(
                              "Remarks",
                              style: TextStyle(fontSize: 12),
                            ),
                            icon: Icon(
                              Icons.list_alt_outlined,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: todaysPlan.length,
                        itemBuilder: (ctx, i) => ViewPlanItem(
                          item: todaysPlan[i],
                          disabled: _unfinishedPlans.contains(todaysPlan[i]),
                          rearranged: _rearrangedPlans.contains(todaysPlan[i]),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red.shade800)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Provider.of<Plan>(context, listen: false)
                                  .initEditCompletePlan(plan);
                              Provider.of<Plan>(context, listen: false)
                                  .setTodaysEditingPlanId();
                              _savePlan();
                            },
                            child: Text('SAVE'),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ]),
                  )
                ],
              ),
      ),
    );
  }
}
