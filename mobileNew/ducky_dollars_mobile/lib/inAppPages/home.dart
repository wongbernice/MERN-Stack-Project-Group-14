import 'package:flutter/material.dart';
import 'package:ducky_dollars_mobile/main.dart';
import 'package:http/http.dart' as http;
import 'package:ducky_dollars_mobile/services/authStorage.dart';
import 'package:cristalyse/cristalyse.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

const spentColor = Color(0xffff6b6b);
const leftColor = Color(0xff98d8a3);

const addTransCatColor = Color(0xfff0becd);

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
  ThemeMode _themeMode = ThemeMode.system;

  late Future<List<Category>> _categoriesFuture;
  int currentPageIndex = 0;

  void _cycleThemeMode() {
    setState(() {
      switch (_themeMode) {
        case ThemeMode.light:
          _themeMode = ThemeMode.dark;
          break;
        case ThemeMode.dark:
          _themeMode = ThemeMode.system;
          break;
        case ThemeMode.system:
          _themeMode = ThemeMode.light;
          break;
      }
    });
  }

  String get _themeLabel {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  IconData get _themeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.settings_brightness_outlined;
    }
  }

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
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
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

  void _showAddTransactionDialog(BuildContext context, List<Category> categories) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    DateTime selectedTransactionDate = DateTime.now();
    dateController.text = _formatDate(selectedTransactionDate);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
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
                          'Add Transaction',
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
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownMenu<Category>(
                    controller: categoryController,
                    // The default requestFocusOnTap value depends on the platform.
                    // On mobile, it defaults to false, and on desktop, it defaults to true.
                    // Setting this to true will trigger a focus request on the text field, and
                    // the virtual keyboard will appear afterward.
                    requestFocusOnTap: true,
                    label: const Text('Category'),
                    dropdownMenuEntries: categories.map((category) {
                      return DropdownMenuEntry<Category>(
                        value: category,
                        label: category.catName,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    onTap: () async {
                      final now = DateTime.now();
                      final pickedDate = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedTransactionDate.isAfter(now)
                            ? now
                            : selectedTransactionDate,
                        firstDate: DateTime(1992, 1, 1),
                        lastDate: now,
                        builder: (pickerContext, child) {
                          return child!;
                        },
                      );

                      if (pickedDate != null) {
                        setDialogState(() {
                          selectedTransactionDate = pickedDate;
                          dateController.text = _formatDate(pickedDate);
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Transaction Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note',
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
                          final note = noteController.text.trim();
                          final amountText = amountController.text.trim();

                          if (note.isEmpty || amountText == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter a valid name and budget limit.'),
                              ),
                            );
                            return;
                          }

                          await _newCategory(note, amountText as double);

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
        ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month-$day-$year';
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Amount spent:",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: "Fredoka",
                      fontWeight: FontWeight.w600,
                      fontSize: 15
                    ),
                  ),
                  Text(
                    "\$$moneySpent",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: "Fredoka",
                      fontWeight: FontWeight.w600,
                      fontSize: 30
                    ),
                  ),
                ],
              )
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text("Total Budget: \$${totalBudget.toStringAsFixed(2)}"),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text("Remaining Budget: \$${leftover.toStringAsFixed(2)}"),
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
    return Column(
        children: [
      const Text(
      "Expenses by Category",
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
    )
        ]
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
              'Limit: \$${category.catLimit.toStringAsFixed(2)} | Spent: \$${category.catSpent.toStringAsFixed(2)}',
            ),
            trailing: Wrap(
              spacing: 12, // space between two icons
              children: <Widget>[
                IconButton(
                    onPressed: () => print("Edit clicked"),//_deleteCategory(category.catId),
                    icon: const Icon(Icons.edit_outlined)
                ),
                IconButton(
                    onPressed: () => _deleteCategory(category.catId),
                    icon: const Icon(Icons.delete_outlined)
                ),
              ],
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
                    _buildCategoryPieChart(pieData),
                    _buildSpentVsLeftChart(moneySpent, totalBudget),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _showAddTransactionDialog(context, retrievedCats),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(170, 40),
                            backgroundColor: loginBlue,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                            )
                          ),
                        child: const Text("Add Transaction"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => _showAddThingDialog(context),
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(170, 40),
                              backgroundColor: addTransCatColor,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)
                              )
                          ),
                          child: const Text("Add Category"),
                        ),
                      ],
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
          'No Transactions',
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
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(170, 40),
                    backgroundColor: addTransCatColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    )
                ),
                child: const Text('Add Category'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            const Text ("Working!"),
            ElevatedButton(
              onPressed: () async {
                await _logout();
              }, child: const Text ("Logout")
            )
          ],
        )
      )
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

        if (currentPageIndex < 0 || currentPageIndex > 3) {
          currentPageIndex = 0;
        }
        final pages = [
          _buildHomeTab(retrievedCats),
          _buildTransactionsTab(),
          _buildCategoriesTab(retrievedCats),
          _buildSettingsTab()
        ];

        return Scaffold(
          backgroundColor: ddSky,
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(

              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: Colors.black);
                }
                return const IconThemeData(color: loginBlue);
              }),

              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(color: Colors.black);
                }
                return const TextStyle(color: loginBlue);
              }),

              indicatorColor: Colors.transparent, // removes the default highlight bubble
            ),
            child: NavigationBar(
              selectedIndex: currentPageIndex,
              onDestinationSelected: (int index) async {
                setState(() {
                  currentPageIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.paid_outlined),
                  selectedIcon: Icon(Icons.paid_rounded),
                  label: 'Transactions',
                ),
                NavigationDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder_rounded),
                  label: 'Categories',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          ),
          body: pages[currentPageIndex],
        );
      },
    );
  }
}
