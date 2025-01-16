import 'package:chatdem/features/authentication/view_models/authentication_provider.dart';
import 'package:chatdem/shared/Navigation/app_route_strings.dart';
import 'package:chatdem/shared/Navigation/app_router.dart';
import 'package:chatdem/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (BuildContext context, AuthenticationProvider authProvider,
          Widget? child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.appColor,
            automaticallyImplyLeading: false,
            title: Text(
              'Chats',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  // Search functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.exit_to_app, color: Colors.white),
                onPressed: () {
                  authProvider.logout().then((_) =>
                      AppRouter.pushAndClear(AppRouteStrings.loginScreen));
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ChatTile(
                  onTap: () {
                    AppRouter.push(AppRouteStrings.chatScreen);
                  },
                  name: 'User ${index + 1}',
                  message: 'Hello! How are you doing?',
                  time: '12:${10 + index} PM',
                  avatarUrl: 'https://via.placeholder.com/150',
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              AppRouter.push(AppRouteStrings.createChatScreen);
            },
            backgroundColor: AppColors.appColor,
            child: Icon(Icons.chat, color: Colors.white),
          ),
        );
      },
    );
  }
}

class ChatTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String avatarUrl;
  final VoidCallback? onTap;

  const ChatTile(
      {super.key,
      required this.name,
      required this.message,
      required this.time,
      required this.avatarUrl,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
      ),
      title: Text(
        name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(message),
      trailing: Text(
        time,
        style: TextStyle(color: Colors.grey),
      ),
      onTap: onTap,
    );
  }
}
