import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf_invoice/page/anasayfa.dart';
import 'package:email_validator/email_validator.dart';
import 'package:pdf_invoice/translations/locale_keys.g.dart';

import '../provider/all_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _saticiKey = GlobalKey<FormState>();
  final TextEditingController _emailGirisController = TextEditingController();
  final TextEditingController _sifreGirisController = TextEditingController();

  final TextEditingController _emailKayitController = TextEditingController();
  final TextEditingController _sifreKayitController = TextEditingController();
  final TextEditingController _saticiAdiController = TextEditingController();
  final TextEditingController _saticiAdresiController = TextEditingController();
  final TextEditingController _saticiTelefonController =
      TextEditingController();
  final TextEditingController _bankaAccountNameController =
      TextEditingController();
  final TextEditingController _bankaSortCodeController =
      TextEditingController();
  final TextEditingController _bankaAccountNumberController =
      TextEditingController();

  final TextEditingController _sifreSifirlamaEmailController =
      TextEditingController();

  //final DatabaseHelper _databaseHelper = DatabaseHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _girisFormKey = GlobalKey<FormState>();
  final _sifreSifirlamaKey = GlobalKey<FormState>();

  late FirebaseAuth auth;

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('User oturumu kapalı!');
      } else {
        debugPrint(
            'User oturum açık ${user.email} ve e-mail durumu ${user.emailVerified}');

        if (user.emailVerified) {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnaSayfa(),
                ),
                (route) => true);
          }
        } else if (!user.emailVerified) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text(LocaleKeys.mail_dogrulama_istek_mesaji.tr()),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(LocaleKeys.tamam.tr()))
                  ],
                );
              });
        }
      }
    });
  }

  @override
  void dispose() {
    //auth.authStateChanges().listen((event) {}).cancel();
    _emailGirisController.dispose();
    _sifreGirisController.dispose();
    _emailKayitController.dispose();
    _sifreKayitController.dispose();
    _saticiAdiController.dispose();
    _saticiAdresiController.dispose();
    _saticiTelefonController.dispose();
    _bankaAccountNameController.dispose();
    _bankaSortCodeController.dispose();
    _bankaAccountNumberController.dispose();
    _sifreSifirlamaEmailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(LocaleKeys.giris_ekrani.tr()),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width / 10),
        child: Form(
          key: _girisFormKey,
          child: Column(
            children: [
              const Expanded(child: SizedBox()),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return LocaleKeys.email_bos_birakilamaz.tr();
                  } else if (!EmailValidator.validate(value)) {
                    return LocaleKeys.gecerli_bir_email_adresi_girin.tr();
                  } else {
                    return null;
                  }
                },
                controller: _emailGirisController,
                decoration: InputDecoration(
                    label: Text(LocaleKeys.email.tr()),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              const Expanded(child: SizedBox()),
              TextFormField(
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return LocaleKeys.sifre_bos_birakilamaz.tr();
                  } else if (value.length < 6) {
                    return LocaleKeys.sifre_en_az_6_karakter_olmali.tr();
                  } else {
                    return null;
                  }
                },
                controller: _sifreGirisController,
                decoration: InputDecoration(
                    label: Text(LocaleKeys.sifre.tr()),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              const Expanded(child: SizedBox()),
              ElevatedButton(
                  onPressed: () {
                    if (_girisFormKey.currentState!.validate()) {
                      loginUserEmailandPassword();
                    }
                  },
                  child: Text(LocaleKeys.giris_yap.tr())),
              TextButton(
                  onPressed: () {
                    kayitOl();
                  },
                  child: Text(LocaleKeys.kayit_ol.tr())),
              TextButton(
                  onPressed: () {
                    sifremiUnuttum();
                  },
                  child: Text(LocaleKeys.sifremi_unuttum.tr())),
              const Expanded(flex: 10, child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }

  void kayitOl() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocaleKeys.kayit_ol.tr()),
          content: Form(
              key: _saticiKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(LocaleKeys.ilk_giris_mesaji.tr()),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 50,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailKayitController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return LocaleKeys.bos_birakilamaz.tr();
                        } else if (!EmailValidator.validate(value)) {
                          return LocaleKeys.gecerli_bir_email_adresi_girin.tr();
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: Text(LocaleKeys.email.tr()),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    TextFormField(
                      controller: _sifreKayitController,
                      obscureText: true,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return LocaleKeys.bos_birakilamaz.tr();
                        } else if (value.length < 6) {
                          return LocaleKeys.sifre_en_az_6_karakter_olmali.tr();
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: Text(LocaleKeys.sifre.tr()),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    TextFormField(
                      controller: _saticiAdiController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return LocaleKeys.bos_birakilamaz.tr();
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: Text(LocaleKeys.firma_adi.tr()),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    TextFormField(
                      maxLines: 4,
                      controller: _saticiAdresiController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return LocaleKeys.bos_birakilamaz.tr();
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: Text(LocaleKeys.firma_adresi.tr()),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: _saticiTelefonController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return LocaleKeys.bos_birakilamaz.tr();
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: Text(LocaleKeys.telefon.tr()),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    TextFormField(
                      controller: _bankaAccountNameController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return LocaleKeys.bos_birakilamaz.tr();
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: Text(LocaleKeys.banka_hesap_adi.tr()),
                          hintText: 'Sadece Banka Hesap Adını Yazın...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _bankaSortCodeController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return LocaleKeys.bos_birakilamaz.tr();
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: Text(LocaleKeys.banka_sort_kodu.tr()),
                          hintText: 'Sadece Banka Sort Kodu Yazın...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _bankaAccountNumberController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return LocaleKeys.bos_birakilamaz.tr();
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: Text(LocaleKeys.banka_hesap_numarasi.tr()),
                          hintText: 'Sadece Banka Hesap Numarası Yazın...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                  ],
                ),
              )),
          actions: <Widget>[
            TextButton(
              child: Text(LocaleKeys.vazgec.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
                onPressed: () async {
                  if (_saticiKey.currentState!.validate()) {
                    emailSifreileKayitOlustur();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Text(LocaleKeys.eksik_bilgi_girdiniz.tr()),
                    )));
                  }
                },
                child: Text(LocaleKeys.kaydet.tr()))
          ],
        );
      },
    );
  }

  void emailSifreileKayitOlustur() async {
    try {
      var _hesap = await auth.createUserWithEmailAndPassword(
          email: _emailKayitController.text.trim(),
          password: _sifreKayitController.text.trim());
      var _kullanici = _hesap.user;

      if (!_kullanici!.emailVerified) {
        await _kullanici.sendEmailVerification();
        bilgileriFirebaseDByeYaz();
        Navigator.of(context).pop();
      } else {
        debugPrint('kullanıcının maili onaylanmış ilgili sayfaya gidebilir...');
        bilgileriFirebaseDByeYaz();
        Navigator.of(context).pop();
      }
      debugPrint(_hesap.toString());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(LocaleKeys
                    .bu_mail_adresi_ile_daha_once_kayit_olusturulmus
                    .tr()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(LocaleKeys.tamam.tr()))
                ],
              );
            });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                LocaleKeys.bir_hata_olustu_daha_sonra_tekrar_deneyin.tr())));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void loginUserEmailandPassword() async {
    try {
      var _userCredential = await auth.signInWithEmailAndPassword(
          email: _emailGirisController.text.trim(),
          password: _sifreGirisController.text.trim());
      kodlariGetir().then((value) {
        //int yetkiSeviyesi = ref.watch(yetkiSeviyesiProvider)!;
        debugPrint(_userCredential.toString());
        var _myUser = _userCredential.user;
        if (!_myUser!.emailVerified) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text(LocaleKeys
                      .kayit_esnasinda_mail_adresinize_gonderilen
                      .tr()),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Tamam'))
                  ],
                );
              });
        } else {
          debugPrint(
              'kullanıcının maili onaylanmış ilgili sayfaya gidebilir...');
          
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnaSayfa(),
                ),
                (route) => false);
          

          /* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnaSayfa(),
            )); */
        }

        /* await kullaniciBilgileriGetir();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MyHomePage(),
      )); */
      });
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Text(LocaleKeys.bu_email_ile_kayitli_kullanici_yok.tr()),
        )));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Text(LocaleKeys.sifreyi_yanlis_girdiniz.tr()),
        )));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Text(LocaleKeys.gecerli_bir_email_adresi_girin.tr()),
        )));
      }

      /* debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail veya Şifre Yanlış Girildi...'))); */
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(LocaleKeys.email_veya_sifre_yanlis_girildi.tr())));
    }
  }

  void bilgileriFirebaseDByeYaz() async {
    Map<String, dynamic> firmaBilgileri = {
      'adi': _saticiAdiController.text.trim(),
      'adresi': _saticiAdresiController.text.trim(),
      'email': _emailKayitController.text.trim(),
      'telefon': _saticiTelefonController.text.trim(),
      'bankaAccountName': _bankaAccountNameController.text.trim(),
      'bankaSortCode': _bankaSortCodeController.text.trim(),
      'bankaAccountNumber': _bankaAccountNumberController.text.trim(),
      'yetkiSeviyesi': 1,
      'firmaLogo':'',
      'faturaFormati':'Format1'
    };
    //await _databaseHelper.kaydet(_emailKayitController.text);
    Future(
      () {
        _firestore
            .collection(_emailKayitController.text.trim())
            .doc('saticiFirma')
            .set(firmaBilgileri);
        _firestore
            .collection(_emailKayitController.text.trim())
            .doc('saticiFirma')
            .collection('faturaNoBicim')
            .doc('faturaNoBicim')
            .set({'faturaNoBicim': 'Tarih + Sayı'});
      },
    ).then((value) {
      ref
          .read(saticiAdi.notifier)
          .update((state) => _emailKayitController.text.trim());
      Navigator.pop(context);
    });
  }

  void sifremiUnuttum() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _sifreSifirlamaEmailController.text = '';
                  },
                  child: Text(LocaleKeys.vazgec.tr())),
              ElevatedButton(
                  onPressed: () async {
                    sifreSifirlamaMailiGonder();

                    //Navigator.pop(context);
                  },
                  child: Text(LocaleKeys.tamam.tr()))
            ],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(LocaleKeys.sifrenizi_yenilemek_icin_mail_adresinizi_girin
                    .tr()),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 40,
                ),
                Form(
                  key: _sifreSifirlamaKey,
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return LocaleKeys.email_bos_birakilamaz.tr();
                      } else if (!EmailValidator.validate(value)) {
                        return LocaleKeys.gecerli_bir_email_adresi_girin.tr();
                      } else {
                        return null;
                      }
                    },
                    controller: _sifreSifirlamaEmailController,
                    decoration: InputDecoration(
                        label: Text(LocaleKeys.email.tr()),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  ),
                )
              ],
            ),
            title: Text(LocaleKeys.sifremi_unuttum.tr()),
          );
        });
  }

  void sifreSifirlamaMailiGonder() async {
    if (_sifreSifirlamaKey.currentState!.validate()) {
      try {
        await auth.sendPasswordResetEmail(
            email: _sifreSifirlamaEmailController.text.trim());
        /* Future(
          () {
            
          },
        ).then((value) {
          
        }); */
        Navigator.pop(context);
        _sifreSifirlamaEmailController.text = '';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Text(LocaleKeys.sifre_sifirlama_maili_gonderildi.tr()),
        )));
      } on FirebaseAuthException catch (e) {
        debugPrint(e.code);
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Text(LocaleKeys.bu_email_ile_kayitli_kullanici_yok.tr()),
          )));
        } else if (e.code == 'invalid-email') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Text(LocaleKeys.gecerli_bir_email_adresi_girin.tr()),
          )));
        }
      }
    }
  }

  Future<void> kodlariGetir() async {
    var kodlar = await _firestore.doc('kodlar/kodlar').get();
    List<dynamic> kodlarListesi = kodlar.data()!['kodlar'];
    ref
        .read(dogrulamaKodlariProvider.notifier)
        .update((state) => kodlarListesi);
  }
}
