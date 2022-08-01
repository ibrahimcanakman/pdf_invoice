import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/hotmail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_invoice/page/anasayfa.dart';

import '../api/pdf_invoice1.dart';
import '../api/pdf_invoice2.dart';
import '../model/customer.dart';
import '../model/invoice.dart';
import '../model/supplier.dart';
import '../provider/all_providers.dart';
import '../provider/firebase_connect.dart';
import '../translations/locale_keys.g.dart';

class CokluFaturaAlicisiSec extends ConsumerStatefulWidget {
  const CokluFaturaAlicisiSec({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CokluFaturaAlicisiSecState();
}

class _CokluFaturaAlicisiSecState extends ConsumerState<CokluFaturaAlicisiSec> {
  final TextEditingController aliciEmailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mailBilgisiGetir();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        ref
            .read(radioCokluFaturaAliciProvider.notifier)
            .update((state) => null);
        ref
            .read(cokluFaturaEmailEnabledProvider.notifier)
            .update((state) => false);
        ref.read(secilenTopluFaturalarProvider.notifier).update((state) => []);
        ref.read(cokluFaturaAliciMailProvider.notifier).update((state) => null);
        ref.read(cokluFaturaPathleriProvider.notifier).update((state) => []);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.alici_sec.tr()),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        ref.watch(cokluFaturaAliciListesiProvider).length,
                    itemBuilder: (context, index) {
                      var oAnkiMusteri =
                          ref.watch(cokluFaturaAliciListesiProvider)[index];
                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              if (index ==
                                  ref
                                          .watch(
                                              cokluFaturaAliciListesiProvider)
                                          .length -
                                      1) {
                                ref
                                    .read(cokluFaturaEmailEnabledProvider
                                        .notifier)
                                    .update((state) => true);
                              } else {
                                ref
                                    .read(cokluFaturaEmailEnabledProvider
                                        .notifier)
                                    .update((state) => false);
                                ref
                                    .read(cokluFaturaAliciMailProvider.notifier)
                                    .update((state) => ref.watch(
                                            cokluFaturaAliciListesiProvider)[
                                        index]['email']);
                              }
                              ref
                                  .read(radioCokluFaturaAliciProvider.notifier)
                                  .update((state) => index);
                            },
                            leading: Radio(
                              value: index,
                              groupValue:
                                  ref.watch(radioCokluFaturaAliciProvider),
                              onChanged: (int? yeniDeger) {
                                if (yeniDeger ==
                                    ref
                                            .watch(
                                                cokluFaturaAliciListesiProvider)
                                            .length -
                                        1) {
                                  ref
                                      .read(cokluFaturaEmailEnabledProvider
                                          .notifier)
                                      .update((state) => true);
                                } else {
                                  ref
                                      .read(cokluFaturaEmailEnabledProvider
                                          .notifier)
                                      .update((state) => false);
                                  ref
                                      .read(
                                          cokluFaturaAliciMailProvider.notifier)
                                      .update((state) => ref.watch(
                                              cokluFaturaAliciListesiProvider)[
                                          yeniDeger!]['email']);
                                }

                                ref
                                    .read(
                                        radioCokluFaturaAliciProvider.notifier)
                                    .update((state) => index);
                              },
                            ),
                            subtitle: ref
                                        .watch(secilenTopluFaturalarProvider)
                                        .every((element) =>
                                            element.data()['aliciAdi'] ==
                                            ref
                                                .watch(
                                                    secilenTopluFaturalarProvider)
                                                .first
                                                .data()['aliciAdi']) &&
                                    index == 0
                                ? Text(LocaleKeys.fatura_sahibi.tr())
                                : null,
                            title: oAnkiMusteri['adi'] != 'email'
                                ? Text(ref.watch(
                                        cokluFaturaAliciListesiProvider)[index]
                                    ['adi'])
                                : TextFormField(
                                    controller: aliciEmailController,
                                    enabled: ref
                                        .watch(cokluFaturaEmailEnabledProvider),
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        label: Text(
                                            LocaleKeys.gonderilecek_email_girin.tr()),
                                        contentPadding:
                                            EdgeInsets.fromLTRB(12, 0, 12, 0),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                  ),
                          ),
                          const Divider(
                            height: 0,
                            thickness: 2,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Visibility(
                  visible: (ref.watch(radioCokluFaturaAliciProvider) != null &&
                          ref.watch(radioCokluFaturaAliciProvider) !=
                              ref
                                      .watch(cokluFaturaAliciListesiProvider)
                                      .length -
                                  1) ||
                      (ref.watch(radioCokluFaturaAliciProvider) ==
                              ref
                                      .watch(cokluFaturaAliciListesiProvider)
                                      .length -
                                  1 &&
                          EmailValidator.validate(
                              aliciEmailController.text.trim())),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: ElevatedButton(
                        onPressed: () {
                          if (ref.watch(cokluFaturaEmailEnabledProvider)) {
                            ref
                                .read(cokluFaturaAliciMailProvider.notifier)
                                .update((state) =>
                                    aliciEmailController.text.trim());
                          }
                          showDialog(
                            context: context,
                            builder: (context) =>
                                Center(child: CircularProgressIndicator()),
                          );
                          faturalariOlusturGonder().then((value) {
                            ref
                                .read(faturaCheckboxProvider.notifier)
                                .update((state) => null);
                            ref
                                .read(cokluFaturaHepsiProvider.notifier)
                                .update((state) => false);
                            ref
                                .read(seciliTarihAraligiProvider.notifier)
                                .update((state) =>
                                    LocaleKeys.baslangic_ve_bitis_tarihi_secin.tr());
                            ref
                                .read(seciliTarihAraligindakiFaturalar.notifier)
                                .update((state) => []);
                            ref
                                .read(radioCokluFaturaAliciProvider.notifier)
                                .update((state) => null);
                            ref
                                .read(cokluFaturaEmailEnabledProvider.notifier)
                                .update((state) => false);
                            ref
                                .read(secilenTopluFaturalarProvider.notifier)
                                .update((state) => []);
                            ref
                                .read(cokluFaturaAliciMailProvider.notifier)
                                .update((state) => null);
                            ref
                                .read(cokluFaturaPathleriProvider.notifier)
                                .update((state) => []);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AnaSayfa(),
                                ),
                                (route) => false);
                          });
                        },
                        child: Text(
                          LocaleKeys.faturalari_gonder.tr(),
                          style: TextStyle(fontSize: 24),
                        )),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void mailBilgisiGetir() async {
    var mailBilgisiData = await gondericiMail.get();
    var mailIcerik = mailBilgisiData.data();
    ref.read(mailBilgisiProvider.notifier).update((state) => mailIcerik!);
  }

