import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:intl/intl.dart';
import 'package:pdf_invoice/page/urun_ekleme_page.dart';

import '../provider/all_providers.dart';
import '../translations/locale_keys.g.dart';

class TarihSec extends ConsumerStatefulWidget {
  const TarihSec({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TarihSecState();
}

class _TarihSecState extends ConsumerState<TarihSec> {
  final TextEditingController _faturaNoController = TextEditingController();
  final GlobalKey<FormState> _faturaNoKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String>? faturaNolar;

  @override
  void initState() {
    super.initState();
    bicimGetir();
  }

  //DateTime _seciliGun = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        ref.read(tarihDatetimeProvider.notifier).update((state) => null);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.tarih_sec.tr()),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(
              flex: 2,
            ),
            ElevatedButton(
                onPressed: () async {
                  DateTime? seciliGun = await gunSec(context);
                  if (seciliGun != null) {
                    //_seciliGun = seciliGun;

                    String gun = DateFormat('dd.MM.yyyy').format(seciliGun);
                    String faturaNo = DateFormat('yyyyMMdd').format(seciliGun);
                    //debugPrint(faturaNo);
                    ref
                        .read(faturaNoProvider.notifier)
                        .update((state) => faturaNo);
                    ref
                        .read(tarihDatetimeProvider.notifier)
                        .update((state) => seciliGun);

                    /* String secilenTarih =
                      '${seciliGun.day}.${seciliGun.month}.${seciliGun.year}'; */
                    ref.read(tarihProvider.notifier).update((state) => gun);
                    showDialog(
                      context: context,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                    faturaNolariGetir().then((value) async {
                      List<int> tarihSayi = [];
                      List<int> artanSayi = [];

                      if (value != null) {
                        switch (ref.watch(faturaNoBicimProvider)) {
                          case "Artan Sayı 3'er":
                            if (value.containsKey('artanSayi')) {
                              List<dynamic> artanSayiListesi =
                                  value['artanSayi'];
                              int sonDeger = artanSayiListesi.last;
                              int yeniDeger = 3 - (sonDeger % 3) + sonDeger;
                              ref
                                  .read(faturaNoProvider.notifier)
                                  .update((state) => '$yeniDeger');
                              artanSayiListesi.add(yeniDeger);
                              for (var element in artanSayiListesi) {
                                artanSayi.add(element);
                              }
                            } else {
                              ref
                                  .read(faturaNoProvider.notifier)
                                  .update((state) => '1');
                              /* ref
                            .read(faturaDocAdiProvider.notifier)
                            .update((state) => 'S-$faturaNo-0'); */
                              artanSayi = [1];
                            }
                            ref
                                .read(yazilacakFaturaNoProvider.notifier)
                                .update((state) => {'artanSayi': artanSayi});
                            break;

                          case "Artan Sayı 5'er":
                            if (value.containsKey('artanSayi')) {
                              List<dynamic> artanSayiListesi =
                                  value['artanSayi'];
                              int sonDeger = artanSayiListesi.last;
                              int yeniDeger = 5 - (sonDeger % 5) + sonDeger;
                              ref
                                  .read(faturaNoProvider.notifier)
                                  .update((state) => '$yeniDeger');
                              artanSayiListesi.add(yeniDeger);
                              for (var element in artanSayiListesi) {
                                artanSayi.add(element);
                              }
                            } else {
                              ref
                                  .read(faturaNoProvider.notifier)
                                  .update((state) => '1');
                              artanSayi = [1];
                            }
                            ref
                                .read(yazilacakFaturaNoProvider.notifier)
                                .update((state) => {'artanSayi': artanSayi});
                            break;

                          case "Tarih + Sayı":
                            if (value.containsKey('tarihSayi')) {
                              ref.read(faturaNoProvider.notifier).update((state) =>
                                  '$faturaNo-${value['tarihSayi'].length + 1}');
                              for (var i = 1;
                                  i <= value['tarihSayi'].length + 1;
                                  i++) {
                                tarihSayi.add(i);
                              }
                            } else {
                              ref
                                  .read(faturaNoProvider.notifier)
                                  .update((state) => '$faturaNo-1');
                              tarihSayi = [1];
                            }
                            ref
                                .read(yazilacakFaturaNoProvider.notifier)
                                .update((state) => {'tarihSayi': tarihSayi});
                            break;
                          default:
                        }
                      } else {
                        switch (ref.watch(faturaNoBicimProvider)) {
                          case "Artan Sayı 3'er":
                            ref
                                .read(faturaNoProvider.notifier)
                                .update((state) => '1');
                            artanSayi = [1];
                            ref
                                .read(yazilacakFaturaNoProvider.notifier)
                                .update((state) => {'artanSayi': artanSayi});
                            break;

                          case "Artan Sayı 5'er":
                            ref
                                .read(faturaNoProvider.notifier)
                                .update((state) => '1');
                            artanSayi = [1];
                            ref
                                .read(yazilacakFaturaNoProvider.notifier)
                                .update((state) => {'artanSayi': artanSayi});
                            break;

                          case "Tarih + Sayı":
                            ref
                                .read(faturaNoProvider.notifier)
                                .update((state) => '$faturaNo-1');
                            tarihSayi = [1];
                            ref
                                .read(yazilacakFaturaNoProvider.notifier)
                                .update((state) => {'tarihSayi': tarihSayi});
                            break;
                          default:
                        }
                      }

                      /* if (value != null &&
                        ref.watch(faturaNoBicimProvider) == "Artan Sayı 3'er") {
                      if (value.containsKey('artanSayi')) {
                        List<dynamic> artanSayiListesi = value['artanSayi'];
                        int sonDeger = artanSayiListesi.last;
                        int yeniDeger = 3 - (sonDeger % 3) + sonDeger;
                        ref
                            .read(faturaNoProvider.notifier)
                            .update((state) => '$yeniDeger');
                        artanSayiListesi.add(yeniDeger);
                        for (var element in artanSayiListesi) {
                          artanSayi.add(element);
                        }
                        /* ref.read(faturaDocAdiProvider.notifier).update((state) =>
                            'S-$faturaNo-${value['artanSayi'].length}'); */
                        /* for (var i = 0; i < value['artanSayi'].length + 1; i++) {
                          artanSayi.add(i);
                        } */
                      } else {
                        ref
                            .read(faturaNoProvider.notifier)
                            .update((state) => '0');
                        /* ref
                            .read(faturaDocAdiProvider.notifier)
                            .update((state) => 'S-$faturaNo-0'); */
                        artanSayi = [0];
                      }
                      ref
                          .read(yazilacakFaturaNoProvider.notifier)
                          .update((state) => {'artanSayi': artanSayi});
                      //faturaNoYazArtanSayi(artanSayi);
                    } else if (value == null &&
                        ref.watch(faturaNoBicimProvider) == 'Artan Sayı') {
                      ref.read(faturaNoProvider.notifier).update((state) => '0');
                      /* ref
                          .read(faturaDocAdiProvider.notifier)
                          .update((state) => 'S-$faturaNo-0'); */
                      artanSayi = [0];
                      ref
                          .read(yazilacakFaturaNoProvider.notifier)
                          .update((state) => {'artanSayi': artanSayi});
                      //faturaNoYazArtanSayi(artanSayi);
                    } else if (value != null &&
                        ref.watch(faturaNoBicimProvider) == 'Tarih + Sayı') {
                      if (value.containsKey('tarihSayi')) {
                        ref.read(faturaNoProvider.notifier).update(
                            (state) => '$faturaNo-${value['tarihSayi'].length}');
                        /* ref.read(faturaDocAdiProvider.notifier).update((state) =>
                            'TS-$faturaNo-${value['tarihSayi'].length}'); */
    
                        for (var i = 0; i < value['tarihSayi'].length + 1; i++) {
                          tarihSayi.add(i);
                        }
                        /* ref
                          .read(tarihSayiProvider.notifier)
                          .update((state) => tarihSayi); */
    
                      } else {
                        ref
                            .read(faturaNoProvider.notifier)
                            .update((state) => '$faturaNo-0');
                        /* ref
                            .read(faturaDocAdiProvider.notifier)
                            .update((state) => 'TS-$faturaNo-0'); */
    
                        tarihSayi = [0];
                        //ref.read(tarihSayiProvider.notifier).update((state) => [0]);
    
                      }
                      ref
                          .read(yazilacakFaturaNoProvider.notifier)
                          .update((state) => {'tarihSayi': tarihSayi});
                      //faturaNoYazTarihSayi(tarihSayi);
                    } else if (value == null &&
                        ref.watch(faturaNoBicimProvider) == 'Tarih + Sayı') {
                      ref
                          .read(faturaNoProvider.notifier)
                          .update((state) => '$faturaNo-0');
                      /* ref
                          .read(faturaDocAdiProvider.notifier)
                          .update((state) => 'TS-$faturaNo-0'); */
                      tarihSayi = [0];
                      ref
                          .read(yazilacakFaturaNoProvider.notifier)
                          .update((state) => {'tarihSayi': tarihSayi});
                      //faturaNoYazTarihSayi(tarihSayi);
                    } */

                      _faturaNoController.text = ref.watch(faturaNoProvider);

                      Navigator.pop(context);
                    });
                  }
                },
                child: Text(LocaleKeys.tarih_sec.tr())),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    LocaleKeys.fatura_numarasi.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                  Expanded(
                    flex: 2,
                    child: Form(
                      key: _faturaNoKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: TextFormField(
                        enabled: true,
                        controller: _faturaNoController,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp('[ ]'))
                        ],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15))),
                        onTap: () async {
                          await _firestore
                              .collection(_auth.currentUser!.displayName!)
                              .doc('saticiFirma')
                              .collection('faturalar')
                              .get()
                              .then((value) {
                            if (value.docs.isNotEmpty) {
                              faturaNolar = [];
                              for (var element in value.docs) {
                                faturaNolar!.add(element.id);
                              }
                            }
                            debugPrint(faturaNolar.toString());
                          });
                        },
                        onFieldSubmitted: (value) {
                          ref
                              .read(faturaNoProvider.notifier)
                              .update((state) => value);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Fatura numarası boş bırakılamaz.';
                          } else if (faturaNolar != null &&
                              faturaNolar!.contains(value.trim())) {
                            return 'Bu fatura numarası daha önce kullanılmış';
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
                onPressed: () {
                  if (_faturaNoKey.currentState!.validate()) {
                    if (ref.read(tarihDatetimeProvider) != null) {
                      if (ref.read(faturaNoProvider) !=
                          _faturaNoController.text.trim()) {
                        ref
                            .read(faturaNoProvider.notifier)
                            .update((state) => _faturaNoController.text.trim());
                        if (int.tryParse(_faturaNoController.text.trim()) !=
                            null) {
                          if (int.parse(_faturaNoController.text.trim()) % 3 ==
                                  0 ||
                              int.parse(_faturaNoController.text.trim()) % 5 ==
                                  0) {
                            if (ref
                                .read(faturaNoBicimProvider)!
                                .contains('Artan Sayı')) {
                              List<int> liste = ref.read(
                                  yazilacakFaturaNoProvider)!['artanSayi'];
                              liste.removeLast();
                              liste.add(int.parse(ref.read(faturaNoProvider)));
                              liste.sort();
                              ref
                                  .read(yazilacakFaturaNoProvider.notifier)
                                  .update((state) => {'artanSayi': liste});
                              //FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DescriptionAddPage(),
                                  ));
                            } else {
                              artanSayilariGetir().then((value) {
                                List<int>? liste = value;
                                if (liste != null) {
                                  liste.add(
                                      int.parse(ref.read(faturaNoProvider)));
                                  liste.sort();
                                  ref
                                      .read(yazilacakFaturaNoProvider.notifier)
                                      .update((state) => {'artanSayi': liste});
                                } else {
                                  ref
                                      .read(yazilacakFaturaNoProvider.notifier)
                                      .update((state) => {
                                            'artanSayi': [
                                              int.parse(
                                                  ref.read(faturaNoProvider))
                                            ]
                                          });
                                }
                                //FocusManager.instance.primaryFocus?.unfocus();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DescriptionAddPage(),
                                    ));
                              });
                            }
                          } else {
                            ref
                                .read(yazilacakFaturaNoProvider.notifier)
                                .update((state) => null);
                            //FocusManager.instance.primaryFocus?.unfocus();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DescriptionAddPage(),
                                ));
                          }
                        } else {
                          ref
                              .read(yazilacakFaturaNoProvider.notifier)
                              .update((state) => null);
                          //FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DescriptionAddPage(),
                              ));
                        }
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DescriptionAddPage(),
                            ));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewPadding.bottom),
                        child: Text('Tarih seçimi yapmalısınız !'),
                      )));
                    }
                  }
                },
                child: Text(LocaleKeys.kaydet_ve_devam_et.tr())),
            const Spacer(
              flex: 2,
            )
          ],
        ),
      ),
    );
  }

  Future<DateTime?> gunSec(BuildContext context) async {
    final DateTime? secili = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 3),
        lastDate: DateTime(DateTime.now().year + 3));
    return secili;
  }

  Future<List<int>?> artanSayilariGetir() async {
    var artanSayiDoc = await _firestore
        .collection(_auth.currentUser!.displayName!)
        .doc('saticiFirma')
        .collection('faturaNumaralari')
        .doc('artanSayi')
        .get();
    if (artanSayiDoc.data() != null) {
      List<int> artanSayiListesi = artanSayiDoc.data()!['artanSayi'];
      return artanSayiListesi;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> faturaNolariGetir() async {
    if (ref.watch(faturaNoBicimProvider) == 'Tarih + Sayı') {
      var faturaNolarDoc = await _firestore
          .collection(_auth.currentUser!.displayName!)
          .doc('saticiFirma')
          .collection('faturaNumaralari')
          .doc('tarihSayi')
          .collection(ref.watch(faturaNoProvider))
          .doc('tarihSayi')
          .get();
      ref
          .read(faturaNolarProvider.notifier)
          .update((state) => faturaNolarDoc.data());
      return faturaNolarDoc.data();
    } else {
      var faturaNolarDoc = await _firestore
          .collection(_auth.currentUser!.displayName!)
          .doc('saticiFirma')
          .collection('faturaNumaralari')
          .doc('artanSayi')
          .get();
      ref
          .read(faturaNolarProvider.notifier)
          .update((state) => faturaNolarDoc.data());
      return faturaNolarDoc.data();
    }
    /* var faturaNolarDoc = await _firestore
        .collection(ref.watch(saticiAdi))
        .doc('saticiFirma')
        .collection('faturaNumaralari')
        .doc(ref.watch(faturaNoProvider))
        .get();
    ref
        .read(faturaNolarProvider.notifier)
        .update((state) => faturaNolarDoc.data());
    return faturaNolarDoc.data(); */
  }

  Future<void> bicimGetir() async {
    var bicimSS = await _firestore
        .collection(_auth.currentUser!.displayName!)
        .doc('saticiFirma')
        .collection('faturaNoBicim')
        .doc('faturaNoBicim')
        .get();
    String? bicim = bicimSS.data()!['faturaNoBicim'];
    ref.read(faturaNoBicimProvider.notifier).update((state) => bicim);
  }
}
