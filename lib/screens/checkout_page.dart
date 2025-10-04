import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:coffee_app/providers/cart_provider.dart';
import 'package:coffee_app/models/cart_item.dart';
import 'package:coffee_app/providers/theme_provider.dart';
import 'home_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool isDelivery = true;
  final double deliveryFee = 2.00;
  String? selectedLocation;

  Future<void> _chooseLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Location permanently denied. Enable in settings.")),
        );
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        selectedLocation =
            "Lat: ${pos.latitude.toStringAsFixed(4)}, Long: ${pos.longitude.toStringAsFixed(4)}";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final double subtotal = cartProvider.totalPrice;
    final double total = isDelivery ? subtotal + deliveryFee : subtotal;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Checkout"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ChoiceChip(
                label: const Text("Pick Up"),
                selected: !isDelivery,
                onSelected: (_) => setState(() => isDelivery = false),
              ),
              ChoiceChip(
                label: const Text("Delivery"),
                selected: isDelivery,
                onSelected: (_) => setState(() => isDelivery = true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isDelivery)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: const Text("Delivery Location"),
                subtitle: Text(
                  selectedLocation ?? "Auto-detected from GPS",
                  style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                ),
                trailing: TextButton(
                  onPressed: _chooseLocation,
                  child: const Text("Choose"),
                ),
              ),
            ),
          if (isDelivery) const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.local_cafe, color: Colors.brown),
              title: const Text("Coffee Heaven - Main Street"),
              subtitle: Text(
                isDelivery
                    ? "Delivery Time: ~30 minutes"
                    : "Pickup Time: 15 minutes",
                style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Order Summary",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: List.generate(cartProvider.items.length, (index) {
                final CartItem item = cartProvider.items[index];
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(item.productImage),
                      ),
                      title: Text(item.productName,
                          style: TextStyle(color: cs.onSurface)),
                      subtitle: Text(
                        "Size: ${item.selectedSize}, Sugar: ${item.selectedSugar}",
                        style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                      ),
                      trailing: Text(
                        "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: cs.onSurface),
                      ),
                    ),
                    if (index < cartProvider.items.length - 1)
                      const Divider(height: 1),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Subtotal",
                      style: TextStyle(
                          fontSize: 16, color: cs.onSurface.withOpacity(0.8))),
                  Text("\$${subtotal.toStringAsFixed(2)}",
                      style: TextStyle(
                          fontSize: 16, color: cs.onSurface.withOpacity(0.8))),
                ],
              ),
              if (isDelivery) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Delivery Fee",
                        style: TextStyle(
                            fontSize: 16,
                            color: cs.onSurface.withOpacity(0.8))),
                    Text("\$${deliveryFee.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 16,
                            color: cs.onSurface.withOpacity(0.8))),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    "\$${total.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode
                    ? Colors.black
                    : const Color(0xFF3E2723),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          "Order placed! Total: \$${total.toStringAsFixed(2)}")),
                );
                Future.delayed(const Duration(seconds: 2), () {
                  cartProvider.clear();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                });
              },
              child: const Text(
                "Place Order",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
