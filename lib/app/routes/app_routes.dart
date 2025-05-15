// part of 'app_pages.dart';

part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const SPLASH = _Paths.SPLASH;
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const ASSET_DATA = _Paths.ASSET_DATA;
  static const ASSET_DETAIL = _Paths.ASSET_DETAIL;
  static const ASSET_FORM = _Paths.ASSET_FORM;
  static const ADD_ASSET = _Paths.ADD_ASSET;
  static const EDIT_ASSET = _Paths.EDIT_ASSET;
  static const CATEGORY = _Paths.CATEGORY;
  static const NOTA = _Paths.NOTA;
  static const LOCATION = _Paths.LOCATION;
  static const CONDITION = _Paths.CONDITION;
  static const ASSET_HISTORY = _Paths.ASSET_HISTORY;
  static const QR_SCANNER = _Paths.QR_SCANNER;
  static const QR_GALLERY = _Paths.QR_GALLERY;
  static const ASSET_REPORT = _Paths.ASSET_REPORT;
  static const ASSET_REPORT_FULL_LIST = _Paths.ASSET_REPORT_FULL_LIST;
}

abstract class _Paths {
  _Paths._();

  static const SPLASH = '/splash';
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const ASSET_DATA = '/asset-data';
  static const ASSET_DETAIL = '/asset-detail';
  static const ASSET_FORM = '/asset-form';
  static const ADD_ASSET = '/add-asset';
  static const EDIT_ASSET = '/edit-asset';
  static const CATEGORY = '/category';
  static const NOTA = '/nota';
  static const ASSET_NOTA = '/asset-nota';
  static const LOCATION = '/location';
  static const CONDITION = '/condition';
  static const ASSET_HISTORY = '/asset-history';
  static const QR_SCANNER = '/qr-scanner';
  static const QR_GALLERY = '/qr_gallery';
  static const ASSET_REPORT = '/asset_report';
  static const ASSET_REPORT_FULL_LIST = '/asset_report_full_list';
}
