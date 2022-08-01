import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'all_providers.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
final gondericiMail = _firestore.collection('uygulama_mail').doc('mail');
final emailCollection = _firestore.collection(_auth.currentUser!.displayName!);
final saticiFirmaCollection =
    _firestore.collection(_auth.currentUser!.displayName!).doc('saticiFirma');
