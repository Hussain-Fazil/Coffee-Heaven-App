import 'package:flutter/foundation.dart';
import 'package:coffee_app/services/cart_service.dart';
import 'package:coffee_app/models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount {
    return _items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.fold<double>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
  }

  Future<void> loadCart() async {
    _items = await CartService.loadCart();
    notifyListeners();
  }

  Future<void> _persist() async {
    await CartService.saveCart(_items);
    notifyListeners();
  }

  Future<void> addItem(CartItem item) async {
    bool found = false;
    for (final existing in _items) {
      if (existing.productId == item.productId &&
          existing.selectedSize == item.selectedSize &&
          existing.selectedSugar == item.selectedSugar) {
        existing.quantity += item.quantity;
        found = true;
        break;
      }
    }
    if (!found) {
      _items.add(item);
    }
    await _persist();
  }

  Future<void> increment(int index) async {
    _items[index].quantity++;
    await _persist();
  }

  Future<void> decrement(int index) async {
    final it = _items[index];
    if (it.quantity > 1) {
      it.quantity--;
    } else {
      _items.removeAt(index);
    }
    await _persist();
  }

  Future<void> removeAt(int index) async {
    _items.removeAt(index);
    await _persist();
  }

  Future<void> clear() async {
    _items.clear();
    await CartService.clearCart();
    notifyListeners();
  }
}
