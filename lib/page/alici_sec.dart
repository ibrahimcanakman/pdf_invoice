import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/page/alici_bilgisi_ekle.dart';
import 'package:pdf_invoice/page/anasayfa.dart';
import 'package:pdf_invoice/page/tarih_sec.dart';

final gecerliMusteri = StateProvider<Map<String, dynamic>>(
  (ref) => {},
);

class AliciSec extends ConsumerWidget {
  AliciSec({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var liste = ref.watch(provider);
    List<Map<String,dynamic>> aliciListesi=[];
    if (liste.isNotEmpty) {
      for (var item in liste) {
      item.id == 'saticiFirma' ? null : aliciListesi.add(item.data());
    }
    }
    

    return Scaffold(
      appBar: AppBar(
        title: Text('Alıcı Seç'),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AliciBilgisiEkle(),
                        ));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: Colors.orange,
                        size: 30,
                      ),
                      Text('Müşteri Ekle')
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: aliciListesi.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TarihSec(),
                                  ));
                              ref.read(gecerliMusteri.notifier).update((state) {
                                return aliciListesi[index];
                              });
                              /*Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DescriptionAddPage(),
                                  )); */
                            },
                            title: Text(aliciListesi[index]['adi']),
                          ),
                          Divider(
                            height: 0,
                            thickness: 2,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
