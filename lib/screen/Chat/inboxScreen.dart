import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:flutter/material.dart';
import 'package:nexus/models/userModel.dart';
import 'package:nexus/providers/manager.dart';
import 'package:nexus/screen/ProfileDetails/userProfile.dart';
import 'package:nexus/utils/Encrypt_Message.dart';
import 'package:nexus/utils/constants.dart';
import 'package:nexus/utils/devicesize.dart';
import 'package:nexus/utils/widgets.dart';
import 'package:provider/provider.dart';

class inboxScreen extends StatefulWidget {
  String? chatId;
  String? myId;
  String? yourUid;

  inboxScreen({this.yourUid, this.chatId, this.myId});

  @override
  State<inboxScreen> createState() => _inboxScreenState();
}

class _inboxScreenState extends State<inboxScreen> {
  TextEditingController? messageController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, NexusUser>? allUsers =
        Provider.of<manager>(context, listen: false).fetchAllUsers;
    bool haveIBlocked = Provider.of<manager>(context)
        .fetchAllUsers[widget.myId]!
        .blocked
        .contains(widget.yourUid);

    bool haveTheyBlocked = Provider.of<manager>(context)
        .fetchAllUsers[widget.yourUid]!
        .blocked
        .contains(widget.myId);
    
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          title: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => userProfile(
                          uid: widget.yourUid,
                        ),
                      ));
                },
                child: (allUsers[widget.yourUid]!.dp.isNotEmpty)
                    ? CircleAvatar(
                        radius: displayWidth(context) * 0.042,
                        backgroundImage: NetworkImage(
                          allUsers[widget.yourUid]!.dp,
                        ),
                      )
                    : CircleAvatar(
                        radius: displayWidth(context) * 0.042,
                        child: const Icon(
                          Icons.person,
                          color: Colors.orange,
                        ),
                        backgroundColor: Colors.grey[200],
                      ),
              ),
              const Opacity(
                  opacity: 0,
                  child: VerticalDivider(
                    width: 12,
                  )),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => userProfile(
                          uid: widget.yourUid,
                        ),
                      ));
                },
                child: Text(
                  allUsers[widget.yourUid]!.username,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          //color: Colors.white,
          color: Colors.white,
          child: CommentBox(
            textColor: Colors.black,
            sendButtonMethod: () {
              String normalMessage = messageController!.text.toString();
              if(haveTheyBlocked || haveIBlocked){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You can no longer reply to this conversation')));
              }
              else{
                if (normalMessage.trim().isNotEmpty) {
                  String encryptedMessage =
                  encryptMessage().encryptThisMessage(normalMessage);
                  sendMessage(widget.chatId.toString(), encryptedMessage,
                      widget.myId!, widget.yourUid!);
                  setState(() {
                    messageController!.clear();
                  });
                }  
              }
              
            },
            backgroundColor: Colors.white,
            commentController: messageController,
            formKey: formKey,
            userImage: allUsers[widget.myId]!.dp != ''
                ? allUsers[widget.myId]!.dp
                : constants().fetchDpUrl,
            sendWidget: const Icon(
              Icons.send,
              color: Colors.orangeAccent,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8, left: 2, right: 10),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chat-room')
                    .doc(widget.chatId)
                    .collection('chat-room')
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return (snapshot.data.docs.length == 0)
                        ? const Center(
                            child: Text(
                              'Say Hello to your new friend',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          )
                        : ListView.builder(
                            reverse: true,
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              String encryptedMessage =
                                  snapshot.data.docs[index]['message'];
                              String uid = snapshot.data.docs[index]['uid'];
                              String message = encryptMessage()
                                  .decryptThisMessage(encryptedMessage);
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: 12.0,
                                ),
                                child: messageContainer(message, uid,
                                    allUsers[uid]!.dp, widget.myId!, context),
                              );
                            },
                          );
                  } else {
                    return Center(
                      child: load(context),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
