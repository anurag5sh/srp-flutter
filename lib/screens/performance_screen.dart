import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_routine_planner/models/http_exception.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../providers/plan.dart';

class PerformanceScreen extends StatefulWidget {
  static final routeName = '/performance';
  static var completedTasks = 0.0;
  static var totalTasks = 0;
  static var percentComplete = 0.0;
  static var weeklyData = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  static var monthlyDataInit = [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0
  ];

  static List<String> months = [
    "january",
    "february",
    "march",
    "april",
    "may",
    "june",
    "july",
    "august",
    "september",
    "october",
    "november",
    "december"
  ];

  @override
  _PerformanceScreenState createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  String weeklyError = '';
  var monthlyData = PerformanceScreen.monthlyDataInit;
  String monthlyError = '';

  var selectedMonth = PerformanceScreen.months[DateTime.now().month - 1];

  @override
  Widget build(BuildContext context) {
    PerformanceScreen.completedTasks =
        Provider.of<Plan>(context).completedTasks;
    PerformanceScreen.totalTasks = Provider.of<Plan>(context).todaysPlan.length;
    PerformanceScreen.percentComplete =
        (PerformanceScreen.completedTasks / PerformanceScreen.totalTasks) * 100;
    final deviceSize = MediaQuery.of(context).size;

    getWeeklyStats() async {
      try {
        final List response =
            await Provider.of<Plan>(context).getStats(isWeek: true);
        DateTime today = DateTime.now();
        DateTime _firstDayOfTheweek =
            today.subtract(Duration(days: today.weekday));

        for (var i = 0; i < today.weekday; i++) {
          DateTime day = _firstDayOfTheweek.add(Duration(days: (i + 1)));
          try {
            var dayScore = response.firstWhere((element) {
              var data = element[0].split("/");
              DateTime d = DateTime(
                  int.parse(data[2]), int.parse(data[1]), int.parse(data[0]));
              if (d.year == day.year &&
                  d.month == day.month &&
                  d.day == day.day) return true;
              return false;
            });

            PerformanceScreen.weeklyData[i] =
                dayScore[1].toDouble().roundToDouble();
          } catch (e) {
            debugPrint(e.toString());
          }
        }
        weeklyError = '';
      } on HttpException catch (err) {
        weeklyError = err.toString();
      } catch (err) {
        weeklyError = 'Routine does not exist!';
      }
    }

    getMonthlyStats({String month}) async {
      try {
        final List response = await Provider.of<Plan>(context, listen: false)
            .getStats(isWeek: false, month: month);

        for (var i = 0; i < 31; i++) {
          try {
            var dayScore = response.firstWhere((element) {
              return (i + 1) == element[0];
            });

            monthlyData[i] = dayScore[1].toDouble().roundToDouble();
          } catch (e) {
            monthlyData[i] = 0;
          }
        }
        monthlyError = '';
      } on HttpException catch (err) {
        for (var i = 0; i < 31; i++) {
          monthlyData[i] = 0;
        }
        monthlyError = err.toString();
      } catch (err) {
        monthlyError = 'Routine does not exist!';
      }
    }

    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Performance"),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                text: "Daily",
              ),
              Tab(
                text: "Weekly",
              ),
              Tab(
                text: "Monthly",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            //Daily Chart
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  if (Provider.of<Plan>(context).todaysPlan.isEmpty)
                    Text(
                      'You have not created today\'s Plan.',
                      style: TextStyle(fontSize: 16),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 200,
                          height: deviceSize.height * 0.3,
                          child: SfCircularChart(
                            margin: EdgeInsets.all(0.0),
                            series: _getDailyDoughnutSeries(),
                          ),
                        ),
                        Text(
                          "Overall Score\n${double.parse(Provider.of<Plan>(context).overallScore).round()}%",
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                ],
              ),
            ),

            //Weekly Chart
            SingleChildScrollView(
              child: FutureBuilder(
                future: getWeeklyStats(),
                builder: (ctx, snapshot) =>
                    snapshot.connectionState == ConnectionState.waiting
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                height: deviceSize.height * 0.5,
                                child: SfCartesianChart(
                                  plotAreaBorderWidth: 0,
                                  primaryXAxis: CategoryAxis(
                                    majorGridLines: MajorGridLines(width: 0),
                                  ),
                                  primaryYAxis: NumericAxis(
                                      // title: AxisTitle(text: "Score"),
                                      axisLine: AxisLine(width: 0),
                                      labelFormat: '{value}%',
                                      majorTickLines: MajorTickLines(size: 0)),
                                  series: _getDefaultColumnSeries(),
                                  tooltipBehavior: TooltipBehavior(
                                      enable: true,
                                      header: 'Score',
                                      canShowMarker: false),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              if (weeklyError != null && weeklyError != '')
                                Text(
                                  'Error - $weeklyError',
                                  style: TextStyle(fontSize: 16),
                                )
                            ],
                          ),
              ),
            ),

            //Monthly Chart
            SingleChildScrollView(
              child: FutureBuilder(
                future: getMonthlyStats(month: selectedMonth),
                builder: (ctx, snapshot) => snapshot.connectionState ==
                        ConnectionState.waiting
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(
                        children: [
                          DropdownButton(
                            items: PerformanceScreen.months
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  toBeginningOfSentenceCase(value),
                                  style: TextStyle(color: Colors.black),
                                ),
                              );
                            }).toList(),
                            hint: Text("Choose Month"),
                            value: selectedMonth,
                            onChanged: (value) {
                              setState(() {
                                selectedMonth = value;
                              });

                              getMonthlyStats(month: selectedMonth);
                            },
                          ),
                          SizedBox(height: 20),
                          SfCartesianChart(
                            plotAreaBorderWidth: 0,
                            // legend: Legend(
                            //     isVisible: true ? false : true,
                            //     overflowMode: LegendItemOverflowMode.wrap),
                            primaryXAxis: NumericAxis(
                                edgeLabelPlacement: EdgeLabelPlacement.shift,
                                interval: 1,
                                majorGridLines: MajorGridLines(width: 0)),
                            primaryYAxis: NumericAxis(
                                majorGridLines: MajorGridLines(width: 0.5),
                                labelFormat: '{value}%',
                                axisLine: AxisLine(width: 0),
                                majorTickLines:
                                    MajorTickLines(color: Colors.transparent)),
                            series: _getDefaultLineSeries(monthlyData),
                            tooltipBehavior: TooltipBehavior(enable: true),
                          ),
                          SizedBox(height: 20),
                          if (monthlyError != null && monthlyError != '')
                            Text(
                              'Error - $monthlyError',
                              style: TextStyle(fontSize: 16),
                            )
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoughnutData {
  final String xData;
  final num yData;
  final String text;
  final Color color;
  _DoughnutData({this.xData, this.yData, this.text, this.color});
}

