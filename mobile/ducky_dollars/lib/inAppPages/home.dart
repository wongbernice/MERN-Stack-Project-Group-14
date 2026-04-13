import 'package:flutter/material.dart';
import 'package:ducky_dollars/main.dart';
import 'package:http/http.dart' as http;
import 'package:ducky_dollars/services/authStorage.dart';
import 'package:cristalyse/cristalyse.dart';
import 'dart:convert';

const spentColor = Color(0xffff6b6b);
const leftColor = Color(0xff98d8a3);

const pieBlue = Color(0xff87cfeb);
const pieYellow = Color(0xfffede2c);
const piePink = Color(0xfff4b8c8);
const pieGreen = Color(0xff98d8a3);
const pieOrange = Color(0xffffb347);
const piePurple = Color(0xffc9a0dc);
const pieSalmon = Color(0xffff6b6b);

class Category {
  final String catId;
  final String catName;
  final catLimit;
  final catSpent;

  Category({
    required this.catId,
    required this.catName,
    required this.catLimit,
    required this.catSpent
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      catId: json['_id'] ?? json['id'],
      catName: json['name'],
      catLimit: (json['budgetLimit'] as num).toDouble(),
      catSpent: (json['budgetSpent'] as num).toDouble()
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _getCategories();
  }

  // Create new category
  Future<void> _newCategory(String name, budgetLimit) async{
    try {
      final token = await AuthStorage.getToken();
      final response = await http.post(
        Uri.parse('http://67.205.159.14:5000/api/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'budgetLimit': budgetLimit,
        })
      );

      print(response.body);

      if (response.statusCode == 201) {
        /*
        final responseData = jsonDecode(response.body);
        final verificationState = responseData['isVerified'];
        if (verificationState == 'False') {
        } else {
        }
        */
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category with that name already exists.')),
        );
      } else {
        Error();
      }
    } catch (e) {
      setState(() {
        // _errorMessage = 'Unexpected error occurred';
      });
    }
  }

  // Get categories
  Future<List<Category>> _getCategories() async{
    try {
      final token = await AuthStorage.getToken();
      final response = await http.get(
        Uri.parse('http://67.205.159.14:5000/api/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        List<Category> categories = [];
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final data = decoded['categories'] as List;

        /*
        setState(() {
          categories = data.map((item) => Category.fromJson(item)).toList();
        });
        */

        categories = data.map((item) => Category.fromJson(item)).toList();
        return categories;
      } else {
        Error();
        return[];
      }
    } catch (e) {
      print(e);
      print(FlutterError.demangleStackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error retrieving budget categories.')),
      );
      return[];
    }
  }

  // Delete category
  Future<void> _deleteCategory(String id) async{
    try {
      final token = await AuthStorage.getToken();
      final response = await http.delete(
          Uri.parse('http://67.205.159.14:5000/api/categories/$id'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          }
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        /*
        final responseData = jsonDecode(response.body);
        final verificationState = responseData['isVerified'];
        if (verificationState == 'False') {
        } else {
        }
        */
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Authentication error or category not found.')),
        );
      } else {
        Error();
      }
    } catch (e) {
      setState(() {
        // _errorMessage = 'Unexpected error occurred';
      });
    }
  }

  // Edit category
  Future<void> _editCategory(String id, String name, budgetLimit) async{
    try {
      final token = await AuthStorage.getToken();
      final response = await http.put(
          Uri.parse('http://67.205.159.14:5000/api/categories/$id'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode(<String, dynamic>{
            'name': name,
            'budgetLimit': budgetLimit,
          })
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        /*
        final responseData = jsonDecode(response.body);
        final verificationState = responseData['isVerified'];
        if (verificationState == 'False') {
        } else {
        }
        */
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Authentication error or category not found.')),
        );
      } else {
        Error();
      }
    } catch (e) {
      setState(() {
        // _errorMessage = 'Unexpected error occurred';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          }

          final retrievedCats = snapshot.data ?? [];

          final pieData = retrievedCats.map((category) {
            return {
              'category': category.catName,
              'value': category.catSpent,
            };
          }).toList();

          final monthlyBars = retrievedCats.expand((category) => [
            {
              'label': '${category.catName} - Total',
              'value': category.catLimit,
              'category' : category.catName,
              'section': 'Total',
            },
            /*
            {
              'label': '${category.catName} - Remaining',
              'value': (category.catLimit - category.catSpent).clamp(0, double.infinity),
              'category' : category.catName,
              'section': 'Remaining',
            },
             */
            {
              'label': '${category.catName} - Spent',
              'value': category.catSpent,
              'category' : category.catName,
              'section': 'Spent',
            },
          ]).toList();

          num totalBudget = 0;
          for(int i = 0; i < retrievedCats.length; i++) {
            totalBudget += retrievedCats[i].catLimit;
          }

          num moneySpent = 0;
          for(int i = 0; i < retrievedCats.length; i++) {
            moneySpent += retrievedCats[i].catSpent;
          }

          num leftover = (totalBudget - moneySpent).clamp(0, double.infinity);

        return Scaffold(
          backgroundColor: ddSky,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 100,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      child: Center(
                                        child: Text(
                                          "Amount spent: \$$moneySpent",
                                          style: TextStyle(
                                            fontFamily: "Fredoka",
                                            fontWeight: FontWeight.w600
                                          )
                                        )
                                      )
                                    )
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            child: Center(
                                              child: Text(
                                                "Total Budget: \$$totalBudget"
                                              )
                                            )
                                          )
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            child: Center(
                                              child: Text(
                                                "Remaining Budget: \$$leftover"
                                              )
                                            )
                                          )
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            child: const Center(
                                              child: const Text(
                                                "Transactions: "
                                              )
                                            )
                                          )
                                        ),
                                      ]
                                    )
                                  )
                                ],
                              )
                            ),
                            // Bar chart by category
                            Column(
                              children: [
                                const Text("Monthly Spending",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w700, fontSize: 19.0)
                                ),
                                SizedBox(
                                  height: 300,
                                  width: double.infinity,
                                  child: CristalyseChart()
                                    .data(monthlyBars)
                                    .mapping(x: 'category', y: 'value', color: 'section')
                                    .geomBar(
                                      borderRadius: BorderRadius.circular(4),
                                      roundOutwardEdges: true,
                                      borderWidth: 0,
                                      width: 0.3
                                    ).coordFlip() // Makes it horizontal
                                    .scaleXOrdinal()
                                    .scaleYContinuous(min: 0)
                                    .theme(ChartTheme.defaultTheme().copyWith(
                                      colorPalette: [
                                        pieBlue,
                                        pieYellow,
                                        piePink,
                                        pieGreen,
                                        pieOrange,
                                        piePurple,
                                        pieSalmon,
                                      ]
                                    )).build()
                                )
                              ]
                            ),
                            // Money spent vs remaining
                            Column(
                              children: [
                                const Text("Amount Left vs Spent",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w700, fontSize: 19.0)
                                ),
                                SizedBox(
                                  height: 300,
                                  width: double.infinity,
                                  child: CristalyseChart()
                                    .data([
                                      {'category': 'Amount Spent', 'value': moneySpent.toDouble()},
                                      {'category': 'Amount Left', 'value': (totalBudget - moneySpent).toDouble()}
                                    ]).mappingPie(value: 'value', category: 'category')
                                    .geomPie(
                                      outerRadius: 120.0,
                                      strokeWidth: 2.0,
                                      strokeColor: Colors.white,
                                      showLabels: true,
                                      showPercentages: true,
                                      startAngle: 0
                                    ).theme(
                                      ChartTheme.defaultTheme().copyWith(
                                        colorPalette: [
                                          spentColor,
                                          leftColor
                                        ]
                                      )
                                    ).animate(
                                      duration: Duration(milliseconds: 4200),
                                      curve: Curves.elasticOut,
                                    ).build(),
                                )
                              ]
                            ),
                            // Expenses by category pie
                            SizedBox(
                              height: 300,
                              width: double.infinity,
                              child: CristalyseChart()
                                .data(pieData).mappingPie(value: 'value', category: 'category')
                                .geomPie(
                                  outerRadius: 120.0,
                                  strokeWidth: 2.0,
                                  strokeColor: Colors.white,
                                  showLabels: true,
                                  showPercentages: true,
                                  startAngle: 0
                              ).theme(
                                ChartTheme.defaultTheme().copyWith(
                                  colorPalette: [
                                    pieBlue,
                                    pieYellow,
                                    piePink,
                                    pieGreen,
                                    pieOrange,
                                    piePurple,
                                    pieSalmon
                                  ]
                                )
                              ).animate(
                                duration: Duration(milliseconds: 4200),
                                curve: Curves.elasticOut,
                              ).build(),
                            ),
                            ElevatedButton(
                              child: const Text(
                                "Test"
                              ), onPressed: () async {
                                _newCategory('Test', 450);
                              },
                            ),
                            ElevatedButton(
                              child: const Text(
                                "Logout"
                              ), onPressed: () async {
                                await AuthStorage.deleteToken();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MyLandingPage(title: 'Ducky Dollars')),
                                );
                              }
                            ),
                          ]
                        )
                      )
                  )
                );
              }
            )
          )
        );
      }
    );
  }
}