import 'package:flutter/material.dart';

import '../../components/network_image.dart';
import '../../components/widget_button.dart';
import '../../controller/constants.dart';
import '../../controller/routers.dart';
import '../collection_view.dart';

class Crops extends StatefulWidget {
  const Crops({super.key});

  @override
  State<Crops> createState() => _CropsState();
}

class _CropsState extends State<Crops> {
  @override
  Widget build(BuildContext context) {
    return GridView(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: .9,
      ),
      children: [
        for (var crop in Constants.cropsList) ...[
          Card(
            clipBehavior: Clip.antiAlias,
            child: WidgetButton(
              onTap: () {
                Routers.goTO(
                  context,
                  toBody: CollectionView(
                    collectionId: crop['id'].toString(),
                  ),
                );
              },
              child: KskNetworkImage(
                crop['image']!,
                height: 160,
                width: MediaQuery.sizeOf(context).width,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
