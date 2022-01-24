import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';

import 'flavors.dart';
import 'ui/views/memo_list_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YAMemo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: "MPLUSRounded1c",
      ),
      routes: {
        MemoListScreen.id: (context) => const MemoListScreen(),
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
      home: I18n(
          child: _flavorBanner(
        child: const MemoListScreen(),
        show: kDebugMode,
      )),
    );
  }

  Widget _flavorBanner({
    required Widget child,
    bool show = true,
  }) =>
      show
          ? Banner(
              child: child,
              location: BannerLocation.topStart,
              message: F.name,
              color: Colors.green.withOpacity(0.6),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.0,
                  letterSpacing: 1.0),
              textDirection: TextDirection.ltr,
            )
          : Container(
              child: child,
            );
}
