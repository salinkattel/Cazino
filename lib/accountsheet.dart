import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:regamba/game.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserListView extends StatefulWidget {
  const UserListView({Key? key});

  @override
  _UserListViewState createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  late Database _database;
  List<Map<String, dynamic>> _users = [];
  bool isDatabaseEmpty = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }


  Future<void> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'users3.db');

    _database = await openDatabase(
      path,
      version: 1,
    );

    bool isDatabaseExists = await databaseExists(path);

    if (!isDatabaseExists) {
      isDatabaseEmpty = true;
    } else {
      int? count = Sqflite.firstIntValue(
          await _database.rawQuery('SELECT COUNT(*) FROM users'));
      if (count == 0) {
        isDatabaseEmpty = true;
      }
    }

    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _database.query('users');
    setState(() {
      _users = users;
    });
  }
  Future<void> UpdateUser(String email, BuildContext context) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(email).get();
      if (!docSnapshot.exists) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final userData = docSnapshot.data() as Map<String, dynamic>;
      final balance = userData['balance'] as int;
      final useremail = userData['email'] as String;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Sucessful'),
          content: Text('Your balance is $balance.'),
          actions: <Widget>[
            balance < 50
                ? TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Account lacks funds"),
            )
                : TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("ReLogin"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameTime(balance, true, useremail)),
                );
              },
              child: Text("Go to Table"),
            ),
          ],
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to find email in database'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      print('Failed to login: $e');
    }
  }
  Future<void> storeUserInfo(String uid, String email, String password, int balance, BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    setState(() {
      _isLoading = true;
    });

    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(email).get();
      if (docSnapshot.exists) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Email already exists'),
            content: Text('Please change the email to upload this account'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Enter a Unique Email'),
                        content: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Please change the email to upload this account'),
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(labelText: 'New Email'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an email';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  if (!docSnapshot.exists) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    return 'Email already exists';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                storeUserInfo(uid, emailController.text, password, balance,context);
                                _changeemail(email,emailController.text);
                                Navigator.of(context).pop();
                                print('Email updated to: ${emailController.text}');
                              }
                            },
                            child: Text('Update'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel'),
                          ),
                        ],
                      ),
                    );
                },
                child: Text('Edit email'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        _changestatus(email);
        await FirebaseFirestore.instance.collection('users').doc(email).set({
          'email': email,
          'password': password,
          'balance': balance,
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('User info stored successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to store user info: $e'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _loadUsers();
      });
    }
  }

  Future<void> _deleteUser(String email) async {
    await _database.delete(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    _loadUsers();
  }
  Future<void> _changestatus(String email) async {
    await _database.update(
      'users',
      {'isOnline': 1},
      where: 'email = ?',
      whereArgs: [email],
    );
    _loadUsers();
  }
  Future<void> _changeemail(String email,String newemail) async {
    await _database.update(
      'users',
      {'email': newemail},
      where: 'email = ?',
      whereArgs: [email],
    );
    _loadUsers();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('User List'),
        actions: [
          _isLoading
              ? Padding(
            padding: const EdgeInsets.all(5.0),
            child: CircularProgressIndicator(
              color: Colors.deepPurpleAccent,
            ),
          )
              : SizedBox(),
        ],
      ),
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/resultsbg.jpg'),
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.75),
              BlendMode.darken,
            ),
          ),
        ),
        child: isDatabaseEmpty
            ? Center(
          child: Text(
            "PLS SIGN UP WITH A ACCOUNT",
            style: TextStyle(color: Colors.white),
          ),
        )
            : ListView.builder(
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];
            return ListTile(
              title: Row(
                children: [
                  Column(
                    children: [
                      user['isOnline'] == 0
                          ? IconButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          await storeUserInfo(
                            user['id'].toString(),
                            user['email'],
                            user['password'],
                            user['balance'],
                            context,
                          );
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        icon: const Icon(Icons.upload, color: Colors.white),
                      )
                          : SizedBox(),
                      user['isOnline']==0
                      ? Text(
                        "Upload",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                          : Text("Uploaded",
                            style: TextStyle(fontSize: 12, color: Colors.grey),)

                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      if (user['balance'] <= 0) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Sorry'),
                              content: const Text('Insufficient Funds.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameTime(user['balance'], false, user['email']),
                          ),
                        );
                      }
                    },
                    child: Text(
                      user['email'].split('@')[0].toUpperCase(),
                      style: TextStyle(fontSize: 14, color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Balance: ${user['balance']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () => _deleteUser(user['email']),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}