import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './screens/change_password_screen.dart';
import './screens/delete_account_screen.dart';
import './screens/auto_generate_plan_screen.dart';
import './screens/auto_rearrange_screen.dart';
import './screens/performance_screen.dart';
import './providers/profile.dart';
import './screens/choose_create_plan_screen.dart';
import './screens/create_plan_screen.dart';
import './screens/view_routine_screen.dart';
import './screens/account_screen.dart';
import "./screens/auth_screen.dart";
import "./screens/homepage_screen.dart";
import './screens/profile_screen.dart';
import './screens/settings_screen.dart';
import './screens/about_screen.dart';
import "./screens/splash_screen.dart";
import "./screens/fill_new_profile_screen.dart";
import "./providers/auth.dart";
import "./providers/plan.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Profile>(
            create: null,
            update: (ctx, auth, previousProfile) => Profile(
                token: auth.token,
                profileData: previousProfile == null
                    ? Profile.profileInit
                    : previousProfile.profileData),
          ),
          ChangeNotifierProxyProvider<Auth, Plan>(
            create: null,
            update: (ctx, auth, previousPlan) => Plan(
              token: auth.token,
              tempPlan: previousPlan != null ? previousPlan.tempPlan : [],
              todaysPlanList:
                  previousPlan != null ? previousPlan.todaysPlanList : [],
              planConfig: previousPlan != null
                  ? previousPlan.planConfig
                  : Plan.planConfigInit,
            ),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Routine Planner',
            theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepPurpleAccent.shade200,
                fontFamily: 'Raleway'),
            home: auth.isAuth
                ? MyHomePage()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              MyHomePage.routeName: (ctx) => MyHomePage(),
              ProfileScreen.routeName: (ctx) => ProfileScreen(),
              AccountScreen.routeName: (ctx) => AccountScreen(),
              SettingsScreen.routeName: (ctx) => SettingsScreen(),
              AboutScreen.routeName: (ctx) => AboutScreen(),
              ChooseCreatePlan.routeName: (ctx) => ChooseCreatePlan(),
              CreatePlanScreen.routeName: (ctx) => CreatePlanScreen(),
              ViewRoutineScreen.routeName: (ctx) => ViewRoutineScreen(),
              NewProfile.routeName: (ctx) => NewProfile(),
              PerformanceScreen.routeName: (ctx) => PerformanceScreen(),
              AutoRearrange.routeName: (ctx) => AutoRearrange(),
              AutoGeneratePlan.routeName: (ctx) => AutoGeneratePlan(),
              ChangePasswordScreen.routeName: (ctx) => ChangePasswordScreen(),
              DeleteAccountScreen.routeName: (ctx) => DeleteAccountScreen()
            },
          ),
        ));
  }
}
