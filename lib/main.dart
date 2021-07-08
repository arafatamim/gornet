import 'package:chillyflix/Models/models.dart';
import 'package:chillyflix/Pages/DetailPage.dart';
import 'package:chillyflix/Pages/SearchPage.dart';
import 'package:chillyflix/Services/favorites.dart';
import 'package:chillyflix/Services/next_up.dart';
import 'package:chillyflix/theme/modern.dart';
import 'package:chillyflix/utils.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:chillyflix/Pages/HomePage.dart';
import 'package:chillyflix/Services/api.dart';

// extension Precision on double {
//   double toPrecision(int fractionDigits) {
//     double mod = pow(10, fractionDigits.toDouble());
//     return ((this * mod).round().toDouble() / mod);
//   }
// }

void main() {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIOverlays([]);
  } catch (e) {
    print(e);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.0.100:6767/api",
      responseType: ResponseType.json,
      receiveDataWhenStatusError: true,
    ),
  )..interceptors.addAll([
      // InterceptorsWrapper(
      //   onError: (DioError e, _handler) {
      //     throw ServerError.fromJson(e.response?.data ?? "Woooooaahh");
      //     // print(e.message);
      //     // return _handler.next(e);
      //   },
      // ),
      DioCacheInterceptor(options: cacheOptions)
    ]);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FtpbdService>(
          create: (_) => FtpbdService(dioClient: dio),
        ),
        Provider<FavoritesService>(
          create: (_) => FavoritesService(dioClient: dio),
        ),
        Provider<NextUpService>(
          create: (_) => NextUpService(dioClient: dio),
        ),
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
