import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:pdf_invoice/api/pdf_api.dart';

import '../model/customer.dart';
import '../model/invoice.dart';
import '../model/supplier.dart';
import '../utils.dart';

class PdfSayfaFormati {
  static Future<Document> documentGenerate(Invoice invoice, String tarih,
      String faturaNo, Map bankaBilgileri) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      build: (context) => [
        buildHeader(invoice, tarih, faturaNo),
        SizedBox(height: 2 * PdfPageFormat.cm),
        buildDescription(invoice),
        buildInvoice(invoice),
        Divider(),
        buildTotal(invoice),
      ],
      footer: (context) => buildFooter(invoice, bankaBilgileri),
    ));

    PdfApi.saveDocument(name: '$faturaNo.pdf', pdf: pdf);
    return pdf;
  }

  static Future<File> generate(Invoice invoice, String tarih, String faturaNo,
      Map bankaBilgileri) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      build: (context) => [
        buildHeader(invoice, tarih, faturaNo),
        SizedBox(height: 2 * PdfPageFormat.cm),
        buildDescription(invoice),
        buildInvoice(invoice),
        Divider(),
        buildTotal(invoice),
      ],
      footer: (context) => buildFooter(invoice, bankaBilgileri),
    ));

    return PdfApi.saveDocument(name: '$faturaNo.pdf', pdf: pdf);
  }

  static Widget buildHeader(Invoice invoice, String tarih, String faturaNo) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 1 * PdfPageFormat.cm),
          buildTitle(),
          buildSupplierAddress(invoice.supplier),
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildCustomerAddress(invoice.customer),
              buildInvoiceInfo(invoice.info, tarih, faturaNo),
            ],
          ),
        ],
      );

  static Widget buildCustomerAddress(Customer customer) => Container(
      width: 100 * PdfPageFormat.mm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60 * PdfPageFormat.mm,
            child: Text(customer.name,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            width: 60 * PdfPageFormat.mm,
            child: Text(customer.address),
          ),
          Text(customer.email),
          Text(customer.phone),
        ],
      ));

  static Widget buildInvoiceInfo(
      InvoiceInfo info, String tarih, String faturaNo) {
    final titles = <String>[
      'Invoice Number:',
      'Invoice Date:',
    ];
    final data = <String>[faturaNo, tarih];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return buildText(title: title, value: value, width: 200);
      }),
    );
  }

  static Widget buildSupplierAddress(Supplier supplier) => Container(
      width: 70 * PdfPageFormat.mm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(supplier.name, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(supplier.address),
          Text(supplier.email),
          Text(supplier.phone),
        ],
      ));

  static Widget buildDescription(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(invoice.info.description),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static Widget buildTitle() => Container(
      width: 59 * PdfPageFormat.mm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INVOICE',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: PdfColor.fromRYB(0, 0, 0.6)),
          ),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      ));

  static Widget buildInvoice(Invoice invoice) {
    final headers = ['Description', 'Quantity', 'Unit Price', 'VAT', 'Total'];
    final data = invoice.items.map((item) {
      final total = item.unitPrice * item.quantity;

      return [
        item.description,
        '${item.quantity}',
        '\£ ${item.unitPrice}',
        '${item.vat} %',
        '\£ ${total.toStringAsFixed(2)}',
      ];
    }).toList();

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: const BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
        5: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(Invoice invoice) {
    final netTotal = invoice.items
        .map((item) => item.unitPrice * item.quantity)
        .reduce((item1, item2) => item1 + item2);
    final vatPercent = invoice.items.first
        .vat; //burası pdf halinde total kdv değerini yazan ve hsaplayan kısım. DÜZENLENECEK...
    //final vat = netTotal * (vatPercent / 100);
    final vat = invoice.items
        .map((item) => (item.unitPrice * item.quantity * item.vat / 100))
        .reduce((item1, item2) => item1 + item2);
    final total = netTotal + vat;

    return Container(
      //bunu github a commit edebilirmisin
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Net total',
                  value: Utils.formatPrice(netTotal),
                  unite: true,
                ),
                buildText(
                  title: 'Vat $vatPercent %',
                  value: Utils.formatPrice(vat),
                  unite: true,
                ),
                Divider(),
                buildText(
                  title: 'Total amount due',
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  value: Utils.formatPrice(total),
                  unite: true,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFooter(Invoice invoice, Map bankaBilgileri) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 2 * PdfPageFormat.mm),
          //Banka hesabı bilgileri gelecek
          // Account Name
          //Sort Code
          //Account Number
          Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            buildSimpleText(
                title: 'Account Name__: ',
                value: bankaBilgileri['accountName']),
            SizedBox(height: 1 * PdfPageFormat.mm),
            buildSimpleText(
                title: 'Sort Code______: ', value: bankaBilgileri['sortCode']),
            SizedBox(height: 1 * PdfPageFormat.mm),
            buildSimpleText(
                title: 'Account Number: ',
                value: bankaBilgileri['accountNumber']),
          ])
          /* SizedBox(height: 1 * PdfPageFormat.mm),
          buildSimpleText(title: 'Paypal', value: invoice.supplier.paymentInfo), */
        ],
      );

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: 70 * PdfPageFormat.mm, //width / 1.2,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}
