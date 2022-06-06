import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/page/alici_bilgisi_duzenle.dart';
import 'package:pdf_invoice/page/alici_bilgisi_ekle.dart';
import 'package:pdf_invoice/page/tarih_sec.dart';
import 'package:pdf_invoice/translations/locale_keys.g.dart';

import '../constants/constant.dart';
import '../provider/all_providers.dart';

class AliciSec extends ConsumerStatefulWidget {
  const AliciSec({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AliciSecState();
}

class _AliciSecState extends ConsumerState<AliciSec> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    aliciListesiniGetir();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        /* ref
            .read(aliciSecBottomNavBarProvider.notifier)
            .update((state) => false); */
        ref.read(radioAliciProvider.notifier).update((state) => null);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.alici_sec.tr()),
        ),
        bottomNavigationBar: BottomNavigationBar(
            showUnselectedLabels: true,
            selectedItemColor: Colors.deepOrange,
            unselectedItemColor: Colors.deepOrange,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            currentIndex: 0,
            onTap: (value) {
              if (ref.watch(radioAliciProvider) == null) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        //title: const Text('Alıcı Seçmediniz'),
                        content:
                            Text(LocaleKeys.lutfen_alici_secimi_yapin.tr()),
                        actions: <Widget>[
                          TextButton(
                            child: Text(LocaleKeys.tamam.tr()),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              } else {
                switch (value) {
                  case 0:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AliciBilgisiDuzenle(),
                        ));
                    break;
                  case 1:
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(LocaleKeys.alici_bilgisi_sil.tr()),
                            content: Text(LocaleKeys
                                .bu_alici_silinecek_onayliyor_musun
                                .tr()),
                            actions: <Widget>[
                              TextButton(
                                child: Text(LocaleKeys.vazgec.tr()),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    aliciSil(ref);
                                    var liste = ref.watch(aliciListesiProvider);
                                    liste.remove(ref
                                        .watch(aliciSecSeciliMusteriProvider));
                                    ref
                                        .read(aliciListesiProvider.notifier)
                                        .update((state) => liste);
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(LocaleKeys.sil.tr()))
                            ],
                          );
                        });
                    //ref.read(provider.notifier).update((state) => aliciListesi);
                    break;
                  default:
                }
              }
              /* ref
                  .read(aliciSecBottomNavBarProvider.notifier)
                  .update((state) => false); */
              ref.read(radioAliciProvider.notifier).update((state) => null);
            },
            items: [
              BottomNavigationBarItem(
                  icon: const Icon(Icons.edit),
                  label: LocaleKeys.bilgileri_duzenle.tr()),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.delete),
                  label: LocaleKeys.aliciyi_sil.tr())
            ]),
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
                      /* ref
                          .read(aliciSecBottomNavBarProvider.notifier)
                          .update((state) => false); */
                      ref
                          .read(radioAliciProvider.notifier)
                          .update((state) => null);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          color: Colors.deepOrange,
                          size: 40,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 20,
                        ),
                        Text(
                          LocaleKeys.musteri_ekle.tr(),
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: ListView.builder(
                      itemCount: ref.watch(aliciListesiProvider).length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ListTile(
                              onTap: () {
                                ref
                                    .read(radioAliciProvider.notifier)
                                    .update((state) => index);
                                ref
                                    .read(gecerliMusteri.notifier)
                                    .update((state) {
                                  return ref.watch(aliciListesiProvider)[index];
                                });
                                ref
                                    .read(
                                        aliciSecSeciliMusteriProvider.notifier)
                                    .update((state) =>
                                        ref.watch(aliciListesiProvider)[index]);
                              },
                              leading: Radio(
                                value: index,
                                groupValue: ref.watch(radioAliciProvider),
                                onChanged: (int? yeniDeger) {
                                  ref
                                      .read(radioAliciProvider.notifier)
                                      .update((state) => index);
                                  ref
                                      .read(gecerliMusteri.notifier)
                                      .update((state) {
                                    return ref
                                        .watch(aliciListesiProvider)[index];
                                  });
                                  ref
                                      .read(aliciSecSeciliMusteriProvider
                                          .notifier)
                                      .update((state) => ref
                                          .watch(aliciListesiProvider)[index]);
                                  /* ref
                                      .read(seciliFaturaProvider.notifier)
                                      .update((state) => ref
                                          .watch(faturalarProvider)[index]
                                          .data()); */
                                },
                              ),
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
                  Visibility(
                    visible: ref.watch(radioAliciProvider) != null,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 50),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 15,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TarihSec(),
                                  ));
                              ref
                                  .read(radioAliciProvider.notifier)
                                  .update((state) => null);
                            },
                            child: Text(
                              LocaleKeys.sec_ve_devam_et.tr(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            )),
                      ),
                    ),
                  ),
                  const Spacer(
                    flex: 2,
                  )
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

  void aliciListesiniGetir() async {
    var gelenBilgi =
        await _firestore.collection(auth.currentUser!.email!).get();

    ref.read(provider.notifier).update((state) => gelenBilgi.docs);
    var liste = ref.watch(provider);
    List<Map<String, dynamic>> aliciListesi = [];

    if (liste.isNotEmpty) {
      for (var item in liste) {
        item.id == 'saticiFirma' ? null : aliciListesi.add(item.data());
      }
      ref.read(aliciListesiProvider.notifier).update((state) => aliciListesi);
    }
  }
}
