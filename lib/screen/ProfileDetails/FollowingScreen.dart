import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexus/models/userModel.dart';
import 'package:nexus/providers/manager.dart';
import 'package:nexus/screen/ProfileDetails/userProfile.dart';
import 'package:nexus/utils/devicesize.dart';
import 'package:nexus/utils/widgets.dart';
import 'package:provider/provider.dart';

class FollowingScreen extends StatefulWidget {
  List<dynamic> following;
  Map<String, NexusUser> allUsers;
  FollowingScreen({required this.following, required this.allUsers});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  List<NexusUser> displayList = [];
  List<NexusUser> primaryList = [];

  TextEditingController? searchController;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    createMyFollowersList();
    searchController = TextEditingController();
  }

  createMyFollowersList() {
    for (var element in widget.following) {
      NexusUser user = widget.allUsers[element]!;
      primaryList.add(user);
    }
    displayList = primaryList;
  }

  searchBox() {
    return Container(
      height: displayHeight(context) * 0.08,
      width: displayWidth(context),
      //color: Colors.red,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 10, right: 10),
        child: Center(
          child: TextFormField(
            onChanged: (value) {
              if (value.isEmpty) {
                setState(() {
                  displayList = primaryList;
                });
              } else {
                List<NexusUser> tempList = primaryList
                    .where((element) =>
                        (element.uid != currentUser!.uid) &&
                        (element.title
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            element.username
                                .toLowerCase()
                                .contains(value.toLowerCase())))
                    .toList();
                setState(() {
                  displayList = tempList;
                });
              }
            },
            controller: searchController,
            decoration: const InputDecoration(
              prefixIconColor: Colors.orange,
              suffixIcon: Icon(
                Icons.person,
                color: Colors.black45,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.orange,
              ),
              hintText: "Search",
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, NexusUser> allUsers =
        Provider.of<manager>(context).fetchAllUsers;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Following',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        color: Colors.white,
        height: displayHeight(context),
        width: displayWidth(context),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              searchBox(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      if (displayList[index].uid != currentUser!.uid) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  userProfile(uid: displayList[index].uid),
                            ));
                      }
                    },
                    visualDensity:
                        const VisualDensity(horizontal: 0, vertical: -3),
                    leading: (displayList[index].dp != '')
                        ? CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                displayList[index].dp),
                            radius: displayWidth(context) * 0.05,
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            radius: displayWidth(context) * 0.05,
                            child: Icon(
                              Icons.person,
                              size: displayWidth(context) * 0.075,
                              color: Colors.orange[400],
                            ),
                          ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          displayList[index].username,
                          style: TextStyle(
                              color: Colors.black45,
                              fontSize: displayWidth(context) * 0.035),
                        ),
                        Opacity(
                            opacity: 0.0,
                            child: VerticalDivider(
                              width: displayWidth(context) * 0.003,
                            )),
                        (displayList[index].followers.length >= 25)
                            ? Icon(
                                Icons.verified,
                                color: Colors.orange[400],
                                size: displayWidth(context) * 0.048,
                              )
                            : const SizedBox(),
                      ],
                    ),
                    title: Text(
                      displayList[index].title,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: displayWidth(context) * 0.038),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
