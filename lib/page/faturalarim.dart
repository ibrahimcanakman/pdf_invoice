import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/database_helper.dart';
import 'package:pdf_invoice/page/anasayfa.dart';
import 'package:pdf_invoice/page/description_add_page.dart';

import '../api/pdf_api.dart';
import '../api/pdf_invoice_api.dart';
import '../model/customer.dart';
import '../model/invoice.dart';
import '../model/supplier.dart';
import '../provider/all_providers.dart';
import 'alici_sec.dart';
import 'home_page.dart';

class Faturalarim extends ConsumerStatefulWidget {
  const Faturalarim({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FaturalarimState();
}

class _FaturalarimState extends ConsumerState<Faturalarim> {
  final _saticiKey = GlobalKey<FormState>();
  TextEditingController _saticiAdiController = TextEditingController();
  TextEditingController _saticiAdresiController = TextEditingController();
  TextEditingController _saticiTelefonController = TextEditingController();
  TextEditingController _saticiEmailController = TextEditingController();
  TextEditingController _bankaAccountNameController = TextEditingController();
  TextEditingController _bankaSortCodeController = TextEditingController();
  TextEditingController _bankaAccountNumberController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    faturalariGetir();
    super.initState();
  }

  faturalariGetir() async {
    var value = await _databaseHelper.getir();
    ref
        .read(saticiAdi.notifier)
        .update((state) => value.first['firmaAdi'].toString());
    var gelenFaturalarSS = await _firestore
        .collection(value.first['firmaAdi'].toString())
        .doc('saticiFirma')
        .collection('faturalar')
        .get();
    var gelenFaturalarListesi = gelenFaturalarSS.docs;
    gelenFaturalarListesi
        .sort((a, b) => int.parse(b.id).compareTo(int.parse(a.id)));
    ref
        .read(faturalarProvider.notifier)
        .update((state) => gelenFaturalarListesi);
  }

  @override
  Widget build(BuildContext context) {
    //faturalariGetir();
    
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AnaSayfa(),
            ),
            (route) => false);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Faturalarım'),
        ),
        bottomNavigationBar: Visibility(
          visible: ref.watch(radioProvider) != null,
          child: BottomNavigationBar(
              selectedItemColor: Colors.deepOrange,
              unselectedItemColor: Colors.deepOrange,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              currentIndex: 0,
              onTap: (index) {
                switch (index) {
                  case 0:
                    pdfGoruntule();
                    debugPrint('0 tıklandı');
                    break;
                  case 1:
                    faturaDuzenle();
                    debugPrint('1 tıklandı');
                    break;
                  case 2:
                    //faturaGonder();
                    debugPrint('2 tıklandı');
                    break;
                  default:
                }
              },
              items: const [
                BottomNavigationBarItem(
                    label: 'Görüntüle', icon: Icon(Icons.picture_as_pdf)),
                BottomNavigationBarItem(
                    label: 'Düzenle', icon: Icon(Icons.edit_note_sharp)),
                BottomNavigationBarItem(
                    label: 'Gönder', icon: Icon(Icons.share)),
              ]),
        ),
        body: ref.watch(faturalarProvider).isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Future(
                        () async {
                          var value = await _databaseHelper.getir();
                          return value;
                        },
                      ).then((value) async {
                        if (value.isEmpty) {
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Kayıt Ol'),
                                content: Form(
                                    key: _saticiKey,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                              'İlk girişiniz olduğu için faturalarda kullanılmak üzere firmanızın bilgilerini bir kereliğine kaydetmelisiniz ! '),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                50,
                                          ),
                                          TextFormField(
                                            controller: _saticiAdiController,
                                            validator: (value) {
                                              if (value!.trim().isEmpty) {
                                                return 'Boş bırakılamaz...';
                                              } else {
                                                return null;
                                              }
                                            },
                                            decoration: InputDecoration(
                                                label: Text('Firma Adı'),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15))),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  50),
                                          TextFormField(
                                            controller: _saticiAdresiController,
                                            validator: (value) {
                                              if (value!.trim().isEmpty) {
                                                return 'Boş bırakılamaz...';
                                              } else {
                                                return null;
                                              }
                                            },
                                            decoration: InputDecoration(
                                                label: Text('Firma Adresi'),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15))),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  50),
                                          TextFormField(
                                            controller:
                                                _saticiTelefonController,
                                            validator: (value) {
                                              if (value!.trim().isEmpty) {
                                                return 'Boş bırakılamaz...';
                                              } else {
                                                return null;
                                              }
                                            },
                                            decoration: InputDecoration(
                                                label: Text('Telefon'),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15))),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  50),
                                          TextFormField(
                                            controller: _saticiEmailController,
                                            validator: (value) {
                                              if (value!.trim().isEmpty) {
                                                return 'Boş bırakılamaz...';
                                              } else {
                                                return null;
                                              }
                                            },
                                            decoration: InputDecoration(
                                                label: Text('E-Mail'),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15))),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  50),
                                          TextFormField(
                                            controller:
                                                _bankaAccountNameController,
                                            validator: (value) {
                                              if (value!.trim().isEmpty) {
                                                return 'Boş bırakılamaz...';
                                              } else {
                                                return null;
                                              }
                                            },
                                            decoration: InputDecoration(
                                                label:
                                                    Text('Bank Account Name'),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15))),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  50),
                                          TextFormField(
                                            controller:
                                                _bankaSortCodeController,
                                            validator: (value) {
                                              if (value!.trim().isEmpty) {
                                                return 'Boş bırakılamaz...';
                                              } else {
                                                return null;
                                              }
                                            },
                                            decoration: InputDecoration(
                                                label: Text('Bank Sort Code'),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15))),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  50),
                                          TextFormField(
                                            controller:
                                                _bankaAccountNumberController,
                                            validator: (value) {
                                              if (value!.trim().isEmpty) {
                                                return 'Boş bırakılamaz...';
                                              } else {
                                                return null;
                                              }
                                            },
                                            decoration: InputDecoration(
                                                label:
                                                    Text('Bank Account Number'),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15))),
                                          ),
                                        ],
                                      ),
                                    )),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Vazgeç'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  ElevatedButton(
                                      onPressed: () async {
                                        if (_saticiKey.currentState!
                                            .validate()) {
                                          Map<String, dynamic> firmaBilgileri =
                                              {
                                            'adi': _saticiAdiController.text,
                                            'adresi':
                                                _saticiAdresiController.text,
                                            'email':
                                                _saticiEmailController.text,
                                            'telefon':
                                                _saticiTelefonController.text,
                                            'bankaAccountName':
                                                _bankaAccountNameController
                                                    .text,
                                            'bankaSortCode':
                                                _bankaSortCodeController.text,
                                            'bankaAccountNumber':
                                                _bankaAccountNumberController
                                                    .text
                                          };
                                          await _databaseHelper.kaydet(
                                              _saticiAdiController.text);
                                          Future(
                                            () {
                                              _firestore
                                                  .collection(
                                                      _saticiAdiController.text)
                                                  .doc('saticiFirma')
                                                  .set(firmaBilgileri);
                                            },
                                          ).then((value) {
                                            ref.read(saticiAdi.notifier).update(
                                                (state) =>
                                                    _saticiAdiController.text);
                                            Navigator.pop(context);
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Padding(
                                            padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom,
                                            ),
                                            child:
                                                Text('Eksik bilgi girdiniz...'),
                                          )));
                                        }
                                      },
                                      child: Text('KAYDET'))
                                ],
                              );
                            },
                          );
                        } else {
                          ref.read(saticiAdi.notifier).update(
                              (state) => value.first['firmaAdi'].toString());
                          var gelenBilgi = await _firestore
                              .collection(value.first['firmaAdi'].toString())
                              .get();

                          ref
                              .read(provider.notifier)
                              .update((state) => gelenBilgi.docs);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AliciSec(),
                              ));
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Icon(
                          Icons.add_circle,
                          color: Colors.deepOrange,
                          size: 30,
                        ),
                        Text(
                          'Yeni Fatura Ekle',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ref.watch(faturalarProvider).length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ListTile(
                              onTap: () {
                                ref
                                    .read(radioProvider.notifier)
                                    .update((state) => index);
                                ref.read(seciliFaturaProvider.notifier).update(
                                    (state) => ref
                                        .watch(faturalarProvider)[index]
                                        .data());
                              },
                              leading: Radio(
                                value: index,
                                groupValue: ref.watch(radioProvider),
                                onChanged: (int? yeniDeger) {
                                  ref
                                      .read(radioProvider.notifier)
                                      .update((state) => index);
                                  ref
                                      .read(seciliFaturaProvider.notifier)
                                      .update((state) => ref
                                          .watch(faturalarProvider)[index]
                                          .data());
                                },
                              ),
                              title: Text(ref
                                  .watch(faturalarProvider)[index]
                                  .data()['aliciAdi']),
                              subtitle: Text(ref
                                  .watch(faturalarProvider)[index]
                                  .data()['faturaTarihi']),
                              trailing: Text(
                                  '£ ${ref.watch(faturalarProvider)[index].data()['faturaToplami']}'),
                            ),
                            const Divider(
                              height: 0,
                              thickness: 1,
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void pdfGoruntule() async {
    var saticiBilgileriSS = await _firestore
        .collection(ref.watch(saticiAdi).toString())
        .doc('saticiFirma')
        .get();
    var saticiBilgileriMap = saticiBilgileriSS.data();

    Map<String, dynamic> bankaBilgileri = {
      'accountName': saticiBilgileriMap!['bankaAccountName'],
      'sortCode': saticiBilgileriMap['bankaSortCode'],
      'accountNumber': saticiBilgileriMap['bankaAccountNumber']
    };

    final invoice = Invoice(
      supplier: Supplier(
        name: saticiBilgileriMap['adi'],
        address: saticiBilgileriMap['adresi'],
      ),
      customer: Customer(
        name: ref.watch(seciliFaturaProvider)['aliciAdi'],
        address: ref.watch(seciliFaturaProvider)['aliciAdresi'],
      ),
      info: InvoiceInfo(
        date: ref.watch(seciliFaturaProvider)['faturaTarihi'],
        description: '',
      ),
      items: [
        for (var item in ref.watch(seciliFaturaProvider)['urunler'])
          InvoiceItem(
            description: item['urunAdi']!,
            quantity: int.parse(item['urunMiktari']!),
            vat: double.parse(item['urunKDV']!),
            unitPrice: double.parse(item['urunBirimi']!),
          ),
      ],
    );

    final pdfFile = await PdfSayfaFormati.generate(
        invoice,
        ref.watch(seciliFaturaProvider)['faturaTarihi'],
        ref.watch(seciliFaturaProvider)['faturaNo'],
        bankaBilgileri);

    PdfApi.openFile(pdfFile);
  }

  void faturaDuzenle() async {
    List<Map<String, dynamic>> urunler = [];
    for (var item in ref.watch(seciliFaturaProvider)['urunler']) {
      var eklenecekUrun = {
        'urunAdi': item['urunAdi'],
        'urunMiktari': item['urunMiktari'],
        'urunBirimi': item['urunBirimi'],
        'urunKDV': item['urunKDV'],
      };
      urunler.add(eklenecekUrun);
    }

    ref.read(urunListesiProvider.notifier).update((state) => urunler);
    ref.read(gecerliMusteri.notifier).update((state) => {
          'adi': ref.watch(seciliFaturaProvider)['aliciAdi'],
          'adresi': ref.watch(seciliFaturaProvider)['aliciAdresi'],
          'email': '',
          'telefon': ''
        });
    ref
        .read(faturaNoProvider.notifier)
        .update((state) => ref.watch(seciliFaturaProvider)['faturaNo']);
    ref
        .read(tarihProvider.notifier)
        .update((state) => ref.watch(seciliFaturaProvider)['faturaTarihi']);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DescriptionAddPage(),
        ));
  }
}
