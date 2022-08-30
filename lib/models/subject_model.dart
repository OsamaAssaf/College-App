class SubjectModel {
  String? subjectID;
  String? subjectName;
  String? instructorName;
  String? instructorEmail;
  String? classDays;
  String? startTime;
  String? endTime;
  int? subjectLevel;

  SubjectModel({
    this.subjectID,
    this.subjectName,
    this.instructorName,
    this.instructorEmail,
    this.classDays,
    this.startTime,
    this.endTime,
    this.subjectLevel,
  });

  Map<String, dynamic> toJSON() {
    return {
      'subjectID': subjectID,
      'subjectName': subjectName,
      'instructorName': instructorName,
      'instructorEmail': instructorEmail,
      'classDays': classDays,
      'startTime': startTime,
      'endTime': endTime,
      'subjectLevel': subjectLevel,
    };
  }

  void fromJSON(Map<String, dynamic> json) {
    subjectID = json['subjectID'];
    subjectName = json['subjectName'];
    instructorName = json['instructorName'];
    instructorEmail = json['instructorEmail'];
    classDays = json['classDays'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    subjectLevel = json['subjectLevel'];
  }
}
