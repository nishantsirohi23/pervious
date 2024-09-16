import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import SystemChrome
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:perwork/postwork/profform.dart';
import 'package:perwork/postwork/workerverify.dart';
import 'package:perwork/screens/costumer/trackproflocation.dart';
import 'package:perwork/screens/maps/directionScreen.dart';
import 'package:perwork/screens/naviagtion_items/HomeScreenContent.dart';
import 'package:perwork/taskerdash/deliver.dart';
import 'package:perwork/try/my_global.dart';
import 'package:perwork/try/pigeon.dart';
import 'package:perwork/try/splash.dart';
import 'package:perwork/widget_tree.dart';
import 'package:perwork/widgets/addrest.dart';
import 'package:provider/provider.dart';

import 'api/apis.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _initializeFirebase();
  await Globals.fetchApiKey();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize("1baa9293-ad9b-4076-8850-798be5ddd231");

// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt

  OneSignal.Notifications.requestPermission(true);

  // Set fullscreen mode for Android





  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String? screen;

  const MyApp({Key? key, this.screen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ApiKeyProvider()..fetchApiKey(),
      child: MaterialApp(
        home: SplashScreen(name: '',),
      ),
    );
  }
}


_initializeFirebase() async {

  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  log('\nNotification Channel Result: $result');
}

