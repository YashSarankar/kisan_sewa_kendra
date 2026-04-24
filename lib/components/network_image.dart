import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class KskNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width, height;
  final BoxFit? fit;
  final double? borderRadius;

  const KskNetworkImage(
    this.imageUrl, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
  });

  @override
  State<KskNetworkImage> createState() => _KskNetworkImageState();
}

class _KskNetworkImageState extends State<KskNetworkImage> {
  @override
  Widget build(BuildContext context) {
    final double radius = widget.borderRadius ?? 12.0;

    if (widget.imageUrl.isEmpty) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child:
            const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
      );
    }

    // 1. URL Cleanup & Shopify Cloud Transformation
    String cleanUrl = widget.imageUrl.trim();
    String finalUrl = cleanUrl;

    if (cleanUrl.contains('shopify.com')) {
      // Create a clean base URL without existing width/format params
      Uri uri = Uri.parse(cleanUrl);
      Map<String, String> params = Map.from(uri.queryParameters);

      // Determine target width
      int widthParam = (widget.width != null &&
              widget.width! > 0 &&
              widget.width! != double.infinity)
          ? (widget.width! * 2).toInt()
          : 800;

      // PNG + Transparency flags for Shopify Cloud conversion
      params['format'] = 'png';
      params['width'] = widthParam.toString();
      params['transparent'] = 'true';
      params['pad'] = '0';

      finalUrl = uri.replace(queryParameters: params).toString();
    }

    // 2. High-Performance Progressive Double-Pass Loader with Curves
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: finalUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit ?? BoxFit.contain,
        memCacheWidth: (widget.width != null &&
                widget.width! > 0 &&
                widget.width! != double.infinity)
            ? (widget.width! * 2).toInt()
            : 800,
        placeholder: (context, url) {
          String thumbUrl = finalUrl;
          if (finalUrl.contains('shopify.com')) {
            Uri thumbUri = Uri.parse(finalUrl);
            Map<String, String> thumbParams =
                Map.from(thumbUri.queryParameters);
            thumbParams['width'] = '50';
            thumbUrl =
                thumbUri.replace(queryParameters: thumbParams).toString();
          }
          return CachedNetworkImage(
            imageUrl: thumbUrl,
            width: widget.width,
            height: widget.height,
            fit: widget.fit ?? BoxFit.contain,
            placeholder: (context, url) => _buildShimmer(radius),
          );
        },
        fadeOutDuration: Duration.zero,
        fadeInDuration: Duration.zero,
        errorWidget: (context, url, error) => SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Icon(Icons.broken_image_outlined,
              color: Colors.grey, size: 20),
        ),
      ),
    );
  }

  Widget _buildShimmer(double radius) {
    return Shimmer.fromColors(
      baseColor: Colors.transparent,
      highlightColor: Colors.white.withOpacity(0.02),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
