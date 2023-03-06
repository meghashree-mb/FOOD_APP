import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexus/models/NotificationModel.dart';
import 'package:nexus/models/PostModel.dart';
import 'package:nexus/models/StoryModel.dart';
import 'package:nexus/models/VideoModel.dart';
import 'package:nexus/models/userModel.dart';
import 'package:nexus/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:nexus/utils/widgets.dart';

class manager extends ChangeNotifier {
  List<NotificationModel> notificationList = [];

  List<StoryModel> feedStoryList = [];

  Map<String, PostModel> feedPostMap = {};

  Map<String, PostModel> yourPostsMap = {};

  Map<String, PostModel> myPostsMap = {};

  Map<String, PostModel> savedPostsMap = {};

  Map<String, PostModel> get fetchSavedPostsMap => savedPostsMap;

  Map<String, PostModel> get fetchFeedPostsMap => feedPostMap;

  Map<String, PostModel> get fetchYourPostsMap => yourPostsMap;

  Map<String, PostModel> get fetchMyPostsMap => myPostsMap;

  Map<String, VideoModel> myVideoMap = {};

  Map<String, VideoModel> yourVideoMap = {};

  Map<String, VideoModel> get fetchMyVideoMap => myVideoMap;

  Map<String, VideoModel> get fetchYourVideoMap => yourVideoMap;

  Map<String, VideoModel> feedVideoMap = {};

  Map<String, VideoModel> get fetchFeedVideoMap => feedVideoMap;

  List<PostModel> savedPostList = [];

  List<PostModel> feedPostList = [];

  List<PostModel> yourPostsList = [];

  List<PostModel> myPostsList = [];

  List<VideoModel> feedVideoList = [];

  List<VideoModel> yourVideoList = [];

  List<VideoModel> myVideoList = [];

  List<PostModel> get fetchSavedPostList {
    return [...savedPostList];
  }

  List<VideoModel> get fetchMyVideoList {
    myVideoList.sort((a, b) => b.dateOfPost.compareTo(a.dateOfPost));
    return [...myVideoList];
  }

  List<VideoModel> get fetchYourVideoList {
    yourVideoList.sort((a, b) => b.dateOfPost.compareTo(a.dateOfPost));
    return [...yourVideoList];
  }

  List<PostModel> get fetchMyPostsList {
    myPostsList.sort((a, b) => b.dateOfPost.compareTo(a.dateOfPost));
    return [...myPostsList];
  }

  List<PostModel> get fetchYourPostsList {
    yourPostsList.sort((a, b) => b.dateOfPost.compareTo(a.dateOfPost));
    return [...yourPostsList];
  }

  List<PostModel> get fetchFeedPostList {
    return [...feedPostList];
  }

  List<VideoModel> get fetchFeedVideoList {
    return [...feedVideoList];
  }

  Map<String, NexusUser> allUsers = {};

  Map<String, NexusUser> get fetchAllUsers {
    return allUsers;
  }

  Future<void> setMyProfile(String myUid) async {
    final String api = constants().fetchApi + 'users/${myUid}.json';
    try {
      final response = await http.get(Uri.parse(api));
      final data = json.decode(response.body) as Map<String, dynamic>;
      NexusUser updatedUser = NexusUser(
        blocked: data['blocked'],
          bio: data['bio'],
          coverImage: data['coverImage'],
          dp: data['dp'],
          email: data['email'],
          followers: data['followers'] ?? [],
          followings: data['followings'] ?? [],
          title: data['title'],
          uid: data['uid'],
          username: data['username'],
          story: data['story'] ?? '',
          storyTime: DateTime.parse(data['storyTime']),
          views: data['views'] ?? []);
      allUsers[myUid] = updatedUser;
      notifyListeners();
    } catch (error) {}
  }

  Future<void> deleteCommentFromThisPost(
      String postId, String commentId) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  Future<void> setAllUsers() async {
    final String api = constants().fetchApi + 'users.json';
    Map<String, NexusUser> temp = {};
    try {
      final userResponse = await http.get(Uri.parse(api));
      final userData = json.decode(userResponse.body) as Map<String, dynamic>;
      userData.forEach((key, value) {
        temp[key] = NexusUser(
          blocked: value['blocked']??[],
            views: value['views'] ?? [],
            story: value['story'] ?? '',
            storyTime: DateTime.parse(value['storyTime']),
            bio: value['bio'],
            coverImage: value['coverImage'],
            dp: value['dp'],
            email: value['email'],
            followers: value['followers'] ?? [],
            followings: value['followings'] ?? [],
            title: value['title'],
            uid: key,
            username: value['username']);
      });
      allUsers = temp;
      notifyListeners();
    } catch (error) {}
  }

