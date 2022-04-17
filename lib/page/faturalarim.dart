import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/hotmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_invoice/page/anasayfa.dart';
import 'package:pdf_invoice/page/description_add_page.dart';

import '../api/pdf_api.dart';
import '../api/pdf_invoice_api.dart';
import '../constants/constant.dart';
import '../model/customer.dart';
import '../model/invoice.dart';
import '../model/supplier.dart';
import '../provider/all_providers.dart';
import 'alici_sec.dart';

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

  //String saticiFirmaAdi = '';

  @override
  void initState() {
    faturalariGetir();
    mailBilgisiGetir();
    super.initState();
  }

  faturalariGetir() async {
    //var value = await _databaseHelper.getir();
    ref.read(saticiAdi.notifier).update((state) => auth.currentUser!.email!);
    var gelenFaturalarSS = await _firestore
        .collection(auth.currentUser!.email!)
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

  /* saticiFirmaGetir() async {
    var saticiFirma = await _databaseHelper.getir();
    saticiFirmaAdi = saticiFirma.first['firmaAdi'].toString();
  } */

  @override
  Widget build(BuildContext context) {
    //faturalariGetir();
    //saticiFirmaGetir();

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
          title: const Text('Faturalarım'),
        ),

        //bottom nav bar
        bottomNavigationBar: Visibility(
          visible: ref.watch(radioFaturaProvider) != null,
          child: BottomNavigationBar(
              showUnselectedLabels: true,
              selectedItemColor: Colors.deepOrange,
              unselectedItemColor: Colors.deepOrange,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              currentIndex: 0,
              onTap: (index) {
                if (ref.watch(radioFaturaProvider) != null) {
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
                      emailGonder();
                      //faturaGonder();
                      debugPrint('2 tıklandı');
                      break;
                    case 3:
                      faturaSil();
                      debugPrint('3 tıklandı');
                      break;
                    default:
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fatura seçimi yapın...')));
                }
                ref.read(radioFaturaProvider.notifier).update((state) => null);
              },
              items: const [
                BottomNavigationBarItem(
                    label: 'Görüntüle', icon: Icon(Icons.picture_as_pdf)),
                BottomNavigationBarItem(
                    label: 'Düzenle', icon: Icon(Icons.edit_note_sharp)),
                BottomNavigationBarItem(
                    label: 'Gönder', icon: Icon(Icons.share)),
                BottomNavigationBarItem(
                    label: 'Fatura Sil', icon: Icon(Icons.delete))
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
                ref
                    .read(saticiAdi.notifier)
                    .update((state) => auth.currentUser!.email!);
                var gelenBilgi =
                    await _firestore.collection(auth.currentUser!.email!).get();

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
                  const Text(
                    'Yeni Fatura Ekle',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  )
                ],
              ),
            ),

            //faturaların olduğu liste
            Expanded(
              child: ListView.builder(
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
        email: ref.watch(seciliFaturaProvider)['aliciEmail'],
        phone: ref.watch(seciliFaturaProvider)['aliciTelefon'],
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
              title: const Text('Fatura Silme'),
              content: const Text('Fatura silinecek onaylıyor musunuz ?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Vazgeç')),
                ElevatedButton(
                    onPressed: () async {
                      await _firestore
                          .collection(ref.watch(saticiAdi))
                          .doc('saticiFirma')
                          .collection('faturalar')
                          .doc(ref.watch(seciliFaturaProvider)['faturaNo'])
                          .delete();
                      faturalariGetir();
                      Navigator.pop(context);
                      ref
                          .read(radioFaturaProvider.notifier)
                          .update((state) => null);
                    },
                    child: const Text('SİL'))
              ],
            ));
  }

  void emailGonder() async {
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
        ),
        customer: Customer(
          name: ref.watch(seciliFaturaProvider)['aliciAdi'],
          address: ref.watch(seciliFaturaProvider)['aliciAdresi'],
          email: ref.watch(seciliFaturaProvider)['aliciEmail'],
          phone: ref.watch(seciliFaturaProvider)['aliciTelefon'],
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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Mail gönderildi')));
      } on MailerException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Mail gönderilirken hata oluştu, daha sonra tekrar deneyin')));
        debugPrint('Message not sent.');
        for (var p in e.problems) {
          debugPrint('Problem: ${p.code}: ${p.msg}');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fatura bulunamadı...'),
        ),
      );
    }
  }

  void mailBilgisiGetir() async {
    var mailBilgisiData =
        await _firestore.collection('uygulama_mail').doc('mail').get();
    var mailIcerik = mailBilgisiData.data();
    ref.read(mailBilgisiProvider.notifier).update((state) => mailIcerik!);
  }
}
