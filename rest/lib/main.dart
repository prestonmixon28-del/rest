import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'album.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AlbumPage(),
    );
  }
}

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {

  Future<List<Album>> fetchAlbums() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/albums'),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data.map((item) => Album.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load albums');
    }
  }

  late Future<List<Album>> albums;
  Album? selectedAlbum;

  @override
  void initState() {
    super.initState();
    albums = fetchAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Album Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Album>>(
  future: albums,
  builder: (context, snapshot) {

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return const Center(
        child: Text('Error loading albums'),
      );
    }

    final albumList = snapshot.data!;

    return Column(
      children: [

        // Selected Album Details
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: selectedAlbum == null
              ? const Text('No Album Selected')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Title: ${selectedAlbum!.title}'),
                    Text('Album ID: ${selectedAlbum!.id}'),
                    Text('User ID: ${selectedAlbum!.userId}'),
                  ],
                ),
        ),

        // Album List
        Expanded(
          child: ListView.builder(
            itemCount: albumList.length,
            itemBuilder: (context, index) {
              final album = albumList[index];

              return ListTile(
                title: Text(album.title),
                subtitle: Text('Album ID: ${album.id}'),
                onTap: () {
                  setState(() {
                    selectedAlbum = album;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  },
),
    );
  }
}
