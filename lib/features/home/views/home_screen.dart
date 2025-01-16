import 'package:chatdem/features/authentication/view_models/authentication_provider.dart';
import 'package:chatdem/features/home/view_models/chat_provider.dart';
import 'package:chatdem/shared/Navigation/app_route_strings.dart';
import 'package:chatdem/shared/Navigation/app_router.dart';
import 'package:chatdem/shared/colors.dart';
import 'package:chatdem/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    context.read<ChatProvider>().fetchRooms();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(DateTime.now().toIso8601String());
    return Consumer<AuthenticationProvider>(
      builder: (BuildContext context, AuthenticationProvider authProvider,
          Widget? child) {
        return Consumer<ChatProvider>(
          builder:
              (BuildContext context, ChatProvider chatProvider, Widget? child) {
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
              body: RefreshIndicator(
                onRefresh: () async {
                  chatProvider.fetchRooms();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: chatProvider.isLoading
                      ? loaderWidget()
                      : chatProvider.rooms.isEmpty
                          ? const Center(
                              child: Text("Chat is Empty"),
                            )
                          : ListView.builder(
                              itemCount: chatProvider.rooms.length,
                              itemBuilder: (context, index) {
                                final each = chatProvider.rooms[index];
                                return ChatTile(
                                  onTap: () {
                                    AppRouter.push(AppRouteStrings.chatScreen);
                                  },
                                  name: each.chatName ?? "",
                                  message: 'Hello! How are you doing?',
                                  time: '12:${10 + index} PM',
                                  avatarUrl: each.img ?? "",
                                );
                              },
                            ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await AppRouter.push(AppRouteStrings.createChatScreen)
                      .then((_) => chatProvider.fetchRooms());
                },
                backgroundColor: AppColors.appColor,
                child: const Icon(Icons.chat, color: Colors.white),
              ),
            );
          },
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
