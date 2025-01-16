import 'dart:io';

import 'package:chatdem/features/authentication/view_models/authentication_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../shared/Navigation/app_route_strings.dart';
import '../../../shared/Navigation/app_router.dart';
import '../../../shared/colors.dart';
import '../../../shared/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthenticationProvider>(
          builder: (BuildContext context, AuthenticationProvider authProvider,
              Widget? child) {
            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Register on Chat Dem",
                        textAlign: TextAlign.center,
                        style: style.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.only(top: 50.0, bottom: 20),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: authProvider.profileImage != null
                                  ? FileImage(authProvider.profileImage!)
                                  : null,
                              radius: 50,
                            ),
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () async {
                                    final isCamera = await showModalBottomSheet(
                                        backgroundColor: AppColors.white,
                                        context: context,
                                        builder: (_) => Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SafeArea(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20,
                                                        vertical: 40),
                                                    decoration:
                                                        const BoxDecoration(
                                                            color:
                                                                AppColors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(50),
                                                              topRight: Radius
                                                                  .circular(50),
                                                            )),
                                                    child: Column(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            AppRouter.pop(
                                                                arg: true);
                                                          },
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .camera_alt,
                                                                color: AppColors
                                                                    .appColor,
                                                                size: 30,
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text("Camera",
                                                                  style: style
                                                                      .copyWith(
                                                                    fontSize:
                                                                        20,
                                                                    color: AppColors
                                                                        .appColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  )),
                                                            ],
                                                          ),
                                                        ),
                                                        const Divider(
                                                          height: 40,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            AppRouter.pop(
                                                                arg: false);
                                                          },
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.image,
                                                                color: AppColors
                                                                    .appColor,
                                                                size: 30,
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text("Gallery",
                                                                  style: style
                                                                      .copyWith(
                                                                    fontSize:
                                                                        20,
                                                                    color: AppColors
                                                                        .appColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  )),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ));

                                    if (isCamera != null) {
                                      final img = await pickImage(isCamera);

                                      if (img != null) {
                                        authProvider.setImage(img);
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.white),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: AppColors.appColor,
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    AppTextInput(
                      controller: nameController,
                      label: "Name",
                      validator: (a) =>
                          (a ?? '').length > 3 ? null : "Invalid name",
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    AppTextInput(
                      controller: emailController,
                      label: "Email",
                      inputFormatter: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9a-zA-Z@._-]'))
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
                          (a ?? '').length > 6 ? null : "Invalid password",
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    if (authProvider.loading)
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.appColor),
                        ),
                      )
                    else
                      AppButton(
                        text: "Register",
                        action: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            if (authProvider.profileImage == null) {
                              AppRouter.message("Profile image is required");
                              return;
                            }
                            final a = await authProvider.register(
                              email: emailController.text,
                              password: passwordController.text,
                              name: nameController.text,
                            );
                            if (a.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(a.error ?? "")));
                            } else {
                              AppRouter.pushAndClear(
                                  AppRouteStrings.homeScreen);
                            }
                          }
                        },
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
                                      AppRouteStrings.loginScreen);
                                },
                              text: " Login",
                              style: style.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.appColor),
                            )
                          ],
                          text: "Already have an account?",
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
            );
          },
        ),
      ),
    );
  }
}

Future<File?> pickImage(bool isCamera) async {
  try {
    final img = await ImagePicker()
        .pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);
    if (img != null) {
      final file = File(img.path);
      if (file.checkSize() <= 5) {
        return file;
      }
    }
    return null;
  } catch (_) {
    return null;
  }
}
