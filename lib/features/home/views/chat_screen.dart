import 'package:chatdem/features/home/models/chat_model.dart';
import 'package:chatdem/shared/colors.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.chatModel});

  final ChatModel? chatModel;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appColor,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatModel?.img ?? ""),
            ),
            SizedBox(width: 10),
            Text(
              widget.chatModel?.chatName ?? "",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Message list
            Expanded(
              child: ListView(
                reverse: true,
                padding: const EdgeInsets.all(10),
                children: const [
                  ChatBubble(
                    isMe: true,
                    message: 'Hello! How are you doing today?',
                    time: '12:30 PM',
                  ),
                  ChatBubble(
                    isMe: false,
                    message: 'Hi! I am doing great. How about you?',
                    time: '12:31 PM',
                  ),
                  ChatBubble(
                    isMe: true,
                    message: 'I\'m fine too. Thanks for asking!',
                    time: '12:32 PM',
                  ),
                ],
              ),
            ),

            // Text input area
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
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
                    onPressed: () {
                      // Send message functionality
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final String time;

  const ChatBubble({
    required this.isMe,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
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
    );
  }
}
