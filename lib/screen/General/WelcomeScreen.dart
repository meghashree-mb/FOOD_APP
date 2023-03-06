import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexus/providers/manager.dart';
import 'package:nexus/screen/General/homescreen.dart';
import 'package:nexus/utils/devicesize.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class welcomeScreen extends StatefulWidget {
  @override
  _welcomeScreenState createState() => _welcomeScreenState();
}

class _welcomeScreenState extends State<welcomeScreen> {
  bool init = true;
  User? currentUser;
  final Future<SharedPreferences> localStoreInstance =
      SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    if (init) {
      final SharedPreferences localStore = await localStoreInstance;
      localStore.setBool('feedPosts', false);
      localStore.setBool('myPosts', false);
      await Provider.of<manager>(context, listen: false).setAllUsers();
      await Provider.of<manager>(context, listen: false)
          .setSavedPostsOnce(currentUser!.uid);
      init = false;
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => homescreen(),
            ));
      }
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: displayHeight(context),
          width: displayWidth(context),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: displayHeight(context) * 0.35,
              ),
              Expanded(
                child: Image.asset(
                  'images/openLoad.gif',
                  height: displayHeight(context) * 0.2,
                  width: displayWidth(context) * 0.5,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: displayHeight(context) * 0.2,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          ' Inbuilt India',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: displayWidth(context) * 0.04,
                              color: Colors.black),
                        ),
                        const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        Text(
                          ' By Tilak',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: displayWidth(context) * 0.04,
                              color: Colors.black),
                        )
                      ],
                    ),
                    Opacity(
                        opacity: 0.0,
                        child: Divider(
                          height: displayHeight(context) * 0.05,
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Foodizo ",
                          style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w500,
                              fontSize: displayWidth(context) * 0.03),
                        ),
                        Icon(
                          Icons.copyright,
                          color: Colors.black54,
                          size: displayWidth(context) * 0.035,
                        ),
                        Text(
                          " ${DateTime.now().year}",
                          style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w500,
                              fontSize: displayWidth(context) * 0.03),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
