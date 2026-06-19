import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calculation_model.dart';

class CarbonService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'carbon_calculations';

  Future<String> addCalculation(CalculationRecord record) async {
    final docRef = await _db.collection(_collection).add(record.toFirestore());
    return docRef.id;
  }

  Future<void> updateCalculation(CalculationRecord record) async {
    await _db.collection(_collection).doc(record.id).update(record.toFirestore());
  }

  Future<void> deleteCalculation(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  /// All calculations — for admin view (read-only)
  Stream<List<CalculationRecord>> getCalculationsStream() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CalculationRecord.fromFirestore(doc))
            .toList());
  }

  /// Only calculations belonging to a specific owner — for owner view
  Stream<List<CalculationRecord>> getCalculationsStreamByOwner(String ownerUid) {
    return _db
        .collection(_collection)
        .where('ownerUid', isEqualTo: ownerUid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => CalculationRecord.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }
}
