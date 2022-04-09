import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_invoice/database_helper.dart';
import 'package:pdf_invoice/page/alici_sec.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final provider =
    StateProvider<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
  (ref) => [],
);

final saticiAdi = StateProvider<String>((ref) => '',);

class AnaSayfa extends ConsumerWidget {
  AnaSayfa({Key? key}) : super(key: key);

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _saticiKey = GlobalKey<FormState>();
  TextEditingController _saticiAdiController = TextEditingController();
  TextEditingController _saticiAdresiController = TextEditingController();
  TextEditingController _saticiTelefonController = TextEditingController();
  TextEditingController _saticiEmailController = TextEditingController();
  TextEditingController _bankaAccountNameController = TextEditingController();
  TextEditingController _bankaSortCodeController = TextEditingController();
  TextEditingController _bankaAccountNumberController = TextEditingController();

  DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Ana Sayfa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 10,
                child: ElevatedButton(
                    onPressed: () async {
                      Future(
                        () async {
                          var value = await _databaseHelper.getir();
                          return value;
                        },
                      ).then((value) async {
                        if (value.isEmpty) {
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
                                          Text(
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
                                            controller:
                                                _saticiTelefonController,
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
                                            controller: _bankaAccountNameController,
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
                                            controller: _bankaAccountNumberController,
                                            validator: (value) {
                                              if (value!.trim().isEmpty) {
                                                return 'Boş bırakılamaz...';
                                              } else {
                                                return null;
                                              }
                                            },
                                            decoration: InputDecoration(
                                                label: Text('Bank Account Number'),
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
                                        if (_saticiKey.currentState!
                                            .validate()) {
                                          Map<String, dynamic> firmaBilgileri =
                                              {
                                            'adi': _saticiAdiController.text,
                                            'adresi':
                                                _saticiAdresiController.text,
                                            'email':
                                                _saticiEmailController.text,
                                            'telefon':
                                                _saticiTelefonController.text,
                                                'bankaAccountName':
                                                _bankaAccountNameController.text,
                                                'bankaSortCode':
                                                _bankaSortCodeController.text,
                                                'bankaAccountNumber':
                                                _bankaAccountNumberController.text
                                          };
                                          await _databaseHelper.kaydet(
                                              _saticiAdiController.text);
                                          Future(
                                            () {
                                              _firestore
                                                  .collection(
                                                      _saticiAdiController.text)
                                                  .doc('saticiFirma')
                                                  .set(firmaBilgileri);
                                            },
                                          ).then((value) {
                                            ref.read(saticiAdi.notifier).update((state)=>_saticiAdiController.text);
                                              Navigator.pop(context);
                                          });
                                              }
                                          
                                   
                                        else {
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
                        } else {
                          ref.read(saticiAdi.notifier).update((state) => value.first['firmaAdi'].toString());
                          var gelenBilgi = await _firestore
                              .collection(value.first['firmaAdi'].toString())
                              .get();

                          ref
                              .read(provider.notifier)
                              .update((state) => gelenBilgi.docs);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AliciSec(),
                              ));
                        }
                      });
                    },
                    child: const Text(
                      'Fatura Kes',
                      style: TextStyle(fontSize: 24),
                    )))
          ],
        ),
      ),
    );
  }
}
