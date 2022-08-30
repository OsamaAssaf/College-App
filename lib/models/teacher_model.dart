class TeacherModel {
  int? idNumber;
  String? email;
  String? password;
  String? fullName;
  String? gender;
  String? address;
  String? mobileNumber;
  int? yearsOfExperience;
  double? salary;
  String? section;
  String? imageURL;

  TeacherModel({
    this.idNumber,
    this.email,
    this.password,
    this.fullName,
    this.gender,
    this.address,
    this.mobileNumber,
    this.yearsOfExperience,
    this.salary,
    this.section,
    this.imageURL = '',
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
      'yearsOfExperience': yearsOfExperience,
      'salary': salary,
      'section': section,
      'imageURL': imageURL,
    };
  }

  void fromJSON(Map<String, dynamic> json) {
    idNumber = json['idNumber'] as int;
    email = json['email'] as String;
    password = json['password'] as String;
    fullName = json['fullName'] as String;
    gender = json['gender'] as String;
    address = json['address'] as String;
    mobileNumber = json['mobileNumber'] as String;
    yearsOfExperience = json['yearsOfExperience'] as int;
    salary = json['salary'] as double;
    section = json['section'];
    imageURL = json['imageURL'];
  }
}
