import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/page/anasayfa.dart';
import 'package:pdf_invoice/provider/all_providers.dart';
import 'package:pdf_invoice/translations/locale_keys.g.dart';

class AyarlarSayfasi extends ConsumerStatefulWidget {
  const AyarlarSayfasi({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AyarlarSayfasiState();
}

class _AyarlarSayfasiState extends ConsumerState<AyarlarSayfasi> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  //String dropdownDeger = 'Artan Sayı';

  @override
  void initState() {
    super.initState();
    faturaNoBicimGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.ayarlar.tr()),
      ),
      body: ref.watch(faturaNoBicimProvider) == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                            await context
                                .setLocale(const Locale('en'))
                                .whenComplete(() {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AnaSayfa(),
                                  ),
                                  (route) => false);
                            });
                          },
                          icon: const Icon(Icons.language),
                          label: const Text('English')),
                      ElevatedButton.icon(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                            await context
                                .setLocale(const Locale('tr'))
                                .whenComplete(() {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AnaSayfa(),
                                  ),
                                  (route) => false);
                            });
                          },
                          icon: const Icon(Icons.language),
                          label: const Text('Türkçe')),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(
                          child: Text(
                        'Fatura Numarası Biçimi:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      Expanded(
                        child: Material(
                          borderRadius: BorderRadius.circular(15),
                          elevation: 16,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(20),
                              elevation: 16,
                              value: ref.watch(faturaNoBicimProvider),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Artan Sayı',
                                  child: Text('Artan Sayı'),
                                ),
                                DropdownMenuItem(
                                    value: 'Tarih + Sayı',
                                    child: Text('Tarih + Sayı')),
                              ],
                              onChanged: (value) {
                                ref
                                    .read(faturaNoBicimProvider.notifier)
                                    .update((state) => value);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        onPressed: () {
                          degisiklikleriKaydet()
                              .then((value) => Navigator.pop(context));
                        },
                        child: Text('Kaydet')),
                  )
                ],
              ),
            ),
    );
  }

  Future<void> degisiklikleriKaydet() async {
    await _firestore
        .collection(auth.currentUser!.email!)
        .doc('saticiFirma')
        .collection('faturaNoBicim')
        .doc('faturaNoBicim')
        .set({'faturaNoBicim': ref.watch(faturaNoBicimProvider)});
  }

  Future<void> faturaNoBicimGetir() async {
    var bicimSS = await _firestore
        .collection(auth.currentUser!.email!)
        .doc('saticiFirma')
        .collection('faturaNoBicim')
        .doc('faturaNoBicim')
        .get();
    String? bicim = bicimSS.data()!['faturaNoBicim'];
    ref.read(faturaNoBicimProvider.notifier).update((state) => bicim);
  }
}
