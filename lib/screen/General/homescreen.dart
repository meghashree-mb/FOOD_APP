import 'package:flutter/material.dart';
import 'package:nexus/providers/screenIndexProvider.dart';
import 'package:nexus/screen/Posts/addPostScreen.dart';
import 'package:nexus/screen/Chat/chatScreen.dart';
import 'package:nexus/screen/Posts/feedScreen.dart';
import 'package:nexus/screen/ProfileDetails/myProfile.dart';
import 'package:nexus/screen/General/searchScreen.dart';
import 'package:nexus/screen/personalvideo/VideoScreen.dart';
import 'package:nexus/screen/personalvideo/add_video_screen.dart';
import 'package:nexus/utils/devicesize.dart';
import 'package:provider/provider.dart';

class homescreen extends StatelessWidget {
  final List<dynamic> screens = [
    feedScreen(),
    searchScreen(),
    chatScreen(),
    profiletScreen(),
    VideoScreen(),
    AddVideoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    int screenIndex =
        Provider.of<screenIndexProvider>(context).fetchCurrentIndex;
    return Scaffold(
      // appBar: AppBar(leading: Drawer(),),
      body: Container(
        height: displayHeight(context),
        width: displayWidth(context),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: displayHeight(context),
              width: displayWidth(context),
              //color: Colors.white70,
              child: screens[screenIndex],
            ),
            Positioned(
                bottom: displayHeight(context) * 0.01,
                child: Card(
                  elevation: 6.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
                    ),
                    height: displayHeight(context) * 0.068,
                    width: displayWidth(context) * 0.63,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            child: (screenIndex == 0)
                                ? CircleAvatar(
                                    radius: displayWidth(context) * 0.05,
                                    backgroundColor: Colors.greenAccent,
                                    child: const Icon(
                                      Icons.home,
                                      color: Colors.white,
                                    ),
                                  )
                                : IconButton(
                                    iconSize: displayWidth(context) * 0.06,
                                    color: Colors.black54,
                                    icon: const Icon(Icons.home_outlined),
                                    onPressed: () {
                                      Provider.of<screenIndexProvider>(context,
                                              listen: false)
                                          .updateIndex(0);
                                    },
                                  )),
                        Expanded(
                            child: (screenIndex == 1)
                                ? CircleAvatar(
                                    radius: displayWidth(context) * 0.05,
                                    backgroundColor: Colors.greenAccent,
                                    child: const Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    ),
                                  )
                                : IconButton(
                                    iconSize: displayWidth(context) * 0.06,
                                    color: Colors.black54,
                                    icon: const Icon(Icons.search),
                                    onPressed: () {
                                      Provider.of<screenIndexProvider>(context,
                                              listen: false)
                                          .updateIndex(1);
                                    },
                                  )),
                        Expanded(
                            child: IconButton(
                          iconSize: displayWidth(context) * 0.06,
                          color: Colors.black54,
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => addPostScreen(),
                                ));
                          },
                        )),
                        Expanded(
                            child: (screenIndex == 2)
                                ? CircleAvatar(
                                    radius: displayWidth(context) * 0.05,
                                    backgroundColor: Colors.greenAccent,
                                    child: const Icon(
                                      Icons.mail,
                                      color: Colors.white,
                                    ),
                                  )
                                : IconButton(
                                    iconSize: displayWidth(context) * 0.06,
                                    color: Colors.black54,
                                    icon: const Icon(Icons.mail),
                                    onPressed: () {
                                      Provider.of<screenIndexProvider>(context,
                                              listen: false)
                                          .updateIndex(2);
                                    },
                                  )),
                        Expanded(
                            child: (screenIndex == 4)
                                ? CircleAvatar(
                              radius: displayWidth(context) * 0.05,
                              backgroundColor: Colors.greenAccent,
                              child: const Icon(
                                Icons.video_call,
                                color: Colors.white,
                              ),
                            )
                                : IconButton(
                              iconSize: displayWidth(context) * 0.06,
                              color: Colors.black54,
                              icon: const Icon(Icons.video_call),
                              onPressed: () {
                                Provider.of<screenIndexProvider>(context,
                                    listen: false)
                                    .updateIndex(4);
                              },
                            )),
                        Expanded(
                            child: (screenIndex == 3)
                                ? CircleAvatar(
                                    radius: displayWidth(context) * 0.05,
                                    backgroundColor: Colors.greenAccent,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  )
                                : IconButton(
                                    iconSize: displayWidth(context) * 0.06,
                                    color: Colors.black54,
                                    icon: const Icon(Icons.person_outlined),
                                    onPressed: () {
                                      Provider.of<screenIndexProvider>(context,
                                              listen: false)
                                          .updateIndex(3);
                                    },
                                  )),
                        Expanded(
                            child: (screenIndex == 5)
                                ? CircleAvatar(
                              radius: displayWidth(context) * 0.05,
                              backgroundColor: Colors.greenAccent,
                              child: const Icon(
                                Icons.upload_file,
                                color: Colors.white,
                              ),
                            )
                                : IconButton(
                              iconSize: displayWidth(context) * 0.06,
                              color: Colors.black54,
                              icon: const Icon(Icons.upload_file),
                              onPressed: () {
                                Provider.of<screenIndexProvider>(context,
                                    listen: false)
                                    .updateIndex(5);
                              },
                            )),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
