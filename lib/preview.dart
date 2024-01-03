import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class Preview extends StatelessWidget {
  final List<String> photos;
  final int index;

  const Preview({super.key, required this.photos, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(35, 109, 180, 1),
      ),
      body: PhotoViewGallery.builder(
        itemCount: photos.length,
        builder: (context, index) => PhotoViewGalleryPageOptions.customChild(
            child: CachedNetworkImage(
              imageUrl: photos[index],
              placeholder: (context, url) => Container(
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.red.shade400,
              ),
            ),
            minScale: PhotoViewComputedScale.covered,
            heroAttributes: PhotoViewHeroAttributes(tag: photos[index])),
        pageController: PageController(initialPage: index),
      ),
    );
  }
}
