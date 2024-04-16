import 'dart:async';
import 'package:regamba/betsheet.dart';
import 'package:flutter/material.dart';

int totalAmountGame=0;
List<dynamic> bets = [];
bool onlineAcc=false;
String email='';
bool? betOnRed;
bool? betOnBlack;
int amtonred= 0;
int amtonblack= 0;
class GameTime extends StatefulWidget {
  String Accemail;
  bool online;
  int totalAmount;
  GameTime(this.totalAmount,this.online,this.Accemail);
  @override
  State<GameTime> createState() => _GameTimeState();
}

class _GameTimeState extends State<GameTime>{
  @override
  void initState() {
    totalAmountGame = widget.totalAmount;
    onlineAcc = widget.online;
    email = widget.Accemail;
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.green,

        body: Column(
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child:const Center(
                      child: Text('0',style: TextStyle(color: Colors.white,fontFamily: 'Black',fontWeight: FontWeight.bold),)
                  ),
                ),
              ),
              const RouletteTableDesign(),
              const Padding(padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DraggableImage(asset: 'assets/chipBlue.png',value: 100,),
                    DraggableImage(asset: 'assets/chipRed.png',value: 50,)
                  ],
                ),),
              OutlinedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Betsheet()));
              }, child: const Text("See Bets"))
            ]),
      ),
    );
  }
}


class DraggableImage extends StatefulWidget {
  final String asset;
  final int value;

  const DraggableImage({super.key, required this.asset, required this.value});

  @override
  _DraggableImageState createState() => _DraggableImageState();
}

class _DraggableImageState extends State<DraggableImage> {
  bool isVisible = true;

  @override
  void didUpdateWidget(covariant DraggableImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    checkVisibility();
  }

  void checkVisibility() {
    setState(() {
      isVisible = totalAmountGame >= widget.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Draggable<Map>(
          data: {'imagepath': widget.asset.toString(), 'amount': widget.value},
          feedback: Image.asset(widget.asset, width: 50),
          onDragStarted: checkVisibility,
          childWhenDragging: Container(),
          onDragEnd: (details) {
            if (totalAmountGame >= widget.value) {
            } else {
              checkVisibility();
            }
            checkVisibility();
          },
          child: isVisible
              ? Image.asset(widget.asset, width: 50)
              : Container(),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
          ),
          onPressed: () {
            setState(() {
              checkVisibility();
            });
          },
          child: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}

class PlaceBets {
  final String bet;
  final int amount;

  PlaceBets(this.bet, this.amount) {
    totalAmountGame -= amount;
    bool found = false;
    for (int i = 0; i < bets.length; i++) {
      if (bets[i]['bet'] == bet) {
        bets[i]['amount'] += amount;
        found = true;
        break;
      }
    }
    if (!found) {
      bets.add({'bet': bet, 'amount': amount});
    }
  }
}

class PlaceBetsColor {
  final String bet;
  final int amount;

  PlaceBetsColor(this.bet, this.amount) {
    totalAmountGame -= amount;
    if (bet == "red") {
      betOnRed = true;
      amtonred += amount;
    } else {
      betOnBlack = true;
      amtonblack += amount;
    }
  }
}

class RouletteNumberBox extends StatefulWidget {
  final int number;
  final Color color;
  const RouletteNumberBox(this.number, this.color, {super.key});
  @override
  _MyDragTargetState createState() => _MyDragTargetState();
}

class _MyDragTargetState extends State<RouletteNumberBox> {
  String? imagePath;


  @override
  Widget build(BuildContext context) {
    return DragTarget<Map>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 68,
          height: 50,
          decoration: BoxDecoration(
            color: widget.color,
          ),
          child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    widget.number.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ), imagePath == null
                      ? Container() : Image.asset(imagePath!,width: 30,),
                ],
              )
          ),
        );
      },
      onWillAcceptWithDetails: (data) => true,
        onAcceptWithDetails: (DragTargetDetails<Map> details) async {
          setState(() {
            imagePath = details.data['imagepath'];
          });
          PlaceBets(widget.number.toString(), details.data['amount']);
        },

    );
  }
}
class ColorBet extends StatefulWidget {
  final Color name;
  final double size;

  const ColorBet(this.name, this.size, {super.key});
  @override
  _ColorBet createState() => _ColorBet();
}

class _ColorBet extends State<ColorBet> {
  String? imagePath;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Map>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 120*widget.size,
          height: 50*4*widget.size,
          decoration: BoxDecoration(color: widget.name,
            border: Border.all(color: Colors.white, width: 1),
          ),
          child:Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    "RED",style: TextStyle(color:widget.name,fontFamily: 'Bold',fontSize: 30*widget.size),
                  ), imagePath == null
                      ? Container() : Image.asset(imagePath!,width: 30,),
                ],
              )
          ),
        );
      },
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (DragTargetDetails<Map> details) async {
        setState(() {
          imagePath = details.data['imagepath'];
        });
        PlaceBets(widget.name.toString(), details.data['amount']);
      },
    );
  }
}
class SectionBet extends StatefulWidget {
  final String name;
  final double size;

  const SectionBet(this.name, this.size, {super.key});
  @override
  _SectionBet createState() => _SectionBet();
}

