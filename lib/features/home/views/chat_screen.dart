import 'package:chatdem/features/home/models/chat_model.dart';
import 'package:chatdem/features/home/models/message_model.dart';
import 'package:chatdem/features/home/models/user_model.dart';
import 'package:chatdem/features/home/view_models/chat_provider.dart';
import 'package:chatdem/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.arg});

  final ChatScreenArg arg;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msgController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isNewUser = false;
  String? convoId;

  @override
  void initState() {
    isNewUser = widget.arg.isNewUser;
    final uids = [
      widget.arg.userModel?.uid,
      context.read<ChatProvider>().userModel?.uid
    ]..sort();
    if (widget.arg.userModel != null) {
      convoId = uids.join("_");
    }

    super.initState();
  }

  List<MessageModel> msgs = [];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        bottomSheet: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SafeArea(
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    // IconButton(
                    //   icon: const Icon(Icons.emoji_emotions, color: Colors.grey),
                    //   onPressed: () {
                    //     // Emoji functionality
                    //   },
                    // ),
                    Expanded(
                      child: TextFormField(
                        validator: (a) =>
                            (a ?? "").length < 2 ? "Inavlid message" : null,
                        controller: msgController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // IconButton(
                    //   icon: Icon(Icons.attach_file, color: Colors.grey),
                    //   onPressed: () {
                    //     // Attach file functionality
                    //   },
                    // ),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppColors.appColor),
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final sent =
                              await context.read<ChatProvider>().sendMsg(
                                    roomId: widget.arg.chatModel?.id,
                                    msg: msgController.text,
                                    isNewMsg: msgs.isEmpty,
                                    convoId: convoId,
                                    otherUserId: widget.arg.userModel?.uid,
                                    recipientName: widget.arg.userModel?.name,
                                    recipientImg: widget.arg.userModel?.img,
                                  );
                          if (sent == true) {
                            isNewUser = false;
                            setState(() {});
                          }
                          msgController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        appBar: AppBar(
          backgroundColor: AppColors.appColor,
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    (widget.arg.chatModel?.img ?? widget.arg.userModel?.img) ??
                        ""),
              ),
              const SizedBox(width: 10),
              Text(
                (widget.arg.chatModel?.chatName ??
                        widget.arg.userModel?.name) ??
                    "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: (isNewUser)
              ? const Center(child: Text("Start a Conversation"))
              : Column(
                  children: [
                    StreamBuilder(
                        stream: context.read<ChatProvider>().getMsg(
                            (widget.arg.chatModel?.id ?? convoId ?? "")),
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                                height: 200,
                                child:
                                    Center(child: CircularProgressIndicator()));
                          } else if (snapshot.hasError) {
                            return const SizedBox(
                                height: 200,
                                child: Center(
                                    child: Text("Can not fetch messages now")));
                          } else if ((snapshot.data?.size ?? 0) < 1) {
                            return const SizedBox(
                                height: 200,
                                child: Center(child: Text("No messages yet")));
                          }
                          final listOfMessages = snapshot.data?.docs ?? [];

                          msgs = List<MessageModel>.from(listOfMessages.map(
                              (e) => MessageModel.fromJson(e.data())
                                  .copyWith(msgId: e.id)));

                          msgs.sort((a, b) => (b.time ?? DateTime.now())
                              .compareTo(a.time ?? DateTime.now()));

                          return Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 110),
                              reverse: true,
                              itemBuilder: (_, i) {
                                final each = msgs[i];
                                if ((each.seen?.length ?? 0) < 2 &&
                                    each.id !=
                                        context
                                            .read<ChatProvider>()
                                            .userModel
                                            ?.uid) {
                                  context.read<ChatProvider>().updateSeen(
                                      msgId: each.msgId, chatId: convoId);
                                }
                                return ChatBubble(
                                  seen: (each.seen?.length ?? 0) > 1,
                                  received: each.id ==
                                      context
                                          .read<ChatProvider>()
                                          .userModel
                                          ?.uid,
                                  name: each.name ?? "",
                                  image: each.image ?? "",
                                  isMe: each.id ==
                                      context
                                          .read<ChatProvider>()
                                          .userModel
                                          ?.uid,
                                  message: each.msg ?? "",
                                  time: DateFormat("hh:mm a")
                                      .format(each.time ?? DateTime.now()),
                                );
                              },
                              shrinkWrap: true,
                              itemCount: msgs.length,
                            ),
                          );
                        }),

                    // Text input area
                  ],
                ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final String time;
  final String image;
  final String name;
  final bool seen;
  final bool received;

  const ChatBubble({
    super.key,
    required this.isMe,
    required this.message,
    required this.time,
    required this.image,
    required this.name,
    this.seen = false,
    this.received = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(image),
              ),
            ),
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(10),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.appColor : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                    bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white70 : Colors.black54,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  color: isMe ? AppColors.appColor : Colors.black,
                ),
              ),
              if (isMe && seen)
                const Icon(
                  Icons.done_all,
                  size: 15,
                  color: AppColors.grey,
                )
              else if (isMe && received)
                const Icon(
                  Icons.done,
                  size: 15,
                  color: AppColors.grey,
                ),
            ],
          ),
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(image),
              ),
            ),
        ],
      ),
    );
  }
}

class ChatScreenArg {
  final ChatModel? chatModel;
  final UserModel? userModel;
  final bool isGroup;
  final bool isNewUser;

  ChatScreenArg(
      {this.chatModel,
      this.isGroup = true,
      this.userModel,
      this.isNewUser = false});
}
