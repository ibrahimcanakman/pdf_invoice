import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/contoller/description_controllers.dart';
import 'package:pdf_invoice/page/faturalarim.dart';
import '../provider/all_providers.dart';

class DescriptionAddPage extends ConsumerStatefulWidget {
  const DescriptionAddPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DescriptionAddPageState();
}

class _DescriptionAddPageState extends ConsumerState<DescriptionAddPage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          title: const Text('Description Add'),
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
                children: const [
                  Expanded(
                      flex: 1,
                      //width: MediaQuery.of(context).size.width / 5,
                      child: SizedBox()),
                  Expanded(
                      flex: 3,
                      //width: MediaQuery.of(context).size.width / 5,
                      child: Center(
                        child: Text(
                          'Ürün Adı:',
                          textAlign: TextAlign.center,
                        ),
                      )),
                  Expanded(
                      flex: 3,
                      //width: MediaQuery.of(context).size.width / 5,
                      child: Center(
                        child: Text(
                          'Miktarı:',
                          textAlign: TextAlign.center,
                        ),
                      )),
                  Expanded(
                      flex: 3,
                      //width: MediaQuery.of(context).size.width / 5,
                      child: Center(
                        child: Text(
                          'Birim Fiyatı:',
                          textAlign: TextAlign.center,
                        ),
                      )),
                  Expanded(
                      flex: 3,
                      //width: MediaQuery.of(context).size.width / 5,
                      child: Center(
                        child: Text(
                          'KDV:',
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
                                  child: Text(
                                    ref.watch(urunListesiProvider)[index]
                                        ['urunAdi'],
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
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
                                              child: const Text(
                                                'Net total',
                                                style: TextStyle(
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
                                              child: const Text(
                                                'Vat 18 %',
                                                style: TextStyle(
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
                                              child: const Text(
                                                'Total amount due',
                                                style: TextStyle(
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
                            if (urunAdi.text.trim().isNotEmpty &&
                                urunMiktari.text.trim().isNotEmpty &&
                                urunBirimi.text.trim().isNotEmpty &&
                                urunKDV.text.trim().isNotEmpty) {
                              var eklenenUrun = {
                                'urunAdi': urunAdi.text,
                                'urunMiktari': urunMiktari.text,
                                'urunBirimi': urunBirimi.text,
                                'urunKDV': urunKDV.text
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
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      content: Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom),
                                child: const Text('Alanlar boş bırakılamaz...'),
                              )));
                            }
                          },
                          child: const Icon(Icons.add),
                        ),
                      ),
                      //Ürün girişi textformfieldlar
                      const Expanded(child: DescriptionWidget()),
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
                                faturayiFirebaseYaz(ref);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Faturalarim(),
                                    ));
                                ref
                                    .read(radioProvider.notifier)
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
                                  child: const Text(
                                      'Boş fatura oluşturulamaz, ürün girin...'),
                                )));
                              }
                            },
                            child: const Text('Kaydet'))),
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

  void faturayiFirebaseYaz(WidgetRef ref) async {
    Map<String, dynamic> eklenecekFatura = {
      'aliciAdi': ref.watch(gecerliMusteri)['adi'],
      'aliciAdresi': ref.watch(gecerliMusteri)['adresi'],
      'faturaNo': ref.watch(faturaNoProvider),
      'faturaTarihi': ref.watch(tarihProvider),
      'faturaToplami':
          ref.watch(toplamDegerleriProvider)['kdvDahilToplam'].toString(),
      'urunler': [for (var item in ref.watch(urunListesiProvider)) item]
    };

    await _firestore
        .collection(ref.watch(saticiAdi))
        .doc('saticiFirma')
        .collection('faturalar')
        .doc(ref.watch(faturaNoProvider))
        .set(eklenecekFatura);
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
}

class DescriptionWidget extends StatelessWidget {
  const DescriptionWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Form(
                child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              child: TextFormField(
                controller: urunAdi,
                decoration: InputDecoration(
                    label: const Text('Ürün Adı'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            )),
            Form(
                child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: urunMiktari,
                decoration: InputDecoration(
                    label: const Text('Ürün Miktarı'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            )),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Form(
                child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: urunBirimi,
                decoration: InputDecoration(
                    label: const Text('Ürün Birim Fiyatı'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            )),
            Form(
                child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: urunKDV,
                decoration: InputDecoration(
                    label: const Text('Ürün KDV %'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            )),
          ],
        ),
        /* SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ), */
      ],
    );
  }
}
