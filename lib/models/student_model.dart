class StudentModel {
  int? idNumber;
  String? email;
  String? password;
  String? fullName;
  String? gender;
  String? address;
  String? mobileNumber;
  String? major;
  String? imageURL;
  double? result;
  int? numberOfSubjects;

  StudentModel({
    this.idNumber,
    this.email,
    this.password,
    this.fullName,
    this.gender,
    this.address,
    this.mobileNumber,
    this.major,
    this.imageURL = '',
    this.result,
    this.numberOfSubjects,
  });

  Map<String, dynamic> toJSON() {
    return {
      'idNumber': idNumber,
      'email': email,
      'password': password,
      'fullName': fullName,
      'gender': gender,
      'address': address,
      'mobileNumber': mobileNumber,
      'section': major,
      'imageURL': imageURL,
      'result': result,
      'numberOfSubjects': numberOfSubjects,
    };
  }

  void fromJSON(Map<String, dynamic> json) {
    idNumber = json['idNumber'];
    email = json['email'];
    password = json['password'];
    fullName = json['fullName'];
    gender = json['gender'];
    address = json['address'];
    mobileNumber = json['mobileNumber'];
    major = json['section'];
    imageURL = json['imageURL'];
    result = json['result'];
    numberOfSubjects = json['numberOfSubjects'];
  }
}
