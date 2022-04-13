import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path_provider/path_provider.dart';
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
        ref.read(radioProvider.notifier).update((state) => null);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Faturalarım'),
        ),

        //bottom nav bar
        bottomNavigationBar: Visibility(
          visible: ref.watch(radioProvider) != null,
          child: BottomNavigationBar(
              showUnselectedLabels: true,
              selectedItemColor: Colors.deepOrange,
              unselectedItemColor: Colors.deepOrange,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              currentIndex: 0,
              onTap: (index) {
                if (ref.watch(radioProvider) != null) {
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
                      faturaGonder();
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
                ref.read(radioProvider.notifier).update((state) => null);
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
        body: ref.watch(faturalarProvider).isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  //yeni fatura ekleme butonu
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

  void faturaGonder() async {
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
                      ref.read(radioProvider.notifier).update((state) => null);
                    },
                    child: const Text('SİL'))
              ],
            ));
  }

  void emailGonder() async {
    /* final appDocumentDir = await getApplicationDocumentsDirectory();
      final filePath = appDocumentDir.path +
          '/20220501.pdf'; */

    bool dosyaVarMi;
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final filePath = appDocumentDir.path +
          '/${ref.watch(seciliFaturaProvider)['faturaNo']}.pdf';
      final file = File(filePath);
      dosyaVarMi = await file.exists();
      if (dosyaVarMi) {
        ref.read(filePathProvider.notifier).update((state) => filePath);
        const token = '';
        final smtpServer =
            gmailRelaySaslXoauth2('ibocan351130@gmail.om', token);
        final message = Message()
          ..from = const Address('ibocan351130@gmail.com')
          ..recipients = ['ibrahimcanakman@hotmail.com']
          ..subject = 'subject'
          ..text = 'text'
          ..attachments = [FileAttachment(File(filePath))];
        try {
          final sendReport = await send(message, smtpServer);
          print('Message sent: ' + sendReport.toString());
        } on MailerException catch (e) {
          print('Message not sent.' + e.problems.toString());
          for (var p in e.problems) {
            print('Problem: ${p.code}: ${p.msg}');
          }
        }
        var connection =
            PersistentConnection(smtpServer, timeout: Duration(seconds: 15));
        // Send multiple mails on one connection:
        try {
          for (var i = 0; i < 3; i++) {
            message.subject =
                'Test Dart Mailer library :: 😀 :: ${DateTime.now()} / $i';
            final sendReport = await connection.send(message);
            print('Message sent: ' + sendReport.toString());
          }
        } on MailerException catch (e) {
          print('Message not sent.');
          for (var p in e.problems) {
            print('Problem: ${p.code}: ${p.msg}');
          }
        } catch (e) {
          print('Other exception: $e');
        } finally {
          await connection.close();
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
        final smtpServer = gmailSaslXoauth2('ibocan351130@gmail.om', token);
        final message = Message()
          ..from = const Address('ibocan351130@gmail.com', 'Can Akman')
          ..recipients.add('ibrahimcanakman@hotmail.com')
          ..subject = 'subject'
          ..text = 'text'
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
        var connection =
            PersistentConnection(smtpServer, timeout: Duration(seconds: 15));
        // Send multiple mails on one connection:
        try {
          for (var i = 0; i < 3; i++) {
            message.subject =
                'Test Dart Mailer library :: 😀 :: ${DateTime.now()} / $i';
            final sendReport = await connection.send(message);
            print('Message sent: ' + sendReport.toString());
          }
        } on MailerException catch (e) {
          print('Message not sent.');
          for (var p in e.problems) {
            print('Problem: ${p.code}: ${p.msg}');
          }
        } catch (e) {
          print('Other exception: $e');
        } finally {
          await connection.close();
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
}
