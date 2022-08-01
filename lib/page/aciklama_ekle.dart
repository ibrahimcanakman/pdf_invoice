/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf_invoice/page/anasayfa.dart';
import 'package:pdf_invoice/translations/locale_keys.g.dart';
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
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  //int _selectedFruit = 0;

  final TextEditingController _yeniAciklamaController = TextEditingController();
  //TextEditingController _aciklamaController = TextEditingController();
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();

  /* @override
  void initState() {
    super.initState();
    //aciklamalariGetir();
  } */

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(LocaleKeys.aciklama_ve_imza_ekle.tr()),
          ),
          body: /* ref.watch(aciklamalarProvider).isEmpty
              ? Center(
                  child: Text(LocaleKeys.aciklamalar_getiriliyor.tr()),
                )
              :  */
              Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(children: [
              /* Expanded(
                      flex: 3,
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                      onSelectedItemChanged:
                                          (int selectedItem) {
                                        setState(() {
                                          _selectedFruit = selectedItem;
                                        });
                                        ref
                                            .read(
                                                seciliAciklamaProvider.notifier)
                                            .update((state) =>
                                                ref.watch(aciklamalarProvider)[
                                                    selectedItem]['aciklama']);
                                        _aciklamaController.text = ref.watch(
                                                    seciliAciklamaProvider) !=
                                                null
                                            ? ref.watch(seciliAciklamaProvider)!
                                            : ref.watch(aciklamalarProvider)[
                                                _selectedFruit]['aciklama'];
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
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
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
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10),
                                                    child: Center(
                                                      child: Text(
                                                        ref.watch(
                                                                aciklamalarProvider)[
                                                            index]['aciklama'],
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        );
                                      }),
                                    ),
                                  );
                                  
                                },
                                child: Text(LocaleKeys.aciklama_sec.tr())),
                          ),
                          ref.watch(aciklamalarProvider)[_selectedFruit]
                                      ['aciklama'] !=
                                  LocaleKeys.yeni_aciklama_ekle.tr()
                              ? TextFormField(
                                  maxLines: 5,
                                  readOnly: true,
                                  controller: _aciklamaController,
                                  decoration: InputDecoration(
                                      hintText: LocaleKeys.bir_aciklama_secin.tr(),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      )),
                                )

                              /* Row(
                                  children: [
                                    const Text(
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
                                ) */
                              : Column(
                                  children: [
                                    TextFormField(
                                      controller: _yeniAciklamaController,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                          label: Text(LocaleKeys.yeni_aciklama.tr()),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15))),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                            onPressed: () async {
                                              aciklamaEkle();
                                              ref
                                                  .read(aciklamalarProvider
                                                      .notifier)
                                                  .update((state) {
                                                var liste = [];
                                                for (var element in state) {
                                                  element['aciklama'] !=
                                                          LocaleKeys.yeni_aciklama_ekle.tr()
                                                      ? liste.add(element)
                                                      : null;
                                                }

                                                return [
                                                  ...liste,
                                                  {
                                                    'aciklama':
                                                        _yeniAciklamaController
                                                            .text
                                                            .trim()
                                                  },
                                                  {
                                                    'aciklama':
                                                        LocaleKeys.yeni_aciklama_ekle.tr()
                                                  }
                                                ];
                                              });
                                              _yeniAciklamaController.clear();
                                              _selectedFruit = ref
                                                      .watch(
                                                          aciklamalarProvider)
                                                      .length -
                                                  2;
                                            },
                                            child: Text(
                                              LocaleKeys.aciklamayi_ekle.tr(),
                                              textAlign: TextAlign.center,
                                            )),
                                      ],
                                    )
                                  ],
                                ),
                          /* ref.watch(aciklamalarProvider)[_selectedFruit]['aciklama'] !=
                                    'Yeni Açıklama Ekle' &&
                                ref.watch(aciklamalarProvider)[_selectedFruit]
                                        ['aciklama'] !=
                                    'Bir Açıklama Seçin' */

                          /* ref.watch(seciliAciklamaProvider) != null &&
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
                                          .update(
                                              (state) => 'Bir Açıklama Seçin');
                                    });
                                  },
                                  child: Text('Açıklamayı Kaydet'))
                              : SizedBox() */
                        ],
                      ),
                    ),
                     */
              /* Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        LocaleKeys.fatura_aciklamasi.tr(),
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.headline5!.fontSize,
                            color: Colors.deepOrange),
                      ),
                      TextFormField(
                        controller: _yeniAciklamaController,
                        maxLines: 3,
                        decoration: InputDecoration(
                            label: Text(LocaleKeys.yeni_aciklama.tr()),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15))),
                      ),
                    ],
                  ),
                ),
              ), */
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Text(LocaleKeys.musteri_imzasi.tr(),
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.headline5!.fontSize,
                            color: Colors.deepOrange)),
                    Container(
                        child: SfSignaturePad(
                            key: signatureGlobalKey,
                            backgroundColor: Colors.white,
                            strokeColor: Colors.black,
                            minimumStrokeWidth: 1.0,
                            maximumStrokeWidth: 4.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                          color: Colors.grey,
                        ))),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: Text(LocaleKeys.temizle.tr()),
                          onPressed: _handleClearButtonPressed,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 20,
                      child: ElevatedButton(
                          onPressed: () {
                            _imzayiKaydet().then((value) {
                              firebasefaturayiYaz().then((value) {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AnaSayfa(),
                                    ),
                                    (route) => false);
                                ref
                                    .read(seciliAciklamaProvider.notifier)
                                    .update((state) =>
                                        LocaleKeys.bir_aciklama_secin.tr());
                                ref
                                    .read(tarihDatetimeProvider.notifier)
                                    .update((state) => null);
                              });
                            });
                          },
                          child: Text(LocaleKeys.faturayi_kaydet.tr()))),
                ),
              )
            ]),
          )),
    );
  }

  void _handleClearButtonPressed() async {
    signatureGlobalKey.currentState!.clear();
  }

  Future<void> _imzayiKaydet() async {
    final data =
        await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);

    debugPrint(data.toString());
    final bytes = await data.toByteData(format: ui.ImageByteFormat.png);
    var imza = String.fromCharCodes(
        bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));

    ref.read(imzaProvider.notifier).update((state) => imza);
  }

  /* void _showDialog(Widget child) {
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
 */
  /* Future<void> aciklamalariGetir() async {
    var aciklamalar = await _databaseHelper.aciklamalarigetir();
    ref.read(aciklamalarProvider.notifier).update((state) => [
          ...aciklamalar,
          {'aciklama': LocaleKeys.yeni_aciklama_ekle.tr()}
        ]);
  } */

  /* Future<void> aciklamaEkle() async {
    await _databaseHelper.aciklamaekle(_yeniAciklamaController.text.trim());
  } */

  
}
 */