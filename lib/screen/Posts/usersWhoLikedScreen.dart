import 'package:flutter/material.dart';
import 'package:nexus/models/userModel.dart';
import 'package:nexus/providers/manager.dart';
import 'package:nexus/utils/devicesize.dart';
import 'package:nexus/utils/widgets.dart';
import 'package:provider/provider.dart';

class usersWhoLikedScreen extends StatelessWidget {
  final List<dynamic>? usersWhoLiked;
  usersWhoLikedScreen({this.usersWhoLiked});

  @override
  Widget build(BuildContext context) {
    Map<String, NexusUser> allUsers =
        Provider.of<manager>(context).fetchAllUsers;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: const Text(
          'Likes',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        color: Colors.white,
        height: displayHeight(context),
        width: displayWidth(context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: usersWhoLiked!.length,
            itemBuilder: (context, index) {
              return displayProfileHeads(
                  context, allUsers[usersWhoLiked![index]]!);
            },
          ),
        ),
      ),
    );
  }
}
