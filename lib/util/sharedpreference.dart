import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceUtil {
  static Future<SharedPreferences> get _instance async =>
      _prefsInstance ??= await SharedPreferences.getInstance();
  static SharedPreferences _prefsInstance;

  static final SharedPreferenceUtil _navigation =
      SharedPreferenceUtil._internal();

  factory SharedPreferenceUtil() {
    return _navigation;
  }

  SharedPreferenceUtil._internal();

  // call this method from iniState() function of mainApp().
   Future<SharedPreferences> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance;
  }

   String getString(String key, [String defValue]) {
    return _prefsInstance.getString(key) ?? defValue ?? "";
  }

   int getInt(String key, [int defValue]) {
    return _prefsInstance.getInt(key) ?? defValue ?? -1;
  }

   double getDouble(String key, [double defValue]) {
    return _prefsInstance.getDouble(key) ?? defValue ?? -1;
  }

   bool getBool(String key, [bool defValue]) {
    return _prefsInstance.getBool(key) ?? defValue ?? false;
  }

  Future<bool> setString(String key, String value) async {
    var prefs = await _instance;
    return prefs?.setString(key, value) ?? Future.value(false);
  }

   Future<bool> setInt(String key, int value) async {
    var prefs = await _instance;
    return prefs?.setInt(key, value) ?? Future.value(false);
  }

   Future<bool> setBool(String key, bool value) async {
    var prefs = await _instance;
    return prefs?.setBool(key, value) ?? Future.value(false);
  }

   Future<bool> setDouble(String key, double value) async {
    var prefs = await _instance;
    return prefs?.setDouble(key, value) ?? Future.value(false);
  }
  Future<bool> containsKey(String key) async {
    var prefs = await _instance;
    return prefs?.containsKey(key) ?? Future.value(false);
  }
}