List<DoughnutSeries<_DoughnutData, String>> _getDailyDoughnutSeries() {
  final List<_DoughnutData> chartData = <_DoughnutData>[
    _DoughnutData(
        xData: 'Complete',
        yData: PerformanceScreen.percentComplete.round(),
        text: '${PerformanceScreen.percentComplete.round()}%\nComplete',
        color: Colors.green.shade600),
    _DoughnutData(
        xData: 'Pending',
        yData: 100 - PerformanceScreen.percentComplete.round(),
        text: '${100 - PerformanceScreen.percentComplete.round()}%\nPending',
        color: Colors.indigo.shade100),
  ];
  return <DoughnutSeries<_DoughnutData, String>>[
    DoughnutSeries<_DoughnutData, String>(
      radius: '90%',
      // explode: true,
      // explodeOffset: '10%',
      dataSource: chartData,
      xValueMapper: (_DoughnutData data, _) => data.xData,
      yValueMapper: (_DoughnutData data, _) => data.yData,
      dataLabelMapper: (_DoughnutData data, _) => data.text,
      pointColorMapper: (_DoughnutData data, _) => data.color,
      dataLabelSettings: DataLabelSettings(isVisible: true),
      enableTooltip: true,
      innerRadius: "40%",
      animationDuration: 1000.0,
    )
  ];
}

List<ColumnSeries<ChartSampleData, String>> _getDefaultColumnSeries() {
  final List<ChartSampleData> chartData = <ChartSampleData>[
    ChartSampleData(x: 'Mon', y: PerformanceScreen.weeklyData[0]),
    ChartSampleData(x: 'Tue', y: PerformanceScreen.weeklyData[1]),
    ChartSampleData(x: 'Wed', y: PerformanceScreen.weeklyData[2]),
    ChartSampleData(x: 'Thu', y: PerformanceScreen.weeklyData[3]),
    ChartSampleData(x: 'Fri', y: PerformanceScreen.weeklyData[4]),
    ChartSampleData(x: 'Sat', y: PerformanceScreen.weeklyData[5]),
    ChartSampleData(x: 'Sun', y: PerformanceScreen.weeklyData[6]),
  ];
  return <ColumnSeries<ChartSampleData, String>>[
    ColumnSeries<ChartSampleData, String>(
      dataSource: chartData,
      xValueMapper: (ChartSampleData sales, _) => sales.x,
      yValueMapper: (ChartSampleData sales, _) => sales.y,
      dataLabelSettings: DataLabelSettings(
          isVisible: true, textStyle: const TextStyle(fontSize: 10)),
    )
  ];
}

List<LineSeries<_ChartData, num>> _getDefaultLineSeries(monthlyData) {
  var i = 1.0;
  final List<_ChartData> chartData = <_ChartData>[
    ...monthlyData.map((item) => _ChartData(i++, item)).toList(),
  ];
  return <LineSeries<_ChartData, num>>[
    LineSeries<_ChartData, num>(
        animationDuration: 2000,
        dataSource: chartData,
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y,
        width: 2,
        name: 'Score',
        markerSettings: MarkerSettings(isVisible: true)),
  ];
}

class _ChartData {
  _ChartData(this.x, this.y);
  final double x;
  final double y;
}

class ChartSampleData {
  final String x;
  final double y;

  ChartSampleData({this.x, this.y});
}
