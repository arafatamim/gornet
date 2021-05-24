import 'package:chillyflix/Models/FtpbdModel.dart';
import 'package:chillyflix/Pages/DetailPage.dart';
import 'package:chillyflix/Pages/SearchPage.dart';
import 'package:chillyflix/theme/modern.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:chillyflix/Pages/HomePage.dart';
import 'package:chillyflix/Services/FtpbdService.dart';

// extension Precision on double {
//   double toPrecision(int fractionDigits) {
//     double mod = pow(10, fractionDigits.toDouble());
//     return ((this * mod).round().toDouble() / mod);
//   }
// }

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FtpbdService>(create: (_) => FtpbdService()),
      ],
      child: Shortcuts(
        // needed for AndroidTV to be able to select
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent()
        },
        child: MaterialApp(
          title: 'Goriber Netflix',
          theme: ModernTheme.darkTheme,
          home: HomePage(title: 'Goriber Netflix'),
          onGenerateRoute: (settings) {
            if (settings.name == "/detail") {
              return MaterialPageRoute(
                settings: RouteSettings(name: "detail"),
                builder: (context) =>
                    DetailPage(settings.arguments as SearchResult),
              );
            }
            if (settings.name == "/search") {
              return MaterialPageRoute(
                settings: RouteSettings(name: "search"),
                builder: (context) => SearchPage(),
              );
            }
          },
        ),
      ),
    );
  }
}
