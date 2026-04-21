/*
import 'package:flutter/material.dart';
import 'package:ducky_dollars/main.dart';
import 'package:http/http.dart' as http;
import 'package:ducky_dollars/services/authStorage.dart';
import 'package:cristalyse/cristalyse.dart';
import 'package:decimal/decimal.dart';
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

class Transaction {
  final String transId;
  final String catId;
  final transAmount;
  final transDate;
  final String transNote;

  Transaction({
    required this.transId,
    required this.catId,
    required this.transAmount,
    required this.transDate,
    required this.transNote
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transId: json['_id'] ?? json['id'],
      catId: json['categoryId'],
      transAmount: (json['amount'] as num).toDouble(),
      transDate: json['date'],
      transNote: json['note'],
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
  int currentPageIndex = 0;

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

  void _showAddThingDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Add Item',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter something',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final text = controller.text.trim();

                          if (text.isEmpty) return;

                          // Do API call here
                          // await myApiCall(text);

                          Navigator.pop(context);
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              indicatorColor: ddBarYellow,
              selectedIndex: currentPageIndex,
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(Icons.home_rounded),
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.paid_rounded),
                  icon: Icon(Icons.paid_outlined),
                  label: 'Transactions',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.folder_rounded),
                  icon: Icon(Icons.folder_outlined),
                  label: 'Categories',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.logout_rounded),
                  icon: Icon(Icons.logout_outlined),
                  label: 'Logout',
                ),
              ],
            ),
          body: <Widget>[
            SafeArea(
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
                                                                "Amount spent:\n\$$moneySpent",
                                                                textAlign: TextAlign.center,
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
                                                                      child: Text(
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
                                          // _newCategory('Test', 450);
                                          _showAddThingDialog(context);
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
            ),
          ][currentPageIndex],
        );
      }
    );
  }
}
 */

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
  final double catLimit;
  final double catSpent;

  Category({
    required this.catId,
    required this.catName,
    required this.catLimit,
    required this.catSpent,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      catId: json['_id'] ?? json['id'],
      catName: json['name'],
      catLimit: (json['budgetLimit'] as num).toDouble(),
      catSpent: (json['budgetSpent'] as num).toDouble(),
    );
  }
}

class Transaction {
  final String transId;
  final String catId;
  final double transAmount;
  final dynamic transDate;
  final String transNote;

