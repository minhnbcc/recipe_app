import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_app/models/recipe_model.dart';
import 'package:recipe_app/views/recipe_view.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<RecipeModel> recipies = new List();
  String ingridients;
  bool _loading = false;
  String query = "";
  TextEditingController textEditingController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        title: Text('Food Recipes'),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.teal[800], Colors.teal[400]],
                    begin: FractionalOffset.topRight,
                    end: FractionalOffset.bottomLeft)),
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: !kIsWeb ? Platform.isAndroid ? 60 : 30 : 30,
                  horizontal: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 60,
                  ),
                  Text(
                    "What would you like to cook today?",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Overpass'),
                  ),
                  Text(
                    "Please Enter Ingredients you prefer",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'OverpassRegular'),
                  ),
                  Text(
                    "We will help you to sort of recipes for having your meal shortly",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'OverpassRegular'),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: textEditingController,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontFamily: 'Overpass'),
                            decoration: InputDecoration(
                              hintText: "Search recipes",
                              hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800].withOpacity(0.5),
                                  fontFamily: 'Overpass'),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        InkWell(
                            onTap: () async {
                              if (textEditingController.text.isNotEmpty) {
                                setState(() {
                                  _loading = true;
                                });
                                recipies = new List();
                                String url =
                                    "https://api.edamam.com/search?q=${textEditingController.text}&app_id=0f21d949&app_key=8bcdd93683d1186ba0555cb95e64ab26";
                                var response = await http.get(url);
                                print(" $response this is response");
                                Map<String, dynamic> jsonData =
                                    jsonDecode(response.body);
                                print("this is json Data $jsonData");
                                jsonData["hits"].forEach((element) {
                                  print(element.toString());
                                  RecipeModel recipeModel = new RecipeModel();
                                  recipeModel =
                                      RecipeModel.fromMap(element['recipe']);
                                  recipies.add(recipeModel);
                                  print(recipeModel.url);
                                });
                                setState(() {
                                  _loading = false;
                                });

                                print("doing it");
                              } else {
                                print("not doing it");
                              }
                            },
                            splashColor: Colors.blueAccent,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                      colors: [
                                        Colors.blue[600],
                                        Colors.blue[100]
                                      ],
                                      begin: FractionalOffset.topRight,
                                      end: FractionalOffset.bottomLeft)),
                              padding: EdgeInsets.all(8),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Icon(Icons.search,
                                      size: 18, color: Colors.white),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Wrap(
                    children: <Widget>[
                      GridView(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            mainAxisSpacing: 15.0,
                            maxCrossAxisExtent: 200,
                            crossAxisSpacing: 10.0,
                         
                            
                          ),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: ClampingScrollPhysics(),
                          children: List.generate(recipies.length, (index) {
                            return GridTile(
                                child: RecipieTile(
                              title: recipies[index].label,
                              imgUrl: recipies[index].image,
                              desc: recipies[index].source,
                              url: recipies[index].url,
                            ));
                          }))
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class RecipieTile extends StatefulWidget {
  final String title, desc, imgUrl, url;

  RecipieTile({this.title, this.desc, this.imgUrl, this.url});

  @override
  _RecipieTileState createState() => _RecipieTileState();
}

class _RecipieTileState extends State<RecipieTile> {
  _launchURL(String url) async {
    print(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Card(
            child: Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 10, bottom: 10, right: 10),
                  child: GestureDetector(
                    child: InkWell(
                      onTap: () {
                        if (kIsWeb) {
                          _launchURL(widget.url);
                        } else {
                          print(
                              widget.url + " this is what we are going to see");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RecipeView(
                                        postUrl: widget.url,
                                      )));
                        }
                      },
                      splashColor: Colors.blueAccent,
                      child: Container(
                        margin: EdgeInsets.all(16),
                        child: Stack(
                          children: <Widget>[
                            SingleChildScrollView(
                              child: Image.network(
                                widget.imgUrl,
                                height: 200,
                                width: 300,
                                fit: BoxFit.cover,
                              ),
                            ),

                            Container(
                              width: 200,
                              alignment: Alignment.bottomLeft,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [Colors.white30, Colors.white],
                                      begin: FractionalOffset.centerRight,
                                      end: FractionalOffset.centerLeft)),
                            ),
                            // Padding(
                            //     padding: const EdgeInsets.all(10.0),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  // height: 0,
                                  width: 250.0,
                                  padding: const EdgeInsets.only(
                                      top: 220,
                                      left: 50,
                                      bottom: 200,
                                      right: 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        widget.title,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black54,
                                            fontFamily: 'Overpass'),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        widget.desc,
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black54,
                                            fontFamily: 'OverpassRegular'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GradientCard extends StatelessWidget {
  final Color topColor;
  final Color bottomColor;
  final String topColorCode;
  final String bottomColorCode;

  GradientCard(
      {this.topColor,
      this.bottomColor,
      this.topColorCode,
      this.bottomColorCode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        children: <Widget>[
          Container(
            child: Stack(
              children: <Widget>[
                Container(
                  height: 160,
                  width: 180,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [topColor, bottomColor],
                          begin: FractionalOffset.topLeft,
                          end: FractionalOffset.bottomRight)),
                ),
                Container(
                  width: 180,
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.white30, Colors.white],
                          begin: FractionalOffset.centerRight,
                          end: FractionalOffset.centerLeft)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          topColorCode,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        Text(
                          bottomColorCode,
                          style: TextStyle(fontSize: 16, color: bottomColor),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
