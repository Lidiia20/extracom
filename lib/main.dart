import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

import 'app/routes/app_pages.dart';
import 'app/utils/storage.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/providers/api_provider.dart';
import 'app/modules/asset_data/providers/asset_api_provider.dart';
import 'app/modules/asset_data/services/asset_service.dart';
// import 'app/modules/nota/providers/nota_provider.dart';
// import 'app/modules/nota/services/nota_service.dart';
import 'app/modules/asset_data/services/qr_code_service.dart';
import 'app/modules/asset_data/services/dropdown_options_service.dart';
import 'app/modules/asset_data/services/asset_history_service.dart';

// Create a logger instance
final logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://rbxqxuuefpvwkirwyxez.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJieHF4dXVlZnB2d2tpcnd5eGV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYwODAxMjUsImV4cCI6MjA2MTY1NjEyNX0.4nU2V_uMLBdJXrjFdasT9Jx064IT7iEjhusHbWkm4pI',
  );
  
  await GetStorage.init();
  await initServices();
  
  runApp(const MyApp());
}

Future<void> initServices() async {
  logger.i('Inisialisasi layanan...');

  try {
    // Initialize storage utility first
    await Get.putAsync(() => StorageUtil().init());
    await Get.putAsync(() => QrCodeService().init());

    // Register providers before services that depend on them
    Get.put(ApiProvider());
    Get.put(AssetApiProvider());
    
    // Nota feature is not ready yet
    // Get.put(NotaProvider()); 
    
    // Register DropdownOptionsService with init method
    await Get.putAsync(() => DropdownOptionsService().init());

    // Initialize services that depend on providers
    await Get.putAsync(() => AuthService().init());
    
    // Register AssetService
    Get.put(AssetService());
    
    // Register AssetHistoryService
    Get.put(AssetHistoryService());

    // Nota feature is not ready yet
    // final notaProvider = Get.find<NotaProvider>();
    // await Get.putAsync(() => NotaService(notaProvider: notaProvider).init());

    logger.i('Semua layanan dimulai...');
  } catch (e) {
    logger.e('Error initializing services: $e');
    // Rethrow to make sure the error isn't silently ignored
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ExstraCoM - PLN',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      navigatorKey: Get.key,
    );
  }
}