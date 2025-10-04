import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'coffee_detail_page.dart';

class CoffeeProductsPage extends StatefulWidget {
  const CoffeeProductsPage({super.key});

  @override
  State<CoffeeProductsPage> createState() => _CoffeeProductsPageState();
}

class _CoffeeProductsPageState extends State<CoffeeProductsPage> {
  // Coffee categories
  final List<String> categories = const [
    'Cappuccino',
    'Americano',
    'Iced Coffee',
    'Espresso',
    'Mocha',
    'Latte',
  ];

  int selectedIndex = 0; // which category is selected
  List<Map<String, dynamic>> allProducts = []; // all products
  bool isLoading = true; // loading indicator

  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  // Colors
  static const coffeePrimary = Color(0xFFB87352);
  static const coffeeSecondary = Color(0xFF4E342E);
  static const lightBg = Colors.white;
  static const lightCard = Colors.white;
  static const darkBg = Color(0xFF0E0E0E);
  static const darkSurface = Color(0xFF171717);

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  // Load products from internet (GitHub) or fallback to local JSON
  Future<void> loadProducts() async {
    setState(() => isLoading = true);

    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      // Try loading from internet first
      if (connectivityResult != ConnectivityResult.none) {
        final response = await http.get(
          Uri.parse("https://raw.githubusercontent.com/Hussain-Fazil/coffee_app_data/main/products.json"),
        );
        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          allProducts = data.cast<Map<String, dynamic>>();
        }
      }

      // If nothing came from internet, load from local JSON
      if (allProducts.isEmpty) {
        final String localData = await rootBundle.loadString("assets/products.json");
        final List data = jsonDecode(localData);
        allProducts = data.cast<Map<String, dynamic>>();
      }
    } catch (_) {
      // In case of error, still load local JSON
      final String localData = await rootBundle.loadString("assets/products.json");
      final List data = jsonDecode(localData);
      allProducts = data.cast<Map<String, dynamic>>();
    }

    setState(() => isLoading = false);
  }

  // Filter products by category + search
  List<Map<String, dynamic>> getProductsForCategory() {
    if (allProducts.isEmpty) return [];
    final category = categories[selectedIndex];
    return allProducts
        .where((p) =>
            p["category"] == category &&
            p["name"].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bodyBg = isDark ? darkBg : lightBg;
    final Color cardBg = isDark ? darkSurface : lightCard;
    final Color textColor = isDark ? Colors.white : const Color(0xFF2C2C2C);
    final Color hintColor = isDark ? Colors.white70 : Colors.brown.shade400;

    final products = getProductsForCategory();

    // Responsive layout: portrait = 2 columns, landscape = 3
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final int gridCols = isPortrait ? 2 : 3;

    final double imageHeight = isPortrait ? 120 : 150;
    final double nameFont = isPortrait ? 14 : 18;
    final double priceFont = isPortrait ? 13 : 16;
    final double starSize = isPortrait ? 14 : 18;

    return Scaffold(
      backgroundColor: bodyBg,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : coffeeSecondary,
        elevation: 0,
        title: const Text(
          "Choose Your Coffee",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Search bar + categories
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      children: [
                        // Search bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.white24 : coffeeSecondary),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded, color: hintColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (val) => setState(() => searchQuery = val),
                                  style: TextStyle(color: textColor, fontSize: 14),
                                  cursorColor: coffeePrimary,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Find your coffee',
                                    hintStyle: TextStyle(color: hintColor),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              if (searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    searchController.clear();
                                    setState(() => searchQuery = "");
                                  },
                                  child: const Icon(Icons.close, size: 18, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Categories
                        SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final selected = i == selectedIndex;
                              return GestureDetector(
                                onTap: () => setState(() => selectedIndex = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? (isDark ? coffeePrimary : coffeeSecondary)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: selected
                                          ? Colors.transparent
                                          : (isDark ? Colors.white24 : Colors.brown.shade300),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      categories[i],
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? Colors.white
                                            : (isDark ? Colors.white70 : coffeeSecondary),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Products Grid
                products.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text("No products found")),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final coffee = products[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CoffeeDetailPage(product: coffee),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isDark ? Colors.white24 : coffeeSecondary,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Image.asset(
                                          coffee["img"],
                                          height: imageHeight,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        coffee["name"],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: nameFont,
                                          color: textColor,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            Icons.star,
                                            size: starSize,
                                            color: i < 4 ? Colors.amber : Colors.grey,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "\$${coffee["price"]}",
                                              style: TextStyle(
                                                fontSize: priceFont,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: isDark ? coffeePrimary : coffeeSecondary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.add,
                                                  size: isPortrait ? 18 : 22, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: products.length,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridCols,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.78,
                          ),
                        ),
                      ),

                SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.bottom + 8)),
              ],
            ),
    );
  }
}
