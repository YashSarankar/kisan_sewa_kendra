import 'package:flutter/material.dart';
import 'package:kisan_sewa_kendra/components/products_grid.dart';

import '../components/ksk_appbar.dart';
import '../shopify/shopify.dart';

class CollectionView extends StatefulWidget {
  final String collectionId;
  const CollectionView({super.key, required this.collectionId});

  @override
  State<CollectionView> createState() => _CollectionViewState();
}

class _CollectionViewState extends State<CollectionView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _title = '', _url = '', _subTitle = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _init);
  }

  _init() async {
    if (!mounted) return;
    var col = await ShopifyAPI.getCollection(id: widget.collectionId);
    if (mounted) {
      setState(() {
        _title = "${col['title'] ?? ''}";
        _subTitle = "${col['pro'] ?? ''}";
        _url = "https://kisansewakendra.in/collections/${col['handle'] ?? ''}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: KskAppbar(
        title: _title,
        subTitle: _subTitle,
        share: _url,
      ),
      // Set shrinkWrap to false to fix the 12000px overflow and freezing
      body: ProductsGrid(
        isFilter: true,
        id: widget.collectionId,
        shrinkWrap: false,
      ),
    );
  }
}
