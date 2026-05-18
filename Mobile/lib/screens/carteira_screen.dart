import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile/services/ListStartupService.dart';

class CarteiraScreen extends StatefulWidget{
  const CarteiraScreen({super.key});

  @override
  State<CarteiraScreen> createState() => _CarteiraScreenState();
}

class _CarteiraScreenState extends State<CarteiraScreen>{

  bool _visivel = true;


  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color.fromARGB(255, 2, 12, 20),
    body: Container(
      padding: EdgeInsetsGeometry.all(20),
      margin: EdgeInsets.only (top: MediaQuery.of(context).size.height * 0.1),
      width: double.infinity,
      child: Column(
        spacing: 50,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
            text: "Minha Carteira\n",
            style: TextStyle(fontWeight: FontWeight(800), fontSize: 36),
            children: [
            TextSpan(
              text: "Acompanhe seu saldo e tokens",
              style: TextStyle(fontWeight: FontWeight(200), fontSize: 16)
            )
          ]
        ),
    ),
          Container(
            padding: EdgeInsetsGeometry.only(top: 15, bottom: 15, left: 20, right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(123, 18,56,176),
                    Color.fromARGB(200, 43, 111, 244),
                    Color.fromARGB(123, 18,56,176),
              ]),
              borderRadius: BorderRadiusGeometry.all(Radius.circular(30)),
            ),
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Text("Patrimônio Total",
                          style: TextStyle(
                              fontWeight: FontWeight(300)
                          ),
                        ),
                        IconButton(
                            icon: Icon(
                              _visivel? Icons.remove_red_eye : Icons.question_mark_sharp,
                            ),
                            onPressed: () {
                              setState(() {
                                _visivel = !_visivel;
                              });
                            }
                        ),
                      ],
                    ),
                    _visivel ? Text('R\$ 15.800,00',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight(800),
                        fontSize: 26,
                      ),
                    ) : Text('-',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight(800),
                          fontSize: 26
                      ),
                    ),
                  ],
                ),

                Divider(
                  height: 20,
                  color: Colors.grey,
                  radius: BorderRadiusGeometry.all(Radius.circular(20)),

                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      spacing: 6,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Saldo disponível',
                          style: TextStyle(
                            fontWeight: FontWeight(300)
                          ),
                        ),
                        _visivel ? Text('R\$5.832,00',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight(800),
                            fontSize: 16,
                          ),
                        ) : Text('-',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight(800),
                              fontSize: 16
                          ),
                        ),

                      ],
                    ),
                    SizedBox(
                      height: 50,
                      child: VerticalDivider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    Column(
                      spacing: 6,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lucro/Prejuízo',
                          style: TextStyle(
                              fontWeight: FontWeight(300)
                          ),
                        ),
                        _visivel ? Text('+R\$432,00',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight(800),
                            fontSize: 16,
                            color: Colors.green
                          ),
                        ) : Text('-',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight(800),
                              fontSize: 16
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,

                  children: [
                    ElevatedButton(
                      onPressed: ()=>null,
                      style: ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(15)),
                        backgroundColor: WidgetStatePropertyAll(Color.fromARGB(123, 217, 217, 217)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            side: BorderSide(
                            style: BorderStyle.solid,
                            width: 1,
                            color: Colors.grey,
                        ),borderRadius: BorderRadiusGeometry.all(Radius.circular(10)))),
                      ),
                      child: Container(
                        width: 130,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add,color: Colors.white,),
                            Text("Adicionar Saldo",
                              style: TextStyle(
                                  fontWeight: FontWeight(800),
                                  color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                    ElevatedButton(
                      onPressed: ()=>null,
                      style: ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(15)),
                        backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 43, 111, 244)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.all(Radius.circular(10)))),
                      ),
                      child: Container(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Investir",
                              style: TextStyle(
                                  fontWeight: FontWeight(800),
                                  color: Colors.white,
                              ),
                            ),
                            Icon(Icons.auto_graph,color: Colors.white,)
                          ],
                        ),
                      )
                    ),
                  ],
                )
              ],
            ),
          ),


          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Text("Tokens",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight(800)
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(40, 217, 217, 217),
                    border: BoxBorder.all(
                      color: Colors.grey,
                      width: 0.5
                    ),
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(20))
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsetsGeometry.all(30),
                        child: Row(
                          spacing: 20,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.domain),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Karpós S.A",
                                  style: TextStyle(
                                    fontWeight: FontWeight(600),
                                    fontSize: 20
                                  ),
                                ),
                                Text("350 tokens",
                                  style: TextStyle(
                                    color: Colors.grey
                                  ),
                                ),
                                Text("15,00/un",
                                  style: TextStyle(
                                      color: Colors.grey
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("R\$ 5.250,00",
                                  style: TextStyle(
                                    fontSize: 18
                                  ),
                                ),
                                Text("+ 5.2%",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,

                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.white,)
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          ),




  ],)));
}