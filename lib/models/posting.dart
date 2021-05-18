class Posting{

  final String name;
  final String uid;
  final String creatorId;
  final String content;
  final String date;

  Posting({this.uid, this.name, this.content, this.date, this.creatorId});

  factory Posting.fromJson(Map<String, dynamic> json){
    return new Posting(
      uid: json['id'] as String,
      name: json['name'] as String,
      date: json['date'] as String,
      content: json['content'] as String,
      creatorId: json['creatorId'] as String
    );
  }

}