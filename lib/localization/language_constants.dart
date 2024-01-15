import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String LAGUAGE_CODE = 'languageCode';
const String THEME = 'THEME';


//languages code
const String ENGLISH = 'en';
const String FRENCH = 'fr';
const String ARABIC = 'ar';
const String Indonesia = 'id';
//languages code
const String LIGHT = 'light';
const String DARK = 'dark';


Future<Locale> setLocaleLang(String langCode)async{
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, langCode);
  return _locale(langCode);

}
Future<ThemeData> setTheme(String theme) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(THEME, theme);
  if(theme=="dark")
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.white,
    /*  accentColor: Color(0xFF282B30),
      canvasColor: Color(0xFFFFD503),
      shadowColor: Color(0xFFFFFFFF),
      primaryColorDark:Color(0xFFAFD754),*/
    );
  else
    return ThemeData.light().copyWith(
      primaryColor: AppColors.pink2,
     /* accentColor: Color(0xFFAFD754),
      canvasColor: Color(0xFFFFD503),
      shadowColor: Color(0xFF000000),
      primaryColorDark:Color(0xFF000000),*/
    );
}
Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? await getLocalPhoneLang();
  return _locale(languageCode);
}

Future<String> getLocalPhoneLang() async{
  // الحصول على لغة الجهاز
  String deviceLanguage = PlatformDispatcher.instance.locale.languageCode;
  String lang;
  if (deviceLanguage == "ar") {
    lang = "ar";
  } else if (deviceLanguage == "en") {
    lang = "en";
  } else if (deviceLanguage == "fr") {
    lang = "fr";
  } else if (deviceLanguage == "id") {
    lang = "id";
  } else {
    lang = "en";
  }

  await setLocaleLang(lang);
  return lang;
}


 getCurrentLang() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? "en";
  return languageCode;
}
Future<ThemeData> getTheme() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  
  String themeCode = _prefs.getString(THEME) ?? "light";
  if(themeCode=="dark")
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.white,
     /* accentColor: Color(0xFF282B30),
      canvasColor: Color(0xFFFFD503),
      shadowColor: Color(0xFFFFFFFF),
      primaryColorDark:Color(0xFFAFD754),*/


    );
  else
    return ThemeData.light().copyWith(
      primaryColor: AppColors.pink2,
      /*accentColor: Color(0xFFAFD754),
      canvasColor: Color(0xFFFFD503),
      shadowColor: Color(0xFF000000),
      primaryColorDark:Color(0xFF000000),*/



    );

}
Future<String> getThemeName() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  
  String themeCode = _prefs.getString(THEME) ?? "light";
  return themeCode;

}
Future<bool> getFirstLanch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.containsKey("firstLaunch")) {
    return false;
  } else {
    await prefs.setBool("firstLaunch", true);
    return true;
  }
}
Future<String> getLangCode() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? "en";
  return languageCode;
}
Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return Locale(ENGLISH, 'US');
    case FRENCH:
      return Locale(FRENCH, "FR");
    case ARABIC:
      return Locale(ARABIC, "AR");
    case Indonesia:
      return Locale(Indonesia, "ARB");
    default:
      return Locale(ENGLISH, 'US');
  }
}