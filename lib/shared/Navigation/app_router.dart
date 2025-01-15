import 'package:chatdem/features/authentication/views/login_screen.dart';
import 'package:chatdem/features/authentication/views/register_screen.dart';
import 'package:flutter/cupertino.dart';

import '../../features/home/views/home_screen.dart';
import 'app_route_strings.dart';

class AppRouter {
  static final navKey = GlobalKey<NavigatorState>();

  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouteStrings.loginScreen:
        return CupertinoPageRoute(builder: (_) => const LoginScreen());
      case AppRouteStrings.registerScreen:
        return CupertinoPageRoute(builder: (_) => const RegisterScreen());
      case AppRouteStrings.homeScreen:
        return CupertinoPageRoute(builder: (_) => const HomeScreen());

      default:
        return CupertinoPageRoute(builder: (_) => const LoginScreen());
    }
  }

  static void push(String name, {Object? arg}) {
    navKey.currentState?.pushNamed(name, arguments: arg);
  }

  static void pushReplace(String name, {Object? arg}) {
    navKey.currentState?.pushReplacementNamed(name, arguments: arg);
  }

  static void pop(String name, {Object? arg}) {
    navKey.currentState?.pop(arg);
  }

  static void pushAndClear(String name, {Object? arg}) {
    navKey.currentState?.pushNamedAndRemoveUntil(name, (_) => false);
  }
}
