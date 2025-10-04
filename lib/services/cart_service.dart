import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class CartService {
  static const String cartKey = "cart_items";

  // Save all cart items into local storage
  static Future<void> saveCart(List<CartItem> cartItems) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartJson =
        cartItems.map((item) => jsonEncode(item.toMap())).toList();
    await prefs.setStringList(cartKey, cartJson);
  }

  // Load cart items from local storage
  static Future<List<CartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? cartJson = prefs.getStringList(cartKey);

    if (cartJson == null) return [];

    return cartJson.map((item) {
      return CartItem.fromMap(jsonDecode(item));
    }).toList();
  }

  // Add a single item to the cart
  static Future<void> addItem(CartItem item) async {
    List<CartItem> cartItems = await loadCart();

    bool found = false;
    for (var existing in cartItems) {
      if (existing.productId == item.productId &&
          existing.selectedSize == item.selectedSize &&
          existing.selectedSugar == item.selectedSugar) {
        existing.quantity += item.quantity;
        found = true;
        break;
      }
    }

    if (!found) {
      cartItems.add(item);
    }

    await saveCart(cartItems);
  }

  // Clear all items from the cart
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(cartKey);
  }
}