  // Function to set posts and stories that will be diplayed on your feed screen
  Future<void> setFeedPosts(String myUid) async {
    List<PostModel> tempPostList = [];
    List<StoryModel> tempStoryList = [];
    List<dynamic> myFollowing = allUsers[myUid]!.followings;
    for (int i = 0; i < myFollowing.length; ++i) {
      String uid = myFollowing[i].toString();
      tempPostList.addAll(await getListOfPostsUsingUid(myUid,uid));
      if (hasStory(myFollowing[i])) {
        tempStoryList.add(StoryModel(
          story: allUsers[myFollowing[i]]!.story,
          storyTime: allUsers[myFollowing[i]]!.storyTime,
          views: allUsers[myFollowing[i]]!.views,
          uid: myFollowing[i],
        ));
      }
    }
    feedStoryList = tempStoryList;
    feedPostList = tempPostList;
    feedStoryList.sort((a, b) => b.storyTime!.compareTo(a.storyTime!));
    feedPostList.sort((a, b) => b.dateOfPost.compareTo(a.dateOfPost));
    notifyListeners();
  }

  // Funtion that returns a future list of posts using a provided uid -> only used by setFeedPost()
  Future<List<PostModel>> getListOfPostsUsingUid(String myUid,String uid) async {
    List<PostModel> list = [];
    final String apiForPosts = constants().fetchApi + 'posts/${uid}.json';
    final responseOfPosts = await http.get(Uri.parse(apiForPosts));
    if (json.decode(responseOfPosts.body) != null) {
      final postData =
          json.decode(responseOfPosts.body) as Map<String, dynamic>;
      postData.forEach((key, value) {
        PostModel p = PostModel(
          hiddenFrom: value['hiddenFrom']??[],
            caption: value['caption'],
            dateOfPost: DateTime.parse(value['dateOfPost']),
            image: value['image'],
            uid: value['uid'],
            post_id: key,
            likes: value['likes'] ?? []);
        if(timeBetweenInDays(p.dateOfPost, DateTime.now())<=6 && !(p.hiddenFrom.contains(myUid))){
          feedPostMap[key] = p;
          list.add(p);
        }
      });
    }
    return list;
  }

  //Function to set videos that will be displayed on your feed screen
  Future<void> setFeedVideos(String myUid) async {
    List<VideoModel> tempVideoList = [];
    List<dynamic> myFollowing = allUsers[myUid]!.followings;
    for (int i = 0; i < myFollowing.length; ++i) {
      String uid = myFollowing[i].toString();
      tempVideoList.addAll(await getListOfVideoUsingUid(myUid,uid));
    }
    feedVideoList = tempVideoList;
    feedVideoList.sort((a, b) => b.dateOfPost.compareTo(a.dateOfPost));
    notifyListeners();
  }

  // Funtion that returns a future list of videos using a provided uid -> only used by setFeedVideo()
  Future<List<VideoModel>> getListOfVideoUsingUid(String myUid,String uid) async {
    List<VideoModel> list = [];
    final String apiForVideos = constants().fetchApi + 'videos/${uid}.json';
    final responseOfVideo = await http.get(Uri.parse(apiForVideos));
    if (json.decode(responseOfVideo.body) != null) {
      final postData =
      json.decode(responseOfVideo.body) as Map<String, dynamic>;
      postData.forEach((key, value) {
        VideoModel v = VideoModel(
            hiddenFrom: value['hiddenFrom']??[],
            caption: value['caption'],
            dateOfPost: DateTime.parse(value['dateOfPost']),
            video: value['video'],
            uid: value['uid'],
            video_id: key,
            likes: value['likes'] ?? []);
        if(timeBetweenInDays(v.dateOfPost, DateTime.now())<=6 && !(v.hiddenFrom.contains(myUid))){
          feedVideoMap[key] = v;
          list.add(v);
        }
      });
    }
    return list;
  }

  Future<void> addCoverPicture(File? newImage, String uid) async {
    String imageLocation = 'users/${uid}/details/cp';
    final Reference storageReference =
        FirebaseStorage.instance.ref().child(imageLocation);
    final UploadTask uploadTask = storageReference.putFile(newImage!);
    final TaskSnapshot taskSnapshot = await uploadTask;
    await taskSnapshot.ref.getDownloadURL().then((value) async {
      final String api = constants().fetchApi + 'users/${uid}.json';
      try {
        await http
            .patch(Uri.parse(api), body: jsonEncode({'coverImage': value}))
            .then((_) {
          allUsers[uid]!.changeCoverPicture(value);
          notifyListeners();
        });
      } catch (error) {}
    });
  }

  Future<void> addProfilePicture(File? newImage, String uid) async {
    String imageLocation = 'users/${uid}/details/dp';
    final Reference storageReference =
        FirebaseStorage.instance.ref().child(imageLocation);
    final UploadTask uploadTask = storageReference.putFile(newImage!);
    final TaskSnapshot taskSnapshot = await uploadTask;
    await taskSnapshot.ref.getDownloadURL().then((downloadLink) async {
      final String api = constants().fetchApi + 'users/${uid}.json';
      try {
        await http
            .patch(Uri.parse(api), body: jsonEncode({'dp': downloadLink}))
            .then((value) {
          allUsers[uid]!.changeDP(downloadLink);
          notifyListeners();
        });
      } catch (error) {}
    });
  }

