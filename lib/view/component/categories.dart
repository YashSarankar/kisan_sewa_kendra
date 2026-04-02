import 'package:flutter/material.dart';

import '../../components/network_image.dart';
import '../../components/widget_button.dart';
import '../../controller/constants.dart';
import '../../controller/routers.dart';
import '../../model/categories_model.dart';
import '../../shopify/shopify.dart';
import '../collection_view.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _init);
  }

  List<CategoriesModel> _categories = [];
  bool _isLoading = true;

  Future<void> _init() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    
    final all = await Shopify.getCategories(context);
    
    // 1. Filter out meta-categories, promotional banners, and irrelevant sections
    // 2. Ensure only categories with valid images are shown
    _categories = all.where((cat) {
      final title = cat.title.toLowerCase().trim();
      final hasImage = cat.image.isNotEmpty;
      
      // Extended Blacklist for non-category/promotional sections
      final isNotHomePage = title != "home page";
      final isNotHydroponics = !title.contains('hydroponics');
      final isNotSale = !title.contains('sale') && !title.contains('republic day');
      final isNotBanner = !title.contains('banner') && !title.contains('best seller');
      
      return hasImage && isNotHomePage && isNotHydroponics && isNotSale && isNotBanner;
    }).toList();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Constants.baseColor,
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Text("No categories found."),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.withAlpha(30), width: 1),
            ),
            child: WidgetButton(
              onTap: () {
                Routers.goTO(
                  context,
                  toBody: CollectionView(
                    collectionId: category.id.toString(),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Constants.baseColor.withAlpha(5),
                        ),
                        child: KskNetworkImage(
                          category.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Text(
                        category.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 11,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