  Transaction({
    required this.transId,
    required this.catId,
    required this.transAmount,
    required this.transDate,
    required this.transNote,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transId: json['_id'] ?? json['id'],
      catId: json['categoryId'],
      transAmount: (json['amount'] as num).toDouble(),
      transDate: json['date'],
      transNote: json['note'],
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
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _getCategories();
  }

  Future<void> _refreshCategories() async {
    setState(() {
      _categoriesFuture = _getCategories();
    });
  }

  Future<void> _logout() async {
    await AuthStorage.deleteToken();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MyLandingPage(title: 'Ducky Dollars'),
      ),
          (route) => false,
    );
  }

  // Create new category
  Future<void> _newCategory(String name, double budgetLimit) async {
    try {
      final token = await AuthStorage.getToken();
      final response = await http.post(
        Uri.parse('http://67.205.159.14:5000/api/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'budgetLimit': budgetLimit,
        }),
      );

      if (response.statusCode == 201) {
        await _refreshCategories();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category created successfully.')),
        );
      } else if (response.statusCode == 400) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category with that name already exists.')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create category. Code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error creating category.')),
      );
    }
  }

  // Get categories
  Future<List<Category>> _getCategories() async {
    try {
      final token = await AuthStorage.getToken();
      final response = await http.get(
        Uri.parse('http://67.205.159.14:5000/api/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final data = decoded['categories'] as List;
        return data.map((item) => Category.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      if (!mounted) return [];
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error retrieving budget categories.')),
      );
      return [];
    }
  }

  // Delete category
  Future<void> _deleteCategory(String id) async {
    try {
      final token = await AuthStorage.getToken();
      final response = await http.delete(
        Uri.parse('http://67.205.159.14:5000/api/categories/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await _refreshCategories();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted successfully.')),
        );
      } else if (response.statusCode == 404) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Authentication error or category not found.'),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete category. Code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error deleting category.')),
      );
    }
  }

  // Edit category
  Future<void> _editCategory(String id, String name, double budgetLimit) async {
    try {
      final token = await AuthStorage.getToken();
      final response = await http.put(
        Uri.parse('http://67.205.159.14:5000/api/categories/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'budgetLimit': budgetLimit,
        }),
      );

      if (response.statusCode == 200) {
        await _refreshCategories();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully.')),
        );
      } else if (response.statusCode == 404) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Authentication error or category not found.'),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to edit category. Code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error editing category.')),
      );
    }
  }

  void _showAddThingDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController budgetController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Add Category',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: budgetController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Budget limit',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final budgetText = budgetController.text.trim();
                          final budgetLimit = double.tryParse(budgetText);

                          if (name.isEmpty || budgetLimit == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter a valid name and budget limit.'),
                              ),
                            );
                            return;
                          }

                          await _newCategory(name, budgetLimit);

                          if (!mounted) return;
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummarySection(
      double totalBudget,
      double moneySpent,
      double leftover,
      ) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "Amount spent:\n\$$moneySpent",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "Fredoka",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text("Total Budget: \$$totalBudget"),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text("Remaining Budget: \$$leftover"),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text("Transactions: "),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBarChart(List<Map<String, dynamic>> monthlyBars) {
    return Column(
      children: [
        const Text(
          "Monthly Spending",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontWeight: FontWeight.w700,
            fontSize: 19.0,
          ),
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
            width: 0.3,
          )
              .coordFlip()
              .scaleXOrdinal()
              .scaleYContinuous(min: 0)
              .theme(
            ChartTheme.defaultTheme().copyWith(
              colorPalette: [
                pieBlue,
                pieYellow,
                piePink,
                pieGreen,
                pieOrange,
                piePurple,
                pieSalmon,
              ],
            ),
          )
              .build(),
        ),
      ],
    );
  }

  Widget _buildSpentVsLeftChart(double moneySpent, double totalBudget) {
    return Column(
      children: [
        const Text(
          "Amount Left vs Spent",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontWeight: FontWeight.w700,
            fontSize: 19.0,
          ),
        ),
        SizedBox(
          height: 300,
          width: double.infinity,
          child: CristalyseChart()
              .data([
            {'category': 'Amount Spent', 'value': moneySpent},
            {
              'category': 'Amount Left',
              'value': (totalBudget - moneySpent).clamp(0, double.infinity),
            },
          ])
              .mappingPie(value: 'value', category: 'category')
              .geomPie(
            outerRadius: 120.0,
            strokeWidth: 2.0,
            strokeColor: Colors.white,
            showLabels: true,
            showPercentages: true,
            startAngle: 0,
          )
              .theme(
            ChartTheme.defaultTheme().copyWith(
              colorPalette: [
                spentColor,
                leftColor,
              ],
            ),
          )
              .animate(
            duration: const Duration(milliseconds: 4200),
            curve: Curves.elasticOut,
          )
              .build(),
        ),
      ],
    );
  }

  Widget _buildCategoryPieChart(List<Map<String, dynamic>> pieData) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: CristalyseChart()
          .data(pieData)
          .mappingPie(value: 'value', category: 'category')
          .geomPie(
        outerRadius: 120.0,
        strokeWidth: 2.0,
        strokeColor: Colors.white,
        showLabels: true,
        showPercentages: true,
        startAngle: 0,
      )
          .theme(
        ChartTheme.defaultTheme().copyWith(
          colorPalette: [
            pieBlue,
            pieYellow,
            piePink,
            pieGreen,
            pieOrange,
            piePurple,
            pieSalmon,
          ],
        ),
      )
          .animate(
        duration: const Duration(milliseconds: 4200),
        curve: Curves.elasticOut,
      )
          .build(),
    );
  }

  Widget _buildCategoryList(List<Category> categories) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('No categories yet.'),
        ),
      );
    }

    return Column(
      children: categories.map((category) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(category.catName),
            subtitle: Text(
              'Limit: \$${category.catLimit} | Spent: \$${category.catSpent}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteCategory(category.catId),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHomeTab(List<Category> retrievedCats) {
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
        'category': category.catName,
        'section': 'Total',
      },
      {
        'label': '${category.catName} - Spent',
        'value': category.catSpent,
        'category': category.catName,
        'section': 'Spent',
      },
    ]).toList();

    double totalBudget = 0;
    for (final category in retrievedCats) {
      totalBudget += category.catLimit;
    }

    double moneySpent = 0;
    for (final category in retrievedCats) {
      moneySpent += category.catSpent;
    }

    final double leftover =
    (totalBudget - moneySpent).clamp(0, double.infinity).toDouble();

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: _refreshCategories,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    _buildSummarySection(totalBudget, moneySpent, leftover),
                    _buildMonthlyBarChart(monthlyBars),
                    _buildSpentVsLeftChart(moneySpent, totalBudget),
                    _buildCategoryPieChart(pieData),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _showAddThingDialog(context),
                      child: const Text("Add Category"),
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(170, 40),
                        backgroundColor: loginBlue,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        )
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return const SafeArea(
      child: Center(
        child: Text(
          'Transactions page',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(List<Category> retrievedCats) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshCategories,
        child: ListView(
          children: [
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Fredoka',
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryList(retrievedCats),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => _showAddThingDialog(context),
                child: const Text('Add Category'),
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(170, 40),
                    backgroundColor: loginBlue,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    )
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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

        if (currentPageIndex < 0 || currentPageIndex > 2) {
          currentPageIndex = 0;
        }
        final pages = [
          _buildHomeTab(retrievedCats),
          _buildTransactionsTab(),
          _buildCategoriesTab(retrievedCats),
        ];

        return Scaffold(
          backgroundColor: ddSky,
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentPageIndex,
            indicatorColor: ddBarBlue,
            onDestinationSelected: (int index) async {
              if (index == 3) {
                // Keep the selected tab on the current real page
                await _logout();
                return;
              }

              setState(() {
                currentPageIndex = index;
              });
            },
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.home_rounded),
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.paid_rounded),
                icon: Icon(Icons.paid_outlined),
                label: 'Transactions',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.folder_rounded),
                icon: Icon(Icons.folder_outlined),
                label: 'Categories',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.logout_rounded),
                icon: Icon(Icons.logout_outlined),
                label: 'Logout',
              ),
            ],
          ),
          body: pages[currentPageIndex],
        );
      },
    );
  }
}