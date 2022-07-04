import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/constants/description_controllers.dart';
import 'package:pdf_invoice/page/aciklama_ekle.dart';
import 'package:pdf_invoice/page/faturalarim.dart';
import '../provider/all_providers.dart';
import '../translations/locale_keys.g.dart';

class DescriptionAddPage extends ConsumerStatefulWidget {
  const DescriptionAddPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DescriptionAddPageState();
}

//final _formkey = GlobalKey<FormState>();

class _DescriptionAddPageState extends ConsumerState<DescriptionAddPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    urunleriGetir();
  }

  @override
  Widget build(BuildContext context) {
    Future(
      () {
        ref.read(toplamDegerleriProvider.notifier).update(
              (state) => toplamHesapla(ref),
            );
      },
    );

    //var eklenenUrunlerList = ref.watch(urunListesiProvider);
    /* Future(
      () {
        if (controllerMapList.isEmpty) {
          var a = [
            {
              'urunAdi': urunAdi,
              'urunMiktari': urunMiktari,
              'urunBirim': urunbirimi,
              'urunKDV': urunkdv
            }
          ];
          ref.read(controllerListProvider.notifier).update((state) => a);
        }
        return Future.value(true);
      },
    ); */

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(LocaleKeys.urun_ekle.tr()),
        ),
        body: Column(
          children: [
            /* SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      /* TextEditingController urunAdi1 = TextEditingController();
                      TextEditingController urunMiktari1 =
                          TextEditingController();
                      TextEditingController urunBirim1 = TextEditingController();
                      TextEditingController urunKDV1 = TextEditingController(); */
                      if (urunAdi.text.trim().isNotEmpty &&
                          urunMiktari.text.trim().isNotEmpty &&
                          urunBirim.text.trim().isNotEmpty &&
                          urunKDV.text.trim().isNotEmpty) {
                        var eklenenUrun = {
                          'urunAdi': urunAdi.text,
                          'urunMiktari': urunMiktari.text,
                          'urunBirim': urunBirim.text,
                          'urunKDV': urunKDV.text
                        };

                        ref
                            .read(urunListesiProvider.notifier)
                            .update((state) => [...state, eklenenUrun]);
                        urunAdi.text = '';
                        urunMiktari.text = '';
                        urunBirim.text = '';
                        urunKDV.text = '';
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Text('Alanlar boş bırakılamaz...'),
                        )));
                      }
                    },
                    child: Icon(Icons.add),
                  ),
                ],
              ),
            ), */

            SizedBox(
              height: MediaQuery.of(context).size.height / 20,
            ),
            //GRİ bar başlık
            Container(
              height: MediaQuery.of(context).size.height / 30,
              color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Expanded(
                      flex: 1,
                      //width: MediaQuery.of(context).size.width / 5,
                      child: SizedBox()),
                  Expanded(
                      flex: 3,
                      //width: MediaQuery.of(context).size.width / 5,
                      child: Center(
                        child: Text(
                          LocaleKeys.urun_adi.tr(),
                          textAlign: TextAlign.center,
                        ),
                      )),
                  Expanded(
                      flex: 3,
                      //width: MediaQuery.of(context).size.width / 5,
                      child: Center(
                        child: Text(
                          LocaleKeys.miktari.tr(),
                          textAlign: TextAlign.center,
                        ),
                      )),
                  Expanded(
                      flex: 3,
                      //width: MediaQuery.of(context).size.width / 5,
                      child: Center(
                        child: Text(
                          LocaleKeys.birim_fiyati.tr(),
                          textAlign: TextAlign.center,
                        ),
                      )),
                  Expanded(
                      flex: 3,
                      //width: MediaQuery.of(context).size.width / 5,
                      child: Center(
                        child: Text(
                          LocaleKeys.kdv.tr(),
                          textAlign: TextAlign.center,
                        ),
                      )),
                ],
              ),
            ),

            //ürünlerin listview
            Expanded(
              child: ListView.builder(
                itemCount: ref.watch(urunListesiProvider).length + 1,
                itemBuilder: (context, index) {
                  return index != ref.watch(urunListesiProvider).length
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                flex: 1,
                                //width: MediaQuery.of(context).size.width / 5,
                                child: Center(
                                    child: GestureDetector(
                                  onTap: () {
                                    urunCikar(index);
                                    /* setState(() {
                                      
                                    }); */
                                  },
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.deepOrange,
                                    child: Icon(Icons.remove),
                                  ),
                                ))),
                            Expanded(
                                flex: 3,
                                //width: MediaQuery.of(context).size.width / 4,
                                child: Center(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      ref.watch(urunListesiProvider)[index]
                                          ['urunAdi'],
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                  ),
                                )),
                            Expanded(
                                flex: 3,
                                //width: MediaQuery.of(context).size.width / 4,
                                child: Center(
                                  child: Text(
                                    ref.watch(urunListesiProvider)[index]
                                        ['urunMiktari'],
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                            Expanded(
                                flex: 3,
                                //width: MediaQuery.of(context).size.width / 4,
                                child: Center(
                                  child: Text(
                                    ref.watch(urunListesiProvider)[index]
                                        ['urunBirimi'],
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                            Expanded(
                                flex: 3,
                                //width: MediaQuery.of(context).size.width / 4,
                                child: Center(
                                  child: Text(
                                    ref.watch(urunListesiProvider)[index]
                                        ['urunKDV'],
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                          ],
                        )
                      : ref.watch(urunListesiProvider).isNotEmpty
                          ? Column(
                              children: [
                                const Divider(
                                  color: Colors.black,
                                  thickness: 1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3,
                                              child: Text(
                                                LocaleKeys.net_toplam.tr(),
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4,
                                              child: Text(
                                                '£ ${ref.watch(toplamDegerleriProvider)['toplam'] ?? 0}',
                                                textAlign: TextAlign.end,
                                              ))
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3,
                                              child: Text(
                                                '${LocaleKeys.kdv.tr()} %', //değişen kdv oranlarında burada yazılan da değişmeli, fakat bir faturada birden fazla farklı kdv oranı olursa nasıl olacak...
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4,
                                              child: Text(
                                                '£ ${ref.watch(toplamDegerleriProvider)['kdvToplam'] ?? 0}',
                                                textAlign: TextAlign.end,
                                              ))
                                        ],
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                7 /
                                                12,
                                        child: const Divider(
                                          thickness: 1,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3,
                                              child: Text(
                                                LocaleKeys.toplam_tutar.tr(),
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4,
                                              child: Text(
                                                '£ ${ref.watch(toplamDegerleriProvider)['kdvDahilToplam'] ?? 0}',
                                                textAlign: TextAlign.end,
                                              ))
                                        ],
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                7 /
                                                12,
                                        child: const Divider(
                                          thickness: 1,
                                          color: Colors.grey,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                          : const SizedBox();
                },
              ),
            ),

            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            //ürün girişi fieldlar + floatingactionbutton + kaydet butonu
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                children: [
                  Row(
                    children: [
                      //FloatingActionButonu...
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: FloatingActionButton(
                          heroTag: '0',
                          onPressed: () {
                            /* TextEditingController urunAdi1 = TextEditingController();
                      TextEditingController urunMiktari1 =
                          TextEditingController();
                      TextEditingController urunBirim1 = TextEditingController();
                      TextEditingController urunKDV1 = TextEditingController(); */
                            if (formkey.currentState!.validate()) {
                              var eklenenUrun = {
                                'urunAdi': urunAdi.text.trim(),
                                'urunMiktari': urunMiktari.text.trim(),
                                'urunBirimi': urunBirimi.text.trim(),
                                'urunKDV': urunKDV.text.trim()
                              };

                              ref
                                  .read(urunListesiProvider.notifier)
                                  .update((state) => [...state, eklenenUrun]);
                              ref
                                  .read(toplamDegerleriProvider.notifier)
                                  .update((state) => toplamHesapla(ref));
                              urunAdi.text = '';
                              urunMiktari.text = '';
                              urunBirimi.text = '';
                              urunKDV.text = '';
                            } /* else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      content: Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom),
                                child: Text(
                                    LocaleKeys.alanlar_bos_birakilamaz.tr()),
                              )));
                            } */
                          },
                          child: const Icon(Icons.add),
                        ),
                      ),
                      //Ürün girişi textformfieldlar
                      Expanded(
                        child: DescriptionWidget(
                          ref: ref,
                        ),
                      )
                    ],
                  ),
                  //En alttaki kaydet butonu
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            onPressed: () {
                              if (ref.watch(urunListesiProvider).isNotEmpty) {
                                if (formkey.currentState!.validate()) {
                                  var eklenenUrun = {
                                    'urunAdi': urunAdi.text.trim(),
                                    'urunMiktari': urunMiktari.text.trim(),
                                    'urunBirimi': urunBirimi.text.trim(),
                                    'urunKDV': urunKDV.text.trim()
                                  };

                                  ref.read(urunListesiProvider.notifier).update(
                                      (state) => [...state, eklenenUrun]);
                                  ref
                                      .read(toplamDegerleriProvider.notifier)
                                      .update((state) => toplamHesapla(ref));
                                  urunAdi.text = '';
                                  urunMiktari.text = '';
                                  urunBirimi.text = '';
                                  urunKDV.text = '';
                                }
                                faturayiFirebaseYazmakIcinMap(ref);
                                /* Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Faturalarim(),
                                    )); */
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AciklamaEkle(),
                                    ));
                                ref
                                    .read(radioFaturaProvider.notifier)
                                    .update((state) => null);
                                /* Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FaturaSayfasi(),
                                    )); */
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        content: Padding(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  child: Text(LocaleKeys
                                      .bos_fatura_olusturulamaz_urun_girin
                                      .tr()),
                                )));
                              }
                            },
                            child: Text(LocaleKeys.kaydet.tr()))),
                  ),
                ],
              ),
            ),

            /* Expanded(
              flex: 2,
              //height: MediaQuery.of(context).size.height * 0.65,
              child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    children: [
                      
                    ],
                  ) /* ListView.builder(
                  itemCount:
                      controllerMapList.isEmpty ? 1 : controllerMapList.length,
                  itemBuilder: (context, index) {
                    return controllerMapList.isEmpty
                        ? Text('Ürün Yok')
                        : 
                  },
                ), */
                  ),
            ), */
          ],
        ));
  }

  Map<String, dynamic> toplamHesapla(WidgetRef ref) {
    var faturaElemanlariListesi = ref.watch(urunListesiProvider);
    if (faturaElemanlariListesi.isNotEmpty) {
      double toplam = 0;
      double kdvToplam = 0;
      double kdvDahilToplam = 0;

      for (var item in faturaElemanlariListesi) {
        toplam += double.parse(item['urunMiktari']) *
            double.parse(item['urunBirimi']);
        kdvToplam += double.parse(item['urunMiktari']) *
            double.parse(item['urunBirimi']) *
            double.parse(item['urunKDV']) /
            100;
      }
      kdvDahilToplam = toplam + kdvToplam;
      return {
        'toplam': toplam,
        'kdvToplam': kdvToplam,
        'kdvDahilToplam': kdvDahilToplam
      };
    } else {
      return {'toplam': '', 'kdvToplam': '', 'kdvDahilToplam': ''};
    }
  }

  void faturayiFirebaseYazmakIcinMap(WidgetRef ref) async {
    Map<String, dynamic> eklenecekFatura = {
      'createdAt': ref.watch(tarihDatetimeProvider),
      'aliciAdi': ref.watch(gecerliMusteri)['adi'],
      'aliciAdresi': ref.watch(gecerliMusteri)['adresi'],
      'aliciEmail': ref.watch(gecerliMusteri)['email'],
      'aliciTelefon': ref.watch(gecerliMusteri)['telefon'],
      'faturaNo': ref.watch(faturaNoProvider),
      'faturaTarihi': ref.watch(tarihProvider),
      'faturaToplami':
          ref.watch(toplamDegerleriProvider)['kdvDahilToplam'].toString(),
      'urunler': [for (var item in ref.watch(urunListesiProvider)) item]
    };

    ref
        .read(yazilacakFaturaMapProvider.notifier)
        .update((state) => eklenecekFatura);

    ref.read(urunListesiProvider.notifier).update((state) => []);
  }

  void urunCikar(int index) {
    var urunListesi = ref.watch(urunListesiProvider);
    var silinecekEleman = ref.watch(urunListesiProvider)[index];
    List<Map<String, dynamic>> guncelUrunListesi = [];
    for (var item in urunListesi) {
      item == silinecekEleman ? null : guncelUrunListesi.add(item);
    }
    ref.read(urunListesiProvider.notifier).update((state) => guncelUrunListesi);
  }

  Future<void> urunleriGetir() async {
    var urunler = await _firestore
        .collection(_auth.currentUser!.email!)
        .doc('saticiFirma')
        .collection('urunler')
        .doc('urunler')
        .get();
    if (urunler.data() == null) {
      ref
          .read(urunlerProvider.notifier)
          .update((state) => ['', LocaleKeys.yeni_urun_ekle.tr()]);
    } else {
      ref
          .read(urunlerProvider.notifier)
          .update((state) => [...urunler.data()!['urunler'], LocaleKeys.yeni_urun_ekle.tr()]);
    }

    /* var urunler = await _databaseHelper.urunlerigetir();
    if (urunler.isEmpty) {
      ref.read(urunlerProvider.notifier).update((state) => [
            ...urunler,
            {'urunAdi': ''},
            {'urunAdi': 'Yeni Ürün Ekle'}
          ]);
    } else {
      ref.read(urunlerProvider.notifier).update((state) => [
            ...urunler,
            {'urunAdi': 'Yeni Ürün Ekle'}
          ]);
    } */
  }
}

