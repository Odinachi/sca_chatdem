import 'package:chatdem/features/authentication/view_models/authentication_provider.dart';
import 'package:chatdem/features/home/models/user_model.dart';
import 'package:chatdem/features/home/view_models/chat_provider.dart';
import 'package:chatdem/shared/Navigation/app_route_strings.dart';
import 'package:chatdem/shared/Navigation/app_router.dart';
import 'package:chatdem/shared/colors.dart';
import 'package:chatdem/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../shared/network_connectivity.dart';
import 'chat_screen.dart';

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
        ..fetchDms()
        ..fetchUsers()
        ..setUserModel(context.read<AuthenticationProvider>().userModel);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ValueListenableBuilder(
          valueListenable: NetworkConnectivity().networkListener,
          builder: (_, hasNetwork, __) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(seconds: 3), () {
                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                //     content: Text(hasNetwork
                //         ? "Network has been restored"
                //         : "We lost network connection")));
              });
            });

            return Consumer<AuthenticationProvider>(
              builder: (BuildContext context,
                  AuthenticationProvider authProvider, Widget? child) {
                return GestureDetector(
                  onTap: clearAndCloseSearch,
                  child: ValueListenableBuilder<bool>(
                    builder: (_, showSearchValue, __) {
                      return Consumer<ChatProvider>(
                        builder: (BuildContext context,
                            ChatProvider chatProvider, Widget? child) {
                          final chatRoomList = showSearchValue
                              ? chatProvider.searchedRooms
                              : chatProvider.rooms;

                          final dms = chatProvider.dms;
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
                                        showClearValueListener.value =
                                            a.isNotEmpty;
                                        chatProvider.search(a);
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Search group",
                                        hintStyle: style.copyWith(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                        ),
                                        suffixIcon: ValueListenableBuilder(
                                            valueListenable:
                                                showClearValueListener,
                                            builder: (_, showClearValue, __) {
                                              if (showClearValue) {
                                                return GestureDetector(
                                                    onTap: clearAndCloseSearch,
                                                    child: const Icon(
                                                        Icons.clear));
                                              }
                                              return const SizedBox.shrink();
                                            }),
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: AppColors.appColor,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                        filled: true,
                                        fillColor: AppColors.white,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: const BorderSide(
                                              color: AppColors.appColor),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: const BorderSide(
                                              color: AppColors.appColor),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                    icon: const Icon(Icons.search,
                                        color: Colors.white),
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
                            body: Column(
                              children: [
                                if (chatProvider.users.isNotEmpty)
                                  Container(
                                    height: 80,
                                    margin: const EdgeInsets.only(
                                        top: 20, bottom: 5),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (_, i) {
                                        final each = chatProvider.users[i];
                                        return GestureDetector(
                                          onTap: () async {
                                            final messaged =
                                                await AppRouter.push(
                                                    AppRouteStrings.chatScreen,
                                                    arg: ChatScreenArg(
                                                      userModel: each,
                                                      isGroup: true,
                                                      isNewUser: true,
                                                    ));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                              left: i == 0 ? 20 : 0,
                                              right: 10,
                                            ),
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            each.img ?? ""),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(each.name ?? ""),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: chatProvider.users.length,
                                    ),
                                  ),
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 10,
                                    left: 20,
                                    right: 20,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    border: Border.all(
                                      color: AppColors.appColor,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TabBar(
                                    tabs: const [
                                      Text("DMs"),
                                      Text("Groups"),
                                    ],
                                    labelColor: AppColors.white,
                                    unselectedLabelColor: AppColors.appColor,
                                    labelStyle: style.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    labelPadding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    dividerColor: Colors.transparent,
                                    indicator: BoxDecoration(
                                      color: AppColors.appColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: RefreshIndicator(
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
                                              : TabBarView(children: [
                                                  //DM tab
                                                  ListView.builder(
                                                    itemCount: dms.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final each = dms[index];

                                                      return ChatTile(
                                                        onTap: () async {
                                                          await AppRouter.push(
                                                              AppRouteStrings
                                                                  .chatScreen,
                                                              arg:
                                                                  ChatScreenArg(
                                                                chatModel: each,
                                                                isGroup: false,
                                                                userModel:
                                                                    UserModel(
                                                                  img: each.img,
                                                                  uid: each
                                                                      .participants
                                                                      ?.firstWhere((e) =>
                                                                          e !=
                                                                          chatProvider
                                                                              .userModel
                                                                              ?.uid),
                                                                  name: each
                                                                      .chatName,
                                                                ),
                                                              )).then((_) {
                                                            context
                                                                .read<
                                                                    ChatProvider>()
                                                                .fetchRooms();
                                                          });
                                                        },
                                                        name:
                                                            each.chatName ?? "",
                                                        message: each.lastMsg ??
                                                            "No Message yet",
                                                        time: each.lastMsg ==
                                                                null
                                                            ? ""
                                                            : timeago.format(
                                                                each.lastMsgTime ??
                                                                    DateTime
                                                                        .now()),
                                                        avatarUrl:
                                                            each.img ?? "",
                                                      );
                                                    },
                                                  ),
                                                  //Group Tab
                                                  ListView.builder(
                                                    itemCount:
                                                        chatRoomList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final each =
                                                          chatRoomList[index];

                                                      return ChatTile(
                                                        onTap: () async {
                                                          await AppRouter.push(
                                                              AppRouteStrings
                                                                  .chatScreen,
                                                              arg:
                                                                  ChatScreenArg(
                                                                chatModel: each,
                                                                isGroup: true,
                                                              )).then((_) {
                                                            context
                                                                .read<
                                                                    ChatProvider>()
                                                                .fetchRooms();
                                                          });
                                                        },
                                                        name:
                                                            each.chatName ?? "",
                                                        message: each.lastMsg ??
                                                            "No Message yet",
                                                        time: each.lastMsg ==
                                                                null
                                                            ? ""
                                                            : timeago.format(
                                                                each.lastMsgTime ??
                                                                    DateTime
                                                                        .now()),
                                                        avatarUrl:
                                                            each.img ?? "",
                                                      );
                                                    },
                                                  ),
                                                ]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            floatingActionButton: FloatingActionButton(
                              onPressed: () async {
                                await AppRouter.push(
                                        AppRouteStrings.createChatScreen)
                                    .then((_) => chatProvider.fetchRooms());
                              },
                              backgroundColor: AppColors.appColor,
                              child:
                                  const Icon(Icons.chat, color: Colors.white),
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
          }),
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        time,
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: onTap,
    );
  }
}