  List<StoryModel> get fetchStoryList {
    return [...feedStoryList];
  }

  Future<void> editMyProfile(
      String uid, String fullName, String userName, String bio) async {
    final String api = constants().fetchApi + 'users/${uid}.json';
    NexusUser? oldUser = allUsers[uid];
    NexusUser? updateUser;
    try {
      http
          .patch(Uri.parse(api),
              body: jsonEncode({
                'title': fullName,
                'username': userName,
                'bio': bio,
              }))
          .then((value) {
        updateUser = NexusUser(
          blocked: oldUser!.blocked,
            views: oldUser.views,
            story: oldUser.story,
            storyTime: oldUser.storyTime,
            bio: bio,
            coverImage: oldUser.coverImage,
            dp: oldUser.dp,
            email: oldUser.email,
            followers: oldUser.followers,
            followings: oldUser.followings,
            title: fullName,
            uid: uid,
            username: userName);
        allUsers[uid] = updateUser!;
        notifyListeners();
      });
    } catch (error) {}
  }

  Future<void> followUser(String myUid, String yourUid) async {
    allUsers[myUid]!.addFollowing(yourUid);
    allUsers[yourUid]!.addFolllower(myUid);
    notifyListeners();
    List myFollowings = await getMyFollowings(myUid);
    myFollowings.add(yourUid);
    List yourFollowers = await getYourFollowers(yourUid);
    yourFollowers.add(myUid);
    final String myApi = constants().fetchApi + 'users/${myUid}.json';
    final String yourApi = constants().fetchApi + 'users/${yourUid}.json';
    await http.patch(Uri.parse(myApi),
        body: json.encode({'followings': myFollowings}));
    await http.patch(Uri.parse(yourApi),
        body: json.encode({'followers': yourFollowers}));
    await sendNotification(myUid, yourUid, '', 'follow');
    String? chatId = generateChatRoomUsingUid(myUid, yourUid);
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(myUid)
        .collection('mychats')
        .doc(chatId)
        .set({
      'chatId': chatId,
      'last seen': Timestamp.now(),
      'uid': yourUid,
    });
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(yourUid)
        .collection('mychats')
        .doc(chatId)
        .set({
      'chatId': chatId,
      'last seen': Timestamp.now(),
      'uid': myUid,
    });
    await setFeedPosts(myUid);
  }

  Future<List<dynamic>> getYourFollowers(String uid) async {
    final String api = constants().fetchApi + 'users/${uid}.json';
    List<dynamic>? followers;
    final response = await http.get(Uri.parse(api));
    final data = json.decode(response.body) as Map<String, dynamic>;
    followers = data['followers'] ?? [];
    return followers!;
  }

  Future<List<dynamic>> getMyFollowings(String uid) async {
    final String api = constants().fetchApi + 'users/${uid}.json';
    List<dynamic>? followings;
    final response = await http.get(Uri.parse(api));
    final data = json.decode(response.body) as Map<String, dynamic>;
    followings = data['followings'] ?? [];
    return followings!;
  }

  Future<void> unFollowUser(String myUid, String yourUid) async {
    allUsers[myUid]!.removeFollowing(yourUid);
    allUsers[yourUid]!.removeFollower(myUid);
    notifyListeners();
    List myFollowings = await getMyFollowings(myUid);
    myFollowings.remove(yourUid);
    List yourFollowers = await getYourFollowers(yourUid);
    yourFollowers.remove(myUid);
    final String myApi = constants().fetchApi + 'users/${myUid}.json';
    final String yourApi = constants().fetchApi + 'users/${yourUid}.json';
    await http.patch(Uri.parse(myApi),
        body: json.encode({'followings': myFollowings}));
    await http.patch(Uri.parse(yourApi),
        body: json.encode({'followers': yourFollowers}));
    await setFeedPosts(myUid);
  }

  // Function to set my posts
  Future<void> setMyPosts(String uid) async {
    List<PostModel> tempList = [];
    Map<String, PostModel> tempMap = {};
    final String api = constants().fetchApi + 'posts/${uid}.json';
    final postResponse = await http.get(Uri.parse(api));
    if (json.decode(postResponse.body) != null) {
      final postData = json.decode(postResponse.body) as Map<String, dynamic>;
      postData.forEach((key, value) {
        PostModel p = PostModel(
            hiddenFrom: value['hiddenFrom']??[],
            caption: value['caption'],
            dateOfPost: DateTime.parse(value['dateOfPost']),
            image: value['image'],
            uid: value['uid'],
            post_id: key,
            likes: value['likes'] ?? []);
        tempList.add(p);
        tempMap[key] = p;
      });
    }
    myPostsList = tempList;
    myPostsMap = tempMap;
    notifyListeners();
  }

