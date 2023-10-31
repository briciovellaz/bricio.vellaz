import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'src/core/util/dependencies.dart';
import 'src/core/util/strings.dart' as strings;
import 'src/data/repository/themes_repository.dart';
import 'src/presentation/view/home.dart';

class LocalPushNotification {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('app_icon');
    InitializationSettings initializationSettings =
        const InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse:
          (NotificationResponse notificationResponse) {},
      onDidReceiveNotificationResponse: (NotificationResponse details) {},
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(),
    );
  }
}

final Dependencies dependencies = Dependencies();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dependencies.load();
  await dependencies.initialize();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => dependencies.moviesBloc),
        Provider(create: (_) => dependencies.genresByIdBloc),
        Provider(create: (_) => dependencies.savedMoviesBloc),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  final ThemesRepository themesRepository = ThemesRepository();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Map<String, ThemeData> themes = widget.themesRepository.getAll();

  @override
  void initState() {
    super.initState();
    widget.themesRepository.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: themes[strings.lightThemeName],
      darkTheme: themes[strings.darkThemeName],
      themeMode: ThemeMode.system,
      home: const Home(),
    );
  }
}
