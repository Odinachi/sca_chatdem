import 'dart:math';

import 'package:chatdem/features/home/models/chat_model.dart';
import 'package:chatdem/features/home/view_models/chat_provider.dart';
import 'package:chatdem/shared/Navigation/app_route_strings.dart';
import 'package:chatdem/shared/Navigation/app_router.dart';
import 'package:chatdem/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/colors.dart';

class ChatCreationScreen extends StatefulWidget {
  const ChatCreationScreen({super.key});

  @override
  State<ChatCreationScreen> createState() => _ChatCreationScreenState();
}

class _ChatCreationScreenState extends State<ChatCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final chatNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.appColor,
        title: Text(
          'Create Chat',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Consumer<ChatProvider>(
        builder:
            (BuildContext context, ChatProvider chatProvider, Widget? child) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.only(top: 50.0, bottom: 20),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: chatProvider.chatImg != null
                                  ? FileImage(chatProvider.chatImg!)
                                  : null,
                              radius: 50,
                            ),
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () async {
                                    final isCamera = await useCamera(context);

                                    if (isCamera != null) {
                                      final img = await pickImage(isCamera);

                                      if (img != null) {
                                        chatProvider.setChatImg(img);
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
                    AppTextInput(
                      controller: chatNameController,
                      label: "Chat Name",
                      validator: (a) =>
                          (a ?? '').length > 3 ? null : "Invalid name",
                    ),
                    SizedBox(height: 30),
                    AppButton(
                      loading: chatProvider.isLoading,
                      text: "Create",
                      action: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final create = await chatProvider.createChat(
                              ChatModel(
                                  chatName: chatNameController.text,
                                  img: imgs[Random().nextInt(imgs.length)]));
                          if (create.model != null) {
                            AppRouter.push(AppRouteStrings.chatScreen,
                                arg: create.model);
                          } else {
                            AppRouter.message(create.error ?? "");
                          }
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
