import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helloworld/models/FirebaseData.dart';

Future<void> addKBData(FirebaseData kbData) async {
  CollectionReference kbCollection =
      FirebaseFirestore.instance.collection('kbdata');

  try {
    await kbCollection.add(kbData.toMap());
    print('Data added successfully');
  } catch (e) {
    print('Failed to add data: $e');
  }
}

Future<List<FirebaseData>> getAllKBData() async {
  CollectionReference kbCollection =
      FirebaseFirestore.instance.collection('kbdata');

  try {
    QuerySnapshot snapshot = await kbCollection.get();
    return snapshot.docs
        .map((doc) => FirebaseData.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('Failed to fetch data: $e');
    return [];
  }
}

Future<void> updateKBData(String docId, FirebaseData kbData) async {
  CollectionReference kbCollection =
      FirebaseFirestore.instance.collection('kbdata');

  try {
    await kbCollection.doc(docId).update(kbData.toMap());
    print('Data updated successfully');
  } catch (e) {
    print('Failed to update data: $e');
  }
}

Future<void> deleteKBData(String docId) async {
  CollectionReference kbCollection =
      FirebaseFirestore.instance.collection('kbdata');

  try {
    await kbCollection.doc(docId).delete();
    print('Data deleted successfully');
  } catch (e) {
    print('Failed to delete data: $e');
  }
}

Future<String?> fetchKbid(String botId) async {
  try {
    CollectionReference botsCollection = FirebaseFirestore.instance.collection(
        'kbdata'); // Asegúrate de usar el nombre correcto de tu colección
    QuerySnapshot snapshot =
        await botsCollection.where('botid', isEqualTo: botId).get();

    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs.first.data() as Map<String, dynamic>;
      return data['kbid'] as String?;
    } else {
      print('No matching bot found.');
      return null;
    }
  } catch (e) {
    print('Error fetching kbid: $e');
    return null;
  }
}
