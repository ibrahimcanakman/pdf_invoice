import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/page/description_add_page.dart';

final tarihProvider = StateProvider<DateTime>(
  (ref) => DateTime.now(),
);

class TarihSec extends ConsumerWidget {
  const TarihSec({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarih Seç'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              DateTime seciliGun = await gunSec(context);

              /* String secilenTarih =
                  '${seciliGun.day}.${seciliGun.month}.${seciliGun.year}'; */
              ref.read(tarihProvider.notifier).update((state) => seciliGun);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DescriptionAddPage(),
                  ));
            },
            child: Text('Tarih Seç')),
      ),
    );
  }

  Future<DateTime> gunSec(BuildContext context) async {
    final DateTime? secili = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 3),
        lastDate: DateTime(DateTime.now().year + 3));
    return secili!;
  }
}
