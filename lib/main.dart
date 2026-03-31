import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'services/locale_service.dart';
import 'services/user_data_service.dart';
import 'services/api_service.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart'; // Added

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load configuration
  await NotificationService.init(); // Initialize notifications
  await LocaleService.init();
  await UserDataService.init();
  await ApiService.init();
  await AdService.init();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const CosmicExplorerApp());
}
