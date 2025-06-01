import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat.dart';

class NewChatPage extends StatelessWidget {
  const NewChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Start a New Chat"),
        backgroundColor: const Color.fromARGB(255, 1, 140, 255),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

         
          var users = snapshot.data!.docs
              .where((user) => user.id != currentUserId)
              .toList();

          if (users.isEmpty) {
            return const Center(child: Text("No other users available."));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              String userId = user.id;

             
              String userName =
                  (user.data() as Map<String, dynamic>?)?.containsKey('name') ==
                          true
                      ? user['name']
                      : 'Unknown User';

              
              print("Displaying User: $userName (ID: $userId)");

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(userName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.chat),
                onTap: () =>
                    _startChat(context, currentUserId, userId, userName),
              );
            },
          );
        },
      ),
    );
  }

  void _startChat(BuildContext context, String currentUserId,
      String otherUserId, String otherUserName) async {
    final chatsRef = FirebaseFirestore.instance.collection('chats');


    var existingChat =
        await chatsRef.where('users', arrayContains: currentUserId).get();

    String? chatId;

    for (var chat in existingChat.docs) {
      List<dynamic> users = chat['users'];
      if (users.contains(otherUserId)) {
        chatId = chat.id;
        break;
      }
    }

    
    if (chatId == null) {
      var newChat = await chatsRef.add({
        'users': [currentUserId, otherUserId],
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
      });
      chatId = newChat.id;
    }

   
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatScreen(chatId: chatId!, otherUserId: otherUserId),
      ),
    );
  }
}
