import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/contoller/description_controllers.dart';
import 'package:pdf_invoice/page/home_page.dart';
import 'package:pdf_invoice/page/tarih_sec.dart';

import '../api/pdf_api.dart';
import '../api/pdf_invoice_api.dart';
import '../model/customer.dart';
import '../model/invoice.dart';
import '../model/supplier.dart';
import '../widget/button_widget.dart';

import 'alici_sec.dart';
import 'anasayfa.dart';

final descCounterProvider = StateProvider<int>(
  (ref) => 1,
);
final urunListesiProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) {
    return [];
  },
);

final toplamDegerleriProvider = StateProvider<Map<String, dynamic>>(
  (ref) {
    var faturaElemanlariListesi = ref.watch(urunListesiProvider);
    if (faturaElemanlariListesi.isNotEmpty) {
      double toplam = 0;
      double kdvToplam = 0;
      double kdvDahilToplam = 0;

      for (var item in faturaElemanlariListesi) {
        toplam +=
            double.parse(item['urunMiktari']) * double.parse(item['urunBirim']);
        kdvToplam += double.parse(item['urunMiktari']) *
            double.parse(item['urunBirim']) *
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
  },
);

class DescriptionAddPage extends ConsumerWidget {
  const DescriptionAddPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var eklenenUrunlerList = ref.watch(urunListesiProvider);
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
          title: Text('Description Add'),
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
                  SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Center(
                        child: Text(
                          'Ürün Adı:',
                          textAlign: TextAlign.center,
                        ),
                      )),
                  SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Center(
                        child: Text(
                          'Miktarı:',
                          textAlign: TextAlign.center,
                        ),
                      )),
                  SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Center(
                        child: Text(
                          'Birim Fiyatı:',
                          textAlign: TextAlign.center,
                        ),
                      )),
                  SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
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
                            SizedBox(
                                width: MediaQuery.of(context).size.width / 4,
                                child: Center(
                                  child: Text(
                                    ref.watch(urunListesiProvider)[index]
                                        ['urunAdi'],
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                            SizedBox(
                                width: MediaQuery.of(context).size.width / 4,
                                child: Center(
                                  child: Text(
                                    ref.watch(urunListesiProvider)[index]
                                        ['urunMiktari'],
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                            SizedBox(
                                width: MediaQuery.of(context).size.width / 4,
                                child: Center(
                                  child: Text(
                                    ref.watch(urunListesiProvider)[index]
                                        ['urunBirim'],
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                            SizedBox(
                                width: MediaQuery.of(context).size.width / 4,
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
                                Divider(
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
                                              child: Text(
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
                                        child: Divider(
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
                                        child: Divider(
                                          thickness: 1,
                                          color: Colors.grey,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                          : SizedBox();
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
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      content: Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom),
                                child: Text('Alanlar boş bırakılamaz...'),
                              )));
                            }
                          },
                          child: Icon(Icons.add),
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FaturaSayfasi(),
                                    ));
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
                            child: Text('Kaydet'))),
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
                    label: Text('Ürün Adı'),
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
                    label: Text('Ürün Miktarı'),
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
                controller: urunBirim,
                decoration: InputDecoration(
                    label: Text('Ürün Birim Fiyatı'),
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
                    label: Text('Ürün KDV %'),
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

class FaturaSayfasi extends ConsumerWidget {
  FaturaSayfasi({Key? key}) : super(key: key);

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> bankaBilgileri = {};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future(
      () async {
        var saticiFirma = await _firestore
            .collection(ref.watch(saticiAdi))
            .doc('saticiFirma')
            .get();
        return saticiFirma;
      },
    ).then((value) {
      var satici = value.data();
      bankaBilgileri = {
        'accountName': satici!['bankaAccountName'],
        'sortCode': satici['bankaSortCode'],
        'accountNumber': satici['bankaAccountNumber']
      };
    });
    return Scaffold(
      appBar: AppBar(title: Text('Fatura Oluşturma')),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              Map<String, dynamic> satici = {};
              for (var item in ref.watch(provider)) {
                item.id == 'saticiFirma' ? satici = item.data() : null;
              }

              final date = DateTime.now();
              final dueDate = date.add(const Duration(days: 7));

              final invoice = Invoice(
                supplier: Supplier(
                  name: satici['adi'],
                  address: satici['adresi'],
                  paymentInfo: 'https://paypal.me/sarahfieldzz',
                ),
                customer: Customer(
                  name: ref.watch(gecerliMusteri)['adi'],
                  address: ref.watch(gecerliMusteri)['adresi'],
                ),
                info: InvoiceInfo(
                  date: ref.watch(tarihProvider),
                  //dueDate: dueDate,
                  description: ref.watch(aciklamaProvider) ?? '',
                  //number: '${DateTime.now().year}-9999',
                ),
                items: [
                  for (var item in ref.watch(urunListesiProvider))
                    InvoiceItem(
                      description: item['urunAdi']!,
                      //date: DateTime.now(),
                      quantity: int.parse(item['urunMiktari']!),
                      vat: double.parse(item['urunKDV']!),
                      unitPrice: double.parse(item['urunBirim']!),
                    ),
                  /* InvoiceItem(
                              description: 'Water',
                              date: DateTime.now(),
                              quantity: 8,
                              vat: 0.19,
                              unitPrice: 0.99,
                            ),
                            InvoiceItem(
                              description: 'Orange',
                              date: DateTime.now(),
                              quantity: 3,
                              vat: 0.19,
                              unitPrice: 2.99,
                            ),
                            InvoiceItem(
                              description: 'Apple',
                              date: DateTime.now(),
                              quantity: 8,
                              vat: 0.19,
                              unitPrice: 3.99,
                            ),
                            InvoiceItem(
                              description: 'Mango',
                              date: DateTime.now(),
                              quantity: 1,
                              vat: 0.19,
                              unitPrice: 1.59,
                            ),
                            InvoiceItem(
                              description: 'Blue Berries',
                              date: DateTime.now(),
                              quantity: 5,
                              vat: 0.19,
                              unitPrice: 0.99,
                            ),
                            InvoiceItem(
                              description: 'Lemon',
                              date: DateTime.now(),
                              quantity: 4,
                              vat: 0.19,
                              unitPrice: 1.29,
                            ), */
                ],
              );

              final pdfFile = await PdfSayfaFormati.generate(
                  invoice, ref.watch(tarihProvider), bankaBilgileri);

              PdfApi.openFile(pdfFile);
            },
            child: Text('Faturayı Oluştur')),
      ),
    );
  }
}
