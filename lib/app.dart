import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i18n_extension/i18n_extension.dart';

import 'flavors.dart';
import 'ui/views/backup_screen.dart';
import 'ui/views/memo_list_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return I18n(
      child: MaterialApp(
        title: 'YAMemo',
        restorationScopeId: 'root',
        locale: I18n.locale,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.zenMaruGothicTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        routes: {
          MemoListScreen.id: (context) => const MemoListScreen(),
          BackupScreen.id: (context) => const BackupScreen(),
        },
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', "US"),
          Locale('ja', "JP"),
        ],
        home: _flavorBanner(
          child: const MemoListScreen(),
          show: kDebugMode,
        ),
      ),
    );
  }

  Widget _flavorBanner({
    required Widget child,
    bool show = true,
  }) =>
      show
          ? Banner(
              location: BannerLocation.topStart,
              message: F.name,
              color: Colors.green.withValues(alpha: 0.6),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.0,
                  letterSpacing: 1.0),
              textDirection: TextDirection.ltr,
              child: child,
            )
          : Container(
              child: child,
            );
}
