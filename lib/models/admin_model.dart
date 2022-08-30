class AdminModel {
  int? idNumber;
  String? email;
  String? password;
  String? fullName;
  String? gender;
  String? address;
  String? mobileNumber;
  String? section;
  String? imageURL;

  AdminModel({
    this.idNumber,
    this.email,
    this.password,
    this.fullName,
    this.gender,
    this.address,
    this.mobileNumber,
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
      'section': section,
      'imageURL': imageURL,
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
    section = json['section'];
    imageURL = json['imageURL'];
  }
}
