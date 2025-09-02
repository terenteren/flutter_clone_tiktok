import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiktok_clone/constants/sizes.dart';
import 'package:tiktok_clone/generated/l10n.dart';
import 'package:tiktok_clone/router.dart';
import 'package:tiktok_clone/screens/features/videos/repos/video_playback_config_repo.dart';
import 'package:tiktok_clone/screens/features/videos/view_models/playback_config_vm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy(); // Path URL 전략 사용 (/#/ 없이)

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SharedPreferences? preferences;
  try {
    preferences = await SharedPreferences.getInstance();
    // 개발 중 테스트를 위해 기존 값 삭제 (나중에 이 줄을 제거하세요)
    // await preferences.remove('muted');
    // await preferences.remove('autoplay');
    // print('[DEBUG] SharedPreferences cleared for muted and autoplay');
  } catch (e) {
    if (kDebugMode) {
      print('SharedPreferences 초기화 실패: $e');
    }
    // SharedPreferences 초기화가 실패한 경우, null로 처리
  }

  final repository = preferences != null
      ? VideoPlaybackConfigRepository(preferences)
      : null; // 레포지토리 생성

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => repository != null
              ? PlaybackConfigViewModel(repository)
              : PlaybackConfigViewModel.withoutRepository(), // 뷰모델 생성
        ),
      ],
      child: const TikTokApp(),
    ),
  );
}

class TikTokApp extends StatelessWidget {
  const TikTokApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // S.load(Locale("en"));
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Tiktok Clone',
      localizationsDelegates: [
        S.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English, no country code
        Locale('ko'), // Spanish, no country code
        // Add other supported locales here
      ],
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: Typography.blackMountainView,
        brightness: Brightness.light,
        // textTheme: TextTheme(
        //   displayLarge: GoogleFonts.openSans(
        //     fontSize: 96,
        //     fontWeight: FontWeight.w300,
        //     letterSpacing: -1.5,
        //   ),
        //   displayMedium: GoogleFonts.openSans(
        //     fontSize: 60,
        //     fontWeight: FontWeight.w300,
        //     letterSpacing: -0.5,
        //   ),
        //   displaySmall: GoogleFonts.openSans(
        //     fontSize: 48,
        //     fontWeight: FontWeight.w400,
        //   ),
        //   headlineLarge: GoogleFonts.openSans(
        //     fontSize: 34,
        //     fontWeight: FontWeight.w400,
        //     letterSpacing: 0.25,
        //   ),
        //   headlineMedium: GoogleFonts.openSans(
        //     fontSize: 24,
        //     fontWeight: FontWeight.w400,
        //   ),
        //   headlineSmall: GoogleFonts.openSans(
        //     fontSize: 20,
        //     fontWeight: FontWeight.w500,
        //     letterSpacing: 0.15,
        //   ),
        //   titleLarge: GoogleFonts.openSans(
        //     fontSize: 20,
        //     fontWeight: FontWeight.w500,
        //     letterSpacing: 0.15,
        //   ),
        //   titleMedium: GoogleFonts.openSans(
        //     fontSize: 16,
        //     fontWeight: FontWeight.w400,
        //     letterSpacing: 0.15,
        //   ),
        //   titleSmall: GoogleFonts.openSans(
        //     fontSize: 14,
        //     fontWeight: FontWeight.w500,
        //     letterSpacing: 0.1,
        //   ),
        //   bodyLarge: GoogleFonts.roboto(
        //     fontSize: 16,
        //     fontWeight: FontWeight.w400,
        //     letterSpacing: 0.5,
        //   ),
        //   bodyMedium: GoogleFonts.roboto(
        //     fontSize: 14,
        //     fontWeight: FontWeight.w400,
        //     letterSpacing: 0.25,
        //   ),
        //   bodySmall: GoogleFonts.roboto(
        //     fontSize: 12,
        //     fontWeight: FontWeight.w400,
        //     letterSpacing: 0.4,
        //   ),
        //   labelLarge: GoogleFonts.roboto(
        //     fontSize: 14,
        //     fontWeight: FontWeight.w500,
        //     letterSpacing: 1.25,
        //   ),
        //   labelMedium: GoogleFonts.roboto(
        //     fontSize: 12,
        //     fontWeight: FontWeight.w400,
        //     letterSpacing: 0.4,
        //   ),
        //   labelSmall: GoogleFonts.roboto(
        //     fontSize: 10,
        //     fontWeight: FontWeight.w400,
        //     letterSpacing: 1.5,
        //   ),
        // ),
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Color(0xFFE9435A),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFFE9435A),
        ),
        splashColor: Colors.transparent,
        // highlightColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: Sizes.size16 + Sizes.size2,
            fontWeight: FontWeight.w600,
          ),
        ),
        tabBarTheme: TabBarThemeData(
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey.shade500,
        ),
        listTileTheme: ListTileThemeData(textColor: Colors.black),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        tabBarTheme: TabBarThemeData(
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade700,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFFE9435A),
        ),
        textTheme: Typography.whiteMountainView,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          foregroundColor: Colors.grey.shade900,
          backgroundColor: Colors.grey.shade900,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: Sizes.size16 + Sizes.size2,
            fontWeight: FontWeight.w600,
          ),
          actionsIconTheme: IconThemeData(color: Colors.grey.shade100),
          iconTheme: IconThemeData(color: Colors.grey.shade100),
        ),
        bottomAppBarTheme: BottomAppBarThemeData(color: Colors.grey.shade900),
        primaryColor: Color(0xFFE9435A),
      ),
    );
  }
}
