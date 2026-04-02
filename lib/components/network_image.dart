import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../generated/assets.dart';

class KskNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width, height;
  final BoxFit? fit;

  const KskNetworkImage(
    this.imageUrl, {
    super.key,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();
    if (cleanUrl.isEmpty || !cleanUrl.startsWith("http")) {
      return _buildPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: cleanUrl,
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (context, url) => _buildShimmer(),
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[50],
      alignment: Alignment.center,
      child: Opacity(
        opacity: 0.2,
        child: Image.asset(
          Assets.assetsLogo,
          height: height != null ? height! * 0.4 : 40,
          width: width != null ? width! * 0.4 : 40,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
