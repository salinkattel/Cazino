import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:regamba/accountsheet.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:regamba/game.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  late Database _database;
  bool _isLoading = false;


  Future<void> loginUser(String email, BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.25,
            child: Image.asset(
              "assets/cazino.png",
              height: 800,
              width: 500,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Image.asset(
                    "assets/txtlogo.png",
                    fit: BoxFit.contain,
                  ),
                  Text("LOGIN", style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 20)),
                  const SizedBox(height: 20),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegExp.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value!;
                    },
                  ),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      _password = value; // Assign _password here
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                            },
                            child: const Text("Signup"),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const UserListView()),
                              );
                            },
                            child: const Text("Offline Login", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            loginUser(_email, context);
                          }
                        },
                        child: Text('Login', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Loading indicator
          if (_isLoading)
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.purple),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

}
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  late Database _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(await getDatabasesPath(), 'users3.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, password TEXT,balance INTEGER,isOnline INTEGER)',
        );
        print("DATAENTERS!!!!!!!");
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Ensure the database is initialized
        final Database _database = await _initializeDatabase();

        // Ensure the users table exists
        await _createUsersTableIfNotExists(_database);

        // Query the database to check if the email exists
        final List<Map<String, dynamic>> existingUser = await _database.query(
          'users',
          where: 'email = ?',
          whereArgs: [_email],
        );

        if (existingUser.isEmpty) {
          await _database.insert(
            'users',
            {'email': _email, 'password': _password, 'balance': 1000, 'isOnline': 0},
          );
          // Navigate to the UserListView
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserListView()),
          );
        } else {
          // Show an error dialog if the user already exists
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('User already exists.'),
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
        }
      } catch (e) {
        print('Error saving user data: $e');
      }
    }
  }

  Future<Database> _initializeDatabase() async {
    return await openDatabase(
      'users3.db',
      version: 1,
      onCreate: (db, version) async {
        await _createUsersTableIfNotExists(db);
      },
    );
  }

  Future<void> _createUsersTableIfNotExists(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE,
      password TEXT,
      balance INTEGER,
      isOnline INTEGER
    )
  ''');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.25,
            child: Image.asset(
              "assets/cazino.png",
              // fit: BoxFit.cover,
              height: 800,
              width:500,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Image.asset(
                    "assets/txtlogo.png",
                    fit: BoxFit.cover,
                  ),
                  Text("SIGN UP",style: TextStyle(color: Colors.deepPurpleAccent,fontSize:20),),
                  const SizedBox(height: 20),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegExp.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value!;
                    },
                  ),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      _password = value; // Assign _password here
                      return null;
                    },
                  ),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _password) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _confirmPassword = value!;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      const SizedBox(width: 60),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Sign Up'),
                      ),
                      const SizedBox(width: 50),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text('Login'),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}