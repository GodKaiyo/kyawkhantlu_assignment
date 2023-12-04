import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> setMainAmount(int amount) async {
    await _firestore.collection('users').doc('mainamount').set({'amount': amount});
  }

  Future<int> getMainAmount() async {
    var document = await _firestore.collection('budget').doc('mainamount').get();
    print(document);
    print(document['amount']);
    return document['amount'];
  }

  Future<void> addTransaction(int amount, bool isDeposit) async {
    int currentAmount = await getMainAmount();

    if (isDeposit) {
      currentAmount += amount;
    } else {
      currentAmount -= amount;
    }

    await setMainAmount(currentAmount);
  }

  Future<void> addTransactionLog(String username, int amount, String type, String description) async {

    DateTime now = DateTime.now();
    String datetime = now.toIso8601String();

    await _firestore.collection('transaction').add({
      'username' : username,
      'amount': amount,
      'type': type,
      'description' : description,
    });
  }


  Future<List<TransactionLog>> getTransactionLogs(String username) async {
    try {
      print('username is $username');
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('transaction')
          .where('username', isEqualTo: username)
          .get();

      return querySnapshot.docs.map((doc) {
        return TransactionLog(
          documentId: doc.id,
          username: doc['username'],
          amount: doc['amount'],
          type: doc['type'],
          description: doc['description'],
        );
      }).toList();
    } catch (e) {
      print('Error getting transaction logs: $e');
      return [];
    }
  }

  // Future<List<TransactionLogWithId>> getTransactionLogsWithIds() async {
  //   final querySnapshot =
  //   await FirebaseFirestore.instance.collection('transaction').get();
  //
  //   return querySnapshot.docs.map((doc) {
  //     return TransactionLogWithId(
  //       id: doc.id,
  //       username: doc['username'],
  //       amount: doc['amount'],
  //       type: doc['type'],
  //       description: doc['description'],
  //     );
  //   }).toList();
  // }

  Future<void> updateTransactionDescription(String transactionId, String newDescription) async {
    final transactionRef = _firestore.collection("transaction").doc(transactionId);
    print('transactionRef is $transactionRef');
    await transactionRef.update({
      'description': newDescription,
    });
    print('transaction update done');
    // await FirebaseFirestore.instance.collection('transaction').doc(transactionId).update({
    //   'description': newDescription,
    // });
  }

  Future<void> deleteTransaction(String transactionId) async {
    await FirebaseFirestore.instance.collection('transaction').doc(transactionId).delete();
  }

  Future<void> depositAmount(String userEmail, int amount) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Get the user document
    QuerySnapshot querySnapshot = await users.where('email', isEqualTo: userEmail).get();
    if (querySnapshot.docs.isNotEmpty) {
      // Update the main amount
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      int currentAmount = userDoc['amount'];
      int newAmount = currentAmount + amount;

      // Update Firestore document
      await users.doc(userDoc.id).update({'amount': newAmount});
    } else {
      print('User not found');
    }
  }

  // Function to withdraw amount
  Future<void> withdrawAmount(String userEmail, int amount) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Get the user document
    QuerySnapshot querySnapshot = await users.where('email', isEqualTo: userEmail).get();
    if (querySnapshot.docs.isNotEmpty) {
      // Update the main amount
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      int currentAmount = userDoc['amount'];
      int newAmount = currentAmount - amount;

      if (newAmount >= 0) {
        // Update Firestore document
        await users.doc(userDoc.id).update({'amount': newAmount});
      } else {
        print('Insufficient funds');
      }
    } else {
      print('User not found');
    }
  }


  Future<String?> getUserName(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming 'email' is a unique field, so there should be at most one document
        var document = querySnapshot.docs.first;
        print(document.data()['name']);
        return document.data()['name'];
        return document.data()['rank'];
      } else {
        // No user found with the provided email
        print("no users found??");
        return null;
      }
    } catch (e) {
      // Handle any errors that occurred during the query
      print("Error getting username: $e");
      return null;
    }
  }

  Future<int?> getUserAmount(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming 'email' is a unique field, so there should be at most one document
        var document = querySnapshot.docs.first;
        print(document.data()['amount']);
        return document.data()['amount'];
      } else {
        // No user found with the provided email
        print("no users found??");
        return null;
      }
    } catch (e) {
      // Handle any errors that occurred during the query
      print("Error getting amount: $e");
      return null;
    }
  }

}

// class TransactionLog {
//   final String username;
//   final String datetime;
//   final int amount;
//   final String type;
//   final int mainAmount;
//
//   TransactionLog({
//     required this.username,
//     required this.datetime,
//     required this.amount,
//     required this.type,
//     required this.mainAmount,
//   });
// }

// class TransactionLogWithId {
//   final String id;
//   final String username;
//   final int amount;
//   final String type;
//   final String description;
//
//   TransactionLogWithId({
//     required this.id,
//     required this.username,
//     required this.amount,
//     required this.type,
//     required this.description,
//   });
// }

class TransactionLog {
  final String documentId;
  final int amount;
  final String description;
  final String type;
  final String username;

  TransactionLog({
    required this.documentId,
    required this.amount,
    required this.description,
    required this.type,
    required this.username,
  });

}
