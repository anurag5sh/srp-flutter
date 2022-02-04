import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import '../screens/auto_rearrange_screen.dart';
import '../screens/choose_create_plan_screen.dart';
import '../screens/create_plan_screen.dart';
import '../widgets/view_plan_item_widget.dart';
import '../providers/plan.dart';

class ViewRoutineScreen extends StatefulWidget {
  static final routeName = "/viewRoutine";
  @override
  _ViewRoutineScreenState createState() => _ViewRoutineScreenState();
}

class _ViewRoutineScreenState extends State<ViewRoutineScreen> {
  List<PlanItem> plan;

  @override
  void initState() {
    super.initState();
  }

  DateTime _currentDate;
  bool _isPreviousPlanLoading = false;
  bool _errorOccured = false;
  List<PlanItem> planList = [];
  String _errorMessage = '';
  double previousPlanRating = 3;
  double todaysPlanRating = 3;

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

  void _showRemarks(List<String> remarks, DateTime date) {
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

  void _showLoadingDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deletePlan(DateTime date) {
    DateTime today = DateTime.now();
    bool isToday = false;
    if (today.day == date.day &&
        today.month == date.month &&
        date.year == today.year) isToday = true;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text(
            'Are you sure you want to permanently delete ${isToday ? 'today' : DateFormat.yMMMMd().format(date)}\'s plan?'),
        actions: <Widget>[
          TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              _showLoadingDialog();
              try {
                await Provider.of<Plan>(context, listen: false)
                    .deletePlan(isToday)
                    .then((_) {
                  Navigator.of(context).pop();

                  if (!isToday) loadPreviousPlanData(_currentDate);

                  final snackBar = SnackBar(
                    content: Text('Plan Deleted!'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                });
              } catch (error) {
                Navigator.of(context).pop();
                _showErrorDialog(error.toString());
              }
            },
          ),
        ],
      ),
    );
  }

  void loadPreviousPlanData(DateTime pickedDate) async {
    setState(() {
      _isPreviousPlanLoading = true;
      _currentDate = pickedDate;
      _errorOccured = false;
      planList = [];
    });
    try {
      final _planList = await Provider.of<Plan>(context, listen: false)
          .getPreviousPlan(pickedDate);
      setState(() {
        _isPreviousPlanLoading = false;
        planList = _planList;
        previousPlanRating =
            Provider.of<Plan>(context, listen: false).previousPlanFeedback;
      });
    } on HttpException catch (error) {
      setState(() {
        _isPreviousPlanLoading = false;
        _errorOccured = true;
        _errorMessage = error.message != null
            ? error.message
            : 'An error occured, try again later.';
      });
    } catch (error) {
      setState(() {
        _isPreviousPlanLoading = false;
      });
      // _showErrorDialog(error.toString());
      throw error;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime _pickedDate = await showDatePicker(
        context: context,
        initialDate: _currentDate != null
            ? _currentDate
            : DateTime.now().subtract(Duration(days: 1)),
        firstDate: DateTime(2021, 06, 01),
        lastDate: DateTime.now().subtract(Duration(days: 1)));
    if (_pickedDate != null) {
      loadPreviousPlanData(_pickedDate);
    }
  }

  void _editPreviousPlan() {
    Provider.of<Plan>(context, listen: false).initEditCompletePlan(planList);
    Navigator.of(context).pushNamed(CreatePlanScreen.routeName).then((value) {
      loadPreviousPlanData(_currentDate);
    });
  }

  void _editTodaysPlan() {
    Provider.of<Plan>(context, listen: false).initEditCompletePlan(plan);
    Provider.of<Plan>(context, listen: false).setTodaysEditingPlanId();
    Navigator.of(context).pushNamed(CreatePlanScreen.routeName).then((value) =>
        setState(
            () => plan = Provider.of<Plan>(context, listen: false).todaysPlan));
  }

  void markTodaysPlan({@required bool tick, @required PlanItem item}) async {
    try {
      Provider.of<Plan>(context, listen: false).initEditCompletePlan(plan);
      Provider.of<Plan>(context, listen: false).setTodaysEditingPlanId();
      await Provider.of<Plan>(context, listen: false)
          .markPlan(isToday: true, item: item, tick: tick);
    } catch (err) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  void markPreviousPlan({@required bool tick, @required PlanItem item}) async {
    Provider.of<Plan>(context, listen: false).initEditCompletePlan(planList);
    PlanItem backup = item;
    int index = planList.indexOf(item);
    try {
      if (index >= 0) {
        PlanItem temp = PlanItem(
          category: item.category,
          task: item.task,
          priority: item.priority,
          done: tick,
          startTimeH: item.startTimeH,
          startTimeM: item.startTimeM,
          endTimeH: item.endTimeH,
          endTimeM: item.endTimeM,
        );

        setState(() {
          planList[index] = temp;
        });
        await Provider.of<Plan>(context, listen: false)
            .markPlan(isToday: false, tick: tick, item: item);
      }
    } on Exception catch (err) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err.toString())));
      setState(() {
        planList[index] = backup;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    plan = Provider.of<Plan>(context).todaysPlan;
    var todaysRemarks = Provider.of<Plan>(context).todaysRemarks;
    final deviceSize = MediaQuery.of(context).size;
    todaysPlanRating = Provider.of<Plan>(context).todaysFeedback;
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("View Plans"),
          bottom: TabBar(
            onTap: (index) {
              if (index == 0) setState(() {});
            },
            tabs: <Widget>[
              Tab(
                text: "Today",
              ),
              Tab(
                text: "Previous",
              ),
            ],
          ),
        ),
        body: TabBarView(children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: plan.length == 0
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Create your today's plan"),
                              SizedBox(
                                height: 20.0,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacementNamed(
                                      ChooseCreatePlan.routeName);
                                },
                                child: Text('Create'),
                              ),
                            ],
                          ),
                        )
                      : ListView(children: [
                          Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                OutlinedButton.icon(
                                  style: ButtonStyle(
                                      visualDensity: VisualDensity.comfortable),
                                  onPressed: _editTodaysPlan,
                                  label: Text(
                                    "Edit Plan",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  icon: Icon(
                                    Icons.edit,
                                    size: 18,
                                  ),
                                ),
                                OutlinedButton.icon(
                                  style: ButtonStyle(
                                      visualDensity: VisualDensity.comfortable),
                                  onPressed: () {
                                    _showRemarks(todaysRemarks, DateTime.now());
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
                                OutlinedButton.icon(
                                  style: ButtonStyle(
                                      visualDensity: VisualDensity.comfortable),
                                  onPressed: () => _deletePlan(DateTime.now()),
                                  label: Text(
                                    "Delete Plan",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  icon: Icon(
                                    Icons.delete,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(AutoRearrange.routeName);
                              },
                              icon: Icon(Icons.refresh),
                              label: Text('Auto-Rearrange Plan')),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemCount: plan.length,
                            itemBuilder: (ctx, i) => ViewPlanItem(
                              item: plan[i],
                              markPlan: markTodaysPlan,
                            ),
                          ),
                          if (plan.length > 0)
                            Card(
                              elevation: 5,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    "Rating",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  RatingBar.builder(
                                    initialRating: todaysPlanRating,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      todaysPlanRating = rating;
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  OutlinedButton(
                                    onPressed: () async {
                                      try {
                                        await Provider.of<Plan>(context,
                                                listen: false)
                                            .saveFeedback(
                                                date: DateTime.now(),
                                                feedback: todaysPlanRating);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text('Saved!')));
                                      } on HttpException catch (err) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(err.toString())));
                                      } catch (err) {
                                        print(err);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Error, Unable to process!')));
                                      }
                                    },
                                    child: Text("Save"),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                        ]),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: Icon(Icons.calendar_today_outlined),
                            label: _currentDate == null
                                ? Text("Choose Date")
                                : Text(
                                    DateFormat.yMMMMd().format(_currentDate)),
                          ),
                        ],
                      ),
                    ),
                    if (_errorOccured)
                      Container(
                          margin: EdgeInsets.only(top: deviceSize.height / 4),
                          alignment: Alignment.center,
                          child: Text(_errorMessage)),
                    if (_isPreviousPlanLoading)
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(top: deviceSize.height / 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        ),
                      )
                    else if (planList.isNotEmpty)
                      Container(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton.icon(
                              style: ButtonStyle(
                                  visualDensity: VisualDensity.comfortable),
                              onPressed: _editPreviousPlan,
                              label: Text(
                                "Edit Plan",
                                style: TextStyle(fontSize: 12),
                              ),
                              icon: Icon(
                                Icons.edit,
                                size: 18,
                              ),
                            ),
                            OutlinedButton.icon(
                              style: ButtonStyle(
                                  visualDensity: VisualDensity.comfortable),
                              onPressed: () {
                                var remarks =
                                    Provider.of<Plan>(context, listen: false)
                                        .previousPlanRemarks;
                                _showRemarks(remarks, _currentDate);
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
                            OutlinedButton.icon(
                              style: ButtonStyle(
                                  visualDensity: VisualDensity.comfortable),
                              onPressed: () {
                                _deletePlan(_currentDate);
                              },
                              label: Text(
                                "Delete Plan",
                                style: TextStyle(fontSize: 12),
                              ),
                              icon: Icon(
                                Icons.delete,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: planList.length,
                      itemBuilder: (ctx, i) => ViewPlanItem(
                        item: planList[i],
                        markPlan: markPreviousPlan,
                      ),
                    ),
                    if (planList.length > 0)
                      Card(
                        elevation: 5,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Rating",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            RatingBar.builder(
                              initialRating: previousPlanRating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                previousPlanRating = rating;
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            OutlinedButton(
                              onPressed: () async {
                                try {
                                  await Provider.of<Plan>(context,
                                          listen: false)
                                      .saveFeedback(
                                          date: _currentDate,
                                          feedback: previousPlanRating);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Saved!')));
                                } on HttpException catch (err) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(err.toString())));
                                } catch (err) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Error, Unable to process!')));
                                }
                              },
                              child: Text("Save"),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                  ]),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
