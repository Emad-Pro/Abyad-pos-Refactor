
import 'package:flutter/material.dart';
/// Data model for each setting item
class SettingItemData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  SettingItemData({required this.icon, required this.title, required this.onTap});
}


/// Reusable Card widget
class SettingCard extends StatelessWidget {
  final SettingItemData item;
  const SettingCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 50, color: Colors.blue),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

