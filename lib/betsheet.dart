import 'package:flutter/material.dart';
import 'package:regamba/game.dart';
import 'package:regamba/spin.dart';
class Betsheet extends StatefulWidget {
  const Betsheet({super.key});

  @override
  State<Betsheet> createState() => _BetsheetState();
}

class _BetsheetState extends State<Betsheet> {
  @override
  void initState() {
    if (totalAmountGame < 0) {
      bets.removeLast();
      totalAmountGame = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Bet List'),
              Text("Funds remaning: "+totalAmountGame.toString(),style: TextStyle(fontSize: 18,color: Colors.deepPurpleAccent),)
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
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
          child: bets.isEmpty
              ? const Center(
            child: Text('No bets yet',style: TextStyle(color: Colors.white),),
          )
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: bets.length,
                  itemBuilder: (context, index) {
                    final currentBet = bets[index];
                    return ListTile(
                      title: Text("Bet on : " + currentBet['bet'],style: TextStyle(color: Colors.white)),
                      subtitle: Text('Amount: ${currentBet['amount']}',style: TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete,color: Colors.white,),
                        onPressed: () {
                          setState(() {
                            bets.removeAt(index);
                            totalAmountGame +=
                                (currentBet['amount'] as num).toInt();
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SpinWheel(bets)));
                },
                child: const Text('Spin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


