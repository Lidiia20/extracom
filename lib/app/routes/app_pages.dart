import 'package:get/get.dart';

import '../../splash_screen.dart';
import '../modules/asset_data/bindings/asset_data_binding.dart';
import '../modules/asset_data/bindings/asset_history_binding.dart';
import '../modules/asset_data/controllers/asset_history_controller.dart';
import '../modules/asset_data/bindings/qr_scanner_binding.dart';
import '../modules/asset_data/views/asset_data_view.dart';
import '../modules/asset_data/views/asset_detail_view.dart';
import '../modules/asset_data/views/qr_scanner_view.dart';
import '../modules/asset_form/bindings/asset_form_binding.dart';
import '../modules/asset_form/views/asset_form_view.dart';
import '../modules/asset_report/bindings/asset_report_binding.dart';
import '../modules/asset_report/views/asset_report_view.dart';
import '../modules/category/bindings/category_binding.dart';
import '../modules/category/views/category_view.dart';
import '../modules/condition/bindings/condition_binding.dart';
import '../modules/condition/views/condition_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/location/bindings/location_binding.dart';
import '../modules/location/views/location_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/nota/bindings/nota_binding.dart';
import '../modules/nota/views/asset_nota_view.dart';
import '../modules/nota/views/nota_view.dart';
import '../modules/asset_report/views/asset_report_full_list_view.dart';

// lib/app/routes/app_pages.dart

import '../modules/asset_data/views/asset_history_view.dart'; // Import view riwayat aset yang sudah ada

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // Changed from INITIAL to initial to follow Dart naming conventions
  static const initial = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.ASSET_DATA,
      page: () => AssetDataView(),
      binding: AssetDataBinding(),
    ),
    GetPage(
      name: Routes.ASSET_DETAIL,
      page: () => AssetDetailView(),
      binding: AssetDataBinding(),
    ),
    // Tambahkan rute untuk riwayat aset
    GetPage(
      name: Routes.ASSET_HISTORY,
      page: () => AssetHistoryView(),
      binding: AssetDataBinding(), // Gunakan binding yang sama dengan modul asset_data
    ),
    GetPage(
      name: Routes.ADD_ASSET,
      page: () => AssetFormView(),
      binding: AssetFormBinding(),
    ),
    GetPage(
      name: Routes.EDIT_ASSET,
      page: () => AssetFormView(),
      binding: AssetFormBinding(),
    ),
    GetPage(
      name: Routes.ASSET_FORM,
      page: () => AssetFormView(),
      binding: AssetFormBinding(),
    ),
    GetPage(
      name: Routes.CATEGORY,
      page: () => const CategoryView(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: Routes.NOTA,
      page: () => const NotaView(),
      binding: NotaBinding(),
    ),
    GetPage(
      name: _Paths.ASSET_NOTA,
      page: () => AssetNotaView(
        noInventaris: Get.parameters['noInventaris'] ?? '',
        assetName: Get.parameters['assetName'] ?? 'Aset',
      ),
      binding: NotaBinding(),
    ),
    GetPage(
      name: _Paths.LOCATION,
      page: () => const LocationView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: _Paths.CONDITION,
      page: () => const ConditionView(),
      binding: ConditionBinding(),
    ),
    GetPage(
      name: Routes.QR_SCANNER,
      page: () => const QrScannerView(),
      binding: QrScannerBinding(),
    ),
    // Remove the QR_GALLERY route since QrGalleryView doesn't exist in your codebase
    GetPage(
    name: _Paths.ASSET_REPORT,
    page: () => const AssetReportView(),
    binding: AssetReportBinding(),
  ),
  GetPage(
    name: Routes.ASSET_REPORT_FULL_LIST,
    page: () => const AssetReportFullListView(),
    binding: AssetReportBinding(),
  ),
 

  ];
}
