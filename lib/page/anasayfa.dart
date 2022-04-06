import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/page/alici_sec.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final provider =
    StateProvider<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
  (ref) => [],
);

class AnaSayfa extends ConsumerWidget {
  AnaSayfa({Key? key}) : super(key: key);

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Sayfa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 10,
                child: ElevatedButton(
                    onPressed: () async {
                      
                      var gelenBilgi =
                          await _firestore.collection('ahmet').get();
                      
                      ref
                          .read(provider.notifier)
                          .update((state) => gelenBilgi.docs);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AliciSec(),
                          ));
                    },
                    child: const Text(
                      'Fatura Kes',
                      style: TextStyle(fontSize: 24),
                    )))
          ],
        ),
      ),
    );
  }
}
