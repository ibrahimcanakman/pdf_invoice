/* import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/page/description_add_page.dart';

import '../translations/locale_keys.g.dart';

final saticiFirmaProvider = StateProvider<String?>(
  (ref) => null,
);
final saticiAdresProvider = StateProvider<String?>(
  (ref) => null,
);
final aliciFirmaProvider = StateProvider<String?>(
  (ref) => null,
);
final aliciAdresProvider = StateProvider<String?>(
  (ref) => null,
);
final aciklamaProvider = StateProvider<String?>(
  (ref) => null,
);

// ignore: must_be_immutable
class HomePage extends ConsumerWidget {
  HomePage({Key? key}) : super(key: key);
  TextEditingController saticiFirmaController = TextEditingController();
  TextEditingController saticiAdresController = TextEditingController();
  TextEditingController aliciFirmaController = TextEditingController();
  TextEditingController aliciAdresController = TextEditingController();
  TextEditingController aciklamaController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.fatura_kes.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Form(
                child: TextFormField(
              controller: saticiFirmaController,
              decoration: InputDecoration(
                  label: Text(LocaleKeys.satici_firma.tr()),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            )),
            Form(
                child: TextFormField(
              controller: saticiAdresController,
              decoration: InputDecoration(
                  label: Text(LocaleKeys.satici_firma_adres.tr()),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            )),
            Form(
                child: TextFormField(
              controller: aliciFirmaController,
              decoration: InputDecoration(
                  label: Text(LocaleKeys.alici_firma.tr()),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            )),
            Form(
                child: TextFormField(
              controller: aliciAdresController,
              decoration: InputDecoration(
                  label: Text(LocaleKeys.alici_firma_adres.tr()),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            )),
            Form(
                child: TextFormField(
              controller: aciklamaController,
              decoration: InputDecoration(
                  label: Text(LocaleKeys.aciklama.tr()),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            )),
            ElevatedButton(
                onPressed: () {
                  ref
                      .read(saticiFirmaProvider.notifier)
                      .update((state) => saticiFirmaController.text.trim());
                  ref
                      .read(saticiAdresProvider.notifier)
                      .update((state) => saticiAdresController.text.trim());
                  ref
                      .read(aliciFirmaProvider.notifier)
                      .update((state) => aliciFirmaController.text.trim());
                  ref
                      .read(aliciAdresProvider.notifier)
                      .update((state) => aliciAdresController.text.trim());
                  ref
                      .read(aciklamaProvider.notifier)
                      .update((state) => aciklamaController.text.trim());
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const DescriptionAddPage(),
                  ));
                },
                child: Text(LocaleKeys.urun_ekle.tr()))
          ],
        ),
      ),
    );
  }
}
 */