import 'package:flutter/material.dart';
import 'package:regamba/logsign.dart';
import 'accountsheet.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(),
      routes: {
        '/hello': (context) => const HelloPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/txtlogo.png'),
            Image.asset('assets/cazino.png'),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Challenge your luck",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserListView()),
                    );
                  },
                  child: const Text("Offline Login"),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                  },
                  child: const Text("Signup"),
                ),
              ],
            )
          ],
        ),
    );
  }
}

class HelloPage extends StatelessWidget {
  const HelloPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello Page'),
      ),
      body: const Center(
        child: Text(
          'Hello',
          style: TextStyle(fontSize: 30.0),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:regamba/logsign.dart';
// import 'package:regamba/accountsheet.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: Colors.black,
//         body: Column(
//           children: [
//             SizedBox(height: 20),
//             Image.asset('assets/txtlogo.png'),
//             Image.asset('assets/cazino.png'),
//             SizedBox(height: 10),
//             Center(
//               child: Text(
//                 "Challenge your luck",
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//             SizedBox(height: 50),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 OutlinedButton(
//                   onPressed: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
//                   },
//                   child: Text(
//                     "Login",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => UserListView()),
//                     );
//                   },
//                   child: Text("Offline Login"),
//                 ),
//                 OutlinedButton(
//                   onPressed: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
//                   },
//                   child: Text("Signup"),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
