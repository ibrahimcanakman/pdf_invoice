import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf_invoice/page/anasayfa.dart';
import 'package:pdf_invoice/utils/database_helper.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:ui' as ui;

import '../provider/all_providers.dart';

const double _kItemExtent = 50.0;

class AciklamaEkle extends ConsumerStatefulWidget {
  const AciklamaEkle({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AciklamaEkleState();
}

class _AciklamaEkleState extends ConsumerState<AciklamaEkle> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedFruit = 0;

  DatabaseHelper _databaseHelper = DatabaseHelper();
  TextEditingController _yeniAciklamaController = TextEditingController();
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    aciklamalariGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Açıklama Ekle'),
        ),
        body: ref.watch(aciklamalarProvider).isEmpty
            ? const Center(
                child: Text('Açıklamalar Getiriliyor'),
              )
            : Column(children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Center(
                        child: ElevatedButton(
                            onPressed: () {
                              _showDialog(
                                CupertinoPicker(
                                  magnification: 1,
                                  squeeze: 1.2,
                                  useMagnifier: true,
                                  itemExtent: _kItemExtent,
                                  // This is called when selected item is changed.
                                  onSelectedItemChanged: (int selectedItem) {
                                    setState(() {
                                      _selectedFruit = selectedItem;
                                    });
                                    ref
                                        .read(seciliAciklamaProvider.notifier)
                                        .update((state) =>
                                            ref.watch(aciklamalarProvider)[
                                                selectedItem]['aciklama']);
                                  },
                                  children: List<Widget>.generate(
                                      ref.watch(aciklamalarProvider).length,
                                      (int index) {
                                    return Center(
                                      child: index ==
                                              ref
                                                      .watch(
                                                          aciklamalarProvider)
                                                      .length -
                                                  1
                                          ? Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.add),
                                                  Text(
                                                    ref.watch(
                                                            aciklamalarProvider)[
                                                        index]['aciklama'],
                                                  ),
                                                ],
                                              ),
                                            )
                                          : SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Center(
                                                  child: Text(
                                                    ref.watch(
                                                            aciklamalarProvider)[
                                                        index]['aciklama'],
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                ),
                                              ),
                                            ),
                                    );
                                  }),
                                ),
                              );
                              // This displays the selected fruit name.
                            },
                            child: Text('Açıklama Seç')),
                      ),
                      ref.watch(aciklamalarProvider)[_selectedFruit]
                                  ['aciklama'] !=
                              'Yeni Açıklama Ekle'
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  Text(
                                    'Açıklama : ',
                                    style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline),
                                  ),
                                  Text(
                                    ref.watch(seciliAciklamaProvider) != null
                                        ? ref.watch(seciliAciklamaProvider)!
                                        : ref.watch(aciklamalarProvider)[
                                            _selectedFruit]['aciklama'],
                                    style: const TextStyle(
                                      fontSize: 22.0,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                TextFormField(
                                  controller: _yeniAciklamaController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                      label: Text('Yeni Açıklama'),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15))),
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      aciklamaEkle();
                                      ref
                                          .read(aciklamalarProvider.notifier)
                                          .update((state) {
                                        var liste = [];
                                        for (var element in state) {
                                          element['aciklama'] !=
                                                  'Yeni Açıklama Ekle'
                                              ? liste.add(element)
                                              : null;
                                        }

                                        return [
                                          ...liste,
                                          {
                                            'aciklama': _yeniAciklamaController
                                                .text
                                                .trim()
                                          },
                                          {'aciklama': 'Yeni Açıklama Ekle'}
                                        ];
                                      });
                                      _yeniAciklamaController.clear();
                                      _selectedFruit = ref
                                              .watch(aciklamalarProvider)
                                              .length -
                                          2;
                                    },
                                    child: Text('Kaydet'))
                              ],
                            ),
                      /* ref.watch(aciklamalarProvider)[_selectedFruit]['aciklama'] !=
                                  'Yeni Açıklama Ekle' &&
                              ref.watch(aciklamalarProvider)[_selectedFruit]
                                      ['aciklama'] !=
                                  'Bir Açıklama Seçin' */
                      ref.watch(seciliAciklamaProvider) != null &&
                              ref.watch(aciklamalarProvider)[_selectedFruit]
                                      ['aciklama'] !=
                                  'Yeni Açıklama Ekle' &&
                              ref.watch(aciklamalarProvider)[_selectedFruit]
                                      ['aciklama'] !=
                                  'Bir Açıklama Seçin'
                          ? ElevatedButton(
                              onPressed: () {
                                firebasefaturayiYaz().then((value) {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AnaSayfa(),
                                      ),
                                      (route) => false);
                                  ref
                                      .read(seciliAciklamaProvider.notifier)
                                      .update((state) => 'Bir Açıklama Seçin');
                                });
                              },
                              child: Text('Açıklamayı Kaydet'))
                          : SizedBox()
                    ],
                  ),
                ),
                Expanded(child: SizedBox()),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                        child: SfSignaturePad(
                            key: signatureGlobalKey,
                            backgroundColor: Colors.white,
                            strokeColor: Colors.black,
                            minimumStrokeWidth: 1.0,
                            maximumStrokeWidth: 4.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)))),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    TextButton(
                      child: Text('ToImage'),
                      onPressed: _handleSaveButtonPressed,
                    ),
                    TextButton(
                      child: Text('Clear'),
                      onPressed: _handleClearButtonPressed,
                    )
                  ],
                ),
              ]));
  }

  void _handleClearButtonPressed() {
    signatureGlobalKey.currentState!.clear();
  }

  void _handleSaveButtonPressed() async {
    final data =
        await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);
    final bytes = await data.toByteData(format: ui.ImageByteFormat.png);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Container(
                color: Colors.grey[300],
                child: Image.memory(bytes!.buffer.asUint8List()),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              // The Bottom margin is provided to align the popup above the system navigation bar.
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              // Provide a background color for the popup.
              color: CupertinoColors.systemBackground.resolveFrom(context),
              // Use a SafeArea widget to avoid system overlaps.
              child: SafeArea(
                top: false,
                child: child,
              ),
            ));
  }

  Future<void> aciklamalariGetir() async {
    var aciklamalar = await _databaseHelper.aciklamalarigetir();
    ref.read(aciklamalarProvider.notifier).update((state) => [
          ...aciklamalar,
          {'aciklama': 'Yeni Açıklama Ekle'}
        ]);
  }

  Future<void> aciklamaEkle() async {
    await _databaseHelper.aciklamaekle(_yeniAciklamaController.text.trim());
  }

  Future<void> firebasefaturayiYaz() async {
    Map<String, dynamic> aciklama = {
      'aciklama': ref.watch(seciliAciklamaProvider),
    };
    Map<String, dynamic> eklenecek = ref.watch(yazilacakFaturaMapProvider)!;
    eklenecek.addAll(aciklama);
    await _firestore
        .collection(ref.watch(saticiAdi))
        .doc('saticiFirma')
        .collection('faturalar')
        .doc(ref.watch(faturaDocAdiProvider))
        .set(eklenecek);
/* 
    await _firestore
        .collection(ref.watch(saticiAdi))
        .doc('saticiFirma')
        .collection('faturalar')
        .doc(ref.watch(faturaDocAdiProvider))
        .set(eklenecek, SetOptions(merge: true)); */

    if (ref.watch(yazilacakFaturaNoProvider) != null &&
        ref.watch(yazilacakFaturaNoProvider)!.containsKey('artanSayi')) {
      if (ref.watch(yazilacakFaturaNoProvider)!['artanSayi'].toString() ==
          [0].toString()) {
        await _firestore
            .collection(ref.watch(saticiAdi))
            .doc('saticiFirma')
            .collection('faturaNumaralari')
            .doc('artanSayi')
            .set({
          'artanSayi': ref.watch(yazilacakFaturaNoProvider)!['artanSayi']
        }, SetOptions(merge: true));
      } else {
        await _firestore
            .collection(ref.watch(saticiAdi))
            .doc('saticiFirma')
            .collection('faturaNumaralari')
            .doc('artanSayi')
            .update({
          'artanSayi': ref.watch(yazilacakFaturaNoProvider)!['artanSayi']
        });
      }
    } else {
      if (ref.watch(yazilacakFaturaNoProvider)!['tarihSayi'].toString() ==
          [0].toString()) {
        await _firestore
            .collection(ref.watch(saticiAdi))
            .doc('saticiFirma')
            .collection('faturaNumaralari')
            .doc('tarihSayi')
            .collection(DateFormat('yyyyMMdd')
                .format(ref.watch(tarihDatetimeProvider))
                .toString())
            .doc('tarihSayi')
            .set({
          'tarihSayi': ref.watch(yazilacakFaturaNoProvider)!['tarihSayi']
        }, SetOptions(merge: true));
      } else {
        await _firestore
            .collection(ref.watch(saticiAdi))
            .doc('saticiFirma')
            .collection('faturaNumaralari')
            .doc('tarihSayi')
            .collection(DateFormat('yyyyMMdd')
                .format(ref.watch(tarihDatetimeProvider))
                .toString())
            .doc('tarihSayi')
            .update({
          'tarihSayi': ref.watch(yazilacakFaturaNoProvider)!['tarihSayi']
        });
      }
    }
  }
}
