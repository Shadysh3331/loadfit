class SignUpResponse {
  SignUpResponse({
      this.displayName, 
      this.email, 
      this.token, 
      this.role,});

  SignUpResponse.fromJson(dynamic json) {
    displayName = json['displayName'];
    email = json['email'];
    token = json['token'];
    role = json['role'];
  }
  String? displayName;
  String? email;
  String? token;
  String? role;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['displayName'] = displayName;
    map['email'] = email;
    map['token'] = token;
    map['role'] = role;
    return map;
  }

}