import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_invoice/model/invoice.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfFatura1 {
  /* final picker = ImagePicker();
  Uint8List? image; */

  Future<List<int>> createPDF(Invoice invoice, String faturaNo,
      String faturaTarihi, Map<String, dynamic> bankaBilgileri) async {
    PdfFont font = PdfTrueTypeFont(await _font(), 12);
    PdfFont fontBaslik = PdfTrueTypeFont(await _fontBlack(), 30);

    PdfDocument document = PdfDocument();
    document.pageSettings.size = PdfPageSize.a4;

    final page = document.pages.add();

    if (invoice.supplier.firmaLogo.isNotEmpty) {
      page.graphics.drawImage(
          PdfBitmap(await _resim(invoice.supplier.firmaLogo)),
          Rect.fromLTWH(
              50, 0, page.getClientSize().width / 4, page.size.height / 9));
    }

    //debugPrint(image!.toList().length.toString());

    //büyük harfle INVOICE yazısı yazdırma
    page.graphics.drawString('INVOICE', fontBaslik,
        brush: PdfBrushes.slateGray, bounds: const Rect.fromLTWH(300, 0, 0, 0));

    //SATICI BİLGİLERİNİN YAZILDIĞI KUTU
    PdfTextElement aliciText = PdfTextElement(
        text:
            '${invoice.supplier.name}\n${invoice.supplier.address}\n${invoice.supplier.email}\n${invoice.supplier.phone}',
        font: font);
    aliciText.draw(
        page: page, bounds: Rect.fromLTWH(0, page.size.height / 7, 250, 100))!;

    //ALICI BİLGİLERİNİN YAZILDIĞI KUTU
    PdfTextElement saticiText = PdfTextElement(
        text:
            '${invoice.customer.name}\n${invoice.customer.address}\n${invoice.customer.email}\n${invoice.customer.phone}',
        font: font);
    saticiText.draw(
        page: page,
        bounds: Rect.fromLTWH(
            page.size.width / 2.2, page.size.height / 17, 250, 100))!;

    //FATURA NO VE FATURA TARİHİ YAZILAN KUTU
    PdfTemplate faturanodatetemplate = PdfTemplate(250, 50);

    faturanodatetemplate.graphics!.drawString(
        'Invoice Number:\nInvoice Date:',
        format: PdfStringFormat(
            wordWrap: PdfWordWrapType.word, measureTrailingSpaces: true),
        font,
        brush: PdfBrushes.black,
        bounds: const Rect.fromLTWH(5, 5, 0, 0));

    faturanodatetemplate.graphics!.drawString(
        '$faturaNo\n$faturaTarihi',
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            wordWrap: PdfWordWrapType.word,
            measureTrailingSpaces: true),
        font,
        brush: PdfBrushes.black,
        bounds: const Rect.fromLTWH(245, 5, 0, 0));
    page.graphics.drawPdfTemplate(faturanodatetemplate,
        Offset(page.size.width / 2.2, page.size.height / 5));

    //AÇIKLAMA YAZILAN KUTU
    PdfTextElement aciklamaText =
        PdfTextElement(text: invoice.info.description, font: font);
    aciklamaText.draw(
        page: page,
        bounds: Rect.fromLTWH(5, page.size.height / 3.6, page.size.width, 50))!;

    //sayfanın alt kısmında banka bilgileri ve imza kısmı
    Rect bounds = Rect.fromLTWH(0, 0, page.getClientSize().width, 80);
    PdfPageTemplateElement footer = PdfPageTemplateElement(bounds);
    footer.graphics.drawLine(
        PdfPens.black, const Offset(0, 0), Offset(page.size.width, 0));

    /* final PdfPath path = PdfPath();
    path.addLine(Offset(10, 10), Offset(10, 80));
    path.addLine(Offset(190, 80), Offset(190, 10));
    path.addLine(Offset(190, 10), Offset(10, 10));
    path.draw(graphics: footer.graphics, bounds: Rect.zero); */
    footer.graphics.drawRectangle(
        bounds: Rect.fromLTWH(10, 10, 180, 70), pen: PdfPens.gray);

    invoice.customer.imza != null
        ? footer.graphics.drawImage(
            PdfBitmap(await _resim(invoice.customer.imza!)),
            Rect.fromLTWH(15, 15, page.getClientSize().width / 3, 60))
        : null;
    //var a = await _resim();
    //debugPrint(a.length.toString());
    String bankaBilgisi =
        '\nAccount Name__: ${bankaBilgileri['accountName']}\nSort Code_______: ${bankaBilgileri['sortCode']}\nAccount Number: ${bankaBilgileri['accountNumber']}';
    final Size textSize = font.measureString(bankaBilgisi);
    footer.graphics.drawString(
        bounds: Rect.fromLTWH(
            page.getClientSize().width - (15 + textSize.width),
            0,
            page.getClientSize().width,
            80),
        bankaBilgisi,
        font);
    document.template.bottom = footer;

    //ürünlerin tablo halinde yazılması
    Rect boundstable = const Rect.fromLTWH(0, 300, 0, 0);
    PdfPageTemplateElement table = PdfPageTemplateElement(boundstable);

    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.style.backgroundBrush = PdfBrushes.lightGray;

    header.cells[0].value = 'Description';
    header.cells[1].value = 'Quantity';
    header.cells[1].stringFormat.alignment = PdfTextAlignment.center;
    header.cells[2].value = 'Unit Price';
    header.cells[2].stringFormat.alignment = PdfTextAlignment.center;
    header.cells[3].value = 'VAT';
    header.cells[3].stringFormat.alignment = PdfTextAlignment.center;
    header.cells[4].value = 'Total';
    header.cells[4].stringFormat.alignment = PdfTextAlignment.center;

    int urunSayisi = invoice.items.length;

    PdfPage? page2;
    PdfPage? page3;
    if (urunSayisi > 10) {
      page2 = document.pages.add();
      if (urunSayisi > 35) {
        page3 = document.pages.add();
      }
    }
    PdfGridRow? row;
    double toplamTutar = 0;
    double toplamKDV = 0;
    double toplamNetTutar = 0;

    for (var i = 0; i < urunSayisi; i++) {
      row = grid.rows.add();
      row.cells[0].value = invoice.items[i].description;
      row.cells[1].value = invoice.items[i].quantity.toString();
      row.cells[1].stringFormat.alignment = PdfTextAlignment.center;
      row.cells[2].value = invoice.items[i].unitPrice.toString();
      row.cells[2].stringFormat.alignment = PdfTextAlignment.center;
      row.cells[3].value = invoice.items[i].vat.toString();
      row.cells[3].stringFormat.alignment = PdfTextAlignment.center;
      row.cells[4].value =
          (invoice.items[i].quantity * invoice.items[i].unitPrice).toString();
      toplamTutar += invoice.items[i].quantity * invoice.items[i].unitPrice;
      toplamKDV += (invoice.items[i].quantity *
              invoice.items[i].unitPrice *
              invoice.items[i].vat) /
          100;
    }
    toplamNetTutar = toplamTutar + toplamKDV;

    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable1Light,
        settings: PdfGridBuiltInStyleSettings(applyStyleForBandedRows: false));
    row!.style.backgroundBrush = PdfBrushes.white;

    grid.columns[0].width = 150;

    grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5),
        backgroundBrush: PdfBrushes.white,
        textBrush: PdfBrushes.black,
        font: font);
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
    PdfLayoutResult? result =
        grid.draw(page: page, graphics: table.graphics, bounds: boundstable);

    if (urunSayisi <= 10) {
      page.graphics.drawLine(
          PdfPens.black,
          Offset(0, result!.bounds.bottom + 10),
          Offset(page.size.width, result.bounds.bottom + 10));

      debugPrint(document.pages.count.toString() + 'index bu');
      page.graphics.drawString('Net Total', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              result.bounds.bottom + 15,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page.graphics.drawString('£ $toplamTutar', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              result.bounds.bottom + 15,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));

      page.graphics.drawString('Vat', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              result.bounds.bottom + 30,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page.graphics.drawString('£ $toplamKDV', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              result.bounds.bottom + 30,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));
      page.graphics.drawLine(
          PdfPens.black,
          Offset(quantityCellBounds!.left, result.bounds.bottom + 50),
          Offset(page.size.width, result.bounds.bottom + 50));

      page.graphics.drawString('Total amount due', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              result.bounds.bottom + 60,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page.graphics.drawString('£ $toplamNetTutar', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              result.bounds.bottom + 60,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));

      page.graphics.drawLine(
          PdfPens.gray,
          Offset(quantityCellBounds!.left, result.bounds.bottom + 75),
          Offset(page.size.width, result.bounds.bottom + 75));

      page.graphics.drawLine(
          PdfPens.gray,
          Offset(quantityCellBounds!.left, result.bounds.bottom + 77),
          Offset(page.size.width, result.bounds.bottom + 77));
    } else if (urunSayisi > 10 && urunSayisi < 14) {
      page2!.graphics
          .drawLine(PdfPens.black, Offset(0, 0), Offset(page.size.width, 0));

      page2.graphics.drawString('Net Total', font,
          bounds: Rect.fromLTWH(quantityCellBounds!.left, 15,
              quantityCellBounds!.width, quantityCellBounds!.height));

      page2.graphics.drawString('£ $toplamTutar', font,
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
    } else if (urunSayisi >= 14 && urunSayisi <= 35) {
      page2!.graphics.drawLine(
          PdfPens.black,
          Offset(0, result!.bounds.bottom + 10),
          Offset(page.size.width, result.bounds.bottom + 10));

      debugPrint(document.pages.count.toString() + 'index bu');
      page2.graphics.drawString('Net Total', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              result.bounds.bottom + 15,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page2.graphics.drawString('£ $toplamTutar', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              result.bounds.bottom + 15,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));

      page2.graphics.drawString('Vat', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              result.bounds.bottom + 30,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page2.graphics.drawString('£ $toplamKDV', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              result.bounds.bottom + 30,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));
      page2.graphics.drawLine(
          PdfPens.black,
          Offset(quantityCellBounds!.left, result.bounds.bottom + 50),
          Offset(page.size.width, result.bounds.bottom + 50));

      page2.graphics.drawString('Total amount due', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              result.bounds.bottom + 60,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page2.graphics.drawString('£ $toplamNetTutar', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              result.bounds.bottom + 60,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));

      page2.graphics.drawLine(
          PdfPens.gray,
          Offset(quantityCellBounds!.left, result.bounds.bottom + 75),
          Offset(page.size.width, result.bounds.bottom + 75));

      page2.graphics.drawLine(
          PdfPens.gray,
          Offset(quantityCellBounds!.left, result.bounds.bottom + 77),
          Offset(page.size.width, result.bounds.bottom + 77));
    } else if (urunSayisi > 35 && urunSayisi < 39) {
      page3!.graphics
          .drawLine(PdfPens.black, Offset(0, 0), Offset(page.size.width, 0));

      page3.graphics.drawString('Net Total', font,
          bounds: Rect.fromLTWH(quantityCellBounds!.left, 15,
              quantityCellBounds!.width, quantityCellBounds!.height));

      page3.graphics.drawString('£ $toplamTutar', font,
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
      page3!.graphics.drawLine(
          PdfPens.black,
          Offset(0, result!.bounds.bottom + 10),
          Offset(page.size.width, result.bounds.bottom + 10));

      debugPrint(document.pages.count.toString() + 'index bu');
      page3.graphics.drawString('Net Total', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              result.bounds.bottom + 15,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page3.graphics.drawString('£ $toplamTutar', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              result.bounds.bottom + 15,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));

      page3.graphics.drawString('Vat', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              result.bounds.bottom + 30,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page3.graphics.drawString('£ $toplamKDV', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              result.bounds.bottom + 30,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));
      page3.graphics.drawLine(
          PdfPens.black,
          Offset(quantityCellBounds!.left, result.bounds.bottom + 50),
          Offset(page.size.width, result.bounds.bottom + 50));

      page3.graphics.drawString('Total amount due', font,
          bounds: Rect.fromLTWH(
              quantityCellBounds!.left,
              result.bounds.bottom + 60,
              quantityCellBounds!.width,
              quantityCellBounds!.height));
      page3.graphics.drawString('£ $toplamNetTutar', font,
          bounds: Rect.fromLTWH(
              totalPriceCellBounds!.left,
              result.bounds.bottom + 60,
              totalPriceCellBounds!.width,
              totalPriceCellBounds!.height));

      page3.graphics.drawLine(
          PdfPens.gray,
          Offset(quantityCellBounds!.left, result.bounds.bottom + 75),
          Offset(page.size.width, result.bounds.bottom + 75));

      page3.graphics.drawLine(
          PdfPens.gray,
          Offset(quantityCellBounds!.left, result.bounds.bottom + 77),
          Offset(page.size.width, result.bounds.bottom + 77));
    }

    List<int> bytes = await document.save();
    document.dispose();

    return bytes;
    //saveAndLaunchFile(bytes, '$faturaNo.pdf');
  }

  Future<Uint8List> _font() async {
    final data = await rootBundle.load('assets/fonts/Roboto-Medium.ttf');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<Uint8List> _fontBlack() async {
    final data = await rootBundle.load('assets/fonts/Roboto-Black.ttf');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<List<int>> _resim(String imza) async {
    var dataa = imza.codeUnits;
    final data = Uint8List.fromList(dataa);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
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
}
