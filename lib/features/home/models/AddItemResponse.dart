class AddItemResponse {
  AddItemResponse({
      this.id, 
      this.items,});

  AddItemResponse.fromJson(dynamic json) {
    id = json['id'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items?.add(Items.fromJson(v));
      });
    }
  }
  String? id;
  List<Items>? items;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    if (items != null) {
      map['items'] = items?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Items {
  Items({
      this.id, 
      this.name, 
      this.length, 
      this.width, 
      this.height, 
      this.materialType, 
      this.fragilityType, 
      this.quantity, 
      this.volume, 
      this.weight,});

  Items.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    length = json['length'];
    width = json['width'];
    height = json['height'];
    materialType = json['materialType'];
    fragilityType = json['fragilityType'];
    quantity = json['quantity'];
    volume = json['volume'];
    weight = json['weight'];
  }
  int? id;
  String? name;
  int? length;
  int? width;
  int? height;
  int? materialType;
  int? fragilityType;
  int? quantity;
  int? volume;
  int? weight;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['length'] = length;
    map['width'] = width;
    map['height'] = height;
    map['materialType'] = materialType;
    map['fragilityType'] = fragilityType;
    map['quantity'] = quantity;
    map['volume'] = volume;
    map['weight'] = weight;
    return map;
  }

}