import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/all_providers.dart';

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
        title: const Text('Alıcı Bilgisi Ekleme'),
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
                    return 'Boş bırakılamaz';
                  } else if (kayitliMusteriAdlari
                      .contains(value.toLowerCase())) {
                    return 'Bu isimle kayıtlı bir müşteri bulunmakta';
                  } else {
                    return null;
                  }
                },
                controller: adiController,
                decoration: InputDecoration(
                    label: const Text('Müşteri Adı:'),
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
                    return 'Boş bırakılamaz';
                  } else {
                    return null;
                  }
                },
                controller: adresiController,
                maxLines: 5,
                decoration: InputDecoration(
                    label: const Text('Adresi:'),
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
                    return 'Boş bırakılamaz';
                  } else {
                    return null;
                  }
                },
                controller: telefonController,
                decoration: InputDecoration(
                    label: const Text('Telefon:'),
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
                    return 'Boş bırakılamaz';
                  } else if (!EmailValidator.validate(value)) {
                    return 'Geçerli bir e-mail adresi giriniz.';
                  } else {
                    return null;
                  }
                },
                controller: emailController,
                decoration: InputDecoration(
                    label: const Text('E-Mail:'),
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
                                  title: const Text('Hata Oluştu'),
                                  content: const Text(
                                      'Müşteri kaydı yapılırken hata oluştu, tekrar deneyin...'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Tamam'),
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
                            child: const Text(
                                'Alanları doğru doldurduğunuzdan emin olun.'),
                          )));
                        }
                      },
                      child: const Text('KAYDET')))
            ],
          ),
        ),
      ),
    );
  }
}
