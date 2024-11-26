import 'dart:developer';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:iot_btl/firebase_options.dart';
import 'package:iot_btl/noti_overlay.dart';
import 'package:iot_btl/screens/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrueCallerOverlay(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    getFireData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

Future<void> getFireData() async {
  final bool status = await FlutterOverlayWindow.isPermissionGranted();
  if (!status) {
    await FlutterOverlayWindow.requestPermission();
  }
  try {
    DatabaseReference starCountRef = FirebaseDatabase.instance.ref('gas');
    starCountRef.onValue.listen(
      (DatabaseEvent event) async {
        final data = event.snapshot.value;
        log(data.toString());
        if (data == true) {
          ringNoti();
          FlutterOverlayWindow.showOverlay(
            enableDrag: true,
            overlayTitle: "X-SLAYER",
            overlayContent: 'Overlay Enabled',
            flag: OverlayFlag.defaultFlag,
            visibility: NotificationVisibility.visibilityPublic,
            positionGravity: PositionGravity.auto,
            height: 600,
            width: WindowSize.matchParent,
          );
        } else {
          FlutterRingtonePlayer.stop();
        }
      },
    );
  } catch (e) {
    log(e.toString());
  }
}

void ringNoti() {
  FlutterRingtonePlayer.play(
    fromAsset: "assets/audios/warning.wav",
    ios: IosSounds.glass,
    looping: true, // Android only - API >= 28
    volume: 1, // Android only - API >= 28
    asAlarm: false, // Android only - all APIs
  );
}
