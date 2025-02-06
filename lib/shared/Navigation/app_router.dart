import 'package:chatdem/features/authentication/views/login_screen.dart';
import 'package:chatdem/features/authentication/views/register_screen.dart';
import 'package:chatdem/features/home/views/chat_creation_screen.dart';
import 'package:chatdem/features/home/views/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      case AppRouteStrings.chatScreen:
        return CupertinoPageRoute(
            builder: (_) => ChatScreen(
                  arg: settings.arguments as ChatScreenArg,
                ));
      case AppRouteStrings.createChatScreen:
        return CupertinoPageRoute(builder: (_) => const ChatCreationScreen());

      default:
        return CupertinoPageRoute(builder: (_) => const LoginScreen());
    }
  }

  static Future<dynamic> push(String name, {Object? arg}) async {
    return await navKey.currentState?.pushNamed(name, arguments: arg);
  }

  static void pushReplace(String name, {Object? arg}) {
    navKey.currentState?.pushReplacementNamed(name, arguments: arg);
  }

  static void pop({Object? arg}) {
    navKey.currentState?.pop(arg);
  }

  static void pushAndClear(String name, {Object? arg}) {
    navKey.currentState?.pushNamedAndRemoveUntil(name, (_) => false);
  }

  static void message(String msg, {bool? isSuccessful}) {
    ScaffoldMessenger.of(navKey.currentContext!)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
