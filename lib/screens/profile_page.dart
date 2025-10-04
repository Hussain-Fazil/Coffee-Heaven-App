import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:battery_plus/battery_plus.dart'; // ✅ for battery sensor
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  int _batteryLevel = 100; // default battery level

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final Battery _battery = Battery();

  @override
  void initState() {
    super.initState();
    fetchUserData();
    getBatteryLevel();
  }

  Future<void> getBatteryLevel() async {
    final level = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = level;
    });
  }

  Future<void> fetchUserData() async {
    if (user == null) {
      setState(() {
        isLoading = false;
        userData = {};
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();
      setState(() {
        userData = doc.exists ? doc.data() : {};
        _usernameController.text = userData?['username'] ?? "";
        _phoneController.text = userData?['phone'] ?? "";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        userData = {};
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("profile_pics")
          .child("${user!.uid}.jpg");

      await storageRef.putFile(imageFile);
      final url = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .update({"photoUrl": url});

      setState(() {
        userData?['photoUrl'] = url;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload image")),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .update({
        "username": _usernameController.text.trim(),
        "phone": _phoneController.text.trim(),
      });

      setState(() {
        userData?['username'] = _usernameController.text.trim();
        userData?['phone'] = _phoneController.text.trim();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile")),
      );
    }
  }

  Future<void> _resetPassword() async {
    String? emailToSend = user?.email ?? userData?['email'];
    if (emailToSend == null || emailToSend.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No email found for this account")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailToSend);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email sent to $emailToSend")),
      );
    } catch (e) {
      String errorMessage = "Could not send reset email.";
      if (e.toString().contains("user-not-found")) {
        errorMessage = "No user found for this email.";
      } else if (e.toString().contains("invalid-email")) {
        errorMessage = "Invalid email address.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  // small helper widget for stats card
  Widget buildStatCard(IconData icon, String value, String label,
      Color textColor, Color subTextColor, bool isDark) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.black26 : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: textColor, size: 26),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            Text(label,
                style: TextStyle(fontSize: 12, color: subTextColor)), // ✅ smaller label
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const coffeeBrown = Color(0xFF4E342E);
    final bgColor = isDark ? Colors.black : const Color(0xFFF8F3E9);
    final appBarColor = isDark ? const Color(0xFF3A3A3A) : coffeeBrown;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : coffeeBrown;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text("Profile"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white24,
                                backgroundImage: userData?['photoUrl'] != null &&
                                        userData!['photoUrl'] != ""
                                    ? NetworkImage(userData!['photoUrl'])
                                    : null,
                                child: (userData?['photoUrl'] == null ||
                                        userData!['photoUrl'] == "")
                                    ? Icon(Icons.person,
                                        size: 60, color: textColor)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black54,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          userData?['username']?.isNotEmpty == true
                              ? userData!['username']
                              : "guest",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          userData?['phone']?.isNotEmpty == true
                              ? userData!['phone']
                              : "phone",
                          style:
                              TextStyle(fontSize: 16, color: subTextColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (user?.email?.isNotEmpty == true)
                              ? user!.email!
                              : (userData?['email'] ?? "email"),
                          style:
                              TextStyle(fontSize: 14, color: subTextColor),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Member since: ${user?.metadata.creationTime?.toLocal().toString().split(' ').first ?? 'N/A'}",
                          style:
                              TextStyle(fontSize: 13, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ExpansionTile(
                    title:
                        Text("Edit Profile", style: TextStyle(color: textColor)),
                    leading: Icon(Icons.edit, color: textColor),
                    children: [
                      TextField(
                        controller: _usernameController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: "Username",
                          filled: true,
                          fillColor: isDark ? Colors.black26 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _phoneController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: "Phone",
                          filled: true,
                          fillColor: isDark ? Colors.black26 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text("Save Changes"),
                      )
                    ],
                  ),
                  ListTile(
                    leading: Icon(Icons.lock_reset, color: textColor),
                    title: Text("Change Password",
                        style: TextStyle(color: textColor)),
                    onTap: _resetPassword,
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Log Out",
                        style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginPage()),
                      );
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildStatCard(Icons.shopping_bag, "0", "Orders",
                            textColor, subTextColor, isDark),
                        buildStatCard(Icons.favorite, "0", "Favorites",
                            textColor, subTextColor, isDark),
                        buildStatCard(Icons.star, "0", "Points", textColor,
                            subTextColor, isDark),
                        buildStatCard(
                            Icons.battery_full,
                            "$_batteryLevel%",
                            "Battery",
                            textColor,
                            subTextColor,
                            isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
