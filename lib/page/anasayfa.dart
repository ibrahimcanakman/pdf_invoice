import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/page/alici_sec.dart';
import 'package:pdf_invoice/page/faturalarim.dart';
import 'package:pdf_invoice/page/login_page.dart';

import '../provider/all_providers.dart';

class AnaSayfa extends ConsumerStatefulWidget {
  const AnaSayfa({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends ConsumerState<AnaSayfa> {
  //FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /* final _saticiKey = GlobalKey<FormState>();
  final TextEditingController _saticiAdiController = TextEditingController();
  TextEditingController _saticiAdresiController = TextEditingController();
  TextEditingController _saticiTelefonController = TextEditingController();
  TextEditingController _saticiEmailController = TextEditingController();
  TextEditingController _bankaAccountNameController = TextEditingController();
  TextEditingController _bankaSortCodeController = TextEditingController();
  TextEditingController _bankaAccountNumberController = TextEditingController(); */

  //DatabaseHelper _databaseHelper = DatabaseHelper();
  //late List<Map<String, dynamic>> saticiFirma;
  late FirebaseAuth _auth;
  @override
  void initState() {
    super.initState();
    //saticiyiLocaldenGetir();
    _auth = FirebaseAuth.instance;
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
        title: const Text('Ana Sayfa'),
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
                              title: const Text('Kayıt Ol'),
                              content: Form(
                                  key: _saticiKey,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                            'İlk girişiniz olduğu için faturalarda kullanılmak üzere firmanızın bilgilerini bir kereliğine kaydetmelisiniz ! '),
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
                                              return 'Boş bırakılamaz...';
                                            } else {
                                              return null;
                                            }
                                          },
                                          decoration: InputDecoration(
                                              label: Text('Firma Adı'),
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
                                              return 'Boş bırakılamaz...';
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
                                              return 'Boş bırakılamaz...';
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
                                              return 'Boş bırakılamaz...';
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
                                              return 'Boş bırakılamaz...';
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
                                              return 'Boş bırakılamaz...';
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
                                              return 'Boş bırakılamaz...';
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
                                  child: const Text('Vazgeç'),
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
                      ref.read(saticiAdi.notifier).update(
                          (state) => _auth.currentUser!.email!);
                      //BURADAN KESTİM
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AliciSec(),
                          ));
                      //}
                    },
                    child: const Text(
                      'Fatura Kes',
                      style: TextStyle(fontSize: 24),
                    ))),

            SizedBox(
              height: MediaQuery.of(context).size.height / 30,
            ),

            // Faturalarım Butonu
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 10,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Faturalarim(),
                        ));
                  },
                  child: const Text(
                    'Faturalarım',
                    style: TextStyle(fontSize: 24),
                  )),
            ),
            const Spacer(),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 10,
              child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (route) => false);
                  },
                  child: const Text(
                    'Çıkış Yap',
                    style: TextStyle(fontSize: 24),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
