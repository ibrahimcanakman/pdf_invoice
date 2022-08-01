import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/constants/constant.dart';

import '../provider/all_providers.dart';
import '../translations/locale_keys.g.dart';

class AliciBilgisiDuzenle extends ConsumerStatefulWidget {
  const AliciBilgisiDuzenle({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AliciBilgisiDuzenleState();
}

class _AliciBilgisiDuzenleState extends ConsumerState<AliciBilgisiDuzenle> {
  final TextEditingController _adiController = TextEditingController();
  final TextEditingController _adresiController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    degerAta();
  }

  @override
  Widget build(BuildContext context) {
    List<TextEditingController> controllerler = [
      _adiController,
      _adresiController,
      _telefonController,
      _emailController
    ];
    /* _adiController.text = ref.watch(aliciSecSeciliMusteriProvider)!['adi'];
    _adresiController.text =
        ref.watch(aliciSecSeciliMusteriProvider)!['adresi'];
    _telefonController.text =
        ref.watch(aliciSecSeciliMusteriProvider)!['telefon'];
    _emailController.text = ref.watch(aliciSecSeciliMusteriProvider)!['email']; */
    return WillPopScope(
      onWillPop: () {
        ref
            .read(aliciSecBottomNavBarProvider.notifier)
            .update((state) => false);
        return Future.value(true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(LocaleKeys.alici_bilgisi_duzenleme.tr()),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                controller: _adiController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                    label: Text(LocaleKeys.musteri_adi.tr()),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 50,
              ),
              TextFormField(
                controller: _adresiController,
                textCapitalization: TextCapitalization.words,
                maxLines: 5,
                decoration: InputDecoration(
                    label: Text(LocaleKeys.adresi.tr()),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 50,
              ),
              TextFormField(
                controller: _telefonController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    label: Text(LocaleKeys.telefon.tr()),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 50,
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    label: Text(LocaleKeys.email.tr()),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      onPressed: () async {
                        bool kontrol = false;
                        for (var item in controllerler) {
                          kontrol = item.text.isEmpty ? false : true;
                        }
                        if (!kontrol) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child:
                                Text(LocaleKeys.alanlar_bos_birakilamaz.tr()),
                          )));
                        } else {
                          Map<String, dynamic> eklenecakMap = {
                            'adi': _adiController.text.trim(),
                            'adresi': _adresiController.text.trim(),
                            'telefon': _telefonController.text.trim(),
                            'email': _emailController.text.trim()
                          };
                          try {
                            await _firestore
                                .collection(auth.currentUser!.displayName!)
                                .doc(ref.watch(
                                    aliciSecSeciliMusteriProvider)!['adi'])
                                .delete();
                            await _firestore
                                .collection(auth.currentUser!.displayName!)
                                .doc(_adiController.text.trim())
                                .set(eklenecakMap);
                            var gelenBilgi = await _firestore
                                .collection(auth.currentUser!.displayName!)
                                .get();

                            ref
                                .read(provider.notifier)
                                .update((state) => gelenBilgi.docs);
                            Navigator.pop(context);
                            ref
                                .read(aliciSecBottomNavBarProvider.notifier)
                                .update((state) => false);
                          } catch (e) {
                            showDialog<void>(
                              context: context,
                              barrierDismissible: true, // user must tap button!
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(LocaleKeys.hata_olustu.tr()),
                                  content: Text(LocaleKeys
                                      .musteri_kaydi_yapilirken_hata_olustu_tekrar_deneyin
                                      .tr()),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(LocaleKeys.tamam.tr()),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        }
                      },
                      child: Text(LocaleKeys.kaydet.tr())))
            ],
          ),
        ),
      ),
    );
  }

  void degerAta() {
    Map<String, dynamic> seciliMusteri = {};
    seciliMusteri.addAll(ref.read(aliciSecSeciliMusteriProvider)!);
    _adiController.text = seciliMusteri['adi'];
    _adresiController.text = seciliMusteri['adresi'];
    _telefonController.text = seciliMusteri['telefon'];
    _emailController.text = seciliMusteri['email'];
  }
}
