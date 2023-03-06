// import 'dart:js';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:nexus/models/VideoModel.dart';
// import 'package:nexus/models/userModel.dart';
// import 'package:nexus/providers/manager.dart';
// import 'package:nexus/screen/personalvideo/VideoController.dart';
// import 'package:provider/provider.dart';
// import 'package:video_compress/video_compress.dart';
//
// class UploadVideoController extends GetxController {
//
//   _compressVideo(String videoPath) async {
//     final compressedVideo = await VideoCompress.compressVideo(
//       videoPath,
//       quality: VideoQuality.LowQuality,
//     );
//     return compressedVideo!.file;
//   }
//
//   Future<String> _uploadVideoToStorage(String id, String videoPath) async {
//     Reference ref = firebaseStorage.ref().child('videos').child(id);
//
//     UploadTask uploadTask = ref.putFile(await _compressVideo(videoPath));
//     TaskSnapshot snap = await uploadTask;
//     String downloadUrl = await snap.ref.getDownloadURL();
//     return downloadUrl;
//   }
//
//   _getThumbnail(String videoPath) async {
//     final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
//     return thumbnail;
//   }
//
//   Future<String> _uploadImageToStorage(String id, String videoPath) async {
//     Reference ref = firebaseStorage.ref().child('thumbnails').child(id);
//     UploadTask uploadTask = ref.putFile(await _getThumbnail(videoPath));
//     TaskSnapshot snap = await uploadTask;
//     String downloadUrl = await snap.ref.getDownloadURL();
//     return downloadUrl;
//   }
//
//   var firestore = FirebaseFirestore.instance;
//   var firebaseStorage = FirebaseStorage.instance;
//   var firebaseAuth = FirebaseAuth.instance;
//
// // User? currentUser;
// // currentUser = FirebaseAuth.instance.currentUser;
// // NexusUser? myProfile = Provider.of<manager>(context).fetchAllUsers[currentUser!.uid.toString()];
//
//
//   // upload video
//   uploadVideo(String songName, String caption, String videoPath) async {
//     try {
//       // String uid = firebaseAuth.currentUser!.uid;
//       // String uid = AuthController.instance.firebaseAuth.currentUser!.uid;
//       // THIS IS WERE THE ERROR IS ERROR CONNECTING WITH DATABASE
//       // DocumentSnapshot userDoc =
//       // await firestore.collection('users').doc(uid).get();
//       // get id
//       User? currentUser;
//       currentUser = FirebaseAuth.instance.currentUser;
//       NexusUser? myProfile = Provider.of<manager>(context).fetchAllUsers[currentUser!.uid.toString()];
//
//       var allDocs = await firestore.collection('videos').get();
//       int len = allDocs.docs.length;
//       String videoUrl = await _uploadVideoToStorage("Video $len", videoPath);
//       String thumbnail = await _uploadImageToStorage("Video $len", videoPath);
//
//       Video video = Video(
//         username: (myProfile!.username as Map<String, dynamic>)['name'],
//         uid: myProfile!.uid,
//         id: "Video $len",
//         likes: [],
//         commentCount: 0,
//         shareCount: 0,
//         songName: songName,
//         caption: caption,
//         videoUrl: videoUrl,
//         profilePhoto: (myProfile!.dp as Map<String, dynamic>)['profilePhoto'],
//         thumbnail: thumbnail,
//       );
//
//       await firestore.collection('videos').doc('Video $len').set(
//         video.toJson(),
//       );
//       Get.back();
//     } catch (e) {
//       Get.snackbar(
//         'Error Uploading Video',
//         e.toString(),
//       );
//     }
//   }
// }
//
