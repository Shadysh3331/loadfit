class ErrorResponse {
  ErrorResponse({
      this.errors, 
      this.statusCode, 
      this.message,});

  ErrorResponse.fromJson(dynamic json) {
    errors = json['errors'] != null ? json['errors'].cast<String>() : [];
    statusCode = json['statusCode'];
    message = json['message'];
  }
  List<String>? errors;
  int? statusCode;
  String? message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['errors'] = errors;
    map['statusCode'] = statusCode;
    map['message'] = message;
    return map;
  }

}