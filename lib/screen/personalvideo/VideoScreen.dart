import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerDataSource _betterPlayerDataSource;
  final String? videoUrl =
      "https://firebasestorage.googleapis.com/v0/b/foodizolatest.appspot.com/o/RwtmzFaN1HfgP6ZgfkzmKELWQjn1579935117155461?alt=media&token=34990122-76d5-40c0-b8d4-f35236a0270d";

  @override
  void initState() {
    BetterPlayerConfiguration betterPlayerConfiguration =
        const BetterPlayerConfiguration(
      aspectRatio: 9 / 16,
      fit: BoxFit.cover,
    );
    _betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      videoUrl!,
      cacheConfiguration: const BetterPlayerCacheConfiguration(
        useCache: true,
        preCacheSize: 10 * 1024 * 1024,
        maxCacheSize: 10 * 1024 * 1024,
        maxCacheFileSize: 10 * 1024 * 1024,
        key: "testCacheKey",
      ),
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    super.initState();
  }

  @override
  void dispose() {
    // this method dispose the controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Video',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await _betterPlayerController
                  .setupDataSource(_betterPlayerDataSource);
              await _betterPlayerController.play();
            },
            icon: Icon(Icons.play_arrow),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.next_plan_outlined),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BetterPlayer(controller: _betterPlayerController),
            const Opacity(opacity: 0.0, child: Divider()),
          ],
        ),
      ),
    );
  }
}
