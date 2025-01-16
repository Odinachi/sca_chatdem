import 'dart:io';

import 'package:chatdem/shared/Navigation/app_router.dart';
import 'package:chatdem/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

const style = TextStyle(
  fontSize: 12,
  color: AppColors.black,
  fontWeight: FontWeight.w400,
);

class AppTextInput extends StatelessWidget {
  const AppTextInput(
      {super.key,
      this.validator,
      this.controller,
      this.label,
      this.inputFormatter});

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? label;
  final List<TextInputFormatter>? inputFormatter;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      inputFormatters: inputFormatter,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
        focusedErrorBorder: OutlineInputBorder(),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  const AppButton(
      {super.key, required this.text, this.action, this.loading = false});

  final String text;
  final VoidCallback? action;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return loading
        ? loaderWidget()
        : InkWell(
            onTap: action,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppColors.appColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: style.copyWith(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
          );
  }
}

final emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

extension CurrencyConverter on num? {
  String convertToNaira() => "₦${((this ?? 0) * 1650).toString()}";
}

extension FileExtension on File {
  double checkSize() {
    final bytes = readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    return kb / 1024;
  }
}

List imgs = [
  "https://plus.unsplash.com/premium_photo-1689539137236-b68e436248de?q=80&w=2971&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1445053023192-8d45cb66099d?q=80&w=2970&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://plus.unsplash.com/premium_photo-1664536392896-cd1743f9c02c?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
];

Future<bool?> useCamera(BuildContext context) async {
  return await showModalBottomSheet(
      backgroundColor: AppColors.white,
      context: context,
      builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SafeArea(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      )),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          AppRouter.pop(arg: true);
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              color: AppColors.appColor,
                              size: 30,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text("Camera",
                                style: style.copyWith(
                                  fontSize: 20,
                                  color: AppColors.appColor,
                                  fontWeight: FontWeight.w500,
                                )),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 40,
                      ),
                      GestureDetector(
                        onTap: () {
                          AppRouter.pop(arg: false);
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.image,
                              color: AppColors.appColor,
                              size: 30,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text("Gallery",
                                style: style.copyWith(
                                  fontSize: 20,
                                  color: AppColors.appColor,
                                  fontWeight: FontWeight.w500,
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

Widget loaderWidget() => const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.appColor),
      ),
    );
