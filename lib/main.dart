import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photos/preview.dart';
import 'package:http/http.dart';
import 'dart:convert';

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
  List<String> photos = [];

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
            photos.add(photo['src']['medium']);
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
          backgroundColor: Color.fromRGBO(35, 109, 180, 1),
          title: const Text(
            'Photos',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
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
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search_sharp),
                      onPressed: () {
                        String searchTerm = searchController.text;
                        getPhotos(searchTerm);
                      },
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
              Center(
                child: Text('Please search for photos'),
              )
            else
              Expanded(
                child: GridView.builder(
                  physics: ScrollPhysics(),
                  controller: _scrollController,
                  padding: const EdgeInsets.all(1),
                  itemCount: photos.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemBuilder: ((context, index) {
                    return Container(
                      padding: const EdgeInsets.all(1),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                Preview(photos: photos, index: index),
                          ),
                        ),
                        child: Hero(
                          tag: photos[index],
                          child: CachedNetworkImage(
                            imageUrl: photos[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey),
                            errorWidget: (context, url, error) =>
                                Container(color: Colors.red.shade400),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ));
  }
}
