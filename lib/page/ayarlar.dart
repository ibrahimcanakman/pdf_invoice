import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf_invoice/page/anasayfa.dart';
import 'package:pdf_invoice/provider/all_providers.dart';
import 'package:pdf_invoice/translations/locale_keys.g.dart';

class AyarlarSayfasi extends ConsumerStatefulWidget {
  const AyarlarSayfasi({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AyarlarSayfasiState();
}

class _AyarlarSayfasiState extends ConsumerState<AyarlarSayfasi> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  //String dropdownDeger = 'Artan Sayı';
  final picker = ImagePicker();
  Uint8List? image;

  @override
  void initState() {
    super.initState();
    //faturaNoBicimGetir();
  }

  CarouselController _carouselController = new CarouselController();
  //int _current = 0;

  List<dynamic> _invoiceFormats = [
    {'image': 'assets/invoiceformats/1.png', 'index': 0},
    {'image': 'assets/invoiceformats/2.png', 'index': 1}
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.ayarlar.tr()),
        ),
        body: ref.watch(faturaNoBicimProvider) == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                                await context
                                    .setLocale(const Locale('en'))
                                    .whenComplete(() {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AnaSayfa(),
                                      ),
                                      (route) => false);
                                });
                              },
                              icon: const Icon(Icons.language),
                              label: const Text('English')),
                          ElevatedButton.icon(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                                await context
                                    .setLocale(const Locale('tr'))
                                    .whenComplete(() {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AnaSayfa(),
                                      ),
                                      (route) => false);
                                });
                              },
                              icon: const Icon(Icons.language),
                              label: const Text('Türkçe')),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            LocaleKeys.fatura_numarasi_bicimi.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )),
                          Expanded(
                            child: Material(
                              borderRadius: BorderRadius.circular(15),
                              elevation: 16,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  borderRadius: BorderRadius.circular(20),
                                  elevation: 16,
                                  value: ref.watch(faturaNoBicimProvider),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'Artan Sayı',
                                      child: Text(LocaleKeys.artan_sayi.tr()),
                                    ),
                                    DropdownMenuItem(
                                        value: 'Tarih + Sayı',
                                        child:
                                            Text(LocaleKeys.tarih_sayi.tr())),
                                  ],
                                  onChanged: (value) {
                                    ref
                                        .read(faturaNoBicimProvider.notifier)
                                        .update((state) => value);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                              LocaleKeys.fatura_formati.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            /* Expanded(
                              child: Material(
                                borderRadius: BorderRadius.circular(15),
                                elevation: 16,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(20),
                                    elevation: 16,
                                    value: ref.watch(faturaFormatProvider),
                                    underline: SizedBox(),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Format1',
                                        child: Text('Format1'),
                                      ),
                                      DropdownMenuItem(
                                          value: 'Format2',
                                          child: Text('Format2')),
                                    ],
                                    onChanged: (value) {
                                      ref
                                          .read(faturaFormatProvider.notifier)
                                          .update((state) => value!);
                                    },
                                  ),
                                ),
                              ),
                            ), */
                          ],
                        ),
                      ),
                      CarouselSlider(
                        options: CarouselOptions(
                          height: MediaQuery.of(context).size.height * 0.45,
                          aspectRatio: 16 / 9,
                          initialPage: ref.watch(faturaFormatIndexProvider)!,
                          viewportFraction: 0.70,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            /* setState(() {
                              _current = index;
                            }); */
                            ref
                                .read(faturaFormatIndexProvider.notifier)
                                .update((state) => index);
                            ref.read(faturaFormatProvider.notifier).update(
                                (state) => index == 0 ? 'Format1' : 'Format2');
                          },
                        ),
                        carouselController: _carouselController,
                        items: _invoiceFormats.map((invoice) {
                          return Builder(
                            builder: (BuildContext context) {
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: Image.asset(
                                          'assets/invoiceformats/${ref.watch(faturaFormatIndexProvider)! + 1}.png'),
                                    ),
                                  );
                                },
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 5.0),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        border: invoice['index'] ==
                                                ref.watch(
                                                    faturaFormatIndexProvider)
                                            ? Border.all(
                                                width: 3,
                                                color: Colors.deepOrange)
                                            : null),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.4,
                                      margin: EdgeInsets.only(top: 30),
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Image.asset(invoice['image'],
                                          fit: BoxFit.fill),
                                    )),
                              );
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleKeys.firma_logosu_yukle.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                              onPressed: () {
                                firmaLogosunuKaldir();
                              },
                              child: Text(LocaleKeys.logoyu_kaldir.tr()))
                        ],
                      ),
                      Text(
                        LocaleKeys.logo_yukleme_mesaji.tr(),
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: GestureDetector(
                            onTap: () {
                              resimGetir(ImageSource.gallery);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ref.watch(logoProvider) == null
                                  ? Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              7,
                                      decoration: BoxDecoration(
                                          border: Border.all(),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Center(
                                        child: Icon(Icons.add),
                                      ))
                                  : Image.memory(
                                      ref.watch(logoProvider)!,
                                      fit: BoxFit.fill,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              7,
                                    ),
                            )

                            /* Container(
                              width: MediaQuery.of(context).size.width / 2,
                              //height: MediaQuery.of(context).size.height / 5,
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(20)),
                              child: ref.watch(logoProvider) == null
                                  ? Center(
                                      child: Icon(Icons.add),
                                    )
                                  : Image.memory(
                                      ref.watch(logoProvider)!,
                                      fit: BoxFit.fill,
                                    )), */
                            ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            onPressed: () {
                              degisiklikleriKaydet()
                                  .then((value) => Navigator.pop(context));
                            },
                            child: Text(LocaleKeys.kaydet.tr())),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> degisiklikleriKaydet() async {
    await _firestore
        .collection(auth.currentUser!.email!)
        .doc('saticiFirma')
        .collection('faturaNoBicim')
        .doc('faturaNoBicim')
        .update({'faturaNoBicim': ref.watch(faturaNoBicimProvider)});
    await _firestore
        .collection(auth.currentUser!.email!)
        .doc('saticiFirma')
        .update({'faturaFormati': ref.watch(faturaFormatProvider)});
  }

  /* Future<void> faturaNoBicimGetir() async {
    var bicimSS = await _firestore
        .collection(auth.currentUser!.email!)
        .doc('saticiFirma')
        .collection('faturaNoBicim')
        .doc('faturaNoBicim')
        .get();
    String? bicim = bicimSS.data()!['faturaNoBicim'];
    ref.read(faturaNoBicimProvider.notifier).update((state) => bicim);
  } */

  Future<void> resimGetir(ImageSource source) async {
    final pickedFile =
        await picker.pickImage(source: source).then((value) async {
      ref
          .read(logoProvider.notifier)
          .update((state) => File(value!.path).readAsBytesSync());
      await value!.readAsBytes().then((value) async {
        await _firestore
            .collection(auth.currentUser!.email!)
            .doc('saticiFirma')
            .set({
          'firmaLogo': String.fromCharCodes(value.buffer
              .asUint8List(value.offsetInBytes, value.lengthInBytes))
        }, SetOptions(merge: true));
      });
    });

    /* setState(() {
      image = File(pickedFile!.path).readAsBytesSync();
    }); */
  }

  Future<void> firmaLogosunuKaldir() async {
    await _firestore
        .collection(auth.currentUser!.email!)
        .doc('saticiFirma')
        .update({'firmaLogo': ''});
    ref.read(logoProvider.notifier).update((state) => null);
  }
}
