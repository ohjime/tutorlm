import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const ChatScreen(
      {super.key, required this.chatId, required this.otherUserId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String otherUserName = "Loading...";

  @override
  void initState() {
    super.initState();
    _getOtherUserName();
  }

  void _getOtherUserName() async {
    var userDoc =
        await _firestore.collection('users').doc(widget.otherUserId).get();
    if (userDoc.exists) {
      setState(() {
        otherUserName = userDoc['name'];
      });
    }
  }

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = _auth.currentUser;

    await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'text': _messageController.text,
      'senderId': user?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('chats').doc(widget.chatId).update({
      'lastMessage': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(otherUserName), backgroundColor: const Color.fromARGB(255, 23, 129, 234)), 
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == _auth.currentUser?.uid;

                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore
                          .collection('users')
                          .doc(message['senderId'])
                          .get(),
                      builder: (context, userSnapshot) {
                        String senderName = "Unknown";
                        if (userSnapshot.connectionState ==
                                ConnectionState.done &&
                            userSnapshot.hasData &&
                            userSnapshot.data!.exists) {
                          senderName = userSnapshot.data!['name'];
                        }

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(senderName),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.blue : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(message['text']),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, 
                border: Border.all(
                    color: Colors.grey, width: 1.5), 
                borderRadius: BorderRadius.circular(20), 
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5), 
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Type a message...',
                        border: InputBorder.none, 
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.blue), 
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
