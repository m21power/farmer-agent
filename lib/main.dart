import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maize_guard/features/community/presentation/bloc/community_bloc.dart';

import 'core/route/route.dart';
import 'dependency_injection.dart';
import 'features/Resource/presentation/bloc/info_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/help/presentation/bloc/bloc/history_bloc.dart';
import 'features/help/presentation/bloc/help_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => sl<InfoBloc>()..add(GetInfoEvent())),
          BlocProvider(
              create: (context) => sl<HistoryBloc>()..add(GetHistoryEvent())),
          BlocProvider(create: (context) => sl<HelpBloc>()),
          BlocProvider(create: (context) => sl<ProfileBloc>()),
          BlocProvider(
              create: (context) => sl<CommunityBloc>()
                ..add(GetNotificationEvent())
                ..add(GetPostsEvent())
                ..add(CheckInternetEvent())),
          BlocProvider(
              create: (context) => sl<AuthBloc>()..add(AuthCheckEvent()))
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: "Maize Guard",
          routerConfig: router,
        ));
  }
}
