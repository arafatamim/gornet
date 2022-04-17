import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goribernetflix/freezed/detail_arguments.dart';
import 'package:goribernetflix/pages/profile_page.dart';
import 'package:goribernetflix/scale_page_transition.dart';
import 'package:provider/provider.dart';
import 'package:goribernetflix/pages/detail_page.dart';
import 'package:goribernetflix/pages/home_page.dart';
import 'package:goribernetflix/pages/search_page.dart';
import 'package:goribernetflix/pages/settings_page.dart';
import 'package:goribernetflix/services/api.dart';
import 'package:goribernetflix/services/favorites.dart';
import 'package:goribernetflix/services/next_up.dart';
import 'package:goribernetflix/services/trakt.dart';
import 'package:goribernetflix/services/user.dart';
import 'package:goribernetflix/theme/modern.dart';
import 'package:goribernetflix/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.0.100:6767/api",
      responseType: ResponseType.json,
      receiveDataWhenStatusError: true,
    ),
  )..interceptors.addAll([
      DioCacheInterceptor(
        options: await cacheOptions(),
      ),
    ]);

  runApp(MyApp(dio: dio));
}

class MyApp extends StatelessWidget {
  final Dio dio;

  const MyApp({
    Key? key,
    required this.dio,
  }) : super(key: key);

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
        Provider<UserService>(
          create: (_) => UserService(dioClient: dio),
        ),
        Provider<TraktService>(
          create: (_) => TraktService(
            dioClient: Dio(
              BaseOptions(
                baseUrl: "https://api.trakt.tv",
                responseType: ResponseType.json,
                receiveDataWhenStatusError: true,
              ),
            ),
          ),
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
          home: const ProfilePage(),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case "/detail":
                return ScaleRoute(
                  settings: const RouteSettings(name: "detail"),
                  page: DetailPage(settings.arguments as DetailArgs),
                );
              case "/search":
                return ScaleRoute(
                  settings: const RouteSettings(name: "search"),
                  page: SearchPage(),
                );
              case "/settings":
                return ScaleRoute(
                  settings: const RouteSettings(name: "settings"),
                  page: SettingsPage(),
                );
              case "/home":
                return ScaleRoute(
                  page: const HomePage(title: "Goriber Netflix"),
                );
              default:
                return null;
            }
          },
        ),
      ),
    );
  }
}
