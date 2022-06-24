import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  TextEditingController _faturaNoController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    bicimGetir();
  }

  DateTime _seciliGun = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                DateTime seciliGun = await gunSec(context);
                _seciliGun = seciliGun;

                String gun = DateFormat('dd.MM.yyyy').format(seciliGun);
                String faturaNo = DateFormat('yyyyMMdd').format(seciliGun);
                debugPrint(faturaNo);
                ref.read(faturaNoProvider.notifier).update((state) => faturaNo);
                ref
                    .read(tarihDatetimeProvider.notifier)
                    .update((state) => _seciliGun);

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
                  if (value != null &&
                      ref.watch(faturaNoBicimProvider) == 'Artan Sayı') {
                    if (value.containsKey('artanSayi')) {
                      ref
                          .read(faturaNoProvider.notifier)
                          .update((state) => '${value['artanSayi'].length}');
                      /* ref.read(faturaDocAdiProvider.notifier).update((state) =>
                          'S-$faturaNo-${value['artanSayi'].length}'); */
                      for (var i = 0; i < value['artanSayi'].length + 1; i++) {
                        artanSayi.add(i);
                      }
                    } else {
                      ref
                          .read(faturaNoProvider.notifier)
                          .update((state) => '0');
                      /* ref
                          .read(faturaDocAdiProvider.notifier)
                          .update((state) => 'S-$faturaNo-0'); */
                      artanSayi = [0];
                    }
                    ref.read(yazilacakFaturaNoProvider.notifier).update((state) => {'artanSayi': artanSayi});
                    //faturaNoYazArtanSayi(artanSayi);
                  } else if (value == null &&
                      ref.watch(faturaNoBicimProvider) == 'Artan Sayı') {
                    ref.read(faturaNoProvider.notifier).update((state) => '0');
                    /* ref
                        .read(faturaDocAdiProvider.notifier)
                        .update((state) => 'S-$faturaNo-0'); */
                    artanSayi = [0];
                    ref.read(yazilacakFaturaNoProvider.notifier).update((state) => {'artanSayi': artanSayi});
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
                    ref.read(yazilacakFaturaNoProvider.notifier).update((state) => {'tarihSayi': tarihSayi});
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
                    ref.read(yazilacakFaturaNoProvider.notifier).update((state) => {'tarihSayi': tarihSayi});
                    //faturaNoYazTarihSayi(tarihSayi);
                  }

                  _faturaNoController.text = ref.watch(faturaNoProvider);

                  Navigator.pop(context);
                });
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
                  child: TextFormField(
                    enabled: false,
                    autovalidateMode: AutovalidateMode.always,
                    controller: _faturaNoController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15))),
                    onFieldSubmitted: (value) {
                      ref
                          .read(faturaNoProvider.notifier)
                          .update((state) => value);
                    },
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DescriptionAddPage(),
                    ));
              },
              child: Text(LocaleKeys.kaydet_ve_devam_et.tr())),
          const Spacer(
            flex: 2,
          )
        ],
      ),
    );
  }

  Future<DateTime> gunSec(BuildContext context) async {
    final DateTime? secili = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 3),
        lastDate: DateTime(DateTime.now().year + 3));
    return secili!;
  }

  Future<Map<String, dynamic>?> faturaNolariGetir() async {
    if (ref.watch(faturaNoBicimProvider) == 'Tarih + Sayı') {
      var faturaNolarDoc = await _firestore
          .collection(ref.watch(saticiAdi))
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
          .collection(ref.watch(saticiAdi))
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
        .collection(_auth.currentUser!.email!)
        .doc('saticiFirma')
        .collection('faturaNoBicim')
        .doc('faturaNoBicim')
        .get();
    String? bicim = bicimSS.data()!['faturaNoBicim'];
    ref.read(faturaNoBicimProvider.notifier).update((state) => bicim);
  }
}
