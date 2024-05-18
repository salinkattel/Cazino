import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:regamba/results.dart';
import 'package:rxdart/rxdart.dart';
import 'package:regamba/game.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';


class SpinWheel extends StatefulWidget {
  final List<dynamic> betsSheets;
  const SpinWheel(this.betsSheets, {super.key});
  @override
  State<SpinWheel> createState() => _SpinWheelState();
}

class _SpinWheelState extends State<SpinWheel> {
  List<String> betsHit = [];
  List<dynamic> betsSheetsRes = [];

  Color getColor(int i) {
    return (i == 0) ? Colors.green : (i % 2 != 0) ? Colors.red : Colors.black;
  }

  int balance = 0;

  bool isSpinning = true;
  bool spinEnded = false;
  final selected = BehaviorSubject<int>();
  int rewards = 0;
  List<int> items = [
    0,
    32,
    15,
    19,
    4,
    21,
    2,
    25,
    17,
    34,
    6,
    27,
    13,
    36,
    11,
    30,
    8,
    23,
    10,
    5,
    24,
    16,
    33,
    1,
    20,
    14,
    31,
    9,
    22,
    18,
    29,
    7,
    28,
    12,
    35,
    3,
    26
  ];
  static const Set<int> redPositions = {1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36};
  static const Set<int> blackPositions = {2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35};

  void checkBets(value) {
  for (int i = 0; i < bets.length; i++) {
  final temp = bets[i];

  if (temp['bet'] == value.toString()) {
  int add = temp['amount']*36;
  balance += add ;
  betsHit.add("Your bet on " + temp['bet'] + " hit you won : +" + add.toString());
  }
  if (temp['bet'] == "1st 12" && (value <= 12 && value != 0)) {
  int add = temp['amount']*3;
  balance += add;
  betsHit.add("Your bet on " + temp['bet'] + " hit you won: +" + add.toString());
  }
  if (temp['bet'] == "2nd 12" && (value >= 13 && value <= 24)) {
  int add = temp['amount']*3;
  balance += add;
  betsHit.add("Your bet on " + temp['bet'] + " hit you won: +" + add.toString());
  }
  if (temp['bet'] == "3rd 12" && (value >= 25 && value <= 36)) {
  int add = temp['amount']*3;
  balance += add;
  betsHit.add("Your bet on " + temp['bet'] + " hit you won: +" + add.toString());
  }
  if (temp['bet'] == "1 to 18" && (value >= 1 && value <= 18)) {
  int add = temp['amount']*2;
  balance += add;
  betsHit.add("Your bet on " + temp['bet'] + " hit you won: +" + add.toString());
  }
  if (temp['bet'] == "19 to 36" && (value >= 19 && value <= 36)) {
  int add = temp['amount']*2;
  balance += add;
  betsHit.add("Your bet on " + temp['bet'] + " hit you won: +" + add.toString());
  }
  if (temp['bet'] == "EVEN" && (value % 2 == 0 && value != 0)) {
  int add = temp['amount']*2;
  balance += add;
  betsHit.add("Your bet on " + temp['bet'] + " hit you won: +" + add.toString());
  }
  if (temp['bet'] == "ODD" && (value % 2 != 0)) {
  int add = temp['amount']*2;
  balance += add;
  betsHit.add("Your bet on " + temp['bet'] + " hit you won: +" + add.toString());
  }
  if (temp['bet'] == 'RED' && redPositions.contains(value)) {
    int add = temp['amount'] * 2;
    balance += add;
    betsHit.add("Your bet on ${temp['bet']} hit! You won: +$add");
  }

  if (temp['bet'] == 'BLACK' && blackPositions.contains(value)) {
    int add = temp['amount'] * 2;
    balance += add;
    betsHit.add("Your bet on ${temp['bet']} hit! You won: +$add");
  }

  if (temp['bet'] == "1st Col" && ((value - 1) % 3 == 0)) {
    int add = temp['amount'] * 2;
    balance += add;
    betsHit.add("Your bet on " + temp['bet'] + " : +" + add.toString());
  }
  if (temp['bet'] == "2nd Col" && ((value - 2) % 3 == 0)) {
    int add = temp['amount'] * 2;
    balance += add;
    betsHit.add("Your bet on " + temp['bet'] + " : +" + add.toString());
  }
  if (temp['bet'] == "3rd Col" && ((value - 3) % 3 == 0)) {
    int add = temp['amount'] * 2;
    balance += add;
    betsHit.add("Your bet on " + temp['bet'] + " : +" + add.toString());
    
  }
  }
  totalAmountGame = balance;
  onlineAcc ? updateBalanceByEmail(email, totalAmountGame) : updateBalanceByEmailOffline(email, totalAmountGame);
  }


  Future<void> updateBalanceByEmailOffline(String email, int newBalance) async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'users3.db');

    final db = await openDatabase(
      path,
      version: 1,
    );

    await db.update(
      'users',
      {'balance': newBalance},
      where: 'email = ?',
      whereArgs: [email],
    );
    await db.close();
  }

  Future<void> updateBalanceByEmail(String email, int newBalance) async {
    // Get a reference to the Firestore database
    final firestore = await FirebaseFirestore.instance;

    final querySnapshot = await firestore.collection('users').where('email', isEqualTo: email).get();

    if (querySnapshot.docs.isNotEmpty) {
      final documentId = querySnapshot.docs.first.id;
      await firestore.collection('users').doc(documentId).update({'balance': newBalance});
    } else {
      print('User with email $email not found');
    }
  }


  @override
  void initState() {
    super.initState();
    betsSheetsRes = widget.betsSheets;
    balance = totalAmountGame;
  }

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return spinEnded ? false : !isSpinning ? false : true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50,),
            Image.asset('assets/wheel.png'),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/cazino123.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    width: 500,
                    height: 300,
                    child: FortuneWheel(
                      selected: selected.stream,
                      animateFirst: false,
                      items: [
                        for (int i = 0; i < items.length; i++)
                          ...<FortuneItem>{
                            FortuneItem(
                              style: FortuneItemStyle(
                                color: getColor(i),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const SizedBox(
                                    width: 150,
                                    height: 50,
                                  ),
                                  Positioned(
                                    left: 130,
                                    child: Text(
                                      items[i].toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          },
                      ],
                      onAnimationStart: () {
                        setState(() {
                          isSpinning = false;
                        });
                      },
                      onAnimationEnd: () {
                        setState(() {
                          rewards = items[selected.value];
                          spinEnded = true;
                          isSpinning = false;
                        });
                        checkBets(rewards);
                        print(rewards);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "The ball has landed on $rewards Check Results",
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            spinEnded
                ? ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DisplayResults(
                          rewards,
                          widget.betsSheets,
                          betsHit,
                        ),
                  ),
                );
              },
              child: const Text("Results"),
            )
                : GestureDetector(
              onTap: () {
                isSpinning
                    ? setState(() {
                  selected.add(Fortune.randomInt(0, items.length));
                })
                    : null;
              },
              child: Container(
                height: 40,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "SPIN!!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontFamily: 'Bold',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 100,)
          ],
        ),
      ),
    );
  }
}