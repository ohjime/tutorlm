import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'chat.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkInternet();
  }

  Future<void> _checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    print('Connectivity check result: $connectivityResult');
    setState(() {
      isConnected = connectivityResult != ConnectivityResult.none;
    });
    print('Is connected: $isConnected');

    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      print('Connectivity changed: $results');
      setState(() {
        isConnected = results.last != ConnectivityResult.none;
      });
      print('Is connected (after change): $isConnected');
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Debug authentication state
    print('Current user: ${FirebaseAuth.instance.currentUser?.email}');
    print('Current user ID: $currentUserId');
    print('Is authenticated: ${FirebaseAuth.instance.currentUser != null}');

    return Container(
      padding: const EdgeInsets.all(16),
      child: isConnected
          ? _buildChatList(currentUserId)
          : _buildOfflineMessage(),
    );
  }

  Widget _buildOfflineMessage() {
    return const Center(
      child: Text(
        "No Internet Connection.\nPlease check your network and try again.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _buildChatList(String currentUserId) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .where('users', arrayContains: currentUserId)
                .snapshots(),
            builder: (context, snapshot) {
              // Debug information
              print('Current User ID: $currentUserId');
              print('Snapshot has data: ${snapshot.hasData}');
              print('Snapshot error: ${snapshot.error}');
              print('Connection state: ${snapshot.connectionState}');

              if (snapshot.hasError) {
                print('Firebase error: ${snapshot.error}');
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var chats = snapshot.data!.docs;

              // Sort chats by timestamp manually (newest first)
              chats.sort((a, b) {
                var timestampA = a.data() as Map<String, dynamic>;
                var timestampB = b.data() as Map<String, dynamic>;

                var timeA = timestampA['timestamp'] as Timestamp?;
                var timeB = timestampB['timestamp'] as Timestamp?;

                if (timeA == null && timeB == null) return 0;
                if (timeA == null) return 1;
                if (timeB == null) return -1;

                return timeB.compareTo(
                  timeA,
                ); // Descending order (newest first)
              });

              print('Number of chats found: ${chats.length}');

              if (chats.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text("No messages yet."),
                      SizedBox(height: 8),
                      Text(
                        "Start a conversation!",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  var chat = chats[index];
                  List<dynamic> users = chat['users'];
                  String lastMessage = chat['lastMessage'] ?? 'No messages yet';
                  String chatId = chat.id;

                  String otherUserId = users.firstWhere(
                    (id) => id != currentUserId,
                    orElse: () => 'Unknown',
                  );

                  if (otherUserId == 'Unknown') return const SizedBox.shrink();

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherUserId)
                        .get(),
                    builder: (context, userSnapshot) {
                      String otherUserName = "Unknown User";

                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text(
                            "Loading...",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }

                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        var userData =
                            userSnapshot.data!.data() as Map<String, dynamic>?;
                        if (userData != null && userData.containsKey('name')) {
                          otherUserName = userData['name'];
                        }
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatId: chatId,
                                otherUserId: otherUserId,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          elevation: 3,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              otherUserName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
