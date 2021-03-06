import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_invoice/constants/constant.dart';
import 'package:pdf_invoice/page/aciklama_ekle.dart';
import 'package:pdf_invoice/page/alici_sec.dart';
import 'package:pdf_invoice/page/coklu_fatura_gonder.dart';
import 'package:pdf_invoice/page/fatura_olusturuldu_onay_page.dart';
import 'package:pdf_invoice/page/faturalarim.dart';
import 'package:pdf_invoice/page/login_page.dart';

import '../provider/all_providers.dart';
import '../translations/locale_keys.g.dart';
import 'ayarlar.dart';

class AnaSayfa extends ConsumerStatefulWidget {
  const AnaSayfa({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends ConsumerState<AnaSayfa> {
  final TextEditingController _dogrulamaController = TextEditingController();

  final _dogrulamaKey = GlobalKey<FormState>();

  /* final _saticiKey = GlobalKey<FormState>();
  final TextEditingController _saticiAdiController = TextEditingController();
  TextEditingController _saticiAdresiController = TextEditingController();
  TextEditingController _saticiTelefonController = TextEditingController();
  TextEditingController _saticiEmailController = TextEditingController();
  TextEditingController _bankaAccountNameController = TextEditingController();
  TextEditingController _bankaSortCodeController = TextEditingController();
  TextEditingController _bankaAccountNumberController = TextEditingController(); */

  //late List<Map<String, dynamic>> saticiFirma;
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  @override
  void initState() {
    super.initState();
    //saticiyiLocaldenGetir();
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    yetkiSeviyesiGetir();
  }

  @override
  void dispose() {
    /* _saticiAdiController.dispose();
    _saticiAdresiController.dispose();
    _saticiTelefonController.dispose();
    _saticiEmailController.dispose();
    _bankaAccountNameController.dispose();
    _bankaSortCodeController.dispose();
    _bankaAccountNumberController.dispose(); */
    super.dispose();
  }

  /* saticiyiLocaldenGetir() async {
    saticiFirma = await _databaseHelper.getir();
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(LocaleKeys.anasayfa.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Fatura Kes Butonu
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 10,
                child: ElevatedButton(
                    onPressed: () async {
                      /* if (saticiFirma.isEmpty) {
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Kay??t Ol'),
                              content: Form(
                                  key: _saticiKey,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                            '??lk giri??iniz oldu??u i??in faturalarda kullan??lmak ??zere firman??z??n bilgilerini bir kereli??ine kaydetmelisiniz ! '),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              50,
                                        ),
                                        TextFormField(
                                          controller: _saticiAdiController,
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return 'Bo?? b??rak??lamaz...';
                                            } else {
                                              return null;
                                            }
                                          },
                                          decoration: InputDecoration(
                                              label: Text('Firma Ad??'),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15))),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                50),
                                        TextFormField(
                                          controller: _saticiAdresiController,
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return 'Bo?? b??rak??lamaz...';
                                            } else {
                                              return null;
                                            }
                                          },
                                          decoration: InputDecoration(
                                              label: Text('Firma Adresi'),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15))),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                50),
                                        TextFormField(
                                          controller: _saticiTelefonController,
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return 'Bo?? b??rak??lamaz...';
                                            } else {
                                              return null;
                                            }
                                          },
                                          decoration: InputDecoration(
                                              label: Text('Telefon'),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15))),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                50),
                                        TextFormField(
                                          controller: _saticiEmailController,
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return 'Bo?? b??rak??lamaz...';
                                            } else {
                                              return null;
                                            }
                                          },
                                          decoration: InputDecoration(
                                              label: Text('E-Mail'),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15))),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                50),
                                        TextFormField(
                                          controller:
                                              _bankaAccountNameController,
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return 'Bo?? b??rak??lamaz...';
                                            } else {
                                              return null;
                                            }
                                          },
                                          decoration: InputDecoration(
                                              label: Text('Bank Account Name'),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15))),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                50),
                                        TextFormField(
                                          controller: _bankaSortCodeController,
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return 'Bo?? b??rak??lamaz...';
                                            } else {
                                              return null;
                                            }
                                          },
                                          decoration: InputDecoration(
                                              label: Text('Bank Sort Code'),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15))),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                50),
                                        TextFormField(
                                          controller:
                                              _bankaAccountNumberController,
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return 'Bo?? b??rak??lamaz...';
                                            } else {
                                              return null;
                                            }
                                          },
                                          decoration: InputDecoration(
                                              label:
                                                  Text('Bank Account Number'),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15))),
                                        ),
                                      ],
                                    ),
                                  )),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Vazge??'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      if (_saticiKey.currentState!.validate()) {
                                        Map<String, dynamic> firmaBilgileri = {
                                          'adi': _saticiAdiController.text,
                                          'adresi':
                                              _saticiAdresiController.text,
                                          'email': _saticiEmailController.text,
                                          'telefon':
                                              _saticiTelefonController.text,
                                          'bankaAccountName':
                                              _bankaAccountNameController.text,
                                          'bankaSortCode':
                                              _bankaSortCodeController.text,
                                          'bankaAccountNumber':
                                              _bankaAccountNumberController.text
                                        };
                                        await _databaseHelper
                                            .kaydet(_saticiAdiController.text);
                                        Future(
                                          () {
                                            _firestore
                                                .collection(
                                                    _saticiAdiController.text)
                                                .doc('saticiFirma')
                                                .set(firmaBilgileri);
                                          },
                                        ).then((value) {
                                          ref.read(saticiAdi.notifier).update(
                                              (state) =>
                                                  _saticiAdiController.text);
                                          Navigator.pop(context);
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Padding(
                                          padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom,
                                          ),
                                          child:
                                              Text('Eksik bilgi girdiniz...'),
                                        )));
                                      }
                                    },
                                    child: Text('KAYDET'))
                              ],
                            );
                          },
                        );
                      } */

                      //else {
                      if (ref.watch(yetkiSeviyesiProvider) != null &&
                          ref.watch(yetkiSeviyesiProvider)! < 2) {
                        await dogrulamaPenceresi(context);
                      } else {
                        /* ref
                            .read(saticiAdi.notifier)
                            .update((state) => _auth.currentUser!.email!); */
                        //BURADAN KEST??M
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AliciSec(),
                            ));
                        //}
                      }
                    },
                    child: Text(
                      LocaleKeys.fatura_kes.tr(),
                      style: const TextStyle(fontSize: 24),
                    ))),

            SizedBox(
              height: MediaQuery.of(context).size.height / 30,
            ),

            // Faturalar??m Butonu
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 10,
              child: ElevatedButton(
                  onPressed: () async {
                    if (ref.watch(yetkiSeviyesiProvider) != null &&
                        ref.watch(yetkiSeviyesiProvider)! < 2) {
                      await dogrulamaPenceresi(context);
                    } else {
                      saticiBilgileriniGetir().then((value) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Faturalarim(),
                            ));
                        //faturalariGetir().then((value) {});
                      });
                    }
                  },
                  child: Text(
                    LocaleKeys.faturalarim.tr(),
                    style: const TextStyle(fontSize: 24),
                  )),
            ),

            /* SizedBox(
              height: MediaQuery.of(context).size.height / 30,
            ),

            // ??oklu Fatura G??nder Butonu
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 10,
              child: ElevatedButton(
                  onPressed: () async {
                    if (ref.watch(yetkiSeviyesiProvider) != null &&
                        ref.watch(yetkiSeviyesiProvider)! < 2) {
                      await dogrulamaPenceresi(context);
                    } else {
                      saticiBilgileriniGetir().then((value) {
                        faturalariGetir().then((value) {
                          ref
                              .read(seciliTarihAraligindakiFaturalar.notifier)
                              .update((state) => ref.read(faturalarProvider));
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CokluFaturaGonder(),
                              ));
                        });
                      });
                    }
                  },
                  child: Text(
                    '??oklu Fatura G??nder',
                    style: const TextStyle(fontSize: 24),
                  )),
            ), */
            const Spacer(),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 10,
                child: ElevatedButton(
                    onPressed: () async {
                      if (ref.watch(yetkiSeviyesiProvider) != null &&
                          ref.watch(yetkiSeviyesiProvider)! < 2) {
                        await dogrulamaPenceresi(context);
                      } else {
                        saticiBilgileriniGetir().then((value) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AyarlarSayfasi(),
                              ));
                        });
                      }
                      /* Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AciklamaEkle(),
                          )); */
                    },
                    child: Text(
                      LocaleKeys.ayarlar.tr(),
                      style: const TextStyle(fontSize: 24),
                    ))),

            SizedBox(
              height: MediaQuery.of(context).size.height / 30,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 10,
              child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    ref
                        .read(yetkiSeviyesiProvider.notifier)
                        .update((state) => null);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (route) => false);
                    /* AuthCredential credential = EmailAuthProvider.credential(
                        email: 'ibrahimcanakman@outlook.com',
                        password: '123456');
                    await _auth.currentUser!
                        .reauthenticateWithCredential(credential);
                    await auth.currentUser!
                        .updateEmail('ibrahimcanakman@hotmail.com')
                        .then((value) => debugPrint('de??i??ti'))
                        .catchError(
                            (e) => debugPrint('hata oldu ${e.toString()}'));
                    debugPrint(_auth.currentUser!.displayName);
                    debugPrint(_auth.currentUser!.email); */
                  },
                  child: Text(
                    LocaleKeys.cikis_yap.tr(),
                    style: const TextStyle(fontSize: 24),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  dogrulamaPenceresi(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(LocaleKeys.uygulama_dogrulama.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(LocaleKeys
                  .uygulamayi_kullanabilmek_icin_dogrulama_kodu_girmelisiniz
                  .tr()),
              Form(
                key: _dogrulamaKey,
                child: TextFormField(
                  controller: _dogrulamaController,
                  decoration: InputDecoration(
                      label: Text(LocaleKeys.dogrulama_kodu.tr()),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15))),
                  validator: (value) {
                    if (value!.length != 4) {
                      return LocaleKeys.gecersiz_kod.tr();
                    } else if (ref
                        .watch(dogrulamaKodlariProvider)
                        .every((element) => element['kod'] != value)) {
                      return LocaleKeys.gecersiz_kod.tr();
                    } else {
                      var kontrol = false;
                      for (var element in ref.watch(dogrulamaKodlariProvider)) {
                        if (element['kod'] == value &&
                            !element['kullanildiMi']) {
                          kontrol = true;
                        }
                      }
                      if (!kontrol) {
                        return LocaleKeys.gecersiz_kod.tr();
                      } else {
                        return null;
                      }
                    }
                  },
                ),
              )
            ],
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _auth.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                      (route) => false);
                },
                child: Text(LocaleKeys.vazgec.tr())),
            ElevatedButton(
                onPressed: () {
                  if (_dogrulamaKey.currentState!.validate()) {
                    koduKullanildiYap().then((value) {
                      Navigator.pop(context);
                    });
                  } else {}
                },
                child: Text(LocaleKeys.dogrula.tr())),
          ],
        );
      },
    );
  }

  Future<void> koduKullanildiYap() async {
    ref.read(yetkiSeviyesiProvider.notifier).update((state) => 2);
    String girilenKod = _dogrulamaController.text.trim();
    List<dynamic> guncelListe = [];
    for (var element in ref.watch(dogrulamaKodlariProvider)) {
      if (element['kod'] == girilenKod) {
        Map<String, dynamic> guncelElement = {
          'kod': element['kod'],
          'kullanildiMi': true
        };
        guncelListe.add(guncelElement);
      } else {
        guncelListe.add(element);
      }
    }
    await _firestore.doc('kodlar/kodlar').update({'kodlar': guncelListe});
    await _firestore
        .doc('${_auth.currentUser!.displayName!}/saticiFirma')
        .update({'yetkiSeviyesi': 2});
  }

  Future<void> yetkiSeviyesiGetir() async {
    var gelenBilgi = await _firestore
        .doc('${_auth.currentUser!.displayName!}/saticiFirma')
        .get();
    int yetkiSeviyesi = gelenBilgi.data()!['yetkiSeviyesi'];
    ref.read(yetkiSeviyesiProvider.notifier).update((state) => yetkiSeviyesi);
    //firebaseden logo Stringi okunum providera atma
    String? logoString = gelenBilgi.data()!['firmaLogo'];
    if (logoString!.isNotEmpty) {
      var logolist = logoString.codeUnits;
      final logo = Uint8List.fromList(logolist);
      ref.read(logoProvider.notifier).update((state) => logo);
    }

    //return yetkiSeviyesi;
  }

  Future<void> saticiBilgileriniGetir() async {
    await _firestore
        .doc('${_auth.currentUser!.displayName!}/saticiFirma')
        .get()
        .then((value) async {
      var bilgiler = value.data();
      ref.read(saticiBilgileriProvider.notifier).update((state) => bilgiler);
      if (bilgiler!.keys.contains('imza')) {
        if (bilgiler['imza'] != null) {
          ref.read(imzaProvider.notifier).update((state) => bilgiler['imza']);
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
    ref.read(saticiAdi.notifier).update((state) => _auth.currentUser!.email!);
    var gelenFaturalarSS = await _firestore
        .collection(_auth.currentUser!.email!)
        .doc('saticiFirma')
        .collection('faturalar')
        .get();
    var gelenFaturalarListesi = gelenFaturalarSS.docs;
    gelenFaturalarListesi
        .sort((a, b) => b.data()['createdAt'].compareTo(a.data()['createdAt']));
    List<bool> checkboxList = [
      for (var i = 0; i <= gelenFaturalarListesi.length; i++) false
    ];
    debugPrint('gelen liste uzunlu??u ${checkboxList.length}');
    ref.read(faturaCheckboxProvider.notifier).update((state) => checkboxList);
    ref
        .read(faturalarProvider.notifier)
        .update((state) => gelenFaturalarListesi);
  } */
}