  // Function to set your posts
  Future<void> setYourPosts(String uid) async {
    List<PostModel> tempList = [];
    Map<String, PostModel> tempMap = {};
    final String api = constants().fetchApi + 'posts/${uid}.json';
    final postResponse = await http.get(Uri.parse(api));
    if (json.decode(postResponse.body) != null) {
      final postData = json.decode(postResponse.body) as Map<String, dynamic>;
      postData.forEach((key, value) {
        PostModel p = PostModel(
            hiddenFrom: value['hiddenFrom']??[],
            caption: value['caption'],
            dateOfPost: DateTime.parse(value['dateOfPost']),
            image: value['image'],
            uid: value['uid'],
            post_id: key,
            likes: value['likes'] ?? []);
        tempList.add(p);
        tempMap[key] = p;
      });
    }
    yourPostsList = tempList;
    yourPostsMap = tempMap;
    notifyListeners();
  }

  // Function to add new video
  Future<void> addNewVideo(String caption, String uid, File video) async {
    final String api = constants().fetchApi + 'videos/${uid}.json';
    try {
      var random = Random();
      DateTime datetime = DateTime.now();
      final String dateOfPost = datetime.toString();
      int random1 = random.nextInt(999999);
      int random2 = random.nextInt(555555);
      int random3 = random.nextInt(101);
      int random4 = random.nextInt(540);
      final String name = '${random1}${random2}${random3}${random4}';
      final String location = '${uid}${name}';
      final Reference storageReference =
      FirebaseStorage.instance.ref().child(location);
      final UploadTask uploadTask = storageReference.putFile(video);
      final TaskSnapshot taskSnapshot = await uploadTask;
      taskSnapshot.ref.getDownloadURL().then((value) async {
        http
            .post(Uri.parse(api),
            body: json.encode({
              'caption': caption,
              'video': value,
              'uid': uid,
              'likes': [],
              'dateOfPost': dateOfPost,
            }))
            .then((v) {
          final videodata = json.decode(v.body) as Map<String, dynamic>;
          myVideoMap[videodata['name']] = VideoModel(
              hiddenFrom: [],
              caption: caption,
              dateOfPost: datetime,
              video: value,
              uid: uid,
              video_id: videodata['name'],
              likes: []);
          myVideoList.add(VideoModel(
              hiddenFrom: [],
              caption: caption,
              dateOfPost: datetime,
              video: value,
              uid: uid,
              video_id: videodata['name'],
              likes: []));
          notifyListeners();
        });
      });
    } catch (error) {}
  }

  // Function to add new post
  Future<void> addNewPost(String caption, String uid, File image) async {
    final String api = constants().fetchApi + 'posts/${uid}.json';
    try {
      var random = Random();
      DateTime datetime = DateTime.now();
      final String dateOfPost = datetime.toString();
      int random1 = random.nextInt(999999);
      int random2 = random.nextInt(555555);
      int random3 = random.nextInt(101);
      int random4 = random.nextInt(540);
      final String name = '${random1}${random2}${random3}${random4}';
      final String location = '${uid}${name}';
      final Reference storageReference =
          FirebaseStorage.instance.ref().child(location);
      final UploadTask uploadTask = storageReference.putFile(image);
      final TaskSnapshot taskSnapshot = await uploadTask;
      taskSnapshot.ref.getDownloadURL().then((value) async {
        http
            .post(Uri.parse(api),
                body: json.encode({
                  'caption': caption,
                  'image': value,
                  'uid': uid,
                  'likes': [],
                  'dateOfPost': dateOfPost,
                }))
            .then((v) {
          final postData = json.decode(v.body) as Map<String, dynamic>;
          myPostsMap[postData['name']] = PostModel(
              hiddenFrom: [],
              caption: caption,
              dateOfPost: datetime,
              image: value,
              uid: uid,
              post_id: postData['name'],
              likes: []);
          myPostsList.add(PostModel(
            hiddenFrom: [],
              caption: caption,
              dateOfPost: datetime,
              image: value,
              uid: uid,
              post_id: postData['name'],
              likes: []));

          notifyListeners();
        });
      });
    } catch (error) {}
  }

  // Function to delete post
  Future<void> deletePost(String myUid, String postId) async {
    final String api = constants().fetchApi + 'posts/${myUid}/$postId.json';
    try {
      myPostsMap.remove(postId);
      myPostsList.removeWhere((element) => element.post_id == postId);
      notifyListeners();
      await http.delete(Uri.parse(api));
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
    } catch (error) {}
  }

  // Update likes to server
  Future<void> likePostUpdateToServer(
      String op, String postId, List<dynamic> likes) async {
    final String api = constants().fetchApi + 'posts/${op}/${postId}.json';
    await http.patch(Uri.parse(api), body: json.encode({'likes': likes}));
  }