class _SectionBet extends State<SectionBet> {
  String? imagePath;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Map>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 120*widget.size,
          height: 50*4*widget.size,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
          ),
          child:Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    widget.name.toString(),style: TextStyle(color: Colors.white,fontFamily: 'Bold',fontSize: 30*widget.size),
                  ), imagePath == null
                      ? Container() : Image.asset(imagePath!,width: 30,),
                ],
              )
          ),
        );
      },
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (DragTargetDetails<Map> details) async {
        setState(() {
          imagePath = details.data['imagepath'];
        });
        PlaceBets(widget.name.toString(), details.data['amount']);
      },
    );
  }
}
class ColumnBet extends StatefulWidget {
  final String name;
  final double size;

  const ColumnBet(this.name, this.size, {super.key});
  @override
  _ColumnBet createState() => _ColumnBet();
}

class _ColumnBet extends State<ColumnBet> {
  String? imagePath;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Map>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 68,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
          ),
          child:Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    widget.name.toString(),style: TextStyle(color: Colors.white,fontFamily: 'Bold',fontSize: 30*widget.size),
                  ), imagePath == null
                      ? Container() : Image.asset(imagePath!,width: 30,),
                ],
              )
          ),
        );
      },
      onWillAcceptWithDetails: (data) => true,
        onAcceptWithDetails: (DragTargetDetails<Map> details) async {
          setState(() {
            imagePath = details.data['imagepath'];
          });
          PlaceBets(widget.name.toString(), details.data['amount']);
        },
    );
  }
}
class RouletteTableDesign extends StatelessWidget {
  const RouletteTableDesign({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          child:
          Row(
            children: [
              Row(
                children: [
                  const Column(
                    children: [
                      SectionBet("1 to 18", 0.5),
                      SectionBet("EVEN", 0.5),
                      ColorBet(Colors.red, 0.5),
                      ColorBet(Colors.black, 0.5),
                      SectionBet("ODD", 0.5),
                      SectionBet("19 to 36", 0.5),
                      SizedBox(height: 50,)
                    ],
                  ),
                  Column(
                    children: [
                      const SectionBet("1st 12",1),
                      const SectionBet("2nd 12",1),
                      const SectionBet("3rd 12",1),
                      Container(
                          width: 120,
                          height: 50,
                          decoration:BoxDecoration(
                              border: Border.all(color: Colors.white,width: 1)
                          ),
                          child: const Center(
                            child: Text("",style: TextStyle(color: Colors.white,fontFamily: 'Black',fontSize: 30),
                            ),
                          )
                      )],
                  ),
                ],
              ),
              const Column(
                children: [
                  Row(
                    children: [
                      RouletteNumberBox(1, Colors.red),
                      RouletteNumberBox(2, Colors.black),
                      RouletteNumberBox(3, Colors.red),
                    ],
                  ),
                  Row(
                    children: [
                      RouletteNumberBox(4, Colors.black),
                      RouletteNumberBox(5, Colors.red),
                      RouletteNumberBox(6, Colors.black),
                    ],
                  ),
                  Row(
                    children: [
                      RouletteNumberBox(7, Colors.red),
                      RouletteNumberBox(8, Colors.black),
                      RouletteNumberBox(9, Colors.red),
                    ],
                  ),
                  Row(
                    children: [
                      RouletteNumberBox(10, Colors.black),
                      RouletteNumberBox(11, Colors.black),
                      RouletteNumberBox(12, Colors.red),
                    ],
                  ),
                  Row(
                    children: [
                      RouletteNumberBox(13, Colors.black),
                      RouletteNumberBox(14, Colors.red),
                      RouletteNumberBox(15, Colors.black),
                    ],
                  ),
                  Row(
                    children: [
                      RouletteNumberBox(16, Colors.red),
                      RouletteNumberBox(17, Colors.black),
                      RouletteNumberBox(18, Colors.red),
                    ],
                  ),
                  Row(
                    children: [
                      RouletteNumberBox(19, Colors.red),
                      RouletteNumberBox(20, Colors.black),
                      RouletteNumberBox(21, Colors.red),
                    ],
                  ),
                  Row(
                    children: [
                      RouletteNumberBox(22, Colors.black),
                      RouletteNumberBox(23, Colors.red),
                      RouletteNumberBox(24, Colors.black),
                    ],
                  ),
                  Row(
                    children: [
                      RouletteNumberBox(25, Colors.red),
                      RouletteNumberBox(26, Colors.black),
                      RouletteNumberBox(27, Colors.red),
                    ],
                  ),
                  Row(
                    children: [
                      RouletteNumberBox(28, Colors.black),
                      RouletteNumberBox(29, Colors.black),
                      RouletteNumberBox(30, Colors.red),
                    ],
                  ),
                  Row(
                    children: [
                      RouletteNumberBox(31, Colors.black),
                      RouletteNumberBox(32, Colors.red),
                      RouletteNumberBox(33, Colors.black),
                    ],
                  ),
                  Row(
                      children: [
                        RouletteNumberBox(34, Colors.red),
                        RouletteNumberBox(35, Colors.black),
                        RouletteNumberBox(36, Colors.red),
                      ]
                  ),

                  Row(
                      children: [
                        ColumnBet("2:1", 1),
                        ColumnBet("2:1", 1),
                        ColumnBet("2:1", 1),
                      ]
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }
}