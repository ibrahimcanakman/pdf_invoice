import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/all_providers.dart';
import '../translations/locale_keys.g.dart';

// ignore: must_be_immutable
class AliciBilgisiEkle extends ConsumerWidget {
  AliciBilgisiEkle({Key? key}) : super(key: key);

  TextEditingController adiController = TextEditingController();
  TextEditingController adresiController = TextEditingController();
  TextEditingController telefonController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final _aliciKaydiKey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> kayitliMusteriAdlari = ['saticifirma'];
    for (var item in ref.watch(aliciListesiProvider)) {
      kayitliMusteriAdlari.add(item['adi'].toString().toLowerCase());
    }
    /* List<TextEditingController> controllerler = [
      adiController,
      adresiController,
      telefonController,
      emailController
    ]; */
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(LocaleKeys.alici_bilgisi_ekleme.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _aliciKaydiKey,
          child: Column(
            children: [
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return LocaleKeys.bos_birakilamaz.tr();
                  } else if (kayitliMusteriAdlari
                      .contains(value.toLowerCase())) {
                    return LocaleKeys.bu_isimle_kayitli_bir_musteri_bulunmakta.tr();
                  } else {
                    return null;
                  }
                },
                controller: adiController,
                decoration: InputDecoration(
                    label: Text(LocaleKeys.musteri_adi.tr()),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 50,
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return LocaleKeys.bos_birakilamaz.tr();
                  } else {
                    return null;
                  }
                },
                controller: adresiController,
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) {
                    return LocaleKeys.bos_birakilamaz.tr();
                  } else {
                    return null;
                  }
                },
                controller: telefonController,
                decoration: InputDecoration(
                    label: Text(LocaleKeys.telefon.tr()),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 50,
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) {
                    return LocaleKeys.bos_birakilamaz.tr();
                  } else if (!EmailValidator.validate(value)) {
                    return LocaleKeys.gecerli_bir_email_adresi_girin.tr();
                  } else {
                    return null;
                  }
                },
                controller: emailController,
                decoration: InputDecoration(
                    label: Text(LocaleKeys.email.tr()),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      onPressed: () async {
                        //bool kontrol = false;
                        /* for (var item in controllerler) {
                          kontrol = item.text.isEmpty ? false : true;
                        } */
                        if (_aliciKaydiKey.currentState!.validate()) {
                          Map<String, dynamic> eklenecakMap = {
                            'adi': adiController.text.trim(),
                            'adresi': adresiController.text.trim(),
                            'telefon': telefonController.text.trim(),
                            'email': emailController.text.trim()
                          };
                          try {
                            await _firestore
                                .collection(ref.watch(saticiAdi))
                                .doc(adiController.text.trim())
                                .set(eklenecakMap);
                            var gelenBilgi = await _firestore
                                .collection(ref.watch(saticiAdi))
                                .get();

                            ref
                                .read(provider.notifier)
                                .update((state) => gelenBilgi.docs);
                            var liste = ref.watch(provider);
                            List<Map<String, dynamic>> aliciListesi = [];

                            if (liste.isNotEmpty) {
                              for (var item in liste) {
                                item.id == 'saticiFirma'
                                    ? null
                                    : aliciListesi.add(item.data());
                              }
                              Future(
                                () => ref
                                    .read(aliciListesiProvider.notifier)
                                    .update((state) => aliciListesi),
                              );
                            }
                            Navigator.pop(context);
                          } catch (e) {
                            showDialog<void>(
                              context: context,
                              barrierDismissible: true, // user must tap button!
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(LocaleKeys.hata_olustu.tr()),
                                  content: Text(LocaleKeys.musteri_kaydi_yapilirken_hata_olustu_tekrar_deneyin.tr()),
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
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: Text(LocaleKeys.alanlari_dogru_doldurdugunuzdan_emin_olun.tr()),
                          )));
                        }
                      },
                      child: Text(LocaleKeys.kaydet.tr())))
            ],
          ),
        ),
      ),
    );
  }
}
