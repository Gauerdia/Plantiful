class Posting{

  final String uid;
  final String creatorId;
  final String content;
  final int date;
  final String groupId;
  final int commentsAmount;
  final List<String> likes;

  Posting({this.uid, this.content, this.date, this.creatorId, this.likes, this.groupId,this.commentsAmount});
  
}