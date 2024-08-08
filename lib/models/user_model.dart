class LoginModel {
  String identifier;
  String password;

  LoginModel({required this.identifier, required this.password});
}

class UserModel {
  final String emailAddress;
  final String userName;
  final int loginId;

  UserModel(
      {required this.emailAddress,
      required this.userName,
      required this.loginId});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        emailAddress: json['EmailAddress'],
        userName: json['FirstName'],
        loginId: json['LoginID']);
  }
}
