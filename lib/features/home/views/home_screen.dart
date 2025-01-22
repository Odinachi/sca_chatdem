import 'package:chatdem/features/authentication/view_models/authentication_provider.dart';
import 'package:chatdem/features/home/view_models/chat_provider.dart';
import 'package:chatdem/shared/Navigation/app_route_strings.dart';
import 'package:chatdem/shared/Navigation/app_router.dart';
import 'package:chatdem/shared/colors.dart';
import 'package:chatdem/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();

  ValueNotifier<bool> showSearchValueListener = ValueNotifier(false);
  ValueNotifier<bool> showClearValueListener = ValueNotifier(false);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>()
        ..fetchRooms()
        ..setUserModel(context.read<AuthenticationProvider>().userModel);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (BuildContext context, AuthenticationProvider authProvider,
          Widget? child) {
        return GestureDetector(
          onTap: clearAndCloseSearch,
          child: ValueListenableBuilder<bool>(
            builder: (_, showSearchValue, __) {
              return Consumer<ChatProvider>(
                builder: (BuildContext context, ChatProvider chatProvider,
                    Widget? child) {
                  final chatRoomList = showSearchValue
                      ? chatProvider.searchedRooms
                      : chatProvider.rooms;
                  return Scaffold(
                    appBar: AppBar(
                      elevation: 0,
                      backgroundColor: AppColors.appColor,
                      automaticallyImplyLeading: false,
                      title: showSearchValue
                          ? TextFormField(
                              controller: searchController,
                              cursorColor: AppColors.appColor,
                              onChanged: (a) {
                                showClearValueListener.value = a.isNotEmpty;
                                chatProvider.search(a);
                              },
                              decoration: InputDecoration(
                                hintText: "Search group",
                                hintStyle: style.copyWith(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                                suffixIcon: ValueListenableBuilder(
                                    valueListenable: showClearValueListener,
                                    builder: (_, showClearValue, __) {
                                      if (showClearValue) {
                                        return GestureDetector(
                                            onTap: clearAndCloseSearch,
                                            child: Icon(Icons.clear));
                                      }
                                      return const SizedBox.shrink();
                                    }),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: AppColors.appColor,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                filled: true,
                                fillColor: AppColors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: AppColors.appColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: AppColors.appColor),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: AppColors.appColor),
                                ),
                              ),
                            )
                          : const Text(
                              'Chats',
                              style: TextStyle(color: Colors.white),
                            ),
                      actions: [
                        if (!showSearchValue)
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              // Search functionality
                              showSearchValueListener.value = true;
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.exit_to_app,
                              color: Colors.white),
                          onPressed: () {
                            authProvider.logout().then((_) =>
                                AppRouter.pushAndClear(
                                    AppRouteStrings.loginScreen));
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
                            : chatRoomList.isEmpty
                                ? const Center(
                                    child: Text("Chat is Empty"),
                                  )
                                : ListView.builder(
                                    itemCount: chatRoomList.length,
                                    itemBuilder: (context, index) {
                                      final each = chatRoomList[index];

                                      return ChatTile(
                                        onTap: () async {
                                          await AppRouter.push(
                                                  AppRouteStrings.chatScreen,
                                                  arg: each)
                                              .then((_) {
                                            context
                                                .read<ChatProvider>()
                                                .fetchRooms();
                                          });
                                        },
                                        name: each.chatName ?? "",
                                        message:
                                            each.lastMsg ?? "No Message yet",
                                        time: each.lastMsg == null
                                            ? ""
                                            : timeago.format(each.lastMsgTime ??
                                                DateTime.now()),
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
            valueListenable: showSearchValueListener,
          ),
        );
      },
    );
  }

  void clearAndCloseSearch() {
    searchController.clear();
    showClearValueListener.value = false;
    showSearchValueListener.value = false;
    context.read<ChatProvider>().clearSearch();
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
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(message),
      trailing: Text(
        time,
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: onTap,
    );
  }
}