  // Like post
  Future<void> likePost(
      String myUid, String opId, String postId, String source) async {
    // Souce can be -> "feed","self","yours"

    switch (source) {
      case 'feed':
        {
          PostModel oldPost = feedPostMap[postId]!;
          List<dynamic> likes = oldPost.likes;
          likes.add(myUid);
          int index =
              feedPostList.indexWhere((element) => element.post_id == postId);
          feedPostList.removeAt(index);
          feedPostMap[postId] = PostModel(
            hiddenFrom: oldPost.hiddenFrom,
              caption: oldPost.caption,
              dateOfPost: oldPost.dateOfPost,
              image: oldPost.image,
              uid: oldPost.uid,
              post_id: oldPost.post_id,
              likes: likes);
          feedPostList.insert(
              index,
              PostModel(
                  hiddenFrom: oldPost.hiddenFrom,
                  caption: oldPost.caption,
                  dateOfPost: oldPost.dateOfPost,
                  image: oldPost.image,
                  uid: oldPost.uid,
                  post_id: oldPost.post_id,
                  likes: likes));
          notifyListeners();
        }
        break;
      case 'self':
        {
          PostModel oldPost = myPostsMap[postId]!;
          List<dynamic> likes = oldPost.likes;
          likes.add(myUid);
          int index =
              myPostsList.indexWhere((element) => element.post_id == postId);
          myPostsList.removeAt(index);
          myPostsMap[postId] = PostModel(
              hiddenFrom: oldPost.hiddenFrom,
              caption: oldPost.caption,
              dateOfPost: oldPost.dateOfPost,
              image: oldPost.image,
              uid: oldPost.uid,
              post_id: oldPost.post_id,
              likes: likes);
          myPostsList.insert(
              index,
              PostModel(
                  hiddenFrom: oldPost.hiddenFrom,
                  caption: oldPost.caption,
                  dateOfPost: oldPost.dateOfPost,
                  image: oldPost.image,
                  uid: oldPost.uid,
                  post_id: oldPost.post_id,
                  likes: likes));
          notifyListeners();
        }
        break;

      case 'yours':
        {
          PostModel oldPost = yourPostsMap[postId]!;
          List<dynamic> likes = oldPost.likes;
          likes.add(myUid);
          int index =
              yourPostsList.indexWhere((element) => element.post_id == postId);
          yourPostsList.removeAt(index);
          yourPostsMap[postId] = PostModel(
              hiddenFrom: oldPost.hiddenFrom,
              caption: oldPost.caption,
              dateOfPost: oldPost.dateOfPost,
              image: oldPost.image,
              uid: oldPost.uid,
              post_id: oldPost.post_id,
              likes: likes);
          yourPostsList.insert(
              index,
              PostModel(
                  hiddenFrom: oldPost.hiddenFrom,
                  caption: oldPost.caption,
                  dateOfPost: oldPost.dateOfPost,
                  image: oldPost.image,
                  uid: oldPost.uid,
                  post_id: oldPost.post_id,
                  likes: likes));
          notifyListeners();
        }
        break;
      default:
        {}
    }

    List<dynamic> likes = [];
    final String api = constants().fetchApi + 'posts/${opId}/${postId}.json';
    final postResponse = await http.get(Uri.parse(api));
    final postData = json.decode(postResponse.body) as Map<String, dynamic>;
    likes = postData['likes'] ?? [];
    likes.add(myUid);
    await likePostUpdateToServer(opId, postId, likes);
    await setFeedPosts(myUid);
    await setMyPosts(myUid);
    await setYourPosts(opId);
    await sendNotification(myUid, opId, postId, 'like');
  }

