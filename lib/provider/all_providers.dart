import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mailer/smtp_server.dart';

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
final seciliFaturaProvider = StateProvider<Map<String, dynamic>>(
  (ref) => {},
);

//fatura keserken girilen ürünleri ve birim, miktar, kdv değerlerini tutan provider
final urunListesiProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) {
    return [];
  },
);

//satıcı firmanın adını tutan provider
/* final saticiAdi = StateProvider<String>(
  (ref) => '',
); */

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
final radioFaturaProvider = StateProvider<int?>(
  (ref) => null,
);

//alıcı sec sayfasında radio değeri tutan provider
final radioAliciProvider = StateProvider<int?>(
  (ref) => null,
);

//fatura gönderirken seçilen faturanın dosya yolunu tutan provider
final filePathProvider = StateProvider<String>(
  (ref) => '',
);

//alıcı seç sayfasındaki bottomnavbar görünürlüğü
final aliciSecBottomNavBarProvider = StateProvider<bool>(
  (ref) => false,
);

//alıcı seç sayfasındaki listtile uzun basılınca seçilen müşteri bilgileri
final aliciSecSeciliMusteriProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

//alici seç sayfasındaki alıcı listesini tutan provider
final aliciListesiProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) => [],
);

//uygulamanın gönderen kişisi olduğu mail bilgilerini tutan provider
final mailBilgisiProvider = StateProvider<Map<String, dynamic>>(
  (ref) => {},
);

//doğrulama kodlarını tutan provider
final dogrulamaKodlariProvider = StateProvider<List<dynamic>>(
  (ref) => [],
);

//yetki seviyesi tutan provider
final yetkiSeviyesiProvider = StateProvider<int?>(
  (ref) => null,
);

//db den gelen açıklamaları tutan provider
final aciklamalarProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) => [],
);

//o an geçerli olan açıklamayı tutan provider
final seciliAciklamaProvider = StateProvider<String?>(
  (ref) => null,
);

//db den gelen ürün isimlerini tutan provider
final urunlerProvider = StateProvider<List<String>>(
  (ref) => [],
);

//o an geçerli olan ürünü tutan provider
final seciliUrunProvider = StateProvider<String?>(
  (ref) => null,
);

//firebaseden gelen faturanolar mapini tutan provider
final faturaNolarProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

//tarih sec sayfasında, firebasedeki fatura no eklemek için kullanılacak tarih + sayi formati
final tarihSayiProvider = StateProvider<List<int>>(
  (ref) => [],
);

//firebasede tutulan faturanoBicim değişkenini tutan provider
final faturaNoBicimProvider = StateProvider<String?>(
  (ref) => null,
);

//tarih sec sayfasında secilen tarihi Datetime olarak tutan provider
final tarihDatetimeProvider = StateProvider<DateTime?>((ref) => null);

//firebaseye yazılacak faturanın döküman adını tutan provider
//final faturaDocAdiProvider = StateProvider<String?>((ref) => null,);

//firebaseye yazılacak fatura no map değeri tutan provider
final yazilacakFaturaNoProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

//yazılacak faturanın map halini tutan Provider
final yazilacakFaturaMapProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

//imza String verisi tutan provider
final imzaProvider = StateProvider<String?>(
  (ref) => null,
);

//imza uint8list verisi tutan provider
final imzapngProvider = StateProvider<Uint8List?>(
  (ref) => null,
);

//firma logosu yüklerken galeriden seçilen resmi tutan uint8list provider
final logoProvider = StateProvider<Uint8List?>(
  (ref) => null,
);

//firebasede tutulan faturanoBicim değişkenini tutan provider
final faturaFormatProvider = StateProvider<String>(
  (ref) => 'Format1',
);
final faturaFormatIndexProvider = StateProvider<int?>(
  (ref) => null,
);

//çoklu fatura gönderme sayfası checkbox listesi
final faturaCheckboxProvider = StateProvider<List<bool>?>(
  (ref) => null,
);
final cokluFaturaHepsiProvider = StateProvider<bool>(
  (ref) => false,
);

final seciliTarihAraligiProvider = StateProvider<String>(
  (ref) => 'Başlangıç ve Bitiş Tarihi Seçin',
);

final seciliTarihAraligindakiFaturalar =
    StateProvider<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
  (ref) => [],
);

//çoklu fatura alıcı seç listesi
final cokluFaturaAliciListesiProvider =
    StateProvider<List<Map<String, dynamic>>>(
  (ref) => [],
);

//çoklu fatura alıcı seçme radio button değeri tutan provider
final radioCokluFaturaAliciProvider = StateProvider<int?>(
  (ref) => null,
);

//email enabled provider
final cokluFaturaEmailEnabledProvider = StateProvider<bool>(
  (ref) => false,
);

//toplu göndermek için seçilen faturaları tutan provider
final secilenTopluFaturalarProvider =
    StateProvider<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
  (ref) => [],
);

//çoklu fatura gönderilecek alıcı mail adresini tutan provider
final cokluFaturaAliciMailProvider = StateProvider<String?>(
  (ref) => null,
);

//çoklu fatura pathleri
final cokluFaturaPathleriProvider = StateProvider<List<String>>(
  (ref) => [],
);

//mail göndermek için smtp tutuan provider
final smtpProvider = StateProvider<SmtpServer?>(
  (ref) => null,
);

//fatura oluşturuldu mu onay kontrolü tutan provider
final faturaKaydedildiMiProvider = StateProvider<bool?>(
  (ref) => null,
);

//saticinin firebaseden getirilen bilgilerini tutan provider
final saticiBilgileriProvider = StateProvider<Map<String, dynamic>?>((ref) => null,);


