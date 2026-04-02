import 'package:flutter/material.dart';

import '../controller/constants.dart';
import '../controller/routers.dart';
import '../model/product_model.dart';
import '../shopify/shopify.dart';
import '../view/product_view.dart';
import 'network_image.dart';
import 'widget_button.dart';

class ProductsGrid extends StatefulWidget {
  final String id;
  final int? limit;
  final bool isFilter;
  final bool shrinkWrap;
  final List<String>? excludeIds; // To prevent duplicates

  const ProductsGrid({
    super.key,
    required this.id,
    this.limit,
    this.isFilter = false,
    this.shrinkWrap = true,
    this.excludeIds,
  });

  @override
  State<ProductsGrid> createState() => _ProductsGridState();
}

class _ProductsGridState extends State<ProductsGrid>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _init);
  }

  List<ProductModel> _products = [], _fullProducts = [];
  bool _isLoading = true;

  Future<void> _init() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    
    final result = await Shopify.getProductsFromCollections(
      context,
      id: widget.id,
      limit: widget.limit != null ? (widget.limit! + (widget.excludeIds?.length ?? 0)) : null,
    );
    
    if (mounted) {
      setState(() {
        List<ProductModel> list = (result['product'] as List<dynamic>?)?.cast<ProductModel>() ?? <ProductModel>[];
        
        // Filter out excluded IDs
        if (widget.excludeIds != null) {
          list = list.where((p) => !widget.excludeIds!.contains(p.id)).toList();
        }
        
        // Apply limit after exclusion
        if (widget.limit != null && list.length > widget.limit!) {
          list = list.sublist(0, widget.limit);
        }

        _products = list;
        _fullProducts = _products;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget grid = GridView.builder(
      shrinkWrap: widget.shrinkWrap,
      physics: widget.shrinkWrap ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.61, // Adjusted for rating stars
      ),
      itemCount: _isLoading ? (widget.limit ?? 4) : _products.length,
      itemBuilder: (context, index) {
        if (_isLoading) {
          return _buildShimmerCard();
        } else {
          return ProductCard(
            product: _products[index],
          );
        }
      },
    );

    if (!widget.shrinkWrap) {
      if (widget.isFilter) {
        return Column(
          children: [
            _buildSortHeader(),
            Expanded(child: grid), 
          ],
        );
      }
      return grid;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isFilter) _buildSortHeader(),
        grid,
      ],
    );
  }

  Widget _buildSortHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text("Sort By", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            icon: Icon(Icons.swap_vert_rounded, color: Constants.baseColor, size: 22),
            onSelected: (value) {
              setState(() {
                if (value == "a-z") {
                  _products.sort((a, b) => a.title.compareTo(b.title));
                } else if (value == "z-a") {
                  _products.sort((a, b) => b.title.compareTo(a.title));
                } else {
                  _products = List.from(_fullProducts);
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "a-z", child: Text("Alphabetically A-Z")),
              const PopupMenuItem(value: "z-a", child: Text("Alphabetically Z-A")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Constants.shimmer()),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Constants.shimmer(height: 12, width: double.infinity),
                  const SizedBox(height: 8),
                  Constants.shimmer(height: 12, width: 80),
                  const Spacer(),
                  Constants.shimmer(height: 18, width: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  VariantModel? _minPriceVariant() {
    if (product.variants.isEmpty) return null;
    final available = product.variants.where((v) => v.inventoryQuantity > 0).toList();
    if (available.isEmpty) return product.variants.first;
    available.sort((a, b) {
      final aPrice = double.tryParse(a.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      final bPrice = double.tryParse(b.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      return aPrice.compareTo(bPrice);
    });
    return available.first;
  }

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < fullStars
                ? Icons.star_rounded
                : (i == fullStars && hasHalfStar ? Icons.star_half_rounded : Icons.star_outline_rounded),
            color: Colors.amber,
            size: 14,
          ),
        const SizedBox(width: 4),
        Text(
          rating.toString(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final variant = _minPriceVariant();
    if (variant == null) return const SizedBox.shrink();

    // Use a hash of product ID to generate a consistent fake rating between 4.0 and 5.0
    double fakeRating = 4.0 + (product.id.hashCode % 11) / 10.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: WidgetButton(
        onTap: () => Routers.goTO(context, toBody: ProductView(product: product)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: KskNetworkImage(
                      product.image ?? '',
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRatingStars(fakeRating),
                        const SizedBox(height: 4),
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (variant.compareAtPrice != null && variant.compareAtPrice!.isNotEmpty)
                                  Text(
                                    "${Constants.inr}${variant.compareAtPrice}",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                Text(
                                  "${Constants.inr}${variant.price}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Constants.baseColor,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Constants.baseColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.add_rounded, size: 20, color: Constants.baseColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _buildDiscountBadge(variant),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountBadge(VariantModel variant) {
    if (variant.compareAtPrice == null || variant.compareAtPrice!.isEmpty) return const SizedBox.shrink();
    try {
      double mrp = double.parse(variant.compareAtPrice!.replaceAll(Constants.inr, '').replaceAll(',', ''));
      double sp = double.parse(variant.price.replaceAll(Constants.inr, '').replaceAll(',', ''));
      double per = (100 * (mrp - sp)) / mrp;
      if (per > 1) {
        return Positioned(
          top: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(12)),
            ),
            child: Text(
              "${per.toInt()}% OFF",
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
        );
      }
    } catch (_) {}
    return const SizedBox.shrink();
  }
}
