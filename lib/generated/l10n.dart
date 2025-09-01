// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Sign up for {nameOfTheApp}`
  String signUpTitle(String nameOfTheApp) {
    return Intl.message(
      'Sign up for $nameOfTheApp',
      name: 'signUpTitle',
      desc: 'Title for the sign up screen, with the name of the app included.',
      args: [nameOfTheApp],
    );
  }

  /// `Login to {nameOfTheApp}`
  String loginTitle(String nameOfTheApp) {
    return Intl.message(
      'Login to $nameOfTheApp',
      name: 'loginTitle',
      desc: 'The title people see when they open the log in screen.',
      args: [nameOfTheApp],
    );
  }

  /// `Create a profile, follow other accounts, make your own videos, and more.`
  String get signUpSubTitle {
    return Intl.message(
      'Create a profile, follow other accounts, make your own videos, and more.',
      name: 'signUpSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Use email & password`
  String get EmailPasswordButton {
    return Intl.message(
      'Use email & password',
      name: 'EmailPasswordButton',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Apple`
  String get appleButton {
    return Intl.message(
      'Continue with Apple',
      name: 'appleButton',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get alreadyHaveAnAccount {
    return Intl.message(
      'Already have an account?',
      name: 'alreadyHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get logIn {
    return Intl.message('Log in', name: 'logIn', desc: '', args: []);
  }

  /// `{potato}`
  String likeCount(int potato) {
    final NumberFormat potatoNumberFormat = NumberFormat.compact(
      locale: Intl.getCurrentLocale(),
    );
    final String potatoString = potatoNumberFormat.format(potato);

    return Intl.message(
      '$potatoString',
      name: 'likeCount',
      desc: 'Number of likes on a video',
      args: [potatoString],
    );
  }

  /// `{potato}`
  String commentCount(int potato) {
    final NumberFormat potatoNumberFormat = NumberFormat.compact(
      locale: Intl.getCurrentLocale(),
    );
    final String potatoString = potatoNumberFormat.format(potato);

    return Intl.message(
      '$potatoString',
      name: 'commentCount',
      desc: 'Number of comments on a video',
      args: [potatoString],
    );
  }

  /// `{potato} comment`
  String commentTitle(int potato) {
    final NumberFormat potatoNumberFormat = NumberFormat.compact(
      locale: Intl.getCurrentLocale(),
    );
    final String potatoString = potatoNumberFormat.format(potato);

    return Intl.message(
      '$potatoString comment',
      name: 'commentTitle',
      desc: 'Anything you want',
      args: [potatoString],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ko'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
