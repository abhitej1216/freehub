import 'package:flutter/material.dart';

class CategoryEntity {
  final int? id;
  final String name;
  final String? description;
  final String? icon;
  final int? parentCategoryId;
  final int websiteCount;

  const CategoryEntity({
    this.id,
    required this.name,
    this.description,
    this.icon,
    this.parentCategoryId,
    this.websiteCount = 0,
  });

  CategoryEntity copyWith({
    int? id,
    String? name,
    String? description,
    String? icon,
    int? parentCategoryId,
    int? websiteCount,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      websiteCount: websiteCount ?? this.websiteCount,
    );
  }

  IconData get iconData {
    return _iconMap[icon] ?? Icons.folder_outlined;
  }

  static const Map<String, IconData> _iconMap = {
    'ai': Icons.psychology_outlined,
    'streaming': Icons.play_circle_outlined,
    'music': Icons.music_note_outlined,
    'gaming': Icons.sports_esports_outlined,
    'reading': Icons.menu_book_outlined,
    'downloading': Icons.download_outlined,
    'torrenting': Icons.swap_vert_outlined,
    'educational': Icons.school_outlined,
    'android': Icons.phone_android_outlined,
    'linux': Icons.computer_outlined,
    'privacy': Icons.security_outlined,
    'productivity': Icons.work_outlined,
    'development': Icons.code_outlined,
    'design': Icons.palette_outlined,
    'miscellaneous': Icons.grid_view_outlined,
    'social': Icons.people_outlined,
    'finance': Icons.account_balance_outlined,
    'health': Icons.health_and_safety_outlined,
    'news': Icons.newspaper_outlined,
    'shopping': Icons.shopping_bag_outlined,
    'travel': Icons.flight_outlined,
    'food': Icons.restaurant_outlined,
    'sports': Icons.sports_outlined,
    'storage': Icons.cloud_outlined,
    'communication': Icons.chat_outlined,
    'folder': Icons.folder_outlined,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CategoryEntity(id: $id, name: $name)';
}
