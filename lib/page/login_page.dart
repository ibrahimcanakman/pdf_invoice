import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf_invoice/page/anasayfa.dart';
import 'package:email_validator/email_validator.dart';

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
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: const Text(
                      'Uygulamaya giriş yapabilmek için hesap doğrulaması gerekli. Hesap doğrulaması için gönderilen maile bakın.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tamam'))
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
        title: const Text('Giriş Ekranı'),
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
                    return 'E-mail boş bırakılamaz';
                  } else if (!EmailValidator.validate(value)) {
                    return 'Geçerli bir e-mail girin.';
                  } else {
                    return null;
                  }
                },
                controller: _emailGirisController,
                decoration: InputDecoration(
                    label: const Text('E-Mail'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              const Expanded(child: SizedBox()),
              TextFormField(
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Şifre boş bırakılamaz';
                  } else if (value.length < 6) {
                    return 'Şifre en az 6 karakter olmalı';
                  } else {
                    return null;
                  }
                },
                controller: _sifreGirisController,
                decoration: InputDecoration(
                    label: const Text('Şifre'),
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
                  child: const Text('Giriş Yap')),
              TextButton(
                  onPressed: () {
                    kayitOl();
                  },
                  child: const Text('Kayıt Ol')),
              TextButton(
                  onPressed: () {
                    sifremiUnuttum();
                  },
                  child: const Text('Şifremi Unuttum')),
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
          title: const Text('Kayıt Ol'),
          content: Form(
              key: _saticiKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        'İlk girişiniz olduğu için faturalarda kullanılmak üzere firmanızın bilgilerini ve giriş bilgilerinizi bir kereliğine kaydetmelisiniz ! '),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 50,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailKayitController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Boş bırakılamaz...';
                        } else if (!EmailValidator.validate(value)) {
                          return 'Geçerli bir e-mail girin';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: const Text('E-Mail'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    TextFormField(
                      controller: _sifreKayitController,
                      obscureText: true,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Boş bırakılamaz...';
                        } else if (value.length < 6) {
                          return 'Şifre en az 6 karakterden oluşmalı';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: const Text('Şifre'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    TextFormField(
                      controller: _saticiAdiController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Boş bırakılamaz...';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: const Text('Firma Adı'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    TextFormField(
                      maxLines: 4,
                      controller: _saticiAdresiController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Boş bırakılamaz...';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: const Text('Firma Adresi'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: _saticiTelefonController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Boş bırakılamaz...';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: const Text('Telefon'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    TextFormField(
                      controller: _bankaAccountNameController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Boş bırakılamaz...';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: const Text('Bank Account Name'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _bankaSortCodeController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Boş bırakılamaz...';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: const Text('Bank Sort Code'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _bankaAccountNumberController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Boş bırakılamaz...';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: const Text('Bank Account Number'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15))),
                    ),
                  ],
                ),
              )),
          actions: <Widget>[
            TextButton(
              child: const Text('Vazgeç'),
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
                      child: const Text('Eksik bilgi girdiniz...'),
                    )));
                  }
                },
                child: const Text('KAYDET'))
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
                content: const Text(
                    'Bu mail adresi ile daha önce kayıt oluşturulmuş...'),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Bir hata oluştu, daha sonra tekrar deneyin...')));
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
      debugPrint(_userCredential.toString());
      var _myUser = _userCredential.user;
      if (!_myUser!.emailVerified) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: const Text(
                    'Kayıt esnasında mail adresinize gönderilen doğrulama linkinden hesabınızı doğrulayın...'),
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
        debugPrint('kullanıcının maili onaylanmış ilgili sayfaya gidebilir...');
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
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const Text('Bu e-mail ile kayıtlı kullanıcı yok.'),
        )));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const Text('Şifreyi yanlış girdiniz.'),
        )));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const Text('Geçerli bir e-mail adresi girin.'),
        )));
      }

      /* debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail veya Şifre Yanlış Girildi...'))); */
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail veya Şifre Yanlış Girildi...')));
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
      'bankaAccountNumber': _bankaAccountNumberController.text.trim()
    };
    //await _databaseHelper.kaydet(_emailKayitController.text);
    Future(
      () {
        _firestore
            .collection(_emailKayitController.text.trim())
            .doc('saticiFirma')
            .set(firmaBilgileri);
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
                    _sifreSifirlamaEmailController.text='';
                  },
                  child: const Text('Vazgeç')),
              ElevatedButton(
                  onPressed: () async {
                    sifreSifirlamaMailiGonder();

                    //Navigator.pop(context);
                  },
                  child: const Text('TAMAM'))
            ],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Şifrenizi yenilemek için mail adresinizi girin.'),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 40,
                ),
                Form(
                  key: _sifreSifirlamaKey,
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'E-mail boş bırakılamaz';
                      } else if (!EmailValidator.validate(value)) {
                        return 'Geçerli bir e-mail girin.';
                      } else {
                        return null;
                      }
                    },
                    controller: _sifreSifirlamaEmailController,
                    decoration: InputDecoration(
                        label: const Text('E-Mail'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  ),
                )
              ],
            ),
            title: const Text('Şifremi Unuttum'),
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
        _sifreSifirlamaEmailController.text='';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const Text(
              'Şifre sıfırlama maili gönderildi, gönderilen mailden şifrenizi sıfırlayabilirsiniz.'),
        )));
      } on FirebaseAuthException catch (e) {
        debugPrint(e.code);
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: const Text('Bu e-mail ile kayıtlı kullanıcı yok.'),
          )));
        } else if (e.code == 'invalid-email') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: const Text('Geçerli bir e-mail adresi girin.'),
          )));
        }
      }
    }
  }
}
