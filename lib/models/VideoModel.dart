class VideoModel {
  final String caption;
  final DateTime dateOfPost;
  final String video;
  final String uid;
  final String video_id;
  final List<dynamic> likes;
  final List<dynamic> hiddenFrom;

  VideoModel(
      {required this.caption,
        required this.hiddenFrom,
        required this.dateOfPost,
        required this.video,
        required this.uid,
        required this.video_id,
        required this.likes});

  hideThisPostForMe(String myUid){
    hiddenFrom.add(myUid);
  }

}
