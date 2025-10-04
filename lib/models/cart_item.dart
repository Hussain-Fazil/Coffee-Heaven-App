// lib/models/cart_item.dart
class CartItem {
  final String productId;
  final String productName;
  final String productImage;
  final String selectedSize;
  final String selectedSugar;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.selectedSize,
    required this.selectedSugar,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'selectedSize': selectedSize,
      'selectedSugar': selectedSugar,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'],
      productName: map['productName'],
      productImage: map['productImage'],
      selectedSize: map['selectedSize'],
      selectedSugar: map['selectedSugar'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'],
    );
  }
}