  Future<void> faturalariOlusturGonder() async {
    var saticiBilgileriSS = await saticiFirmaCollection.get();
    var saticiBilgileriMap = saticiBilgileriSS.data();

    Map<String, dynamic> bankaBilgileri = {
      'accountName': saticiBilgileriMap!['bankaAccountName'],
      'sortCode': saticiBilgileriMap['bankaSortCode'],
      'accountNumber': saticiBilgileriMap['bankaAccountNumber']
    };

    var aliciMail = ref.watch(cokluFaturaAliciMailProvider);

    for (var element in ref.watch(secilenTopluFaturalarProvider)) {
      ref.read(seciliFaturaProvider.notifier).update((state) => element.data());

      try {
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
            imza: saticiBilgileriMap['imza'],
          ),
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

        final path = (await getExternalStorageDirectory())!.path;
        final filePath =
            path + '/${ref.watch(seciliFaturaProvider)['faturaNo']}.pdf';
        ref
            .read(cokluFaturaPathleriProvider.notifier)
            .update((state) => [...state, filePath]);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.fatura_bulunamadi.tr()),
          ),
        );
      }
    }

    try {
      if (ref.watch(smtpProvider) == null) {
        final smtpServer = hotmail(ref.watch(mailBilgisiProvider)['email'],
            ref.watch(mailBilgisiProvider)['pass']);
        ref.read(smtpProvider.notifier).update((state) => smtpServer);
      }

      final message = Message()
        ..from = Address(ref.watch(mailBilgisiProvider)['email'],
            ref.watch(mailBilgisiProvider)['name'])
        ..recipients.add(aliciMail)
        ..subject = ref.watch(mailBilgisiProvider)['subject']
        ..text = ref.watch(mailBilgisiProvider)['text']
        ..attachments = [
          for (var element in ref.watch(cokluFaturaPathleriProvider))
            FileAttachment(File(element))
        ];
      try {
        final sendReport = await send(message, ref.watch(smtpProvider)!);
        debugPrint('Message sent: ' + sendReport.toString());
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LocaleKeys.mail_gonderildi.tr())));
      } on MailerException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(LocaleKeys
                .mail_gonderilirken_hata_olustu_daha_sonra_tekrar_deneyin
                .tr())));
        debugPrint('Message not sent. $e');
        for (var p in e.problems) {
          debugPrint('Problem: ${p.code}: ${p.msg}');
        }
      }
    } catch (e) {
      debugPrint('Message not sent. $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(LocaleKeys
              .mail_gonderilirken_hata_olustu_daha_sonra_tekrar_deneyin
              .tr())));
    }
  }
}
