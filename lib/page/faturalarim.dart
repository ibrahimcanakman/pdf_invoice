import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/hotmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_invoice/api/pdf_invoice1.dart';
import 'package:pdf_invoice/api/pdf_invoice2.dart';
import 'package:pdf_invoice/page/anasayfa.dart';
import 'package:pdf_invoice/page/urun_ekleme_page.dart';

import '../api/pdf_api.dart';
import '../api/pdf_invoice_api.dart';
import '../constants/constant.dart';
import '../model/customer.dart';
import '../model/invoice.dart';
import '../model/supplier.dart';
import '../provider/all_providers.dart';
import '../translations/locale_keys.g.dart';
import 'alici_sec.dart';
import 'coklu_fatura_gonder.dart';

class Faturalarim extends ConsumerStatefulWidget {
  const Faturalarim({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FaturalarimState();
}

class _FaturalarimState extends ConsumerState<Faturalarim> {
  /* final _saticiKey = GlobalKey<FormState>();
  final TextEditingController _saticiAdiController = TextEditingController();
  final TextEditingController _saticiAdresiController = TextEditingController();
  final TextEditingController _saticiTelefonController = TextEditingController();
  final TextEditingController _saticiEmailController = TextEditingController();
  final TextEditingController _bankaAccountNameController = TextEditingController();
  final TextEditingController _bankaSortCodeController = TextEditingController();
  final TextEditingController _bankaAccountNumberController = TextEditingController(); */
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //DatabaseHelper _databaseHelper = DatabaseHelper();
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? faturalar;

  //String saticiFirmaAdi = '';

  @override
  void initState() {
    //faturalariGetir();
    //mailBilgisiGetir();
    super.initState();
  }
  /* saticiFirmaGetir() async {
    var saticiFirma = await _databaseHelper.getir();
    saticiFirmaAdi = saticiFirma.first['firmaAdi'].toString();
  } */

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const AnaSayfa(),
            ),
            (route) => false);
        ref.read(radioFaturaProvider.notifier).update((state) => null);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.faturalarim.tr()),
        ),

        //bottom nav bar
        bottomNavigationBar: Visibility(
          visible: true, //ref.watch(radioFaturaProvider) != null,
          child: BottomNavigationBar(
              showUnselectedLabels: true,
              selectedItemColor: Colors.deepOrange,
              unselectedItemColor: Colors.deepOrange,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              currentIndex: 0,
              onTap: (index) {
                switch (index) {
                  case 0:
                    if (ref.watch(radioFaturaProvider) != null) {
                      pdfGoruntule();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(LocaleKeys.fatura_secimi_yapin.tr())));
                    }

                    break;
                  case 1:
                    if (ref.watch(radioFaturaProvider) != null) {
                      faturaDuzenle();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(LocaleKeys.fatura_secimi_yapin.tr())));
                    }

                    break;
                  case 2:
                    ref
                        .read(faturalarProvider.notifier)
                        .update((state) => faturalar!);
                    ref
                        .read(seciliTarihAraligindakiFaturalar.notifier)
                        .update((state) => ref.read(faturalarProvider));
                    List<bool> checkboxList = [
                      for (var i = 0;
                          i <= ref.read(faturalarProvider).length;
                          i++)
                        false
                    ];

                    ref
                        .read(faturaCheckboxProvider.notifier)
                        .update((state) => checkboxList);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CokluFaturaGonder(),
                        ));
                    // emailGonder fonksiyonu tekli fatura göndermek için çalışan fonksiyon
                    //emailGonder();
                    //faturaGonder();
                    break;
                  case 3:
                    if (ref.watch(radioFaturaProvider) != null) {
                      faturaSil();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(LocaleKeys.fatura_secimi_yapin.tr())));
                    }

                    break;
                  default:
                }
                /* if (ref.watch(radioFaturaProvider) != null) {
                  
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(LocaleKeys.fatura_secimi_yapin.tr())));
                } */
                ref.read(radioFaturaProvider.notifier).update((state) => null);
              },
              items: [
                BottomNavigationBarItem(
                    label: LocaleKeys.goruntule.tr(),
                    icon: const Icon(Icons.picture_as_pdf)),
                BottomNavigationBarItem(
                    label: LocaleKeys.duzenle.tr(),
                    icon: const Icon(Icons.edit_note_sharp)),
                BottomNavigationBarItem(
                    label: LocaleKeys.gonder.tr(),
                    icon: const Icon(Icons.share)),
                BottomNavigationBarItem(
                    label: LocaleKeys.faturayi_sil.tr(),
                    icon: const Icon(Icons.delete))
              ]),
        ),
        body: /* ref.watch(faturalarProvider).isEmpty
            ? const Center(
                child: Text('Kayıtlı Faturanız Yok...'),
              )
            :  */
            Column(
          children: [
            //yeni fatura ekleme butonu
            GestureDetector(
              onTap: () async {
                /* if (saticiFirmaAdi == '') {
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
                                  const Text(
                                      'İlk girişiniz olduğu için faturalarda kullanılmak üzere firmanızın bilgilerini bir kereliğine kaydetmelisiniz ! '),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 50,
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
                                                BorderRadius.circular(15))),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
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
                                                BorderRadius.circular(15))),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              50),
                                  TextFormField(
                                    controller: _saticiTelefonController,
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
                                                BorderRadius.circular(15))),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
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
                                                BorderRadius.circular(15))),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              50),
                                  TextFormField(
                                    controller: _bankaAccountNameController,
                                    validator: (value) {
                                      if (value!.trim().isEmpty) {
                                        return 'Boş bırakılamaz...';
                                      } else {
                                        return null;
                                      }
                                    },
                                    decoration: InputDecoration(
                                        label: Text('Bank Account Name'),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15))),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              50),
                                  TextFormField(
                                    controller: _bankaSortCodeController,
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
                                                BorderRadius.circular(15))),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              50),
                                  TextFormField(
                                    controller: _bankaAccountNumberController,
                                    validator: (value) {
                                      if (value!.trim().isEmpty) {
                                        return 'Boş bırakılamaz...';
                                      } else {
                                        return null;
                                      }
                                    },
                                    decoration: InputDecoration(
                                        label: Text('Bank Account Number'),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15))),
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
                                if (_saticiKey.currentState!.validate()) {
                                  Map<String, dynamic> firmaBilgileri = {
                                    'adi': _saticiAdiController.text,
                                    'adresi': _saticiAdresiController.text,
                                    'email': _saticiEmailController.text,
                                    'telefon': _saticiTelefonController.text,
                                    'bankaAccountName':
                                        _bankaAccountNameController.text,
                                    'bankaSortCode':
                                        _bankaSortCodeController.text,
                                    'bankaAccountNumber':
                                        _bankaAccountNumberController.text
                                  };
                                  await _databaseHelper
                                      .kaydet(_saticiAdiController.text);
                                  Future(
                                    () {
                                      _firestore
                                          .collection(_saticiAdiController.text)
                                          .doc('saticiFirma')
                                          .set(firmaBilgileri);
                                    },
                                  ).then((value) {
                                    ref.read(saticiAdi.notifier).update(
                                        (state) => _saticiAdiController.text);
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
                                    child: Text('Eksik bilgi girdiniz...'),
                                  )));
                                }
                              },
                              child: Text('KAYDET'))
                        ],
                      );
                    },
                  );
                }  */
                //else {
                /* ref
                    .read(saticiAdi.notifier)
                    .update((state) => auth.currentUser!.email!); */
                var gelenBilgi = await _firestore
                    .collection(auth.currentUser!.displayName!)
                    .get();

                ref.read(provider.notifier).update((state) => gelenBilgi.docs);
                var liste = ref.watch(provider);
                List<Map<String, dynamic>> aliciListesi = [];

                if (liste.isNotEmpty) {
                  for (var item in liste) {
                    item.id == 'saticiFirma'
                        ? null
                        : aliciListesi.add(item.data());
                  }
                  ref
                      .read(aliciListesiProvider.notifier)
                      .update((state) => aliciListesi);
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AliciSec(),
                    ));
                //}
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle,
                    color: Colors.deepOrange,
                    size: 40,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 20,
                  ),
                  Text(
                    LocaleKeys.yeni_fatura_ekle.tr(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 22),
                  )
                ],
              ),
            ),

            //faturaların olduğu liste
            Expanded(
                child: StreamBuilder(
              stream: _firestore
                  .collection(auth.currentUser!.displayName!)
                  .doc('saticiFirma')
                  .collection('faturalar')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasData) {
                  final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                      _faturalar = snapshot.data!.docs;
                  List<Map<String, dynamic>> faturaListesi = [];
                  _faturalar.sort((a, b) =>
                      b.data()['createdAt'].compareTo(a.data()['createdAt']));
                  /* ref
                      .read(faturalarProvider.notifier)
                      .update((state) => _faturalar); */

                  faturalar = [];
                  faturalar!.addAll(_faturalar);

                  for (var item in _faturalar) {
                    faturaListesi.add(item.data());
                  }
                  return ListView.builder(
                    itemCount: faturaListesi.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              ref
                                  .read(radioFaturaProvider.notifier)
                                  .update((state) => index);
                              ref
                                  .read(seciliFaturaProvider.notifier)
                                  .update((state) => faturaListesi[index]);
                            },
                            leading: Radio(
                              value: index,
                              groupValue: ref.watch(radioFaturaProvider),
                              onChanged: (int? yeniDeger) {
                                ref
                                    .read(radioFaturaProvider.notifier)
                                    .update((state) => index);
                                ref
                                    .read(seciliFaturaProvider.notifier)
                                    .update((state) => faturaListesi[index]);
                              },
                            ),
                            title: Text(faturaListesi[index]['aliciAdi']),
                            subtitle:
                                Text(faturaListesi[index]['faturaTarihi']),
                            trailing: Text(
                                '£ ${faturaListesi[index]['faturaToplami']}'),
                          ),
                          const Divider(
                            height: 0,
                            thickness: 1,
                          )
                        ],
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            )

                /* ListView.builder(
                itemCount: ref.watch(faturalarProvider).length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        onTap: () {
                          ref
                              .read(radioFaturaProvider.notifier)
                              .update((state) => index);
                          ref.read(seciliFaturaProvider.notifier).update(
                              (state) =>
                                  ref.watch(faturalarProvider)[index].data());
                        },
                        leading: Radio(
                          value: index,
                          groupValue: ref.watch(radioFaturaProvider),
                          onChanged: (int? yeniDeger) {
                            ref
                                .read(radioFaturaProvider.notifier)
                                .update((state) => index);
                            ref.read(seciliFaturaProvider.notifier).update(
                                (state) =>
                                    ref.watch(faturalarProvider)[index].data());
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
              ), */
                ),
          ],
        ),
      ),
    );
  }

  /* faturalariGetir() async {
    //var value = await _databaseHelper.getir();
    ref.read(saticiAdi.notifier).update((state) => auth.currentUser!.email!);
    var gelenFaturalarSS = await _firestore
        .collection(auth.currentUser!.email!)
        .doc('saticiFirma')
        .collection('faturalar')
        .get();
    var gelenFaturalarListesi = gelenFaturalarSS.docs;
    gelenFaturalarListesi
        .sort((a, b) => b.data()['createdAt'].compareTo(a.data()['createdAt']));

    ref
        .read(faturalarProvider.notifier)
        .update((state) => gelenFaturalarListesi);
  } */

  void pdfGoruntule() async {
    var saticiBilgileriSS = await _firestore
        .collection(auth.currentUser!.displayName!)
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
        email: saticiBilgileriMap['email'],
        phone: saticiBilgileriMap['telefon'],
        firmaLogo: saticiBilgileriMap['firmaLogo'],
      ),
      customer: Customer(
          name: ref.watch(seciliFaturaProvider)['aliciAdi'],
          address: ref.watch(seciliFaturaProvider)['aliciAdresi'],
          email: ref.watch(seciliFaturaProvider)['aliciEmail'],
          phone: ref.watch(seciliFaturaProvider)['aliciTelefon'],
          imza: saticiBilgileriMap['imza']),
      info: InvoiceInfo(
          date: ref.watch(seciliFaturaProvider)['faturaTarihi'],
          description: '' //ref.watch(seciliFaturaProvider)['aciklama'],
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

    /* final pdfFile = await PdfSayfaFormati.generate(
        invoice,
        ref.watch(seciliFaturaProvider)['faturaTarihi'],
        ref.watch(seciliFaturaProvider)['faturaNo'],
        bankaBilgileri);

    PdfApi.openFile(pdfFile); */
    switch (ref.watch(faturaFormatProvider)) {
      case 'Format1':
        await PdfFatura1()
            .createPDF(invoice, ref.watch(seciliFaturaProvider)['faturaNo'],
                ref.watch(seciliFaturaProvider)['faturaTarihi'], bankaBilgileri)
            .then((value) async {
          await PdfFatura1().saveAndLaunchFile(
              value, '${ref.watch(seciliFaturaProvider)['faturaNo']}.pdf');
        });
        break;
      case 'Format2':
        await PdfFatura2()
            .createPDF(invoice, ref.watch(seciliFaturaProvider)['faturaNo'],
                ref.watch(seciliFaturaProvider)['faturaTarihi'], bankaBilgileri)
            .then((value) async {
          await PdfFatura2().saveAndLaunchFile(
              value, '${ref.watch(seciliFaturaProvider)['faturaNo']}.pdf');
        });
        break;
      default:
    }
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
          'email': ref.watch(seciliFaturaProvider)['aliciEmail'],
          'telefon': ref.watch(seciliFaturaProvider)['aliciTelefon']
        });
    ref
        .read(faturaNoProvider.notifier)
        .update((state) => ref.watch(seciliFaturaProvider)['faturaNo']);
    ref
        .read(tarihProvider.notifier)
        .update((state) => ref.watch(seciliFaturaProvider)['faturaTarihi']);
    ref
        .read(seciliAciklamaProvider.notifier)
        .update((state) => ref.watch(seciliFaturaProvider)['aciklama']);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DescriptionAddPage(),
        ));
  }

  /* void faturaGonder() async {
    var aliciBilgileri = await _firestore
        .collection(ref.watch(saticiAdi).toString())
        .doc(ref.watch(seciliFaturaProvider)['aliciAdi'])
        .get();
    var aliciMail = aliciBilgileri.data()!['email'];

    bool dosyaVarMi;
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final filePath = appDocumentDir.path +
          '/${ref.watch(seciliFaturaProvider)['faturaNo']}.pdf';
      final file = File(filePath);
      dosyaVarMi = await file.exists();
      if (dosyaVarMi) {
        ref.read(filePathProvider.notifier).update((state) => filePath);
        final Email email = Email(
          body:
              'Hello, you can find the invoice I prepared for you in the attachment.\nI created this invoice with the Aa Support application.\nI recommend it to you too.',
          subject: 'INVOICE',
          recipients: [aliciMail],
          attachmentPaths: [filePath],
          isHTML: false,
        );

        String platformResponse;

        try {
          await FlutterEmailSender.send(email);
          //platformResponse = 'Mail gönderildi';
        } catch (error) {
          print(error);
          platformResponse = 'Mail gönderilirken hata oluştu';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(platformResponse),
            ),
          );
        }
      } else {
        ref.read(filePathProvider.notifier).update((state) => '');
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
        final pdfFile = await PdfSayfaFormati.documentGenerate(
            invoice,
            ref.watch(seciliFaturaProvider)['faturaTarihi'],
            ref.watch(seciliFaturaProvider)['faturaNo'],
            bankaBilgileri);

        final appDocumentDir = await getApplicationDocumentsDirectory();
        final filePath = appDocumentDir.path +
            '/${ref.watch(seciliFaturaProvider)['faturaNo']}.pdf';
        final Email email = Email(
          body:
              'Hello, you can find the invoice I prepared for you in the attachment.\nI created this invoice with the Aa Support application.\nI recommend it to you too.',
          subject: 'INVOICE',
          recipients: [aliciMail],
          attachmentPaths: [filePath],
          isHTML: false,
        );

        String platformResponse;

        try {
          await FlutterEmailSender.send(email);
          platformResponse = 'Mail gönderildi';
        } catch (error) {
          print(error);
          platformResponse = 'Mail gönderilirken hata oluştu';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(platformResponse),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fatura bulunamadı...'),
        ),
      );
    }
  }
 */

  void faturaSil() async {
    //var value = await _databaseHelper.getir();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(LocaleKeys.faturayi_sil.tr()),
              content: Text(LocaleKeys.fatura_silinecek_onayliyor_musunuz.tr()),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(LocaleKeys.vazgec.tr())),
                ElevatedButton(
                    onPressed: () async {
                      Timestamp tarih =
                          ref.read(seciliFaturaProvider)['createdAt'];

                      faturaNoSil(ref.read(seciliFaturaProvider)['faturaNo'],
                          tarih.toDate());
                      await _firestore
                          .collection(auth.currentUser!.displayName!)
                          .doc('saticiFirma')
                          .collection('faturalar')
                          .doc(ref.watch(seciliFaturaProvider)['faturaNo'])
                          .delete();
                      //faturalariGetir();
                      Navigator.pop(context);
                      ref
                          .read(radioFaturaProvider.notifier)
                          .update((state) => null);
                    },
                    child: Text(LocaleKeys.sil.tr()))
              ],
            ));
  }

  Future<void> faturaNoSil(String faturaNo, DateTime faturaTarihi) async {
    if ((faturaNo.length > 9 &&
        faturaNo.substring(0, 9) ==
            DateFormat('yyyyMMdd').format(faturaTarihi) + '-')) {
      debugPrint('fatura tarihi içeriyor' +
          DateFormat('yyyyMMdd').format(faturaTarihi) +
          '-');
      String sira = faturaNo.substring(9);
      if (int.tryParse(sira.trim()) != null) {
        await _firestore
            .collection(auth.currentUser!.displayName!)
            .doc('saticiFirma')
            .collection('faturaNumaralari')
            .doc('tarihSayi')
            .collection(DateFormat('yyyyMMdd').format(faturaTarihi))
            .doc('tarihSayi')
            .get()
            .then((value) async {
          if (value.data() != null) {
            List<dynamic> liste = value.data()!['tarihSayi'];
            liste.remove(int.parse(sira.trim()));
            await _firestore
                .collection(auth.currentUser!.displayName!)
                .doc('saticiFirma')
                .collection('faturaNumaralari')
                .doc('tarihSayi')
                .collection(DateFormat('yyyyMMdd').format(faturaTarihi))
                .doc('tarihSayi')
                .update({'tarihSayi': liste});
          }
        });
      }
    } else {
      debugPrint('fatura Tarihi içermiyor');
      if (int.tryParse(faturaNo) != null) {
        await _firestore
            .collection(auth.currentUser!.displayName!)
            .doc('saticiFirma')
            .collection('faturaNumaralari')
            .doc('artanSayi')
            .get()
            .then((value) async {
          if (value.data() != null) {
            List<dynamic> liste = value.data()!['asrtanSayi'];
            liste.remove(int.parse(faturaNo));
            await _firestore
                .collection(auth.currentUser!.displayName!)
                .doc('saticiFirma')
                .collection('faturaNumaralari')
                .doc('artanSayi')
                .update({'artanSayi': liste});
          }
        });
      }
    }
  }

  /* void emailGonder() async {
    var aliciBilgileri = await _firestore
        .collection(ref.watch(saticiAdi).toString())
        .doc(ref.watch(seciliFaturaProvider)['aliciAdi'])
        .get();
    var aliciMail = aliciBilgileri.data()!['email'];

    //bool dosyaVarMi;
    try {
      /* final appDocumentDir = await getApplicationDocumentsDirectory();
      final filePath = appDocumentDir.path +
          '/${ref.watch(seciliFaturaProvider)['faturaNo']}.pdf'; */
      //final file = File(filePath);
      //dosyaVarMi = await file.exists();
      /* if (dosyaVarMi) {
        ref.read(filePathProvider.notifier).update((state) => filePath);

        final smtpServer = hotmail(ref.watch(mailBilgisiProvider)['email'],
            ref.watch(mailBilgisiProvider)['pass']);

        final message = Message()
          ..from = Address(ref.watch(mailBilgisiProvider)['email'],
              ref.watch(mailBilgisiProvider)['name'])
          ..recipients = [aliciMail]
          ..subject = ref.watch(mailBilgisiProvider)['subject']
          ..text = ref.watch(mailBilgisiProvider)['text']
          ..attachments = [FileAttachment(File(filePath))];
        try {
          final sendReport = await send(message, smtpServer);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Mail gönderildi')));
          print('Message sent: ' + sendReport.toString());
        } on MailerException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Mail gönderilirken hata oluştu. Daha sonra tekrar deneyin...')));
          print('Message not sent.' + e.problems.toString());
          for (var p in e.problems) {
            print('Problem: ${p.code}: ${p.msg}');
          }
        }
      } else {
        ref.read(filePathProvider.notifier).update((state) => '');
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
        final pdfFile = await PdfSayfaFormati.documentGenerate(
            invoice,
            ref.watch(seciliFaturaProvider)['faturaTarihi'],
            ref.watch(seciliFaturaProvider)['faturaNo'],
            bankaBilgileri);

        final appDocumentDir = await getApplicationDocumentsDirectory();
        final filePath = appDocumentDir.path +
            '/${ref.watch(seciliFaturaProvider)['faturaNo']}.pdf';
        const token = '';
        final smtpServer = hotmail(ref.watch(mailBilgisiProvider)['email'],
            ref.watch(mailBilgisiProvider)['pass']);

        final message = Message()
          ..from = Address(ref.watch(mailBilgisiProvider)['email'],
              ref.watch(mailBilgisiProvider)['name'])
          ..recipients.add(aliciMail)
          ..subject = ref.watch(mailBilgisiProvider)['subject']
          ..text = ref.watch(mailBilgisiProvider)['text']
          ..attachments = [FileAttachment(File(filePath))];
        try {
          final sendReport = await send(message, smtpServer);
          print('Message sent: ' + sendReport.toString());
        } on MailerException catch (e) {
          print('Message not sent.');
          for (var p in e.problems) {
            print('Problem: ${p.code}: ${p.msg}');
          }
        }
      } */
      ref.read(filePathProvider.notifier).update((state) => '');
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
          email: saticiBilgileriMap['email'],
          phone: saticiBilgileriMap['telefon'],
          firmaLogo: saticiBilgileriMap['firmaLogo'],
        ),
        customer: Customer(
          name: ref.watch(seciliFaturaProvider)['aliciAdi'],
          address: ref.watch(seciliFaturaProvider)['aliciAdresi'],
          email: ref.watch(seciliFaturaProvider)['aliciEmail'],
          phone: ref.watch(seciliFaturaProvider)['aliciTelefon'],
          imza: ref.watch(seciliFaturaProvider)['imza'],
        ),
        info: InvoiceInfo(
          date: ref.watch(seciliFaturaProvider)['faturaTarihi'],
          description: ref.watch(seciliFaturaProvider)['aciklama'],
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
      switch (ref.watch(faturaFormatProvider)) {
        case 'Format1':
          await PdfFatura1()
              .createPDF(
                  invoice,
                  ref.watch(seciliFaturaProvider)['faturaNo'],
                  ref.watch(seciliFaturaProvider)['faturaTarihi'],
                  bankaBilgileri)
              .then((value) async {
            await PdfFatura1().saveFile(
                value, '${ref.watch(seciliFaturaProvider)['faturaNo']}.pdf');
          });
          break;
        case 'Format2':
          await PdfFatura2()
              .createPDF(
                  invoice,
                  ref.watch(seciliFaturaProvider)['faturaNo'],
                  ref.watch(seciliFaturaProvider)['faturaTarihi'],
                  bankaBilgileri)
              .then((value) async {
            await PdfFatura2().saveFile(
                value, '${ref.watch(seciliFaturaProvider)['faturaNo']}.pdf');
          });
          break;
        default:
      }
      /* final pdfFile = await PdfSayfaFormati.documentGenerate(
          invoice,
          ref.watch(seciliFaturaProvider)['faturaTarihi'],
          ref.watch(seciliFaturaProvider)['faturaNo'],
          bankaBilgileri);

      final appDocumentDir = await getApplicationDocumentsDirectory();
      final filePath = appDocumentDir.path +
          '/${ref.watch(seciliFaturaProvider)['faturaNo']}.pdf'; */

      final path = (await getExternalStorageDirectory())!.path;
      final filePath =
          path + '/${ref.watch(seciliFaturaProvider)['faturaNo']}.pdf';

      final smtpServer = hotmail(ref.watch(mailBilgisiProvider)['email'],
          ref.watch(mailBilgisiProvider)['pass']);

      final message = Message()
        ..from = Address(ref.watch(mailBilgisiProvider)['email'],
            ref.watch(mailBilgisiProvider)['name'])
        ..recipients.add(aliciMail)
        ..subject = ref.watch(mailBilgisiProvider)['subject']
        ..text = ref.watch(mailBilgisiProvider)['text']
        ..attachments = [FileAttachment(File(filePath))];
      try {
        final sendReport = await send(message, smtpServer);
        debugPrint('Message sent: ' + sendReport.toString());
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LocaleKeys.mail_gonderildi.tr())));
      } on MailerException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(LocaleKeys
                .mail_gonderilirken_hata_olustu_daha_sonra_tekrar_deneyin
                .tr())));
        debugPrint('Message not sent.');
        for (var p in e.problems) {
          debugPrint('Problem: ${p.code}: ${p.msg}');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.fatura_bulunamadi.tr()),
        ),
      );
    }
  }
 */

  /* void mailBilgisiGetir() async {
    var mailBilgisiData =
        await _firestore.collection('uygulama_mail').doc('mail').get();
    var mailIcerik = mailBilgisiData.data();
    ref.read(mailBilgisiProvider.notifier).update((state) => mailIcerik!);
  } */
}
