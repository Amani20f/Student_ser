import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(const Locale('ar'));

  void toggleLanguage() {
    emit(state.languageCode == 'en' ? const Locale('ar') : const Locale('en'));
  }

  void setLanguage(Locale locale) {
    emit(locale);
  }
}

