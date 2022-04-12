import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

//Seçilen tarihin tutulduğu provider 
final tarihProvider = StateProvider<String>(
  (ref) => DateFormat('dd.MM.yyyy').format(DateTime.now()),
);

//seçilen tarihe göre fatura no oluşturulup tutulan provider format ---->> yyyyMMdd
final faturaNoProvider = StateProvider<String>(
  (ref) => '',
);

//firebaseden okunan faturaların tutulduğu provider
final faturalarProvider =
    StateProvider<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
  (ref) => [],
);

//faturalarım sayfasında seçilen fatura bilgilerini tutan provider
final seciliFaturaProvider = StateProvider<Map<String, dynamic>>((ref) => {},);

//fatura keserken girilen ürünleri ve birim, miktar, kdv değerlerini tutan provider
final urunListesiProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) {
    return [];
  },
);

//satıcı firmanın adını tutan provider
final saticiAdi = StateProvider<String>(
  (ref) => '',
);

/* 
      --------------------->>>>>>>>
      şu an firma collectionu içinde kayıtlı olan alıcılar ve saticifirma documentslerini tutuyor
      -------------------------DEĞİŞECEK--------------------
      >>>>>>>>---------------------
 */
final provider =
    StateProvider<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
  (ref) => [],
);

//alıcı seç kısmında seçilen alıcının bilgilerini tutan provider
/* 
adi, adresi, telefon, email
 */
final gecerliMusteri = StateProvider<Map<String, dynamic>>(
  (ref) => {},
);

//fatura için ürün ekledikçe hesaplanan toplam değerlerini tutan provider
final toplamDegerleriProvider = StateProvider<Map<String, dynamic>>(
  (ref) => {},
);

//faturalarım sayfasında radio değeri tutan provider
final radioProvider = StateProvider<int?>((ref) => null,);