// 
// Subcategories screen showing all subcategories of a parent category
// Displays subcategories as icon grid similar to home screen categories

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dynamic_appbar.dart';
import '../../models/home_data.dart';
import 'subcategories_controller.dart';

class SubcategoriesView extends GetView<SubcategoriesController> {
  const SubcategoriesView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: controller.parentCategory.value?.name ?? 'Subcategories',
      ),
      body: Obx(() {
        if (controller.subcategories.isEmpty) {
          return _buildEmptyState();
        }
        
        return _buildSubcategoriesGrid();
      }),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'No Subcategories',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'This category has no subcategories',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubcategoriesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: AppTheme.spacingMd,
        mainAxisSpacing: AppTheme.spacingMd,
      ),
      itemCount: controller.subcategories.length,
      itemBuilder: (context, index) {
        final subcategory = controller.subcategories[index];
        return _buildSubcategoryItem(subcategory);
      },
    );
  }
  
  Widget _buildSubcategoryItem(HomeCategory subcategory) {
    return GestureDetector(
      onTap: () => controller.goToSubcategoryProducts(subcategory),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Subcategory icon/image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: subcategory.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: Image.network(
                        subcategory.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildIconPlaceholder(subcategory.name),
                      ),
                    )
                  : _buildIconPlaceholder(subcategory.name),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            // Subcategory name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXs),
              child: Text(
                subcategory.name,
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Product count
            if (subcategory.productCount > 0)
              Text(
                '${subcategory.productCount} items',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIconPlaceholder(String name) {
    return Center(
      child: Icon(
        _getSubcategoryIcon(name),
        color: AppTheme.primaryColor,
        size: 28,
      ),
    );
  }
  
  IconData _getSubcategoryIcon(String name) {
    final nameLower = name.toLowerCase();
    
    if (nameLower.contains('tool')) return Icons.build_outlined;
    if (nameLower.contains('paint')) return Icons.format_paint_outlined;
    if (nameLower.contains('electric')) return Icons.electrical_services_outlined;
    if (nameLower.contains('plumb')) return Icons.plumbing_outlined;
    if (nameLower.contains('screw') || nameLower.contains('nail')) return Icons.hardware_outlined;
    if (nameLower.contains('pipe')) return Icons.water_outlined;
    if (nameLower.contains('wire') || nameLower.contains('cable')) return Icons.cable_outlined;
    if (nameLower.contains('light') || nameLower.contains('lamp')) return Icons.lightbulb_outlined;
    if (nameLower.contains('lock') || nameLower.contains('key')) return Icons.lock_outlined;
    if (nameLower.contains('door') || nameLower.contains('window')) return Icons.door_front_door_outlined;
    if (nameLower.contains('garden') || nameLower.contains('outdoor')) return Icons.yard_outlined;
    if (nameLower.contains('safety') || nameLower.contains('protect')) return Icons.health_and_safety_outlined;
    
    return Icons.category_outlined;
  }
}
