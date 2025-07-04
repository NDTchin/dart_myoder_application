class Order {
  final String item;
  final String itemName;
  final double price;
  final String currency;
  final int quantity;

  Order({
    required this.item,
    required this.itemName,
    required this.price,
    required this.currency,
    required this.quantity,
  });

  // Factory constructor to create Order from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      item: json['Item'] as String,
      itemName: json['ItemName'] as String,
      price: (json['Price'] as num).toDouble(),
      currency: json['Currency'] as String,
      quantity: json['Quantity'] as int,
    );
  }

  // Convert Order to JSON
  Map<String, dynamic> toJson() {
    return {
      'Item': item,
      'ItemName': itemName,
      'Price': price,
      'Currency': currency,
      'Quantity': quantity,
    };
  }

  @override
  String toString() {
    return 'Order{item: $item, itemName: $itemName, price: $price, currency: $currency, quantity: $quantity}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order &&
        other.item == item &&
        other.itemName == itemName &&
        other.price == price &&
        other.currency == currency &&
        other.quantity == quantity;
  }

  @override
  int get hashCode {
    return item.hashCode ^
        itemName.hashCode ^
        price.hashCode ^
        currency.hashCode ^
        quantity.hashCode;
  }
}
