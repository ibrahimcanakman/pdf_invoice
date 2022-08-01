import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/constants/constant.dart';

import '../provider/all_providers.dart';
import '../translations/locale_keys.g.dart';

class SaticiBilgisiDuzenle extends ConsumerStatefulWidget {
  const SaticiBilgisiDuzenle({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SaticiBilgisiDuzenleState();
}

class _SaticiBilgisiDuzenleState extends ConsumerState<SaticiBilgisiDuzenle> {
  final TextEditingController _saticiAdiController = TextEditingController();
  final TextEditingController _saticiAdresiController = TextEditingController();
  final TextEditingController _saticiTelefonController =
      TextEditingController();
  final TextEditingController _saticiEmailController = TextEditingController();
  final TextEditingController _saticiBankaAcoountNameController =
      TextEditingController();
  final TextEditingController _saticiBankaAccountNumberController =
      TextEditingController();
  final TextEditingController _saticiBankaSortCodeController =
      TextEditingController();
  final TextEditingController _guncellemeEmailController =
      TextEditingController();
  final TextEditingController _guncellemeSifreController =
      TextEditingController();
  final _saticiBilgiDuzenlemeKey = GlobalKey<FormState>();
  final _saticiBilgiGuncellemeKey = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    degerAta();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        ref
            .read(aliciSecBottomNavBarProvider.notifier)
            .update((state) => false);
        return Future.value(true);
      },
      child: SafeArea(
        child: Scaffold(
          //resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(LocaleKeys.bilgileri_duzenle.tr()),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _saticiBilgiDuzenlemeKey,
                child: Column(
                  children: [
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _saticiEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          label: Text(LocaleKeys.email.tr()),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                      validator: (value) {
                        if (!EmailValidator.validate(value!.trim())) {
                          return LocaleKeys.gecerli_bir_email_adresi_girin.tr();
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 50,
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _saticiAdiController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          label: Text(LocaleKeys.firma_adi.tr()),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.bos_birakilamaz.tr();
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 50,
                    ),
                    TextFormField(
                      controller: _saticiAdresiController,
                      textCapitalization: TextCapitalization.words,
                      maxLines: 5,
                      decoration: InputDecoration(
                          label: Text(LocaleKeys.firma_adresi.tr()),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.bos_birakilamaz.tr();
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 50,
                    ),
                    TextFormField(
                      controller: _saticiTelefonController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          label: Text(LocaleKeys.telefon.tr()),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.bos_birakilamaz.tr();
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 50,
                    ),
                    TextFormField(
                      controller: _saticiBankaAcoountNameController,
                      decoration: InputDecoration(
                          label: Text(LocaleKeys.banka_hesap_adi.tr()),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.bos_birakilamaz.tr();
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 50,
                    ),
                    TextFormField(
                      controller: _saticiBankaAccountNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          label: Text(LocaleKeys.banka_hesap_numarasi.tr()),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.bos_birakilamaz.tr();
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 50,
                    ),
                    TextFormField(
                      controller: _saticiBankaSortCodeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          label: Text(LocaleKeys.banka_sort_kodu.tr()),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.bos_birakilamaz.tr();
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            onPressed: () async {
                              if (_saticiBilgiDuzenlemeKey.currentState!
                                  .validate()) {
                                bilgileriGuncelle();
                              }
                            },
                            child: Text(LocaleKeys.kaydet.tr())))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void degerAta() {
    Map<String, dynamic> saticiBilgileri = {};
    if (ref.read(saticiBilgileriProvider) != null) {
      saticiBilgileri.addAll(ref.read(saticiBilgileriProvider)!);
      _saticiEmailController.text = saticiBilgileri['email'];
      _saticiAdiController.text = saticiBilgileri['adi'];
      _saticiAdresiController.text = saticiBilgileri['adresi'];
      _saticiTelefonController.text = saticiBilgileri['telefon'];
      _saticiBankaAcoountNameController.text =
          saticiBilgileri['bankaAccountName'];
      _saticiBankaAccountNumberController.text =
          saticiBilgileri['bankaAccountNumber'];
      _saticiBankaSortCodeController.text = saticiBilgileri['bankaSortCode'];
    }
  }

  Future<void> bilgileriGuncelle() async {
    String eskiEmail = ref.read(saticiBilgileriProvider)!['email'];
    Map<String, dynamic> guncelVeri = {
      'email': _saticiEmailController.text.trim(),
      'adi': _saticiAdiController.text.trim(),
      'adresi': _saticiAdresiController.text.trim(),
      'telefon': _saticiTelefonController.text.trim(),
      'bankaAccountName': _saticiBankaAcoountNameController.text.trim(),
      'bankaAccountNumber': _saticiBankaAccountNumberController.text.trim(),
      'bankaSortCode': _saticiBankaSortCodeController.text.trim()
    };
    if (eskiEmail != guncelVeri['email']) {
      try {
        await auth.currentUser!.updateEmail(guncelVeri['email']);
        await bilgileriYaz(guncelVeri)
            .whenComplete(() => Navigator.pop(context));
      } on FirebaseAuthException catch (error) {
        if (error.code == 'requires-recent-login') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Form(
                key: _saticiBilgiGuncellemeKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(LocaleKeys.email_guncelleme_mesaji.tr()),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 50,
                      ),
                      /* TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _guncellemeEmailController,
                        decoration: InputDecoration(
                            label: Text(LocaleKeys.email.tr()),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                        validator: (value) {
                          if (!EmailValidator.validate(value!.trim())) {
                            return 'Lütfen geçerli bir e-mail girin';
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 50,
                      ), */
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _guncellemeSifreController,
                        decoration: InputDecoration(
                            label: Text(LocaleKeys.sifre.tr()),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return LocaleKeys.sifre_bos_birakilamaz.tr();
                          } else if (value.length < 6) {
                            return LocaleKeys.sifre_en_az_6_karakter_olmali
                                .tr();
                          } else {
                            return null;
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(LocaleKeys.vazgec.tr())),
                ElevatedButton(
                    onPressed: () async {
                      if (_saticiBilgiGuncellemeKey.currentState!.validate()) {
                        AuthCredential credential =
                            EmailAuthProvider.credential(
                                email: eskiEmail,
                                password:
                                    _guncellemeSifreController.text.trim());
                        await FirebaseAuth.instance.currentUser!
                            .reauthenticateWithCredential(credential)
                            .whenComplete(() async {
                          await auth.currentUser!
                              .updateEmail(guncelVeri['email'])
                              .then((value) => Navigator.pop(context));
                          await bilgileriYaz(guncelVeri).whenComplete(() {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        });
                      }
                    },
                    child: Text(LocaleKeys.onayla.tr()))
              ],
            ),
          );
        }
      }
    } else {
      await bilgileriYaz(guncelVeri).whenComplete(() => Navigator.pop(context));
    }
  }

  Future<void> bilgileriYaz(Map<String, dynamic> guncelVeri) async {
    try {
      await _firestore
          .collection(auth.currentUser!.displayName!)
          .doc('saticiFirma')
          .update(guncelVeri);
      ref.read(saticiBilgileriProvider.notifier).update((state) {
        Map<String, dynamic> bilgiler = {};
        bilgiler.addAll(state!);
        bilgiler.update('email', (value) => guncelVeri['email']);
        bilgiler.update('adi', (value) => guncelVeri['adi']);
        bilgiler.update('adresi', (value) => guncelVeri['adresi']);
        bilgiler.update('telefon', (value) => guncelVeri['telefon']);
        bilgiler.update(
            'bankaAccountName', (value) => guncelVeri['bankaAccountName']);
        bilgiler.update(
            'bankaAccountNumber', (value) => guncelVeri['bankaAccountNumber']);
        bilgiler.update(
            'bankaSortCode', (value) => guncelVeri['bankaSortCode']);

        return bilgiler;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
        child: Text(LocaleKeys.bir_hata_olustu_daha_sonra_tekrar_deneyin.tr()),
      )));
    }
  }
}