  // Dislike post
  Future<void> dislikePost(
      String myUid, String opId, String postId, String source) async {
    // Souce can be -> "feed","self","yours","saved"

    switch (source) {
      case 'feed':
        {
          PostModel oldPost = feedPostMap[postId]!;
          List<dynamic> likes = oldPost.likes;
          likes.remove(myUid);
          int index =
              feedPostList.indexWhere((element) => element.post_id == postId);
          feedPostList.removeAt(index);
          feedPostMap[postId] = PostModel(
              hiddenFrom: oldPost.hiddenFrom,
              caption: oldPost.caption,
              dateOfPost: oldPost.dateOfPost,
              image: oldPost.image,
              uid: oldPost.uid,
              post_id: oldPost.post_id,
              likes: likes);

          feedPostList.insert(
              index,
              PostModel(
                  caption: oldPost.caption,
                  hiddenFrom: oldPost.hiddenFrom,
                  dateOfPost: oldPost.dateOfPost,
                  image: oldPost.image,
                  uid: oldPost.uid,
                  post_id: oldPost.post_id,
                  likes: likes));
          notifyListeners();
        }
        break;
      case 'self':
        {
          PostModel oldPost = myPostsMap[postId]!;
          List<dynamic> likes = oldPost.likes;
          likes.remove(myUid);
          int index =
              myPostsList.indexWhere((element) => element.post_id == postId);
          myPostsList.removeAt(index);
          myPostsMap[postId] = PostModel(
              hiddenFrom: oldPost.hiddenFrom,
              caption: oldPost.caption,
              dateOfPost: oldPost.dateOfPost,
              image: oldPost.image,
              uid: oldPost.uid,
              post_id: oldPost.post_id,
              likes: likes);
          myPostsList.insert(
              index,
              PostModel(
                  caption: oldPost.caption,
                  dateOfPost: oldPost.dateOfPost,
                  image: oldPost.image,
                  uid: oldPost.uid,
                  post_id: oldPost.post_id,
                  hiddenFrom: oldPost.hiddenFrom,
                  likes: likes));
          notifyListeners();
        }
        break;
      case 'yours':
        {
          PostModel oldPost = yourPostsMap[postId]!;
          List<dynamic> likes = oldPost.likes;
          likes.remove(myUid);
          int index =
              yourPostsList.indexWhere((element) => element.post_id == postId);
          yourPostsList.removeAt(index);
          yourPostsMap[postId] = PostModel(
              hiddenFrom: oldPost.hiddenFrom,
              caption: oldPost.caption,
              dateOfPost: oldPost.dateOfPost,
              image: oldPost.image,
              uid: oldPost.uid,
              post_id: oldPost.post_id,
              likes: likes);
          yourPostsList.insert(
              index,
              PostModel(
                  caption: oldPost.caption,
                  hiddenFrom: oldPost.hiddenFrom,
                  dateOfPost: oldPost.dateOfPost,
                  image: oldPost.image,
                  uid: oldPost.uid,
                  post_id: oldPost.post_id,
                  likes: likes));
          notifyListeners();
        }
        break;
      default:
        {}
    }
    List<dynamic> likes = [];
    final String api = constants().fetchApi + 'posts/${opId}/${postId}.json';
    final postResponse = await http.get(Uri.parse(api));
    final postData = json.decode(postResponse.body) as Map<String, dynamic>;
    likes = postData['likes'] ?? [];
    likes.remove(myUid);
    await likePostUpdateToServer(opId, postId, likes);
    await setFeedPosts(myUid);
    await setMyPosts(myUid);
    await setYourPosts(opId);
  }

  Future<void> setSavedPostsOnce(String uid) async {
    final String api = constants().fetchApi + 'saved/${uid}.json';
    Map<String, PostModel> tempPosts = {};
    Map<String, String> tempKeys = {};
    try {
      final savedPostIdResponse = await http.get(Uri.parse(api));
      if (json.decode(savedPostIdResponse.body) != null) {
        final savedPostIdData =
            json.decode(savedPostIdResponse.body) as Map<String, dynamic>;
        savedPostIdData.forEach((key, value) async {
          tempKeys[value['postId']] = value['saveId'];
          tempPosts[value['postId'].toString()] =
              await getThisPostDetail(value['op'], value['postId'].toString());
        });
      }
      savedPostsMap = tempPosts;
      savedPostsKeys = tempKeys;
      notifyListeners();
    } catch (error) {}
  }

  Future<void> updateCaption(
      String myUid, String postId, String updatedCaption) async {
    final String api = constants().fetchApi + 'posts/${myUid}/${postId}.json';
    try {
      PostModel oldPost = myPostsMap[postId]!;
      int index =
          myPostsList.indexWhere((element) => element.post_id == postId);
      myPostsList.removeAt(index);
      PostModel updatedPost = PostModel(
          hiddenFrom: oldPost.hiddenFrom,
          caption: updatedCaption,
          dateOfPost: oldPost.dateOfPost,
          image: oldPost.image,
          uid: oldPost.uid,
          post_id: oldPost.post_id,
          likes: oldPost.likes);
      myPostsList.insert(index, updatedPost);
      myPostsMap[postId] = updatedPost;
      notifyListeners();
      await http.patch(Uri.parse(api),
          body: json.encode({'caption': updatedCaption}));
    } catch (error) {}
  }

  Future<PostModel> getThisPostDetail(String op, String postId) async {
    PostModel? returnThisPost;
    final String api = constants().fetchApi + 'posts/${op}/${postId}.json';
    try {
      final response = await http.get(Uri.parse(api));
      final data = json.decode(response.body) as Map<String, dynamic>;
      returnThisPost = PostModel(
        hiddenFrom: data['hiidenFrom'],
          caption: data['caption'],
          dateOfPost: DateTime.parse(data['dateOfPost']),
          image: data['image'],
          uid: data['uid'],
          post_id: postId,
          likes: data[postId] ?? []);
      return returnThisPost;
    } catch (error) {}
    return returnThisPost!;
  }

