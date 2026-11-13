import '../../domain/entities/category_entity.dart';
import '../../core/constants/database_constants.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    super.id,
    required super.name,
    super.description,
    super.icon,
    super.parentCategoryId,
    super.websiteCount,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map[DatabaseConstants.colCatId] as int?,
      name: map[DatabaseConstants.colCatName] as String,
      description: map[DatabaseConstants.colCatDescription] as String?,
      icon: map[DatabaseConstants.colCatIcon] as String?,
      parentCategoryId: map[DatabaseConstants.colParentCategoryId] as int?,
      websiteCount: map['website_count'] as int? ?? 0,
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      parentCategoryId: json['parent_category_id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DatabaseConstants.colCatId: id,
      DatabaseConstants.colCatName: name,
      DatabaseConstants.colCatDescription: description,
      DatabaseConstants.colCatIcon: icon,
      DatabaseConstants.colParentCategoryId: parentCategoryId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'parent_category_id': parentCategoryId,
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      icon: entity.icon,
      parentCategoryId: entity.parentCategoryId,
      websiteCount: entity.websiteCount,
    );
  }
}
