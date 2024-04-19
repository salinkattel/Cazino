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

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'users1.db');

    _database = await openDatabase(
      path,
      version: 1,
    );

    bool isDatabaseExists = await databaseExists(path);

    if (!isDatabaseExists) {
      isDatabaseEmpty = true;
    } else {
      // Check if the database is empty by querying the number of rows in the 'users' table
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

  Future<void> storeUserInfo(String uid, String email, String password,
      int balance, BuildContext context) async {
    try {
      // Check if document already exists
      final docSnapshot = await FirebaseFirestore.instance.collection('users')
          .doc(email)
          .get();
      if (docSnapshot.exists) {
        // Show entry already uploaded message
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text('Error'),
                content: Text('This user info is already in the database'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  ),
                ],
              ),
        );
        return;
      }


      await FirebaseFirestore.instance.collection('users').doc(email).set({
        'email': email,
        'password': password,
        'balance': balance,
      });

      // Show success message
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
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
    } catch (e) {
      // Show error message
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
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
      print('Failed to store user info: $e');
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('User List'),
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
          child: Text("PLS SIGN UP WITH A ACCOUNT"),
        )
            : ListView.builder(
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];
            return ListTile(
              // Add an icon button here
              title: Row(
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () async {
                          storeUserInfo(user['id'].toString(), user['email'],
                              user['password'], user['balance'], context);
                        },
                        icon: const Icon(Icons.upload,color: Colors.white,),
                      ),
                       Text(
                        "Upload",
                        style: TextStyle(fontSize: 12,color: Colors.grey),
                      )
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            GameTime(user['balance'], false, user['email'])),
                      );
                    },
                    child: Text(user['email'].split('@')[0].toUpperCase(),style: TextStyle(fontSize: 14),),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Balance: ${user['balance']}',style: TextStyle(color: Colors.grey),),
                  IconButton(
                    icon: const Icon(Icons.delete,color: Colors.grey,),
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