  Future<void> savePost(
    PostModel postModel,
    String myUid,
  ) async {
    String? saveId;
    final String api = constants().fetchApi + 'saved/${myUid}.json';
    try {
      savedPostsMap[postModel.post_id] = postModel;

      notifyListeners();
      await http
          .post(Uri.parse(api),
              body: json.encode({
                'op': postModel.uid,
                'postId': postModel.post_id,
              }))
          .then((value) async {
        final serverData = json.decode(value.body) as Map<String, dynamic>;
        saveId = serverData['name'];
      });
      final String savePostApi =
          constants().fetchApi + 'saved/${myUid}/${saveId!}.json';
      await http.patch(Uri.parse(savePostApi),
          body: json.encode({'saveId': saveId}));
      savedPostsKeys[postModel.post_id] = saveId!;
      notifyListeners();
    } catch (error) {
      if (savedPostsMap.containsKey(postModel.post_id)) {
        savedPostsMap.remove(postModel.post_id);
      }
    }
  }

  // Future<void> saveVideo(
  //     VideoModel videoModel,
  //     String myUid,
  //     ) async {
  //   String? saveId;
  //   final String api = constants().fetchApi + 'saved/${myUid}.json';
  //   try {
  //     savedPostsMap[postModel.post_id] = postModel;
  //
  //     notifyListeners();
  //     await http
  //         .post(Uri.parse(api),
  //         body: json.encode({
  //           'op': postModel.uid,
  //           'postId': postModel.post_id,
  //         }))
  //         .then((value) async {
  //       final serverData = json.decode(value.body) as Map<String, dynamic>;
  //       saveId = serverData['name'];
  //     });
  //     final String savePostApi =
  //         constants().fetchApi + 'saved/${myUid}/${saveId!}.json';
  //     await http.patch(Uri.parse(savePostApi),
  //         body: json.encode({'saveId': saveId}));
  //     savedPostsKeys[postModel.post_id] = saveId!;
  //     notifyListeners();
  //   } catch (error) {
  //     if (savedPostsMap.containsKey(postModel.post_id)) {
  //       savedPostsMap.remove(postModel.post_id);
  //     }
  //   }
  // }

  Map<String, String> savedPostsKeys = {};

  Future<void> unsavePost(String postId, String myUid) async {
    final String api = constants().fetchApi +
        'saved/${myUid}/${savedPostsKeys[postId].toString()}.json';
    try {
      await http.delete(Uri.parse(api));
      savedPostsMap.remove(postId);
      savedPostsKeys.remove(postId);
      notifyListeners();
    } catch (error) {}
  }

