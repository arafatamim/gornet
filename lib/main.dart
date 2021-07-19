import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Pages/detail_page.dart';
import 'package:goribernetflix/Pages/search_page.dart';
import 'package:goribernetflix/Services/favorites.dart';
import 'package:goribernetflix/Services/next_up.dart';
import 'package:goribernetflix/theme/modern.dart';
import 'package:goribernetflix/utils.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:goribernetflix/Pages/home_page.dart';
import 'package:goribernetflix/Services/api.dart';

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
          home: const HomePage(title: 'Goriber Netflix'),
          onGenerateRoute: (settings) {
            if (settings.name == "/detail") {
              return MaterialPageRoute(
                settings: const RouteSettings(name: "detail"),
                builder: (context) =>
                    DetailPage(settings.arguments as SearchResult),
              );
            }
            if (settings.name == "/search") {
              return MaterialPageRoute(
                settings: const RouteSettings(name: "search"),
                builder: (context) => SearchPage(),
              );
            }
          },
        ),
      ),
    );
  }
}
