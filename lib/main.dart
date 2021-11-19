/*
 * Copyright (c) 2021 Kennedy Yinusa
 * Kenaff Technology
 *
 */

import 'dart:io';
import 'package:mpipe/Helpers/config.dart';
import 'package:audio_service/audio_service.dart';
import 'package:mpipe/Screens/Library/nowplaying.dart';
import 'package:mpipe/Screens/Library/playlists.dart';
import 'package:mpipe/Screens/Library/recent.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mpipe/Screens/About/about.dart';
import 'package:mpipe/Screens/Home/home.dart';
import 'package:mpipe/Screens/Settings/setting.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mpipe/Screens/Login/auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  try {
    await Hive.openBox('settings');
  } catch (e) {
    print('Failed to open Settings Box');
    print("Error: $e");
    var dir = await getApplicationDocumentsDirectory();
    String dirPath = dir.path;
    String boxName = "settings";
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox("settings");
  }
  try {
    await Hive.openBox('cache');
  } catch (e) {
    print('Failed to open Cache Box');
    print("Error: $e");
    var dir = await getApplicationDocumentsDirectory();
    String dirPath = dir.path;
    String boxName = "cache";
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox("cache");
  }
  try {
    await Hive.openBox('recentlyPlayed');
  } catch (e) {
    print('Failed to open Recent Box');
    print("Error: $e");
    var dir = await getApplicationDocumentsDirectory();
    String dirPath = dir.path;
    String boxName = "recentlyPlayed";
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox("recentlyPlayed");
  }
  try {
    final box = await Hive.openBox('songDetails');
    // clear box if it grows large
    // each song detail is about 3.9KB so it's <5MB
    if (box.length > 1200) {
      box.clear();
    }
    await Hive.openBox('songDetails');
  } catch (e) {
    print('Failed to open songDetails Box');
    print("Error: $e");
    var dir = await getApplicationDocumentsDirectory();
    String dirPath = dir.path;
    String boxName = "songDetails";
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox("songDetails");
  }
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Failed to initialize Firebase');
  }

  Paint.enableDithering = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      setState(() {});
    });
  }

  initialFuntion() {
    return Hive.box('settings').get('name') != null
        ? AudioServiceWidget(child: HomePage())
        : AuthScreen();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'mPipe',
      debugShowCheckedModeBanner: false,
      themeMode: currentTheme.currentTheme(), //system,
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: currentTheme.currentColor(),
          cursorColor: currentTheme.currentColor(),
          selectionColor: currentTheme.currentColor(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: currentTheme.currentColor())),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
        accentColor: currentTheme.currentColor(),
      ),

      darkTheme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: currentTheme.currentColor(),
          cursorColor: currentTheme.currentColor(),
          selectionColor: currentTheme.currentColor(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: currentTheme.currentColor())),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(color: currentTheme.getCanvasColor()),
        canvasColor: currentTheme.getCanvasColor(),
        cardColor: currentTheme.getCardColor(),
        dialogBackgroundColor: currentTheme.getCardColor(),
        accentColor: currentTheme.currentColor(),
      ),
      routes: {
        '/': (context) => initialFuntion(),
        '/setting': (context) => SettingPage(),
        '/about': (context) => AboutScreen(),
        '/playlists': (context) => PlaylistScreen(),
        '/nowplaying': (context) => NowPlaying(),
        '/recent': (context) => RecentlyPlayed(),
      },
    );
  }
}
