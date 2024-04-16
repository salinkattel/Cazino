import 'package:flutter/material.dart';
import 'package:regamba/game.dart';

class DisplayResults extends StatefulWidget {
  final int number;
  final List<dynamic> betsSheets;
  final List<String> process;

  const DisplayResults(this.number, this.betsSheets, this.process, {super.key});

  @override
  _DisplayResults createState() => _DisplayResults();
}

class _DisplayResults extends State<DisplayResults> {
  List<dynamic> betsSheetsRes = [];
  int value = 0;

  @override
  void initState() {
    super.initState();
    betsSheetsRes = widget.betsSheets;
    value = widget.number;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false, // This line removes the back button
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          title: Center(child: const Text("Result tab")),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/offloginbg.png'),
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.75),
                BlendMode.darken,
              ),
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Text(totalAmountGame.toString()),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.process.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(widget.process[index]),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  bets = [];
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        GameTime(totalAmountGame, onlineAcc, email)),
                  );
                },
                child: const Text("Play Again"),
              )
            ],
          ),
        ),
      ),
    );
  }
}