const double _kItemExtent = 50.0;

class DescriptionWidget extends StatefulWidget {
  DescriptionWidget({Key? key, required this.ref}) : super(key: key);
  WidgetRef ref;

  @override
  State<DescriptionWidget> createState() => _DescriptionWidgetState();
}

class _DescriptionWidgetState extends State<DescriptionWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final double _kItemExtent = 50.0;
  int _seciliUrun = 0;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formkey,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: TextFormField(
                  onTap: () {
                    _showDialog(
                      CupertinoPicker(
                        magnification: 1,
                        squeeze: 1.2,
                        useMagnifier: true,
                        itemExtent: _kItemExtent,
                        onSelectedItemChanged: (int selectedItem) {
                          setState(() {
                            _seciliUrun = selectedItem;
                          });
                          widget.ref.read(seciliUrunProvider.notifier).update(
                              (state) => widget.ref
                                  .watch(urunlerProvider)[selectedItem]);
                          urunAdi.text = widget.ref.watch(seciliUrunProvider) !=
                                  null
                              ? widget.ref.watch(seciliUrunProvider)!
                              : widget.ref.watch(urunlerProvider)[_seciliUrun];
                          if (widget.ref.watch(urunlerProvider)[_seciliUrun] ==
                              LocaleKeys.yeni_urun_ekle.tr()) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(LocaleKeys.yeni_urun_ekle.tr()),
                                content: Form(
                                    key: yeniUrunFormKey,
                                    child: TextFormField(
                                      controller: yeniUrunController,
                                      decoration: InputDecoration(
                                          label: Text(LocaleKeys.yeni_urun_adi.tr()),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20))),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return LocaleKeys.urun_ismi_bos_birakilamaz.tr();
                                        } else {
                                          return null;
                                        }
                                      },
                                    )),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        yeniUrunController.clear();
                                        Navigator.pop(context);
                                      },
                                      child: Text(LocaleKeys.vazgec.tr())),
                                  ElevatedButton(
                                      onPressed: () async {
                                        if (yeniUrunFormKey.currentState!
                                            .validate()) {
                                          var liste =
                                              widget.ref.watch(urunlerProvider);
                                          liste.contains('')
                                              ? liste.remove('')
                                              : null;
                                          liste.contains(LocaleKeys.yeni_urun_ekle.tr())
                                              ? liste.remove(LocaleKeys.yeni_urun_ekle.tr())
                                              : null;

                                          await _firestore
                                              .collection(
                                                  _auth.currentUser!.email!)
                                              .doc('saticiFirma')
                                              .collection('urunler')
                                              .doc('urunler')
                                              .set({
                                            'urunler': [
                                              ...liste,
                                              yeniUrunController.text.trim()
                                            ]
                                          }).then((value) async {
                                            var urunler = await _firestore
                                                .collection(
                                                    _auth.currentUser!.email!)
                                                .doc('saticiFirma')
                                                .collection('urunler')
                                                .doc('urunler')
                                                .get();
                                            widget.ref
                                                .read(urunlerProvider.notifier)
                                                .update((state) => [
                                                      ...urunler
                                                          .data()!['urunler'],
                                                      LocaleKeys.yeni_urun_ekle.tr()
                                                    ]);
                                            setState(() {
                                              _seciliUrun = widget.ref
                                                      .watch(urunlerProvider)
                                                      .length -
                                                  2;
                                            });
                                            widget.ref
                                                .read(
                                                    seciliUrunProvider.notifier)
                                                .update((state) => widget.ref
                                                        .watch(urunlerProvider)[
                                                    _seciliUrun]);
                                            urunAdi.text = widget.ref.watch(
                                                        seciliUrunProvider) !=
                                                    null
                                                ? widget.ref
                                                    .watch(seciliUrunProvider)!
                                                : widget.ref
                                                        .watch(urunlerProvider)[
                                                    _seciliUrun];
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            yeniUrunController.clear();
                                          });

                                          /* await _databaseHelper
                                              .urunekle(yeniUrunController.text
                                                  .trim())
                                              .then((value) async {
                                            var urunler = await _databaseHelper
                                                .urunlerigetir();
                                            widget.ref
                                                .read(urunlerProvider.notifier)
                                                .update((state) => [
                                                      ...urunler,
                                                      {
                                                        'urunAdi':
                                                            'Yeni Ürün Ekle'
                                                      }
                                                    ]);
                                            setState(() {
                                              _seciliUrun = urunler.length - 1;
                                            });
                                            widget.ref
                                                .read(
                                                    seciliUrunProvider.notifier)
                                                .update((state) => widget.ref
                                                        .watch(urunlerProvider)[
                                                    selectedItem]['urunAdi']);
                                            urunAdi.text = widget.ref.watch(
                                                        seciliUrunProvider) !=
                                                    null
                                                ? widget.ref
                                                    .watch(seciliUrunProvider)!
                                                : widget.ref
                                                        .watch(urunlerProvider)[
                                                    _seciliUrun]['urunAdi'];
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            yeniUrunController.clear();
                                          }); */
                                        }
                                      },
                                      child: Text(LocaleKeys.kaydet.tr())),
                                ],
                              ),
                            );
                          }
                        },
                        children: List<Widget>.generate(
                            widget.ref.watch(urunlerProvider).length,
                            (int index) {
                          return Center(
                            child: index ==
                                    widget.ref.watch(urunlerProvider).length - 1
                                ? Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add),
                                        Text(
                                          widget.ref
                                              .watch(urunlerProvider)[index],
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Center(
                                        child: Text(
                                          widget.ref
                                              .watch(urunlerProvider)[index],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ),
                          );
                        }),
                      ),
                    );
                  },
                  controller: urunAdi,
                  readOnly: true,
                  decoration: InputDecoration(
                      label: Text(LocaleKeys.urun_adi.tr()),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15))),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return LocaleKeys.bos_birakilamaz.tr();
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: urunMiktari,
                  decoration: InputDecoration(
                      label: Text(LocaleKeys.urun_miktari.tr()),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15))),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return LocaleKeys.bos_birakilamaz.tr();
                    } else {
                      return null;
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: urunBirimi,
                  decoration: InputDecoration(
                      label: Text(LocaleKeys.urun_birim_fiyati.tr()),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15))),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return LocaleKeys.bos_birakilamaz.tr();
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: urunKDV,
                  decoration: InputDecoration(
                      label: Text('${LocaleKeys.urun_kdv.tr()} %'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15))),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return LocaleKeys.bos_birakilamaz.tr();
                    } else {
                      return null;
                    }
                  },
                ),
              ),
            ],
          ),
          /* SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ), */
        ],
      ),
    );
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              color: CupertinoColors.systemBackground.resolveFrom(context),
              child: SafeArea(
                top: false,
                child: child,
              ),
            ));
  }
}
