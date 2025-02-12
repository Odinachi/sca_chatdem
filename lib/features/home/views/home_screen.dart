import 'dart:async';

import 'package:chatdem/features/authentication/view_models/authentication_provider.dart';
import 'package:chatdem/features/home/models/message_model.dart';
import 'package:chatdem/features/home/models/user_model.dart';
import 'package:chatdem/features/home/view_models/chat_provider.dart';
import 'package:chatdem/shared/Navigation/app_route_strings.dart';
import 'package:chatdem/shared/Navigation/app_router.dart';
import 'package:chatdem/shared/colors.dart';
import 'package:chatdem/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  StreamSubscription? listenToMsgStream;
  StreamSubscription? newExistingMessage;

  final unreadNotifier = ValueNotifier(<String, List<String>>{});

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>()
        ..fetchRooms()
        ..fetchDms()
        ..fetchUsers()
        ..setUserModel(context.read<AuthenticationProvider>().userModel);
    });
    listenToMsgStream = context.read<ChatProvider>().listenToMsgs().listen((e) {
      //This is getting every new chat created
      e.docs.forEach((outter) {
        newExistingMessage = FirebaseFirestore.instance
            .collection("chats")
            .doc(outter.id)
            .collection("messages")
            .snapshots()
            .listen((inner) {
          //We are streaming the messages inside each of those chats to see the ones not yet read.
          inner.docs.forEach((e) {
            //sterializing the message object to a model
            final incomingMsg =
                MessageModel.fromJson(e.data()).copyWith(msgId: e.id);

            //we are checking if we are the recipients of the message and also checking if this message has previously been seen.
            if (incomingMsg.id != context.read<ChatProvider>().userModel?.uid &&
                (incomingMsg.seen?.length ?? 0) < 2) {
              //we are getting the current state of our unread map
              final newMap = unreadNotifier.value;

              //we are checking we have previously unread message on the chat using the id
              if (newMap[outter.id] == null) {
                newMap[outter.id] = [incomingMsg.msgId ?? ""];
              } else {
                //add one to the existing unread count
                newMap[outter.id]?.add(incomingMsg.msgId ?? "");

                newMap[outter.id] = newMap[outter.id]?.toSet().toList() ?? [];
              }
              //force our ui to update using the updated value
              unreadNotifier.value = newMap;
            }
          });
          if (context.mounted) {
            context.read<ChatProvider>()
              ..fetchDms()
              ..fetchUsers();
          }
        });
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    listenToMsgStream?.cancel();
    newExistingMessage?.cancel();
    super.dispose();
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
                                  : Text(
                                      context
                                              .read<ChatProvider>()
                                              .userModel
                                              ?.name ??
                                          "",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                                                  dms.isEmpty
                                                      ? const Center(
                                                          child: Text(
                                                              "No Chat yet"),
                                                        )
                                                      : ListView.builder(
                                                          itemCount: dms.length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            final each =
                                                                dms[index];
                                                            final otherUser = each
                                                                .users
                                                                ?.where((e) =>
                                                                    e.uid !=
                                                                    context
                                                                        .read<
                                                                            ChatProvider>()
                                                                        .userModel
                                                                        ?.uid)
                                                                .firstOrNull;

                                                            return ValueListenableBuilder(
                                                                valueListenable:
                                                                    unreadNotifier,
                                                                builder: (_,
                                                                    value, __) {
                                                                  return ChatTile(
                                                                    unreadCount:
                                                                        value[each.convoId]?.length ??
                                                                            0,
                                                                    onTap:
                                                                        () async {
                                                                      await AppRouter.push(
                                                                          AppRouteStrings
                                                                              .chatScreen,
                                                                          arg:
                                                                              ChatScreenArg(
                                                                            chatModel:
                                                                                each,
                                                                            isNewUser:
                                                                                each.lastMsg == null,
                                                                            isGroup:
                                                                                false,
                                                                            userModel:
                                                                                UserModel(
                                                                              img: each.img,
                                                                              uid: each.participants?.firstWhere((e) => e != chatProvider.userModel?.uid),
                                                                              name: each.chatName,
                                                                            ),
                                                                          )).then((_) {
                                                                        context
                                                                            .read<ChatProvider>()
                                                                            .fetchRooms();
                                                                      });
                                                                    },
                                                                    name: otherUser
                                                                            ?.name ??
                                                                        "",
                                                                    message: each
                                                                            .lastMsg ??
                                                                        "No Message yet",
                                                                    time: each.lastMsg ==
                                                                            null
                                                                        ? ""
                                                                        : timeago.format(each.lastMsgTime ??
                                                                            DateTime.now()),
                                                                    avatarUrl:
                                                                        otherUser?.img ??
                                                                            "",
                                                                  );
                                                                });
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
  final int unreadCount;

  const ChatTile(
      {super.key,
      required this.name,
      required this.message,
      required this.time,
      required this.avatarUrl,
      this.onTap,
      this.unreadCount = 0});

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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: const TextStyle(color: Colors.grey),
          ),
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(
                left: 10,
              ),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.appColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: style.copyWith(
                  fontSize: 12,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
        ],
      ),
      onTap: onTap,
    );
  }
}
