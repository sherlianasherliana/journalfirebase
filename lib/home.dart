import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'journal.dart';
import 'audio.dart';
import 'profil.dart';
import 'tambah.dart';
import 'maps.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int currentIndex = 0;

  final List<Widget> pages = [
    YoutubeHome(),
    JournalPage(),
    Audio(),
    ProfilPage(), // Profil sekarang di posisi ke-4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      // FloatingActionButton khusus untuk JournalPage (sekarang index 1)
      floatingActionButton: currentIndex == 1
          ? FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TambahData()),
                );
              },
              child: Icon(Icons.add),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.folder_open), label: "Data"),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Audio"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////
// HOME PAGE MODERN UI (Youtube Section + Statistik)
//////////////////////////////////////////////////////////

class YoutubeHome extends StatefulWidget {
  @override
  _YoutubeHomeState createState() => _YoutubeHomeState();
}

class _YoutubeHomeState extends State<YoutubeHome> {
  final videoURL = "https://youtu.be/WI-j39vOqmk?si=oYzNiLw2LZyZh2r7";
  late YoutubePlayerController youtubeController;

  // Filter periode
  String selectedPeriod = "Bulan Ini"; // Default: Bulan Ini
  final List<String> periods = ["Minggu Ini", "Bulan Ini", "Semua Waktu"];

  @override
  void initState() {
    super.initState();
    final videoID = YoutubePlayer.convertUrlToId(videoURL);
    youtubeController = YoutubePlayerController(
      initialVideoId: videoID!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    youtubeController.dispose();
    super.dispose();
  }

  // Fungsi untuk menghitung skor mood (0-100)
  double _hitungSkorMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'bersemangat':
        return 100;
      case 'senang':
        return 85;
      case 'netral':
        return 50;
      case 'lelah':
        return 30;
      case 'sedih':
        return 20;
      case 'marah':
        return 10;
      default:
        return 50;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Smart Journal"),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: "Buka Maps",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // HERO SECTION - MODERN GRADIENT HEADER
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF5E35B1),
                    Color(0xFF1E88E5),
                    Color(0xFF00ACC1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF5E35B1).withOpacity(0.4),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Icon
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.auto_stories,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: 16),

                        // Title
                        Text(
                          "Selamat Datang! 👋",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 12),

                        // Subtitle with brand name
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Smart Journal",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Description
                        Text(
                          "Ruang aman untuk mengenali diri, merangkul perasaan, dan merawat kesehatan emosionalmu",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.95),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 20),

                        // Decorative divider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.favorite,
                              color: Colors.white.withOpacity(0.7),
                              size: 16,
                            ),
                            SizedBox(width: 10),
                            Container(
                              width: 40,
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
                height: 20), // =============================================
            // STATISTIK JURNAL & MOOD
            // =============================================
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('journal').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;
                int totalJurnal = docs.length;

                // Hitung rata-rata mood
                double totalSkor = 0;
                if (totalJurnal > 0) {
                  for (var doc in docs) {
                    var data = doc.data() as Map<String, dynamic>;
                    String mood = data['mood'] ?? 'netral';
                    totalSkor += _hitungSkorMood(mood);
                  }
                }
                double rataMood = totalJurnal > 0 ? totalSkor / totalJurnal : 0;

                // Hitung distribusi mood
                Map<String, int> distribusiMood = {
                  'bersemangat': 0,
                  'senang': 0,
                  'netral': 0,
                  'lelah': 0,
                  'sedih': 0,
                  'marah': 0,
                };

                for (var doc in docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  String mood = data['mood'] ?? 'netral';
                  if (distribusiMood.containsKey(mood)) {
                    distribusiMood[mood] = distribusiMood[mood]! + 1;
                  }
                }

                return Column(
                  children: [
                    // CARD TOTAL JURNAL
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.book,
                                    size: 40,
                                    color: Colors.blueAccent,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "$totalJurnal",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Total Jurnal",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        // CARD RATA-RATA MOOD
                        Expanded(
                          child: Card(
                            color: _getColorByMoodScore(rataMood),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.mood,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "${rataMood.toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Skor Mood",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // CARD DISTRIBUSI MOOD
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Distribusi Mood",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 15),
                            ...distribusiMood.entries.map((entry) {
                              double persentase = totalJurnal > 0
                                  ? (entry.value / totalJurnal) * 100
                                  : 0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              _getIconByMood(entry.key),
                                              size: 20,
                                              color: _getColorByMood(entry.key),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              entry.key
                                                      .substring(0, 1)
                                                      .toUpperCase() +
                                                  entry.key.substring(1),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "${entry.value} (${persentase.toStringAsFixed(0)}%)",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    LinearProgressIndicator(
                                      value: persentase / 100,
                                      backgroundColor: Colors.grey.shade200,
                                      color: _getColorByMood(entry.key),
                                      minHeight: 8,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: 20),

            // DESKRIPSI
            Text(
              "Panduan video untuk memulai journaling:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 15),

            // VIDEO PLAYER DALAM CARD
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: YoutubePlayer(
                  controller: youtubeController,
                  showVideoProgressIndicator: true,
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper function untuk warna berdasarkan mood
  Color _getColorByMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'bersemangat':
        return Colors.green;
      case 'senang':
        return Colors.lightGreen;
      case 'netral':
        return Colors.amber;
      case 'lelah':
        return Colors.orange;
      case 'sedih':
        return Colors.deepOrange;
      case 'marah':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper function untuk warna berdasarkan skor
  Color _getColorByMoodScore(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.amber;
    if (score >= 20) return Colors.orange;
    return Colors.red;
  }

  // Helper function untuk icon berdasarkan mood
  IconData _getIconByMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'bersemangat':
        return Icons.flash_on;
      case 'senang':
        return Icons.sentiment_very_satisfied;
      case 'netral':
        return Icons.sentiment_neutral;
      case 'lelah':
        return Icons.battery_charging_full;
      case 'sedih':
        return Icons.sentiment_dissatisfied;
      case 'marah':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.mood;
    }
  }
}
