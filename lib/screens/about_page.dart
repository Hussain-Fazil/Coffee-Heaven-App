import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const coffeeBrown = Color(0xFF4E342E);
    final Color bgColor = isDark ? Colors.black : const Color(0xFFF8F3E9);
    final Color onBg = isDark ? Colors.white : const Color(0xFF2C2C2C);
    final Color onBgSub = isDark ? Colors.white70 : const Color(0xFF5B4D45);
    final Color appBarColor = isDark ? const Color(0xFF3A3A3A) : coffeeBrown;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        centerTitle: true,
        title: const Text(
          'About',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: coffeeBrown,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.local_cafe, color: Colors.white, size: 64),
                  ),
                ),
                const SizedBox(height: 30),

                const Text(
                  'Coffee Heaven',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: coffeeBrown,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Your perfect coffee companion',
                  style: TextStyle(
                    fontSize: 18,
                    color: onBgSub,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                Text(
                  'Coffee Heaven brings all kinds of coffee to your fingertips. '
                  'Explore varieties, customize flavors, and enjoy a smooth shopping experience.',
                  style: TextStyle(fontSize: 17, color: onBg),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.star, color: coffeeBrown, size: 22),
                    SizedBox(width: 6),
                    Text(
                      'Features',
                      style: TextStyle(
                        color: coffeeBrown,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.star, color: coffeeBrown, size: 22),
                  ],
                ),
                const SizedBox(height: 18),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FeatureRow(
                      icon: Icons.local_cafe,
                      text: 'Browse delicious coffee varieties',
                      iconColor: coffeeBrown,
                      textColor: onBg,
                    ),
                    FeatureRow(
                      icon: Icons.tune,
                      text: 'Customize size & sugar levels',
                      iconColor: coffeeBrown,
                      textColor: onBg,
                    ),
                    FeatureRow(
                      icon: Icons.shopping_cart,
                      text: 'Add to cart & manage orders',
                      iconColor: coffeeBrown,
                      textColor: onBg,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Container(
                  height: 1.4,
                  width: double.infinity,
                  color: coffeeBrown.withOpacity(0.18),
                ),
                const SizedBox(height: 16),

                Text(
                  'Powered by Coffee Heaven',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: onBgSub,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(color: onBgSub.withOpacity(0.8), fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  'Contact: coffeeheaven@gmail.com',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: onBgSub, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final Color textColor;

  const FeatureRow({
    super.key,
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Icon(icon, color: iconColor, size: 25),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
