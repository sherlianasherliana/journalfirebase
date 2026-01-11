import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'tambah.dart';
import 'detail.dart';

class JournalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // APPBAR
      appBar: AppBar(
        title: Text(
          "Journal Harian",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),

      // TOMBOL +
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TambahData()),
          );
        },
        child: Icon(Icons.add),
      ),

      // LIST FIRESTORE
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('journal')
            .orderBy('tanggal', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                "Belum ada jurnal",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data() as Map<String, dynamic>;

              DateTime tanggal = (data["tanggal"] as Timestamp).toDate();
              String tglFormat =
                  "${tanggal.day}-${tanggal.month}-${tanggal.year}";

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPage(
                        id: doc.id,
                        judul: data['judul'],
                        isi: data['isi'],
                        mood: data['mood'],
                        tanggal: data['tanggal'],
                        imagePath: data['imagePath'],
                        videoPath: data['videoPath'],
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Material(
                    elevation: 3,
                    shadowColor: Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TOP ROW → Judul + Tanggal badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  data["judul"],
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tglFormat,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 8),

                          // CUMLINE ISI
                          Text(
                            data["isi"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          SizedBox(height: 12),

                          // MOOD ROW
                          Row(
                            children: [
                              Icon(
                                Icons.mood,
                                size: 18,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 6),
                              Text(
                                data["mood"],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
