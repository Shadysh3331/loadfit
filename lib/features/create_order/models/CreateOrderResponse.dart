class CreateOrderResponse {
  CreateOrderResponse({
      this.id, 
      this.buyerEmail, 
      this.orderDate, 
      this.status, 
      this.shippingAddress, 
      this.vehicle, 
      this.vehicleCost, 
      this.items, 
      this.subtotal, 
      this.totalPrice, 
      this.paymentIntentId, 
      this.clientSecret,});

  CreateOrderResponse.fromJson(dynamic json) {
    id = json['id'];
    buyerEmail = json['buyerEmail'];
    orderDate = json['orderDate'];
    status = json['status'];
    shippingAddress = json['shippingAddress'] != null ? ShippingAddress.fromJson(json['shippingAddress']) : null;
    vehicle = json['vehicle'];
    vehicleCost = json['vehicleCost'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items?.add(Items.fromJson(v));
      });
    }
    subtotal = json['subtotal'];
    totalPrice = json['totalPrice'];
    paymentIntentId = json['paymentIntentId'];
    clientSecret = json['clientSecret'];
  }
  int? id;
  String? buyerEmail;
  String? orderDate;
  String? status;
  ShippingAddress? shippingAddress;
  String? vehicle;
  double? vehicleCost;
  List<Items>? items;
  double? subtotal;
  double? totalPrice;
  String? paymentIntentId;
  String? clientSecret;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['buyerEmail'] = buyerEmail;
    map['orderDate'] = orderDate;
    map['status'] = status;
    if (shippingAddress != null) {
      map['shippingAddress'] = shippingAddress?.toJson();
    }
    map['vehicle'] = vehicle;
    map['vehicleCost'] = vehicleCost;
    if (items != null) {
      map['items'] = items?.map((v) => v.toJson()).toList();
    }
    map['subtotal'] = subtotal;
    map['totalPrice'] = totalPrice;
    map['paymentIntentId'] = paymentIntentId;
    map['clientSecret'] = clientSecret;
    return map;
  }

}

class Items {
  Items({
      this.id, 
      this.productId, 
      this.productName, 
      this.length, 
      this.width, 
      this.height, 
      this.materialType, 
      this.fragilityType, 
      this.quantity,});

  Items.fromJson(dynamic json) {
    id = json['id'];
    productId = json['productId'];
    productName = json['productName'];
    length = json['length'];
    width = json['width'];
    height = json['height'];
    materialType = json['materialType'];
    fragilityType = json['fragilityType'];
    quantity = json['quantity'];
  }
  int? id;
  int? productId;
  String? productName;
  int? length;
  int? width;
  int? height;
  int? materialType;
  int? fragilityType;
  int? quantity;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['productId'] = productId;
    map['productName'] = productName;
    map['length'] = length;
    map['width'] = width;
    map['height'] = height;
    map['materialType'] = materialType;
    map['fragilityType'] = fragilityType;
    map['quantity'] = quantity;
    return map;
  }

}

class ShippingAddress {
  ShippingAddress({
      this.firstName, 
      this.lastName, 
      this.city, 
      this.street, 
      this.country, 
      this.pickupLocation, 
      this.destinationLocation,});

  ShippingAddress.fromJson(dynamic json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    city = json['city'];
    street = json['street'];
    country = json['country'];
    pickupLocation = json['pickupLocation'];
    destinationLocation = json['destinationLocation'];
  }
  String? firstName;
  String? lastName;
  String? city;
  String? street;
  String? country;
  String? pickupLocation;
  String? destinationLocation;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['firstName'] = firstName;
    map['lastName'] = lastName;
    map['city'] = city;
    map['street'] = street;
    map['country'] = country;
    map['pickupLocation'] = pickupLocation;
    map['destinationLocation'] = destinationLocation;
    return map;
  }

}