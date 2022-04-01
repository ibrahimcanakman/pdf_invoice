import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/contoller/description_controllers.dart';
import 'package:pdf_invoice/page/home_page.dart';

import '../api/pdf_api.dart';
import '../api/pdf_invoice_api.dart';
import '../model/customer.dart';
import '../model/invoice.dart';
import '../model/supplier.dart';
import '../widget/button_widget.dart';

final descCounterProvider = StateProvider<int>(
  (ref) => 1,
);
final controllerListProvider =
    StateProvider<List<Map<String, TextEditingController>>>(
  (ref) {
    return [];
  },
);

class DescriptionAddPage extends ConsumerWidget {
  DescriptionAddPage({Key? key}) : super(key: key);
  /* TextEditingController urunAdi1 = TextEditingController();
  TextEditingController urunMiktari1 = TextEditingController();
  TextEditingController urunBirim1 = TextEditingController();
  TextEditingController urunKDV1 = TextEditingController(); */

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controllerMapList = ref.watch(controllerListProvider);
    Future(
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
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Description Add'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    TextEditingController urunAdi1 = TextEditingController();
                    TextEditingController urunMiktari1 =
                        TextEditingController();
                    TextEditingController urunBirim1 = TextEditingController();
                    TextEditingController urunKDV1 = TextEditingController();
                    var a = {
                      'urunAdi': urunAdi1,
                      'urunMiktari': urunMiktari1,
                      'urunBirim': urunBirim1,
                      'urunKDV': urunKDV1
                    };
                    ref
                        .read(controllerListProvider.notifier)
                        .update((state) => [...state, a]);
                  },
                  child: Icon(Icons.add),
                ),
                ElevatedButton(
                    onPressed: () async {
                      final date = DateTime.now();
                      final dueDate = date.add(const Duration(days: 7));

                      final invoice = Invoice(
                        supplier: Supplier(
                          name: ref.watch(saticiFirmaProvider)!,
                          address: ref.watch(saticiAdresProvider)!,
                          paymentInfo: 'https://paypal.me/sarahfieldzz',
                        ),
                        customer: Customer(
                          name: ref.watch(aliciFirmaProvider)!,
                          address: ref.watch(aliciAdresProvider)!,
                        ),
                        info: InvoiceInfo(
                          date: date,
                          dueDate: dueDate,
                          description: ref.watch(aciklamaProvider)!,
                          number: '${DateTime.now().year}-9999',
                        ),
                        items: [
                          for (var item in ref.watch(controllerListProvider))
                            InvoiceItem(
                              description: item['urunAdi']!.text,
                              date: DateTime.now(),
                              quantity: int.parse(item['urunMiktari']!.text),
                              vat: double.parse(item['urunKDV']!.text),
                              unitPrice: double.parse(item['urunBirim']!.text),
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

                      final pdfFile = await PdfInvoiceApi.generate(invoice);

                      PdfApi.openFile(pdfFile);
                    },
                    child: Text('Fatura Oluştur'))
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: ListView.builder(
                itemCount:
                    controllerMapList.isEmpty ? 1 : controllerMapList.length,
                itemBuilder: (context, index) {
                  return controllerMapList.isEmpty
                      ? Text('Ürün Yok')
                      : DescriptionWidget(
                          urunAdi: controllerMapList[index]['urunAdi']!,
                          urunMiktari: controllerMapList[index]['urunMiktari']!,
                          urunBirim: controllerMapList[index]['urunBirim']!,
                          urunKDV: controllerMapList[index]['urunKDV']!);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DescriptionWidget extends StatelessWidget {
  DescriptionWidget(
      {Key? key,
      required this.urunAdi,
      required this.urunMiktari,
      required this.urunBirim,
      required this.urunKDV})
      : super(key: key);
  TextEditingController urunAdi, urunMiktari, urunBirim, urunKDV;

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
              width: MediaQuery.of(context).size.width * 0.4,
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
              width: MediaQuery.of(context).size.width * 0.4,
              child: TextFormField(
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
              width: MediaQuery.of(context).size.width * 0.4,
              child: TextFormField(
                controller: urunBirim,
                decoration: InputDecoration(
                    label: Text('Ürün Birim Fiyatı'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            )),
            Form(
                child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: TextFormField(
                controller: urunKDV,
                decoration: InputDecoration(
                    label: Text('Ürün KDV %'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            )),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Divider(
          height: 0,
          thickness: 3,
        )
      ],
    );
  }
}
