/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/pdf_api.dart';
import '../api/pdf_invoice_api.dart';
import '../model/customer.dart';
import '../model/invoice.dart';
import '../model/supplier.dart';
import '../provider/all_providers.dart';
import '../translations/locale_keys.g.dart';
import 'home_page.dart';

// ignore: must_be_immutable
class FaturaSayfasi extends ConsumerWidget {
  FaturaSayfasi({Key? key}) : super(key: key);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
      appBar: AppBar(title: Text(LocaleKeys.fatura_kes.tr())),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              Map<String, dynamic> satici = {};
              for (var item in ref.watch(provider)) {
                item.id == 'saticiFirma' ? satici = item.data() : null;
              }

              //final date = DateTime.now();
              //final dueDate = date.add(const Duration(days: 7));

              final invoice = Invoice(
                supplier: Supplier(
                  name: satici['adi'],
                  address: satici['adresi'],
                  email: satici['email'],
                  phone: satici['phone'],
                ),
                customer: Customer(
                  name: ref.watch(gecerliMusteri)['adi'],
                  address: ref.watch(gecerliMusteri)['adresi'],
                  email: ref.watch(gecerliMusteri)['email'],
                  phone: ref.watch(gecerliMusteri)['telefon'],
                ),
                info: InvoiceInfo(
                  date: ref.watch(tarihProvider),
                  //dueDate: dueDate,
                  description: ref.watch(seciliAciklamaProvider) ?? '',
                  //number: '${DateTime.now().year}-9999',
                ),
                items: [
                  for (var item in ref.watch(urunListesiProvider))
                    InvoiceItem(
                      description: item['urunAdi']!,
                      //date: DateTime.now(),
                      quantity: int.parse(item['urunMiktari']!),
                      vat: double.parse(item['urunKDV']!),
                      unitPrice: double.parse(item['urunBirimi']!),
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
                  invoice,
                  ref.watch(tarihProvider),
                  ref.watch(faturaNoProvider),
                  bankaBilgileri);

              PdfApi.openFile(pdfFile);
            },
            child: Text(LocaleKeys.fatura_kes.tr())),
      ),
    );
  }
}
 */