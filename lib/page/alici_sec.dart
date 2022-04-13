import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/page/alici_bilgisi_duzenle.dart';
import 'package:pdf_invoice/page/alici_bilgisi_ekle.dart';
import 'package:pdf_invoice/page/anasayfa.dart';
import 'package:pdf_invoice/page/tarih_sec.dart';

import '../provider/all_providers.dart';

class AliciSec extends ConsumerStatefulWidget {
  const AliciSec({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AliciSecState();
}

class _AliciSecState extends ConsumerState<AliciSec> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        ref
            .read(aliciSecBottomNavBarProvider.notifier)
            .update((state) => false);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alıcı Seç'),
        ),
        bottomNavigationBar: Visibility(
          visible: ref.watch(aliciSecBottomNavBarProvider),
          child: BottomNavigationBar(
              showUnselectedLabels: true,
              selectedItemColor: Colors.deepOrange,
              unselectedItemColor: Colors.deepOrange,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              currentIndex: 0,
              onTap: (value) {
                switch (value) {
                  case 0:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AliciBilgisiDuzenle(),
                        ));
                    break;
                  case 1:
                    aliciSil(ref);
                    var liste = ref.watch(aliciListesiProvider);
                    liste.remove(ref.watch(aliciSecSeciliMusteriProvider));
                    ref
                        .read(aliciListesiProvider.notifier)
                        .update((state) => liste);
                    setState(() {});
                    //ref.read(provider.notifier).update((state) => aliciListesi);

                    break;
                  default:
                }
                ref
                    .read(aliciSecBottomNavBarProvider.notifier)
                    .update((state) => false);
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.edit), label: 'Bilgileri Düzenle'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.delete), label: 'Alıcıyı Sil')
              ]),
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
                      ref
                          .read(aliciSecBottomNavBarProvider.notifier)
                          .update((state) => false);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          color: Colors.deepOrange,
                          size: 30,
                        ),
                        Text('Müşteri Ekle')
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ref.watch(aliciListesiProvider).length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ListTile(
                              onLongPress: () {
                                ref
                                    .read(aliciSecBottomNavBarProvider.notifier)
                                    .update((state) => true);
                                ref
                                    .read(
                                        aliciSecSeciliMusteriProvider.notifier)
                                    .update((state) =>
                                        ref.watch(aliciListesiProvider)[index]);
                              },
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TarihSec(),
                                    ));
                                ref
                                    .read(gecerliMusteri.notifier)
                                    .update((state) {
                                  return ref.watch(aliciListesiProvider)[index];
                                });
                                ref
                                    .read(aliciSecBottomNavBarProvider.notifier)
                                    .update((state) => false);
                                /*Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DescriptionAddPage(),
                                    )); */
                              },
                              title: Text(ref.watch(aliciListesiProvider)[index]
                                  ['adi']),
                            ),
                            const Divider(
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
      ),
    );
  }

  void aliciSil(WidgetRef ref) async {
    await _firestore
        .collection(ref.watch(saticiAdi))
        .doc(ref.watch(aliciSecSeciliMusteriProvider)!['adi'])
        .delete();
  }
}
