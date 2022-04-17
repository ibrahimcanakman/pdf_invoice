import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/all_providers.dart';

// ignore: must_be_immutable
class AliciBilgisiDuzenle extends ConsumerWidget {
  AliciBilgisiDuzenle({Key? key}) : super(key: key);
  final TextEditingController _adiController = TextEditingController();
  final TextEditingController _adresiController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<TextEditingController> controllerler = [
      _adiController,
      _adresiController,
      _telefonController,
      _emailController
    ];
    _adiController.text = ref.watch(aliciSecSeciliMusteriProvider)!['adi'];
    _adresiController.text =
        ref.watch(aliciSecSeciliMusteriProvider)!['adresi'];
    _telefonController.text =
        ref.watch(aliciSecSeciliMusteriProvider)!['telefon'];
    _emailController.text = ref.watch(aliciSecSeciliMusteriProvider)!['email'];
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
          title: const Text('Alıcı Bilgisi Düzenleme'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                controller: _adiController,
                decoration: InputDecoration(
                    label: const Text('Müşteri Adı:'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 50,
              ),
              TextFormField(
                controller: _adresiController,
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
                controller: _telefonController,
                decoration: InputDecoration(
                    label: const Text('Telefon:'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 50,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    label: const Text('E-Mail:'),
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
                            child: const Text('Alanlar boş bırakılamaz'),
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
                                .collection(ref.watch(saticiAdi))
                                .doc(ref.watch(
                                    aliciSecSeciliMusteriProvider)!['adi'])
                                .delete();
                            await _firestore
                                .collection(ref.watch(saticiAdi))
                                .doc(_adiController.text.trim())
                                .set(eklenecakMap);
                            var gelenBilgi = await _firestore
                                .collection(ref.watch(saticiAdi))
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
