import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_invoice/model/invoice.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfFatura2 {
  Future<List<int>> createPDF(Invoice invoice, String faturaNo,
      String faturaTarihi, Map<String, dynamic> bankaBilgileri) async {
    PdfFont font = PdfTrueTypeFont(await _font(), 12);
    PdfFont fontBaslik = PdfTrueTypeFont(await _font(), 30);
    PdfFont fontToplam = PdfTrueTypeFont(await _font(), 18);

    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final Size pageSize = page.getClientSize();

    //sayfa çerçevesini çizdirme
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        pen: PdfPen(PdfColor(142, 170, 219)));

    //Tablo oluşturma için başlıklar
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);
    final PdfGridRow headerRow = grid.headers.add(1)[0];

    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.style.font = font;
    headerRow.cells[0].value = 'Description';
    headerRow.cells[1].value = 'Quantity';
    headerRow.cells[2].value = 'Unit Price';
    headerRow.cells[3].value = 'VAT';
    headerRow.cells[4].value = 'Total';

    //ürün sayısına göre sayfa sayısı oluşturma
    int urunSayisi = invoice.items.length;
    PdfPage? page2;
    PdfPage? page3;
    if (urunSayisi > 8) {
      page2 = document.pages.add();
      if (urunSayisi > 33) {
        page3 = document.pages.add();
      }
    }

    double toplamTutar = 0;
    double toplamKDV = 0;
    double toplamNetTutar = 0;
    //tabloya ürün satırı ekleme
    for (var i = 0; i < urunSayisi; i++) {
      final PdfGridRow row = grid.rows.add();
      row.style.font = font;
      row.cells[0].value = invoice.items[i].description;
      row.cells[1].value = invoice.items[i].quantity.toString();
      row.cells[2].value = '£ ${invoice.items[i].unitPrice}';
      row.cells[3].value = invoice.items[i].vat.toString();
      row.cells[4].value =
          '£ ${(invoice.items[i].quantity * invoice.items[i].unitPrice)}';
      toplamTutar += invoice.items[i].quantity * invoice.items[i].unitPrice;
      toplamKDV += (invoice.items[i].quantity *
              invoice.items[i].unitPrice *
              invoice.items[i].vat) /
          100;
    }
    toplamNetTutar = toplamTutar + toplamKDV;

    //tablo stili belirleme
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);

    grid.columns[0].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];

        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }

    page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(91, 126, 215)),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 115, 90));

    //PDF başında invoice kelimesini yazdırma
    page.graphics.drawString('INVOICE', fontBaslik,
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(25, 0, pageSize.width - 115, 90),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 90),
        brush: PdfSolidBrush(PdfColor(65, 104, 205)));

    //PDF başında amount fatura tutarı yazdırma
    page.graphics.drawString('£ $toplamNetTutar', fontToplam,
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 100),
        brush: PdfBrushes.white,
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));

    final PdfFont contentFont = font;

    page.graphics.drawString('Amount', contentFont,
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 33),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.bottom));

    //fatura no ve tarih yazdırma

    final String invoiceNumber =
        'Invoice Number: \t\t$faturaNo\nInvoice Date:   \t\t\t$faturaTarihi';
    final Size contentSize = contentFont.measureString(invoiceNumber);

    final PdfLayoutResult result =
        PdfTextElement(text: invoiceNumber, font: contentFont).draw(
            page: page,
            bounds: Rect.fromLTWH(pageSize.width - (contentSize.width + 60),
                300, contentSize.width + 30, pageSize.height - 120))!;

    //alıcı adres ve bilgileri yazdırma
    String aliciaddress =
        '${invoice.customer.name}\n${invoice.customer.address}\n${invoice.customer.email}\n${invoice.customer.phone}';
    PdfTextElement(text: aliciaddress, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(30, 150,
            pageSize.width - (contentSize.width + 30), pageSize.height - 120));

    //satıcı adres ve bilgi yazdırma
    String saticiaddress =
        '${invoice.supplier.name}\n${invoice.supplier.address}\n${invoice.supplier.email}\n${invoice.supplier.phone}';
    PdfTextElement(text: saticiaddress, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(
            pageSize.width - (contentSize.width + 60), 200, 180, 100));

    //açıklama yazdırma
    String aciklama = invoice.info.description;
    PdfTextElement(text: aciklama, font: contentFont).draw(
        page: page, bounds: Rect.fromLTWH(30, 250, 250, pageSize.height - 120));

    //firma logosu yazdırma
    if (invoice.supplier.firmaLogo.isNotEmpty) {
      page.graphics.drawImage(
          PdfBitmap(await _resim(invoice.supplier.firmaLogo)),
          Rect.fromLTWH(pageSize.width - (contentSize.width + 60), 100,
              page.getClientSize().width / 4, page.size.height / 9));
    }

    //sayfanın altı imza ve banka bilgileri
    Rect bounds = Rect.fromLTWH(0, 0, page.getClientSize().width, 100);
    PdfPageTemplateElement footer = PdfPageTemplateElement(bounds);

    final PdfPen linePen =
        PdfPen(PdfColor(142, 170, 219), dashStyle: PdfDashStyle.custom);
    linePen.dashPattern = <double>[3, 3];

    footer.graphics.drawLine(linePen, Offset(0, 0), Offset(page.size.width, 0));

    footer.graphics.drawRectangle(
        bounds: Rect.fromLTWH(10, 10, 180, 70),
        pen: PdfPen(PdfColor(142, 170, 219)));

    invoice.customer.imza != null
        ? footer.graphics.drawImage(
            PdfBitmap(await _resim(invoice.customer.imza!)),
            Rect.fromLTWH(15, 15, page.getClientSize().width / 3, 60))
        : null;
    String bankaBilgisi =
        '\nAccount Name__: ${bankaBilgileri['accountName']}\nSort Code_______: ${bankaBilgileri['sortCode']}\nAccount Number: ${bankaBilgileri['accountNumber']}';
    final Size textSize = contentFont.measureString(bankaBilgisi);
    //page.size.width / 1.8
    footer.graphics.drawString(
        bounds: Rect.fromLTWH(
            page.getClientSize().width - (15 + textSize.width),
            20,
            page.getClientSize().width,
            80),
        bankaBilgisi,
        font);
    document.template.bottom = footer;

    //faturadaki ürünlerin tablosunu yazdırma
    Rect? totalPriceCellBounds;
    Rect? quantityCellBounds;

    grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
      final PdfGrid grid = sender as PdfGrid;
      if (args.cellIndex == grid.columns.count - 1) {
        totalPriceCellBounds = args.bounds;
      } else if (args.cellIndex == grid.columns.count - 2) {
        quantityCellBounds = args.bounds;
      }
    };

    PdfLayoutResult? resultgrid = grid.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 10, 0, 0))!;

    //ürün tablosunun altına toplam tutarları yazdırma
    if (urunSayisi <= 8) {
      page.graphics.drawString('Net Total', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              resultgrid.bounds.bottom + 15,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page.graphics.drawString('$toplamTutar', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              resultgrid.bounds.bottom + 15,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));

      page.graphics.drawString('Vat', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              resultgrid.bounds.bottom + 30,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page.graphics.drawString('£ $toplamKDV', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              resultgrid.bounds.bottom + 30,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));
      page.graphics.drawLine(
          PdfPens.black,
          Offset(quantityCellBounds!.left, resultgrid.bounds.bottom + 50),
          Offset(page.size.width, resultgrid.bounds.bottom + 50));

      page.graphics.drawString('Total amount due', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              resultgrid.bounds.bottom + 60,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page.graphics.drawString('£ $toplamNetTutar', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              resultgrid.bounds.bottom + 60,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));

      page.graphics.drawLine(
          PdfPens.gray,
          Offset(quantityCellBounds!.left, resultgrid.bounds.bottom + 75),
          Offset(page.size.width, resultgrid.bounds.bottom + 75));

      page.graphics.drawLine(
          PdfPens.gray,
          Offset(quantityCellBounds!.left, resultgrid.bounds.bottom + 77),
          Offset(page.size.width, resultgrid.bounds.bottom + 77));
    } else if (urunSayisi > 8 && urunSayisi < 12) {
      /* page2!.graphics
          .drawLine(PdfPens.black, Offset(0, 0), Offset(page.size.width, 0)); */

      page2!.graphics.drawString('Net Total', font,
          bounds: Rect.fromLTWH(quantityCellBounds!.left, 15,
              quantityCellBounds!.width, quantityCellBounds!.height));

      page2.graphics.drawString('$toplamTutar', font,
          bounds: Rect.fromLTWH(totalPriceCellBounds!.left, 15,
              totalPriceCellBounds!.width, totalPriceCellBounds!.height));

      page2.graphics.drawString('Vat', font,
          bounds: Rect.fromLTWH(quantityCellBounds!.left, 30,
              quantityCellBounds!.width, quantityCellBounds!.height));

      page2.graphics.drawString('£ $toplamKDV', font,
          bounds: Rect.fromLTWH(totalPriceCellBounds!.left, 30,
              totalPriceCellBounds!.width, totalPriceCellBounds!.height));

      page2.graphics.drawLine(PdfPens.black,
          Offset(quantityCellBounds!.left, 50), Offset(page.size.width, 50));

      page2.graphics.drawString('Total amount due', font,
          bounds: Rect.fromLTWH(quantityCellBounds!.left, 60,
              quantityCellBounds!.width, quantityCellBounds!.height));

      page2.graphics.drawString('£ $toplamNetTutar', font,
          bounds: Rect.fromLTWH(totalPriceCellBounds!.left, 60,
              totalPriceCellBounds!.width, totalPriceCellBounds!.height));

      page2.graphics.drawLine(PdfPens.gray,
          Offset(quantityCellBounds!.left, 75), Offset(page.size.width, 75));

      page2.graphics.drawLine(PdfPens.gray,
          Offset(quantityCellBounds!.left, 77), Offset(page.size.width, 77));
    } else if (urunSayisi >= 12 && urunSayisi <= 33) {
      page2!.graphics.drawString('Net Total', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              resultgrid.bounds.bottom + 15,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page2.graphics.drawString('$toplamTutar', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              resultgrid.bounds.bottom + 15,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));

      page2.graphics.drawString('Vat', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              resultgrid.bounds.bottom + 30,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page2.graphics.drawString('£ $toplamKDV', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              resultgrid.bounds.bottom + 30,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));
      page2.graphics.drawLine(
          PdfPens.black,
          Offset(quantityCellBounds!.left, resultgrid.bounds.bottom + 50),
          Offset(page.size.width, resultgrid.bounds.bottom + 50));

      page2.graphics.drawString('Total amount due', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              resultgrid.bounds.bottom + 60,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page2.graphics.drawString('£ $toplamNetTutar', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              resultgrid.bounds.bottom + 60,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));

      page2.graphics.drawLine(
          PdfPens.gray,
          Offset(quantityCellBounds!.left, resultgrid.bounds.bottom + 75),
          Offset(page.size.width, resultgrid.bounds.bottom + 75));

      page2.graphics.drawLine(
          PdfPens.gray,
          Offset(quantityCellBounds!.left, resultgrid.bounds.bottom + 77),
          Offset(page.size.width, resultgrid.bounds.bottom + 77));
    } else if (urunSayisi > 33 && urunSayisi <= 36) {
      /* page3!.graphics
          .drawLine(PdfPens.black, Offset(0, 0), Offset(page.size.width, 0)); */

      page3!.graphics.drawString('Net Total', font,
          bounds: Rect.fromLTWH(quantityCellBounds!.left, 15,
              quantityCellBounds!.width, quantityCellBounds!.height));

      page3.graphics.drawString('$toplamTutar', font,
          bounds: Rect.fromLTWH(totalPriceCellBounds!.left, 15,
              totalPriceCellBounds!.width, totalPriceCellBounds!.height));

      page3.graphics.drawString('Vat', font,
          bounds: Rect.fromLTWH(quantityCellBounds!.left, 30,
              quantityCellBounds!.width, quantityCellBounds!.height));

      page3.graphics.drawString('£ $toplamKDV', font,
          bounds: Rect.fromLTWH(totalPriceCellBounds!.left, 30,
              totalPriceCellBounds!.width, totalPriceCellBounds!.height));

      page3.graphics.drawLine(PdfPens.black,
          Offset(quantityCellBounds!.left, 50), Offset(page.size.width, 50));

      page3.graphics.drawString('Total amount due', font,
          bounds: Rect.fromLTWH(quantityCellBounds!.left, 60,
              quantityCellBounds!.width, quantityCellBounds!.height));

      page3.graphics.drawString('£ $toplamNetTutar', font,
          bounds: Rect.fromLTWH(totalPriceCellBounds!.left, 60,
              totalPriceCellBounds!.width, totalPriceCellBounds!.height));

      page3.graphics.drawLine(PdfPens.gray,
          Offset(quantityCellBounds!.left, 75), Offset(page.size.width, 75));

      page3.graphics.drawLine(PdfPens.gray,
          Offset(quantityCellBounds!.left, 77), Offset(page.size.width, 77));
    } else {
      page3!.graphics.drawString('Net Total', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              resultgrid.bounds.bottom + 15,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page3.graphics.drawString('$toplamTutar', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              resultgrid.bounds.bottom + 15,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));

      page3.graphics.drawString('Vat', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              resultgrid.bounds.bottom + 30,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page3.graphics.drawString('£ $toplamKDV', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              resultgrid.bounds.bottom + 30,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));
      page3.graphics.drawLine(
          PdfPens.black,
          Offset(quantityCellBounds!.left, resultgrid.bounds.bottom + 50),
          Offset(page.size.width, resultgrid.bounds.bottom + 50));

      page3.graphics.drawString('Total amount due', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              resultgrid.bounds.bottom + 60,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page3.graphics.drawString('£ $toplamNetTutar', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              resultgrid.bounds.bottom + 60,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));

      page3.graphics.drawLine(
          PdfPens.gray,
          Offset(quantityCellBounds!.left, resultgrid.bounds.bottom + 75),
          Offset(page.size.width, resultgrid.bounds.bottom + 75));

      page3.graphics.drawLine(
          PdfPens.gray,
          Offset(quantityCellBounds!.left, resultgrid.bounds.bottom + 77),
          Offset(page.size.width, resultgrid.bounds.bottom + 77));
    }

    final List<int> bytes = await document.save();

    document.dispose();

    return bytes;
    //await saveAndLaunchFile(bytes, '$faturaNo.pdf');
  }

  Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
    final path = (await getExternalStorageDirectory())!.path;
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open('$path/$fileName');
  }

  Future<void> saveFile(List<int> bytes, String fileName) async {
    final path = (await getExternalStorageDirectory())!.path;
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    //return file.path;
    //OpenFile.open('$path/$fileName');
  }

  //ürün ekleme fonksiyonu
  void addProducts(String description, String quantity, double unitPrice,
      double vat, double total, PdfGrid grid) {}

  //resimi uint8list türüne çevirme
  Future<List<int>> _resim(String imza) async {
    var dataa = imza.codeUnits;
    final data = Uint8List.fromList(dataa);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<Uint8List> _font() async {
    final data = await rootBundle.load('assets/fonts/Roboto-Medium.ttf');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<Uint8List> _fontBlack() async {
    final data = await rootBundle.load('assets/fonts/Roboto-Black.ttf');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
