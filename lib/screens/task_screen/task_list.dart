import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../models/FireStoreService.dart';
import '../../models/UserEmailProvider.dart';
import '../auth_screens/login_screen.dart';

import '../../models/auth.dart';
import 'package:flutter/services.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _fromKeyForUpdate = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<TransactionLog> transactionLogs = [];

  final FirestoreService _firestoreService = FirestoreService();

  String Useremail = "";
  String Username = "";
  int Amount = 0;

  @override
  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadUsernameAndAmount();

  }

  Future<void> _loadTransactionLogs(String usernamee) async {
    List<TransactionLog> logs = await _firestoreService.getTransactionLogs(usernamee);
    setState(() {
      transactionLogs = logs;
    });
  }


  Future<void> _loadUsernameAndAmount() async {
    String userEmail = Provider.of<UserEmailProvider>(context, listen: false).enteredEmail;
    print(userEmail);
    String? userName = await _firestoreService.getUserName(userEmail);
    int? amount = await _firestoreService.getUserAmount(userEmail);
    print(userName);
    _loadTransactionLogs(userName!);

    setState(() {
      Username = userName!;
      Useremail = userEmail!;
      Amount = amount!;
    });

  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: Center(child: const Text('Galaxy Ray')),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await UserAuth.clearUserAuth();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (cntxt) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.amberAccent,
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Text(
                        'Email: $Useremail'
                    ),
                    SizedBox(height: 20,),
                    Text(
                        '  Username: $Username '
                    ),
                    SizedBox(height: 20,),
                    Text(
                        ' Main Amount: $Amount'
                    ),
                    SizedBox(height: 20,)
                  ],
                ),
              )
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactionLogs.length,
              itemBuilder: (context, index) {
                print('Data length ${transactionLogs.length}');
                return Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text('Amount: ${transactionLogs[index].amount}'),
                          Text('Description: ${transactionLogs[index].description}'),
                          Text('Type: ${transactionLogs[index].type}'),

                        ],
                      ),
                      Container(
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                await updateTaskShowModalBottomSheet(
                                  transactionLogs[index].documentId,
                                  transactionLogs[index].description
                                );
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                _firestoreService.deleteTransaction(transactionLogs[index].documentId);
                                _loadUsernameAndAmount();
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      )

                    ],
                  )
                  // child: ListTile(
                  //   title: Text('Amount: ${transactionLogs[index].amount}'),
                  //   subtitle: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text('Description: ${transactionLogs[index].description}'),
                  //       Text('Type: ${transactionLogs[index].type}'),
                  //     ],
                  //   ),
                  // ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          onPressed: () {
            addNewTaskShowModalBottomSheet();
          },
          backgroundColor: Colors.amberAccent,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> addNewTaskShowModalBottomSheet() async {
    showModalBottomSheet<void>(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _fromKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter the amount';
                    }
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid integer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter the description';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (_fromKey.currentState!.validate() == true) {
                        print('press clicked before' );
                        await _firestoreService.depositAmount(Useremail, int.parse(_amountController.text));
                        await _firestoreService.addTransactionLog(Username, int.parse(_amountController.text), 'Deposit', _descriptionController.text);
                        print('press after');
                        print(Useremail);
                        _loadUsernameAndAmount();
                      }
                    },
                    child: Text('Deposit')),
                ElevatedButton(
                    onPressed: () async {
                      if (_fromKey.currentState!.validate() == true) {
                        await _firestoreService.withdrawAmount(Useremail, int.parse(_amountController.text));
                        await _firestoreService.addTransactionLog(Username,int.parse(_amountController.text), 'Withdraw', _descriptionController.text);
                        print(Useremail);
                        _loadUsernameAndAmount();
                      }
                    },
                    child: Text('Withdraw')),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      _amountController.clear();
      _descriptionController.clear();
    });
  }

  Future<void> saveTask() async {
    String userId = firebaseAuth.currentUser!.uid;
    Map<String, String> task = {
      'title': _amountController.text.trim(),
      'description': _descriptionController.text.trim(),

    };
    firestore.collection(userId).doc().set(task).then((_) {
      log('Task Added.');
      _fromKey.currentState!.reset();
    }).catchError((onError) {
      log(onError.toString());
    });
  }

  Future<void> updateTaskShowModalBottomSheet(
      String id, String description) async {
    _descriptionController.text = description;
    showModalBottomSheet<void>(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _fromKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text('Update Task'),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter the description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    print('work');
                    print('id is $id');
                    await _firestoreService.updateTransactionDescription(id, _descriptionController.text.trim());
                    _loadUsernameAndAmount();
                    Navigator.pop(context);
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      _amountController.clear();
      _descriptionController.clear();
    });
  }

  Future<void> updateTask(
      String title, String description, String taskId) async {
    String userId = firebaseAuth.currentUser!.uid;
    Map<String, String> task = {
      'title': title,
      'description': description,
    };

    firestore.collection(userId).doc(taskId).update(task).then((_) {
      log('Task Updated.');
      Navigator.pop(context);
    }).catchError((error) {
      log(error.toString());
    });
  }
}
