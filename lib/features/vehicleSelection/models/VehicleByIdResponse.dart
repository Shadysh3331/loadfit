class VehicleByIdResponse {
  VehicleByIdResponse({
      this.id, 
      this.brand, 
      this.type, 
      this.model, 
      this.description, 
      this.pictureUrl, 
      this.price, 
      this.maxWeight, 
      this.length, 
      this.width, 
      this.height, 
      this.driverName, 
      this.isRecommended, 
      this.brandId, 
      this.typeId, 
      this.driverId,});

  VehicleByIdResponse.fromJson(dynamic json) {
    id = json['id'];
    brand = json['brand'];
    type = json['type'];
    model = json['model'];
    description = json['description'];
    pictureUrl = json['pictureUrl'];
    price = json['price'];
    maxWeight = json['maxWeight'];
    length = json['length'];
    width = json['width'];
    height = json['height'];
    driverName = json['driverName'];
    isRecommended = json['isRecommended'];
    brandId = json['brandId'];
    typeId = json['typeId'];
    driverId = json['driverId'];
  }
  int? id;
  String? brand;
  String? type;
  String? model;
  String? description;
  String? pictureUrl;
  double? price;
  int? maxWeight;
  double? length;
  double? width;
  double? height;
  String? driverName;
  bool? isRecommended;
  int? brandId;
  int? typeId;
  int? driverId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['brand'] = brand;
    map['type'] = type;
    map['model'] = model;
    map['description'] = description;
    map['pictureUrl'] = pictureUrl;
    map['price'] = price;
    map['maxWeight'] = maxWeight;
    map['length'] = length;
    map['width'] = width;
    map['height'] = height;
    map['driverName'] = driverName;
    map['isRecommended'] = isRecommended;
    map['brandId'] = brandId;
    map['typeId'] = typeId;
    map['driverId'] = driverId;
    return map;
  }

}