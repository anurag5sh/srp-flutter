import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../widgets/upcoming_plans.dart';
import '../widgets/random_quotes.dart';
import '../providers/plan.dart';
import '../models/http_exception.dart';
import '../screens/fill_new_profile_screen.dart';
import '../providers/profile.dart';
import '../widgets/app_drawer.dart';
import 'choose_create_plan_screen.dart';
import 'view_routine_screen.dart';

class MyHomePage extends StatefulWidget {
  static final routeName = "/homepage";
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future profileFuture;
  Map<String, dynamic> profile;
  var author = '';
  var quote = '';
  var remarks = [];
  bool noInternet = false;

  @mustCallSuper
  void initState() {
    profileFuture = getProfile();

    super.initState();
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

  Future<void> getProfile() async {
    noInternet = false;
    try {
      profile = await Provider.of<Profile>(context, listen: false).profile();
      await Provider.of<Plan>(context, listen: false).getTodaysPlan();
      await getQuotes();
    } on SocketException {
      noInternet = true;
    } on HttpException catch (error) {
      if (error.toString().contains('no profile')) {
        Navigator.of(context).pushReplacementNamed(NewProfile.routeName);
      }
      if (error.toString().toLowerCase().contains('token')) {
        Provider.of<Auth>(context, listen: false).logout();
      }
    } catch (error) {
      print("caught error :" + error.toString());
    }
  }

  Future<void> getQuotes() async {
    final url =
        Uri.parse('https://quotable.io/random?tags=inspirational&limit=1');
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Something went wrong!');
      }

      final responseData = json.decode(response.body);
      setState(() {
        quote = responseData['content'];
        author = toBeginningOfSentenceCase(responseData['author']);
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Routine Planner"),
      ),
      body: FutureBuilder(
        future: profileFuture,
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : profile == null
                ? noInternet
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Unable to reach the server!\nPlease check your internet connection.",
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            OutlinedButton(
                              onPressed: () {
                                getProfile();
                              },
                              child: Text('Retry'),
                            )
                          ],
                        ),
                      )
                    : Text('Creating your profile..')
                : RefreshIndicator(
                    onRefresh: getProfile,
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        ListTile(
                          title: Text(
                            'Welcome ${profile['name'].split(" ")[0]}',
                            style: TextStyle(fontSize: 20),
                          ),
                          subtitle: Provider.of<Plan>(context)
                                  .todaysPlan
                                  .isEmpty
                              ? Text('You don\'t have a plan for today.')
                              : Text(
                                  'You have tasks ${(Provider.of<Plan>(context).todaysPlan.length - Provider.of<Plan>(context).completedTasks).round()}/${Provider.of<Plan>(context).todaysPlan.length} tasks pending.\n Overall Score is ${double.parse(Provider.of<Plan>(context).overallScore.toString()).round()}%'),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Provider.of<Plan>(context).todaysPlan.isEmpty
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 80,
                                  ),
                                  Text(
                                    'Create a plan for today!',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                          ChooseCreatePlan.routeName);
                                    },
                                    icon: Icon(Icons.more_time_rounded),
                                    label: Text('Create Plan'),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                ],
                              )
                            : Card(
                                elevation: 4.0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Today\'s Plan',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    UpcomingPlans(
                                      todaysPlan:
                                          Provider.of<Plan>(context).todaysPlan,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                            ViewRoutineScreen.routeName);
                                      },
                                      icon: Icon(Icons.calendar_today_rounded),
                                      label: Text('View Entire Routine'),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                        SizedBox(
                          height: 30,
                        ),
                        if (Provider.of<Plan>(context).todaysPlan.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Wrap(
                              children: [
                                Text(
                                  'Suggestions',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                if (Provider.of<Plan>(context).todaysRemarks !=
                                        null &&
                                    Provider.of<Plan>(context)
                                            .todaysRemarks
                                            .length <=
                                        2)
                                  ...Provider.of<Plan>(context)
                                      .todaysRemarks
                                      .map(
                                        (item) => Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "• ",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Expanded(
                                              child: Text(
                                                item,
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList()
                                else
                                  Wrap(
                                    children: [
                                      ...Provider.of<Plan>(context)
                                          .todaysRemarks
                                          .sublist(0, 2)
                                          .map(
                                            (item) => Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "• ",
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    item,
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      TextButton(
                                        onPressed: () => _showRemarks(
                                            Provider.of<Plan>(context,
                                                    listen: false)
                                                .todaysRemarks,
                                            DateTime.now()),
                                        child: Text('See all Remarks'),
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ),
                        SizedBox(
                          height: 40,
                        ),
                        RandomQuotes(
                          quote: quote,
                          author: author,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
      ),
      drawer: AppDrawer(),
    );
  }
}
