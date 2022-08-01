import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf_invoice/page/faturalarim.dart';
import 'package:pdf_invoice/translations/locale_keys.g.dart';

import '../provider/all_providers.dart';

class FaturaOlusturulduEkrani extends ConsumerStatefulWidget {
  const FaturaOlusturulduEkrani({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FaturaOlusturulduEkraniState();
}

class _FaturaOlusturulduEkraniState
    extends ConsumerState<FaturaOlusturulduEkrani> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    if (ref.read(faturaKaydedildiMiProvider) != null) {
      Future.delayed(
        const Duration(seconds: 3),
        () {
          saticiBilgileriniGetir().then((value) {
            ref
                .read(faturaKaydedildiMiProvider.notifier)
                .update((state) => null);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const Faturalarim(),
                ),
                (route) => false);
            /* faturalariGetir().then((value) {
              
            }); */
          });
        },
      );
    }
    return Scaffold(
      body: Center(
        child: ref.watch(faturaKaydedildiMiProvider) == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    LocaleKeys.fatura_kaydediliyor.tr(),
                    style: Theme.of(context).textTheme.headline6,
                  )
                ],
              )
            : ref.read(faturaKaydedildiMiProvider) == true
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 60,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        LocaleKeys.fatura_kaydi_basarili.tr(),
                        style: Theme.of(context).textTheme.headline6,
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 60),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        LocaleKeys.fatura_kaydi_basarisiz.tr(),
                        style: Theme.of(context).textTheme.headline6,
                      )
                    ],
                  ),
      ),
    );
  }

  Future<void> saticiBilgileriniGetir() async {
    await _firestore
        .doc('${_auth.currentUser!.displayName!}/saticiFirma')
        .get()
        .then((value) async {
      var bilgiler = value.data();
      if (bilgiler!.keys.contains('imza')) {
        if (bilgiler['imza'] != null) {
          //ref.read(imzaProvider.notifier).update((state) => bilgiler['imza']);
          var dataa = bilgiler['imza'].codeUnits;
          final data = Uint8List.fromList(dataa);
          var imza =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          ref.read(imzapngProvider.notifier).update((state) => imza);
        } else {
          ref.read(imzapngProvider.notifier).update((state) => null);
          //ref.read(imzaProvider.notifier).update((state) => null);
        }
      }

      if (bilgiler['firmaLogo'].isEmpty) {
        ref.read(logoProvider.notifier).update((state) => null);
      } else {
        var dataa = bilgiler['firmaLogo'].codeUnits;
        final data = Uint8List.fromList(dataa);
        var logo =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        ref.read(logoProvider.notifier).update((state) => logo);
      }

      ref
          .read(faturaFormatProvider.notifier)
          .update((state) => bilgiler['faturaFormati']);
      ref
          .read(faturaFormatIndexProvider.notifier)
          .update((state) => bilgiler['faturaFormati'] == 'Format1' ? 0 : 1);
      await _firestore
          .doc(
              '${_auth.currentUser!.displayName!}/saticiFirma/faturaNoBicim/faturaNoBicim')
          .get()
          .then((value) {
        ref
            .read(faturaNoBicimProvider.notifier)
            .update((state) => value.data()!['faturaNoBicim']);
      });
    });
  }

  /* Future<void> faturalariGetir() async {
    //var value = await _databaseHelper.getir();
    //ref.read(saticiAdi.notifier).update((state) => _auth.currentUser!.email!);
    var gelenFaturalarSS = await _firestore
        .collection(_auth.currentUser!.displayName!)
        .doc('saticiFirma')
        .collection('faturalar')
        .get();
    var gelenFaturalarListesi = gelenFaturalarSS.docs;
    gelenFaturalarListesi
        .sort((a, b) => b.data()['createdAt'].compareTo(a.data()['createdAt']));
    List<bool> checkboxList = [
      for (var i = 0; i <= gelenFaturalarListesi.length; i++) false
    ];
    debugPrint('gelen liste uzunluğu ${checkboxList.length}');
    ref.read(faturaCheckboxProvider.notifier).update((state) => checkboxList);
    ref
        .read(faturalarProvider.notifier)
        .update((state) => gelenFaturalarListesi);
  } */
}
