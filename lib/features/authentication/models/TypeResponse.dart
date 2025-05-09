class TypeResponse {
  TypeResponse({
      this.name, 
      this.id,});

  TypeResponse.fromJson(dynamic json) {
    name = json['name']??"";
    id = json['id'];

  }

  String? name;
  int? id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['id'] = id;
    return map;
  }

}