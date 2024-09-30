import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photos/preview.dart';
import 'package:photos/saved.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(MaterialApp(
    home: WDPhotos(),
  ));
}

class WDPhotos extends StatefulWidget {
  const WDPhotos({super.key});

  @override
  State<WDPhotos> createState() => _WDPhotosState();
}

class _WDPhotosState extends State<WDPhotos> {
  List<Map<String, String>> photos = [];

  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool isLoading = false;

  void getPhotos(String key) async {
    setState(() {
      isLoading = true;
    });

    String url = key.isNotEmpty
        ? 'https://api.pexels.com/v1/search?query=' + key + '&per_page=100'
        : 'https://api.pexels.com/v1/search?query=elephants&per_page=100';
    try {
      Response resp = await get(Uri.parse(url), headers: {
        "authorization":
            "454B9DWrYowbAvo9UfJfmEqO6WUsWczyjpmMyhDECrZGq5S7J7ScmcZR",
      });

      if (resp.statusCode == 200) {
        setState(() {
          photos.clear();
          Map<String, dynamic> jsonData = jsonDecode(resp.body);
          List<dynamic> photos_result = jsonData['photos'];
          for (Map<String, dynamic> photo in photos_result) {
            photos.add({
              'thumbnail': photo['src']['small'],
              'original': photo['src']['original']
            });
          }
        });
      } else {
        print('Request failed with status: ${resp.statusCode}');
        print('Error: ${resp.body}');
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Zoho Photos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onSubmitted: (String searchTerm) {
                        getPhotos(searchTerm);
                      },
                      controller: searchController,
                      decoration: InputDecoration(
                          hintText: 'Search...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search_outlined)),
                    ),
                  ),
                ],
              )),
          if (isLoading)
            Center(
                child: LinearProgressIndicator(
              backgroundColor: Colors.blue.shade100,
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            )),
          if (photos.length == 0 && !isLoading)
            Expanded(
              child: Center(
                child: Text('Please search for photos'),
              ),
            )
          else
            Expanded(
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                padding: EdgeInsets.all(12.0),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Preview(photos: photos, index: index),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Hero(
                        tag: photos[index],
                        child: CachedNetworkImage(
                          imageUrl: photos[index]['thumbnail']!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey),
                          errorWidget: (context, url, error) =>
                              Container(color: Colors.red.shade400),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        backgroundColor: Colors.white,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(35, 109, 180, 1),
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Saved Photos'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Saved(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Search Photos'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
