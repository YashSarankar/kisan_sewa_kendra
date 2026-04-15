import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisan_sewa_kendra/components/products_grid.dart';

import '../controller/constants.dart';
import '../shopify/shopify.dart';

class CollectionView extends StatefulWidget {
  final String collectionId;
  final String? title;
  const CollectionView({super.key, required this.collectionId, this.title});

  @override
  State<CollectionView> createState() => _CollectionViewState();
}

class _CollectionViewState extends State<CollectionView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _title = '';

  final GlobalKey<ProductsGridState> _gridKey = GlobalKey<ProductsGridState>();

  @override
  void initState() {
    super.initState();
    _title = widget.title ?? '';
    Future.delayed(Duration.zero, _init);
  }

  _init() async {
    if (!mounted) return;
    var col = await ShopifyAPI.getCollection(id: widget.collectionId);
    if (mounted && widget.title == null) {
      setState(() {
        _title = "${col['title'] ?? ''}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final topPad = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xffF9FBF9),
        body: Stack(
          children: [
            // Background Layer
            Positioned.fill(
              child: Container(color: const Color(0xffF9FBF9)),
            ),

            // Background Shapes
            Positioned(
              top: -50,
              right: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Constants.baseColor.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 220,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Constants.baseColor.withOpacity(0.03),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Constants.baseColor.withOpacity(0.02),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Products Grid — starts right below the header
            Padding(
              padding: EdgeInsets.only(top: topPad + 56),
              child: ProductsGrid(
                key: _gridKey,
                isFilter: false,
                id: widget.collectionId,
                shrinkWrap: false,
              ),
            ),

            // Frosted Glass Header (floating on top)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildFrostedHeader(topPad),
            ),
          ],
        ),
      ),
    );
  }

  /// Frosted glass header with back button and sort
  Widget _buildFrostedHeader(double topPad) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 8, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            border: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.05)),
            ),
          ),
          child: Row(
            children: [
              _circleIconBtn(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _title.isNotEmpty ? _title : "Collection",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Constants.baseColor,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "KrishiKranti Organics • Pure Selection",
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Constants.baseColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Sort button
              _buildSortButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      offset: const Offset(0, 44),
      onSelected: (value) {
        HapticFeedback.lightImpact();
        _gridKey.currentState?.sortProducts(value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: "a-z",
          child: Row(
            children: [
              Icon(Icons.sort_by_alpha_rounded,
                  size: 18, color: Constants.baseColor),
              const SizedBox(width: 10),
              Text("A → Z",
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        PopupMenuItem(
          value: "z-a",
          child: Row(
            children: [
              Icon(Icons.sort_by_alpha_rounded,
                  size: 18, color: Constants.baseColor),
              const SizedBox(width: 10),
              Text("Z → A",
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        PopupMenuItem(
          value: "default",
          child: Row(
            children: [
              Icon(Icons.restart_alt_rounded,
                  size: 18, color: Colors.grey[500]),
              const SizedBox(width: 10),
              Text("Default",
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Constants.baseColor.withOpacity(0.06),
          shape: BoxShape.circle,
        ),
        child:
            Icon(Icons.swap_vert_rounded, size: 20, color: Constants.baseColor),
      ),
    );
  }

  Widget _circleIconBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1E1E1E)),
      ),
    );
  }
}