  Future<void> setNotifications(String myUid) async {

    List<NotificationModel> tempList = [];
    final String api = constants().fetchApi + 'notifications/${myUid}.json';
    try {
      final notificationResponse = await http.get(Uri.parse(api));
      if (json.decode(notificationResponse.body) != null) {
        final notificationData =
            json.decode(notificationResponse.body) as Map<String, dynamic>;
        notificationData.forEach((key, value) {

            tempList.add(NotificationModel(
                notificationId: key,
                read: value['read'],
                notifierUid: value['notifierUid'],
                postId: value['postId'],
                time: DateTime.parse(value['time']),
                type: value['type']));

        });
      }

      notificationList = tempList;

      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> sendNotification(
      String myUid, String yourId, String postId, String type) async {
    if (myUid == yourId) {
      return;
    }
    final String api = constants().fetchApi + 'notifications/${yourId}.json';
    try {
      await http.post(Uri.parse(api),
          body: json.encode({
            'notifierUid': myUid,
            'type': type,
            'time': DateTime.now().toString(),
            'postId': postId,
            'read': false
          }));
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> commentOnPost(
      String myId, String yourId, String postId, String comment) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'comment': comment,
      'time': Timestamp.now(),
      'uid': myId,
      'replies': [],
      'likes': []
    }).then((value) {
      FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(value.id)
          .update({'commentId': value.id});
    });
    await sendNotification(myId, yourId, postId, 'comment');
  }

  bool isMyPost(String postId) {
    return myPostsMap.containsKey(postId);
  }

  Future<void> deleteNotification(String myUid, String notificationId) async {
    final String api =
        constants().fetchApi + 'notifications/${myUid}/${notificationId}.json';
    int index = notificationList
        .indexWhere((element) => element.notificationId == notificationId);
    notificationList.removeAt(index);
    notifyListeners();
    try {
      await http.delete(Uri.parse(api));
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> readAllNotificationAtOnce(String myUid) async {
    final String preApi = constants().fetchApi + 'notifications/${myUid}/';
    try {
      for (var notification in notificationList) {
        notification.updateNotificationStatus();
      }
      notifyListeners();
      for (var notification in notificationList) {
        final String api = preApi + '${notification.notificationId}.json';
        await http.patch(Uri.parse(api), body: json.encode({'read': true}));
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> readNotification(String myUid, String notificationId) async {
    final String api =
        constants().fetchApi + 'notifications/${myUid}/${notificationId}.json';
    int index = notificationList
        .indexWhere((element) => element.notificationId == notificationId);
    notificationList[index].updateNotificationStatus();
    notifyListeners();
    await http.patch(Uri.parse(api),
        body: json.encode({
          'read': true,
        }));
  }

  List<NotificationModel> get fetchNotifications {
    notificationList.sort((a, b) => b.time!.compareTo(a.time!));
    return [...notificationList];
  }

  Future<void> addStoryToServer(String myUid, File? story) async {
    final String imageLocation = '${myUid}/story/storyImage';
    final Reference storageReference =
        FirebaseStorage.instance.ref().child(imageLocation);
    final UploadTask uploadTask = storageReference.putFile(story!);
    final TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then((value) async {
      final String api = constants().fetchApi + 'users/${myUid}.json';
      await http.patch(Uri.parse(api),
          body: json.encode({
            'story': value,
            'storyTime': DateTime.now().toString(),
            'views': [],
          }));
      allUsers[myUid]!.addStory(value);
      notifyListeners();
    });
  }

  bool hasStory(String uid) {
    if (allUsers[uid]!.story != '' &&
        timeBetween(allUsers[uid]!.storyTime, DateTime.now()) < 24) return true;
    return false;
  }

  Future<void> deleteStoryFromServer(String myUid) async {
    final String api = constants().fetchApi + 'users/${myUid}.json';
    allUsers[myUid]!.removeStroy();
    notifyListeners();
    try {
      await http.patch(Uri.parse(api),
          body: json.encode({
            'story': '',
            'views': [],
          }));
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> increaseViewsOnStory(String uid, String myUid) async {
    final String api = constants().fetchApi + 'users/${uid}.json';
    List<dynamic> tempViews;
    try {
      final res = await http.get(Uri.parse(api));
      final data = json.decode(res.body) as Map<String, dynamic>;
      tempViews = data['views'] ?? [];
      if (myUid != uid && !tempViews.contains(myUid)) {
        tempViews.add(myUid);
        await http.patch(Uri.parse(api),
            body: json.encode({'views': tempViews}));
      }
    } catch (error) {}
  }

  // *****  Post reporting functions  **** ////

  Future<void> reportPost(String myUid,String report,String postOwnerId,String postId)async{
    if(!feedPostMap[postId]!.hiddenFrom.contains(myUid)) {
      feedPostMap[postId]!.hideThisPostForMe(myUid);
      int index = feedPostList.indexWhere((element) =>
      element.post_id == postId);
      feedPostList.removeAt(index);
      await reportThisPost(postOwnerId, postId, report);
      final String api = constants().fetchApi +
          'posts/${postOwnerId}/${postId}.json';
      List<
          dynamic> currentListOfHiddenUsers = await fetchListOfUsersWhoHideThisPost(
          postOwnerId, postId);
      currentListOfHiddenUsers.add(myUid);
      await http.patch(Uri.parse(api), body: json.encode({
        'hiddenFrom': currentListOfHiddenUsers
      }));
      notifyListeners();
    }
  }

  Future<List<dynamic>> fetchListOfUsersWhoHideThisPost(String postOwnerId , String postId)async{
    List<dynamic> users = [];
    final String api = constants().fetchApi+'posts/${postOwnerId}/${postId}.json';
    final response = await http.get(Uri.parse(api));
    if(json.decode(response.body)!=null){
      final data = json.decode(response.body) as Map<String,dynamic>;
      users = data['hiddenFrom']??[];
      return users;
    }
    return users;
  }

  Future<void> hidePost(String myUid,String postOwnerId,String postId)async{
    if(!feedPostMap[postId]!.hiddenFrom.contains(myUid)){
      feedPostMap[postId]!.hideThisPostForMe(myUid);
      int index = feedPostList.indexWhere((element) => element.post_id == postId);
      feedPostList.removeAt(index);
      final String api = constants().fetchApi+'posts/${postOwnerId}/${postId}.json';
      List<dynamic> currentListOfHiddenUsers = await fetchListOfUsersWhoHideThisPost(postOwnerId, postId);
      currentListOfHiddenUsers.add(myUid);
      await http.patch(Uri.parse(api),body: json.encode({
        'hiddenFrom' : currentListOfHiddenUsers
      }));
      notifyListeners();
    }
  }


  // ****** Blocking / Unblocking methods ***** //

  Future<void> block(String myUid,String yourUid)async{
    allUsers[myUid]!.blockThisUser(yourUid);
    final String api = constants().fetchApi+'users/${myUid}.json';
    await http.patch(Uri.parse(api),body: json.encode({
      'blocked' : allUsers[myUid]!.blocked,
    }));
    await unFollowUser(myUid, yourUid);
    notifyListeners();
  }

  Future<void> unBlock(String myUid,String yourUid)async{
    allUsers[myUid]!.unblockThisUser(yourUid);
    final String api = constants().fetchApi+'users/${myUid}.json';
    await http.patch(Uri.parse(api),body: json.encode({
      'blocked' : allUsers[myUid]!.blocked
    }));
    notifyListeners();
  }


}
