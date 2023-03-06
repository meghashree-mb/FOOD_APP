// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:nexus/models/VideoModel.dart';
//
// class VideoController extends GetxController {
//   final Rx<List<VideoModel>> _videoList = Rx<List<VideoModel>>([]);
//
//   List<VideoModel> get videoList => _videoList.value;
//   var firestore = FirebaseFirestore.instance;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _videoList.bindStream(
//         firestore.collection('videos').snapshots().map((QuerySnapshot query) {
//           List<VideoModel> retVal = [];
//           for (var element in query.docs) {
//             retVal.add(
//               Video.fromSnap(element),
//             );
//           }
//           return retVal;
//         }));
//   }
//
//   likeVideo(String id) async {
//     DocumentSnapshot doc = await firestore.collection('videos').doc(id).get();
//     var uid = AuthController.instance.user.uid;
//     if ((doc.data()! as dynamic)['likes'].contains(uid)) {
//       await firestore.collection('videos').doc(id).update({
//         'likes': FieldValue.arrayRemove([uid]),
//       });
//     } else {
//       await firestore.collection('videos').doc(id).update({
//         'likes': FieldValue.arrayUnion([uid]),
//       });
//     }
//   }
// }
//
