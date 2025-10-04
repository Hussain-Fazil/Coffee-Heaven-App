import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'coffee_products_page.dart';
import 'cart_page.dart' as realcart;
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import 'profile_page.dart';
import 'about_page.dart';

const Color coffeeTopColor = Color(0xFF3E2723);
const Color coffeeStripColor = Color(0xFF4E342E);
const Color darkAppBarNavColor = Color(0xFF303030);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _username;

  bool _isOffline = false;
  late Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    _loadUsername();

    _connectivity = Connectivity();

    // check internet connection changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      if (!mounted) return;

      final result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      setState(() {
        _isOffline = (result == ConnectivityResult.none);
      });

      if (_isOffline) {
        _username = "Guest";
      } else {
        _loadUsername();
      }
    });

    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final results = await _connectivity.checkConnectivity();
    if (!mounted) return;

    final result =
        results.isNotEmpty ? results.first : ConnectivityResult.none;
    setState(() {
      _isOffline = (result == ConnectivityResult.none);
    });

    if (_isOffline) {
      _username = "Guest";
    } else {
      _loadUsername();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    try {
      if (_isOffline) {
        setState(() {
          _username = "Guest";
        });
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            _username = doc["username"] ?? "Guest";
          });
        } else {
          setState(() {
            _username = "Guest";
          });
        }
      } else {
        setState(() {
          _username = "Guest";
        });
      }
    } catch (e) {
      setState(() {
        _username = "Guest";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;
    final ThemeData theme =
        isDark ? themeProvider.darkTheme : themeProvider.lightTheme;
    final Color navColor = isDark ? darkAppBarNavColor : coffeeStripColor;

    final List<Widget> pages = [
      HomeContent(stripColor: navColor, isDark: isDark),
      const CoffeeProductsPage(),
      const realcart.CartPage(),
      const AboutPage(),
    ];

    return AnimatedTheme(
      data: theme,
      duration: const Duration(milliseconds: 250),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _username ?? "Loading...",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            // toggle theme button
            IconButton(
              tooltip: isDark ? "Light mode" : "Dark mode",
              icon: Icon(
                isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                key: ValueKey(isDark),
                color: Colors.white,
              ),
              onPressed: () => themeProvider.toggleTheme(),
            ),
            // profile button
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                if (_isOffline) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("No internet. Please try again later."),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            if (_isOffline)
              MaterialBanner(
                content: const Text(
                  "You are offline. Using local data.",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.red,
                actions: const [SizedBox.shrink()],
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 360),
                child: pages[_currentIndex],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: PhysicalModel(
              color: Colors.transparent,
              elevation: 6,
              borderRadius: BorderRadius.circular(28),
              clipBehavior: Clip.antiAlias,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: navColor,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white70,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  items: [
                    const BottomNavigationBarItem(
                        icon: Icon(Icons.home), label: "Home"),
                    const BottomNavigationBarItem(
                        icon: Icon(Icons.local_cafe), label: "Coffees"),
                    BottomNavigationBarItem(
                      icon: Consumer<CartProvider>(
                        builder: (_, cart, __) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.shopping_cart),
                              if (cart.itemCount > 0)
                                Positioned(
                                  right: -6,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      cart.itemCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      label: "Cart",
                    ),
                    const BottomNavigationBarItem(
                        icon: Icon(Icons.info_outline), label: "About"),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Home content widget
class HomeContent extends StatefulWidget {
  final Color stripColor;
  final bool isDark;
  const HomeContent({super.key, required this.stripColor, required this.isDark});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _promoController = PageController();
  int _currentPromo = 0;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // search bar + promo slider
          Container(
            color: widget.isDark
                ? Theme.of(context).scaffoldBackgroundColor
                : widget.stripColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color:
                        widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    style: TextStyle(color: cs.onSurface),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search,
                          color: cs.onSurface.withOpacity(0.65)),
                      hintText: "Search coffee",
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          color: cs.onSurface.withOpacity(0.3), fontSize: 15),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: isPortrait ? 160 : 170,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PageView(
                        controller: _promoController,
                        onPageChanged: (i) => setState(() => _currentPromo = i),
                        children: const [
                          PromoCard(
                              image: "assets/images/promo.png",
                              text: "Buy one get one FREE"),
                          PromoCard(
                              image: "assets/images/promo2.png",
                              text: "20% off on Cappuccino"),
                          PromoCard(
                              image: "assets/images/promo3.png",
                              text: "Enjoy Latte with friends!"),
                        ],
                      ),
                      Positioned(
                        left: 8,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                          onPressed: () {
                            if (_currentPromo > 0) {
                              _promoController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            }
                          },
                        ),
                      ),
                      Positioned(
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios,
                              color: Colors.white),
                          onPressed: () {
                            if (_currentPromo < 2) {
                              _promoController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // app title section
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_cafe,
                    color: coffeeStripColor, size: isPortrait ? 26 : 32),
                const SizedBox(width: 8),
                Text(
                  "Coffee Heaven",
                  style: TextStyle(
                    color: coffeeStripColor,
                    fontSize: isPortrait ? 26 : 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.local_fire_department,
                    color: Colors.brown, size: isPortrait ? 20 : 26),
              ],
            ),
          ),
          // coffee grid section
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OrientationBuilder(
              builder: (context, orientation) {
                final isPortrait =
                    MediaQuery.of(context).orientation == Orientation.portrait;
                final int cols = isPortrait ? 2 : 3;

                final double screenWidth = MediaQuery.of(context).size.width;
                const double horizontalPadding = 16 * 2;
                const double spacing = 16.0;

                final double available = screenWidth - horizontalPadding;
                const double extraForText = 52.0;
                final double tileWidth =
                    (available - (cols - 1) * spacing) / cols;

                final double tileHeight = isPortrait
                    ? tileWidth + extraForText + 8
                    : tileWidth + extraForText + 18;

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 4,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    mainAxisExtent: tileHeight,
                  ),
                  itemBuilder: (context, i) {
                    const data = [
                      ("Cappuccino", 4.53, "assets/images/c1.png"),
                      ("Latte", 4.20, "assets/images/c2.png"),
                      ("Macchiato", 4.90, "assets/images/c3.png"),
                      ("Espresso", 3.80, "assets/images/c4.png"),
                    ];
                    final d = data[i];
                    return CoffeeCard(name: d.$1, price: d.$2, image: d.$3);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// promo card widget
class PromoCard extends StatelessWidget {
  final String image;
  final String text;
  const PromoCard({super.key, required this.image, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 3),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(16),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
    );
  }
}

// coffee card widget
class CoffeeCard extends StatelessWidget {
  final String name;
  final double price;
  final String image;

  const CoffeeCard(
      {super.key, required this.name, required this.price, required this.image});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final double imageHeight = isPortrait ? 140 : 200;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: coffeeStripColor, width: 2),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                height: imageHeight,
                width: double.infinity,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Center(
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                    height: imageHeight * 0.9,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text("with Chocolate",
                    style: TextStyle(
                        color: cs.onSurface.withOpacity(0.7), fontSize: 12)),
                const SizedBox(height: 2),
                Text("\$${price.toStringAsFixed(2)}",
                    style: TextStyle(color: cs.onSurface, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
