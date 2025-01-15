import 'package:chatdem/shared/constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/Navigation/app_route_strings.dart';
import '../../../shared/Navigation/app_router.dart';
import '../../../shared/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Chat Dem Login",
                    style: style.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  AppTextInput(
                    controller: emailController,
                    label: "Email",
                    inputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z@._-]'))
                    ],
                    validator: (a) {
                      if (!emailRegex.hasMatch(a ?? "")) {
                        return "Inavlid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  AppTextInput(
                    controller: passwordController,
                    label: "Password",
                    inputFormatter: [
                      FilteringTextInputFormatter.deny(RegExp(r' '))
                    ],
                    validator: (a) =>
                        (a ?? '').isNotEmpty ? null : "Invalid password",
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  if (loading)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.appColor),
                      ),
                    )
                  else
                    AppButton(
                      text: "Login",
                      action: () async {},
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                          text: TextSpan(
                        children: [
                          TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                AppRouter.pushReplace(
                                    AppRouteStrings.registerScreen);
                              },
                            text: " Register",
                            style: style.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.appColor),
                          )
                        ],
                        text: "Don't have an account?",
                        style: style.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
