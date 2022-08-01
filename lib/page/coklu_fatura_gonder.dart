import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf_invoice/page/coklu_fatura_alicisi_sec.dart';
import 'package:pdf_invoice/provider/firebase_connect.dart';
import 'package:pdf_invoice/translations/locale_keys.g.dart';

import '../provider/all_providers.dart';

class CokluFaturaGonder extends ConsumerStatefulWidget {
  const CokluFaturaGonder({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CokluFaturaGonderState();
}

class _CokluFaturaGonderState extends ConsumerState<CokluFaturaGonder> {
  final TextEditingController tarihTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        ref
            .read(seciliTarihAraligiProvider.notifier)
            .update((state) => LocaleKeys.baslangic_ve_bitis_tarihi_secin.tr());
        ref.read(cokluFaturaHepsiProvider.notifier).update((state) => false);
        ref.read(faturaCheckboxProvider.notifier).update((state) => null);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.coklu_fatura_gonder.tr()),
        ),
        body: ref.watch(faturaCheckboxProvider) == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SafeArea(
                child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  children: [
                    TextFormField(
                      readOnly: true,
                      textAlign: TextAlign.center,
                      onTap: () {
                        tarihSec();
                      },
                      decoration: InputDecoration(
                          hintText: ref.watch(seciliTarihAraligiProvider),
                          icon: IconButton(
                              onPressed: () {
                                tarihSec();
                              },
                              icon: Icon(Icons.date_range, size: 36)),
                          border: OutlineInputBorder(
                              gapPadding: 10,
                              borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(50)))),
                    ),
                    /* Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        FloatingActionButton(
                          onPressed: () async {
                            tarihSec();
                          },
                          child: Icon(Icons.date_range),
                        ),
                        Expanded(
                            child: Text(
                          ref.watch(seciliTarihAraligiProvider),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ))
                      ],
                    ), */
                    ListTile(
                      leading: Checkbox(
                        value: ref.watch(cokluFaturaHepsiProvider),
                        onChanged: (value) {
                          if (ref
                              .watch(seciliTarihAraligindakiFaturalar)
                              .isNotEmpty) {
                            if (value!) {
                              ref.read(faturaCheckboxProvider.notifier).update(
                                  (state) => [for (var i in state!) true]);
                            } else {
                              ref.read(faturaCheckboxProvider.notifier).update(
                                  (state) => [for (var i in state!) false]);
                            }
                            ref
                                .read(cokluFaturaHepsiProvider.notifier)
                                .update((state) => value);
                          } else {
                            ref
                                .read(faturaCheckboxProvider.notifier)
                                .update((state) => null);
                          }
                        },
                      ),
                      title: Text(LocaleKeys.hepsini_sec.tr()),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Divider(
                        height: 0,
                        thickness: 2,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            ref.watch(seciliTarihAraligindakiFaturalar).length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  ref
                                      .read(faturaCheckboxProvider.notifier)
                                      .update((state) {
                                    List<bool> x = [];
                                    x.addAll(state!);
                                    x[index] = !x[index];
                                    return x;
                                  });
                                },
                                leading: Checkbox(
                                  value:
                                      ref.watch(faturaCheckboxProvider)![index],
                                  onChanged: (bool? yeniDeger) {
                                    ref
                                        .read(faturaCheckboxProvider.notifier)
                                        .update((state) {
                                      List<bool> x = [];
                                      x.addAll(state!);
                                      x[index] = yeniDeger!;
                                      return x;
                                    });
                                  },
                                ),
                                title: Text(ref
                                    .read(
                                        seciliTarihAraligindakiFaturalar)[index]
                                    .data()['aliciAdi']),
                                subtitle: Text(ref
                                    .read(
                                        seciliTarihAraligindakiFaturalar)[index]
                                    .data()['faturaTarihi']),
                                trailing: Text(
                                    '£ ${ref.read(seciliTarihAraligindakiFaturalar)[index].data()['faturaToplami']}'),
                              ),
                              const Divider(
                                height: 0,
                                thickness: 1,
                              )
                            ],
                          );
                        },
                      ),
                    ),
                    Visibility(
                      visible: ref
                              .watch(seciliTarihAraligindakiFaturalar)
                              .isNotEmpty &&
                          ref.watch(faturaCheckboxProvider) != null &&
                          ref.watch(faturaCheckboxProvider)!.contains(true),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: ElevatedButton(
                            onPressed: () {
                              if (ref.watch(cokluFaturaHepsiProvider)) {
                                ref
                                    .read(
                                        secilenTopluFaturalarProvider.notifier)
                                    .update((state) => ref.read(
                                        seciliTarihAraligindakiFaturalar));
                              } else {
                                List<
                                        QueryDocumentSnapshot<
                                            Map<String, dynamic>>>
                                    seciliFaturalar = [];
                                for (var i = 0;
                                    i <
                                        ref
                                            .read(
                                                seciliTarihAraligindakiFaturalar)
                                            .length;
                                    i++) {
                                  if (ref.watch(faturaCheckboxProvider)![i]) {
                                    seciliFaturalar.add(ref.read(
                                        seciliTarihAraligindakiFaturalar)[i]);
                                  }
                                }
                                ref
                                    .read(
                                        secilenTopluFaturalarProvider.notifier)
                                    .update((state) => seciliFaturalar);
                              }
                              aliciListesiGetir().then((value) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CokluFaturaAlicisiSec(),
                                    ));
                              });
                            },
                            child: Text(
                              LocaleKeys.alici_sec.tr(),
                              style: TextStyle(fontSize: 24),
                            )),
                      ),
                    )
                  ],
                ),
              )),
      ),
    );
  }

  Future<void> aliciListesiGetir() async {
    var gelenBilgi = await emailCollection.get();
    var liste = gelenBilgi.docs;
    List<Map<String, dynamic>> aliciListesi = [];
    if (liste.isNotEmpty) {
      for (var item in liste) {
        item.id == 'saticiFirma' ? null : aliciListesi.add(item.data());
      }
      aliciListesi.add({'adi': 'email'});
      bool a = ref.watch(secilenTopluFaturalarProvider).every((element) =>
          element.data()['aliciAdi'] ==
          ref.watch(secilenTopluFaturalarProvider).first.data()['aliciAdi']);
      debugPrint(a.toString());
      if (a) {
        var index = aliciListesi.indexWhere((element) =>
            element['adi'] ==
            ref.watch(secilenTopluFaturalarProvider).first.data()['aliciAdi']);
        var x = aliciListesi[index];
        aliciListesi.removeAt(index);
        aliciListesi.insert(0, x);
      }
      ref
          .read(cokluFaturaAliciListesiProvider.notifier)
          .update((state) => aliciListesi);
    }
  }

  Future<void> tarihSec() async {
    var dateRange = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2022),
            lastDate: DateTime(DateTime.now().year + 3))
        .then((value) {
      //tarih seçili ise value değeri null olmaz.
      //  bu kontrole göre kayıtları direk getir bu blokta
      if (value != null) {
        DateTime baslangic = value.start;
        DateTime bitis = value.end;
        String yazi = DateFormat('dd.MM.yyyy').format(baslangic) +
            ' - ' +
            DateFormat('dd.MM.yyyy').format(bitis);
        ref.read(seciliTarihAraligiProvider.notifier).update((state) => yazi);
        List<QueryDocumentSnapshot<Map<String, dynamic>>> faturalar = [];
        for (var element in ref.read(faturalarProvider)) {
          Timestamp faturaCreatedAt = element.data()['createdAt'];
          DateTime faturaTarihi = faturaCreatedAt.toDate();
          if ((baslangic.isBefore(faturaTarihi) || baslangic == faturaTarihi) &&
              (bitis.isAfter(faturaTarihi) || bitis == faturaTarihi)) {
            faturalar.add(element);
          }
        }
        ref
            .read(seciliTarihAraligindakiFaturalar.notifier)
            .update((state) => faturalar);
      }
    });
  }
}
