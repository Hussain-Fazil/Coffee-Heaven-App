import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_app/models/cart_item.dart';
import 'package:coffee_app/providers/cart_provider.dart';
import 'package:coffee_app/screens/checkout_page.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double lastX = 0, lastY = 0, lastZ = 0;
  DateTime lastShake = DateTime.now();

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((event) {
      double dx = event.x - lastX;
      double dy = event.y - lastY;
      double dz = event.z - lastZ;
      double delta = sqrt(dx * dx + dy * dy + dz * dz);

      if (delta > 15) {
        final now = DateTime.now();
        if (now.difference(lastShake).inMilliseconds > 1000) {
          final cartProvider = Provider.of<CartProvider>(context, listen: false);
          if (cartProvider.items.isNotEmpty) {
            cartProvider.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cart cleared by shake")),
            );
          }
          lastShake = now;
        }
      }
      lastX = event.x;
      lastY = event.y;
      lastZ = event.z;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final accent = isDark ? const Color.fromARGB(255, 76, 69, 66) : Colors.brown;
    final topBarColor = accent;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: topBarColor,
        title: const Text("Your Cart", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              cartProvider.clear();
            },
          ),
        ],
      ),
      body: cartProvider.items.isEmpty
          ? Center(
              child: Text(
                "Your cart is empty",
                style: TextStyle(color: textColor, fontSize: 18),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: isDark ? Colors.black26 : Colors.brown.shade50,
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "Shake your device to clear the cart",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final CartItem item = cartProvider.items[index];
                      return Card(
                        color: bg,
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Image.asset(item.productImage,
                              width: 50, height: 50),
                          title: Text(
                            item.productName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Size: ${item.selectedSize}, Sugar: ${item.selectedSugar}",
                                style:
                                    TextStyle(color: textColor.withOpacity(0.7)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Price: \$${item.price.toStringAsFixed(2)}",
                                style: TextStyle(color: textColor),
                              ),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    cartProvider.decrement(index);
                                  },
                                ),
                                Text(
                                  item.quantity.toString(),
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    cartProvider.increment(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bg,
                      border: Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              "\$${cartProvider.totalPrice.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const CheckoutPage()),
                              );
                            },
                            child: const Text(
                              "Go to Checkout",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
