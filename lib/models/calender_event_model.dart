class CalenderEventModel {
  int? eventID;
  String? title;
  String? description;
  String? imageUrl;
  CalenderEventModel({
    this.eventID,
    this.title,
    this.description,
    this.imageUrl,
  });

  Map<String, dynamic> toJSON() {
    return {
      'eventID': eventID,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  void fromJSON(Map<String, dynamic> json) {
    eventID = json['eventID'];
    title = json['title'];
    description = json['description'];
    imageUrl = json['imageUrl'];
  }
}
