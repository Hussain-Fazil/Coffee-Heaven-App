import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_app/models/cart_item.dart';
import 'package:coffee_app/providers/cart_provider.dart';

class CoffeeDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const CoffeeDetailPage({super.key, required this.product});

  @override
  State<CoffeeDetailPage> createState() => _CoffeeDetailPageState();
}

class _CoffeeDetailPageState extends State<CoffeeDetailPage> {
  String selectedSize = "Medium";
  String selectedSugar = "40%";
  bool isDark = false;

  double calculatePrice(double basePrice) {
    if (selectedSize == "Small") return basePrice - 0.50;
    if (selectedSize == "Large") return basePrice + 0.75;
    return basePrice;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final String productId = product["id"].toString();
    final double basePrice = (product["price"] as num).toDouble();
    final double displayPrice = calculatePrice(basePrice);

    final Color bg = isDark ? Colors.black : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color accent = isDark ? Colors.brown.shade300 : Colors.brown;

    final String description =
        "${product["desc"]} This specialty coffee is crafted to satisfy your senses with its rich aroma, silky texture, and lasting taste. It's the perfect companion whether you're starting your day or taking a break.";

    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    Widget detailBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 260,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(product["img"]),
              fit: BoxFit.contain,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      product["name"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: textColor,
                      ),
                    ),
                  ),
                  Text(
                    "\$${displayPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  color: textColor.withOpacity(0.75),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Size",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ["Small", "Medium", "Large"].map((size) {
                  final bool isSelected = size == selectedSize;
                  return GestureDetector(
                    onTap: () => setState(() => selectedSize = size),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? accent : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        size,
                        style: TextStyle(
                          color: isSelected ? Colors.white : textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              Text(
                "Sugar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: ["30%", "40%", "50%"].map((sugar) {
                  final bool isSelected = sugar == selectedSugar;
                  return GestureDetector(
                    onTap: () => setState(() => selectedSugar = sugar),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? accent : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        sugar,
                        style: TextStyle(
                          color: isSelected ? Colors.white : textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
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
                final cartItem = CartItem(
                  productId: productId,
                  productName: product["name"],
                  productImage: product["img"],
                  selectedSize: selectedSize,
                  selectedSugar: selectedSugar,
                  price: displayPrice,
                  quantity: 1,
                );
                Provider.of<CartProvider>(context, listen: false)
                    .addItem(cartItem);

                final snackText =
                    "$selectedSize ${product["name"]} ($selectedSugar sugar) added to cart!";
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(snackText)),
                );

                Future.delayed(const Duration(milliseconds: 600), () {
                  Navigator.pop(context);
                });
              },
              child: const Text(
                "Add to Cart",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.brown,
        title: Text(product["name"], style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny : Icons.nightlight_round,
              color: Colors.white,
            ),
            onPressed: () => setState(() => isDark = !isDark),
          ),
        ],
      ),
      body: isPortrait ? detailBody : SingleChildScrollView(child: detailBody),
    );
  }
}
