class BrandResponse {
  BrandResponse({
    this.name,
    this.id,
  });

  BrandResponse.fromJson(dynamic json) {
    name = json['name'];
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
