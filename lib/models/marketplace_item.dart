class MarketplaceItem {

  final int date;
  final int commentsAmount;

  final String uid;
  final String creatorId;
  final String content;
  final String title;

  final String imageIds;


  MarketplaceItem(
      {this.uid, this.title, this.content, this.date, this.creatorId, this.imageIds, this.commentsAmount});
}