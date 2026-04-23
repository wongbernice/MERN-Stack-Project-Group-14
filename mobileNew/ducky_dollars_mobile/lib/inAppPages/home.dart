import 'package:flutter/material.dart';
import 'package:ducky_dollars_mobile/main.dart';
import 'package:http/http.dart' as http;
import 'package:ducky_dollars_mobile/services/authStorage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

const darkSpentColor = Color(0xffff8a8a);
const darkLeftColor = Color(0xff79c98a);

const darkAddTransCatColor = Color(0xff8d3f59);

const darkPieBlue = Color(0xff5bb9dc);
const darkPieYellow = Color(0xffe5c627);
const darkPiePink = Color(0xffd891a8);
const darkPieGreen = Color(0xff79c98a);
const darkPieOrange = Color(0xffe8993a);
const darkPiePurple = Color(0xffad82c0);
const darkPieSalmon = Color(0xffff8a8a);

const darkHomeBackgroundColor = Color(0xff101820);
const darkChartStrokeColor = Color(0xff101820);
const darkActionTextColor = Colors.white;
const darkNavSelectedColor = Colors.white;
const darkNavUnselectedColor = Color(0xff77c6e6);
const darkPrimaryActionColor = Color(0xff58b8dd);
const apiBaseUrl = 'https://duckydollars.xyz/api';

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

class _HomeData {
  final List<Category> categories;
  final List<Transaction> transactions;

  _HomeData({
    required this.categories,
    required this.transactions,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<_HomeData> _homeDataFuture = Future.value(
    _HomeData(categories: const [], transactions: const []),
  );
  int currentPageIndex = 0;

  ThemeMode get _themeMode => appThemeModeNotifier.value;

  Future<void> _cycleThemeMode() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await setAppThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setAppThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        await setAppThemeMode(ThemeMode.light);
        break;
    }
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

  bool get _useDarkHomeColors {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
  }

  Color _themeColor(Color lightColor, Color darkColor) {
    return _useDarkHomeColors ? darkColor : lightColor;
  }

  Color get _spentColor => _themeColor(spentColor, darkSpentColor);
  Color get _leftColor => _themeColor(leftColor, darkLeftColor);
  Color get _addTransCatColor =>
      _themeColor(addTransCatColor, darkAddTransCatColor);
  Color get _pieBlue => _themeColor(pieBlue, darkPieBlue);
  Color get _pieYellow => _themeColor(pieYellow, darkPieYellow);
  Color get _piePink => _themeColor(piePink, darkPiePink);
  Color get _pieGreen => _themeColor(pieGreen, darkPieGreen);
  Color get _pieOrange => _themeColor(pieOrange, darkPieOrange);
  Color get _piePurple => _themeColor(piePurple, darkPiePurple);
  Color get _pieSalmon => _themeColor(pieSalmon, darkPieSalmon);
  Color get _homeBackgroundColor => _themeColor(ddSky, darkHomeBackgroundColor);
  Color get _chartStrokeColor =>
      _themeColor(Colors.white, darkChartStrokeColor);
  Color get _actionTextColor => _themeColor(Colors.black, darkActionTextColor);
  Color get _slidableActionTextColor => Colors.white;
  Color get _navSelectedColor =>
      _themeColor(Colors.black, darkNavSelectedColor);
  Color get _navUnselectedColor =>
      _themeColor(loginBlue, darkNavUnselectedColor);
  Color get _primaryActionColor =>
      _themeColor(loginBlue, darkPrimaryActionColor);

  List<Color> get _piePalette => [
        _pieBlue,
        _pieYellow,
        _piePink,
        _pieGreen,
        _pieOrange,
        _piePurple,
        _pieSalmon,
      ];

  @override
  void initState() {
    super.initState();
    _homeDataFuture = _loadHomeData();
  }

  Future<_HomeData> _loadHomeData() async {
    final categories = await _getCategories();
    final transactions = await _getTransactions();
    return _HomeData(categories: categories, transactions: transactions);
  }

  Future<void> _refreshHomeData() async {
    setState(() {
      _homeDataFuture = _loadHomeData();
    });
  }

  Future<void> _logout() async {
    await AuthStorage.deleteToken();
    await AuthStorage.deleteID();

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
        Uri.parse('$apiBaseUrl/categories'),
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
        await _refreshHomeData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category created successfully.')),
        );
      } else if (response.statusCode == 400) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Category with that name already exists.')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to create category. Code: ${response.statusCode}')),
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
      debugPrint(
          '[GET CATEGORIES] token exists: ${token != null && token.isNotEmpty}');
      debugPrint('[GET CATEGORIES] url: $apiBaseUrl/categories');
      final response = await http.get(
        Uri.parse('$apiBaseUrl/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint('[GET CATEGORIES] status: ${response.statusCode}');
      debugPrint('[GET CATEGORIES] body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['categories'] is List) {
          final data = decoded['categories'] as List;
          return data
              .map((item) => Category.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        debugPrint('[GET CATEGORIES] non-200 response received');
        return [];
      }
    } catch (e) {
      debugPrint('[GET CATEGORIES] exception: $e');
      if (!mounted) return [];
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error retrieving budget categories.')),
      );
      return [];
    }
  }

  // Edit category
  Future<void> _editCategory(String id, String name, double budgetLimit) async {
    try {
      final token = await AuthStorage.getToken();
      final response = await http.put(
        Uri.parse('$apiBaseUrl/categories/$id'),
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
        await _refreshHomeData();
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
          SnackBar(
              content: Text(
                  'Failed to edit category. Code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error editing category.')),
      );
    }
  }

  // Edit transaction
  Future<void> _editTransaction(String transactionId, String categoryId,
      double amount, String date, String note) async {
    try {
      final token = await AuthStorage.getToken();
      final response = await http.put(
        Uri.parse('$apiBaseUrl/transactions/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'categoryId': categoryId,
          'amount': amount,
          'date': date,
          'note': note
        }),
      );

      final decoded = json.decode(response.body);
      debugPrint(decoded['error']);
      if (response.statusCode == 200) {
        await _refreshHomeData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction updated successfully.')),
        );
      } else if (response.statusCode == 404) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Error: Authentication error or transaction not found.'),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to edit transaction. Code: ${response.statusCode}.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error editing transaction.')),
      );
    }
  }

  // Create new transaction
  Future<void> _newTransaction(
      String categoryId, double amount, String date, String note) async {
    try {
      final token = await AuthStorage.getToken();
      final userId = await AuthStorage.getID();
      final response = await http.post(
        Uri.parse('$apiBaseUrl/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'userId': userId,
          'categoryId': categoryId,
          'amount': amount,
          'date': date,
          'note': note
        }),
      );

      if (response.statusCode == 201) {
        await _refreshHomeData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction created successfully.')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to create category. Code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error creating category.')),
      );
    }
  }

  // Get transactions
  Future<List<Transaction>> _getTransactions() async {
    try {
      final token = await AuthStorage.getToken();
      final userId = await AuthStorage.getID();
      debugPrint(
          '[GET TRANSACTIONS] token exists: ${token != null && token.isNotEmpty}');
      debugPrint('[GET TRANSACTIONS] userId: $userId');
      debugPrint(
          '[GET TRANSACTIONS] url: $apiBaseUrl/transactions?userId=$userId');
      final response = await http.get(
        Uri.parse('$apiBaseUrl/transactions?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint('[GET TRANSACTIONS] status: ${response.statusCode}');
      debugPrint('[GET TRANSACTIONS] body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> &&
            decoded['transactions'] is List) {
          final data = decoded['transactions'] as List;
          return data
              .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        debugPrint('[GET TRANSACTIONS] non-200 response received');
        return [];
      }
    } catch (e) {
      debugPrint('[GET TRANSACTIONS] exception: $e');
      if (!mounted) return [];
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error retrieving transactions list.')),
      );
      return [];
    }
  }

  Future<bool> _deleteTransaction(String id, {bool showFeedback = true}) async {
    try {
      final token = await AuthStorage.getToken();
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/transactions/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await _refreshHomeData();
        if (showFeedback && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction deleted successfully.')),
          );
        }
        return true;
      }

      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to delete transaction. Code: ${response.statusCode}')),
        );
      }
      return false;
    } catch (e) {
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unexpected error deleting transaction.')),
        );
      }
      return false;
    }
  }

  Future<void> _deleteCategory(String id) async {
    try {
      final token = await AuthStorage.getToken();

      // 1) Load current transactions and find those in this category
      final allTransactions = await _getTransactions();
      final matching = allTransactions.where((t) => t.catId == id).toList();

      // 2) Delete matching transactions first
      for (final t in matching) {
        final ok = await _deleteTransaction(t.transId, showFeedback: false);
        if (!ok) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Could not delete all linked transactions.')),
          );
          return; // stop so we don't delete category with partial transaction cleanup
        }
      }

      // 3) Delete category
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/categories/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await _refreshHomeData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Category and linked transactions deleted successfully.')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to delete category. Code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error deleting category.')),
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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
                                content: Text(
                                    'Enter a valid name and budget limit.'),
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

  void _showEditThingDialog(
      BuildContext context, id, currentName, currentBudget) {
    final TextEditingController nameController =
        TextEditingController(text: currentName);
    final TextEditingController budgetController =
        TextEditingController(text: currentBudget.toStringAsFixed(2));

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
                          'Edit Category',
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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
                                content: Text(
                                    'Enter a valid name and budget limit.'),
                              ),
                            );
                            return;
                          }

                          await _editCategory(id, name, budgetLimit);

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

  void _showAddTransactionDialog(
      BuildContext context, List<Category> categories) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    String? selectedCategoryId;
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
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
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
                      onSelected: (selectedCategory) {
                        setDialogState(() {
                          selectedCategoryId = selectedCategory?.catId;
                        });
                      },
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
                            final amount = double.tryParse(amountText);
                            final selectedDate =
                                _formatDate(selectedTransactionDate);

                            if (note.isEmpty ||
                                amount == null ||
                                selectedCategoryId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Enter category, amount, date, and note.'),
                                ),
                              );
                              return;
                            }

                            await _newTransaction(
                              selectedCategoryId!,
                              amount,
                              selectedDate,
                              note,
                            );

                            if (!mounted) return;
                            await _refreshHomeData();
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

  void _showEditTransactionDialog(
      BuildContext context,
      List<Category> categories,
      transId,
      newCategory,
      newAmount,
      newDate,
      newName) {
    final TextEditingController amountController =
        TextEditingController(text: newAmount.toStringAsFixed(2));
    final TextEditingController dateController =
        TextEditingController(text: newDate);
    final TextEditingController noteController =
        TextEditingController(text: newName);
    final TextEditingController categoryController = TextEditingController();
    String? selectedCategoryId = newCategory;
    DateTime selectedTransactionDate =
        DateTime.tryParse(newDate.toString()) ?? DateTime.now();
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
                            'Edit Transaction',
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
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
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
                      onSelected: (selectedCategory) {
                        setDialogState(() {
                          selectedCategoryId = selectedCategory?.catId;
                        });
                      },
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
                            final amount = double.tryParse(amountText);
                            final selectedDate =
                                _formatDate(selectedTransactionDate);

                            if (note.isEmpty ||
                                amount == null ||
                                selectedCategoryId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Enter category, amount, date, and note.'),
                                ),
                              );
                              return;
                            }

                            await _editTransaction(transId, selectedCategoryId!,
                                amount, selectedDate, note);

                            if (!mounted) return;
                            await _refreshHomeData();
                            Navigator.pop(dialogContext);
                          },
                          child: const Text('Save'),
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
    return '$year-$month-$day';
  }

  Widget _buildSummarySection(double totalBudget, double moneySpent,
      double leftover, int transactions) {
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
                      fontSize: 15),
                ),
                Text(
                  "\$${moneySpent.toStringAsFixed(2)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: "Fredoka",
                      fontWeight: FontWeight.w600,
                      fontSize: 30),
                ),
              ],
            )),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                        "Total Budget: \$${totalBudget.toStringAsFixed(2)}"),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                        "Remaining Budget: \$${leftover.toStringAsFixed(2)}"),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text("Transactions: $transactions"),
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
                  colorPalette: _piePalette,
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
                strokeColor: _chartStrokeColor,
                showLabels: true,
                showPercentages: true,
                startAngle: 0,
              )
              .theme(
                ChartTheme.defaultTheme().copyWith(
                  colorPalette: [
                    _spentColor,
                    _leftColor,
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
    return Column(children: [
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
              strokeColor: _chartStrokeColor,
              showLabels: true,
              showPercentages: true,
              startAngle: 0,
            )
            .theme(
              ChartTheme.defaultTheme().copyWith(
                colorPalette: _piePalette,
              ),
            )
            .animate(
              duration: const Duration(milliseconds: 4200),
              curve: Curves.elasticOut,
            )
            .build(),
      )
    ]);
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

    return SlidableAutoCloseBehavior(
      child: Column(
        children: categories.map((category) {
          return Slidable(
            key: ValueKey(category.catId),
            startActionPane: ActionPane(
              extentRatio: 0.25,
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => _deleteCategory(category.catId),
                  backgroundColor: _spentColor,
                  foregroundColor: _slidableActionTextColor,
                  icon: Icons.delete_outline,
                  label: 'Delete',
                ),
              ],
            ),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              dismissible: DismissiblePane(
                confirmDismiss: () async {
                  _showEditThingDialog(
                    context,
                    category.catId,
                    category.catName,
                    category.catLimit,
                  ); // opens popup
                  return false; // prevents item from being dismissed
                },
                closeOnCancel: true, // auto-slide back after returning false
                onDismissed: () {},
              ),
              children: [
                SlidableAction(
                  onPressed: (_) => _showEditThingDialog(
                    context,
                    category.catId,
                    category.catName,
                    category.catLimit,
                  ),
                  backgroundColor: _pieBlue,
                  foregroundColor: _slidableActionTextColor,
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                ),
              ],
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(category.catName),
                subtitle: Text(
                  'Limit: \$${category.catLimit.toStringAsFixed(2)} | Spent: \$${category.catSpent.toStringAsFixed(2)}',
                ),
                // remove trailing Wrap(...) icon buttons
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _categoryNameForTransaction(
      String categoryId, List<Category> categories) {
    for (final category in categories) {
      if (category.catId == categoryId) {
        return category.catName;
      }
    }
    return 'Unknown';
  }

  String _formatDateForDisplay(dynamic rawDate) {
    if (rawDate == null) return '';
    final asString = rawDate.toString();
    if (asString.contains('T')) {
      return asString.split('T').first;
    }
    return asString;
  }

  Widget _buildTransactionList(
      List<Transaction> transactions, List<Category> categories) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('No transactions yet.'),
        ),
      );
    }

    return SlidableAutoCloseBehavior(
      child: Column(
        children: transactions.map((transaction) {
          return Slidable(
            key: ValueKey(transaction.transId),
            startActionPane: ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) => _deleteTransaction(transaction.transId),
                  backgroundColor: _spentColor,
                  foregroundColor: _slidableActionTextColor,
                  icon: Icons.delete_outlined,
                  label: 'Delete',
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              dismissible: DismissiblePane(
                confirmDismiss: () async {
                  _showEditTransactionDialog(
                    context,
                    categories,
                    transaction.transId,
                    transaction.catId,
                    transaction.transAmount,
                    transaction.transDate,
                    transaction.transNote,
                  ); // opens popup
                  return false; // prevents item from being dismissed
                },
                closeOnCancel: true, // auto-slide back after returning false
                onDismissed: () {},
              ),
              children: [
                SlidableAction(
                  onPressed: (_) => _showEditTransactionDialog(
                    context,
                    categories,
                    transaction.transId,
                    transaction.catId,
                    transaction.transAmount,
                    transaction.transDate,
                    transaction.transNote,
                  ),
                  backgroundColor: _pieBlue,
                  foregroundColor: _slidableActionTextColor,
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(transaction.transNote),
                subtitle: Text(
                  'Date: ${_formatDateForDisplay(transaction.transDate)} | Category: ${_categoryNameForTransaction(transaction.catId, categories)}',
                ),
                trailing: SizedBox(
                  width: 96,
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '\$${transaction.transAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                // remove trailing Wrap(...) icon buttons
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHomeTab(
      List<Category> retrievedCats, List<Transaction> transactions) {
    final pieData = retrievedCats.map((category) {
      return {
        'category': category.catName,
        'value': category.catSpent,
      };
    }).toList();

    final monthlyBars = retrievedCats
        .expand((category) => [
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
            ])
        .toList();

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

    final int totalTransactions = transactions.length;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: _refreshHomeData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    _buildSummarySection(
                        totalBudget, moneySpent, leftover, totalTransactions),
                    _buildMonthlyBarChart(monthlyBars),
                    _buildCategoryPieChart(pieData),
                    _buildSpentVsLeftChart(moneySpent, totalBudget),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              _showAddTransactionDialog(context, retrievedCats),
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(170, 40),
                              backgroundColor: _primaryActionColor,
                              foregroundColor: _actionTextColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          child: const Text("Add Transaction"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => _showAddThingDialog(context),
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(170, 40),
                              backgroundColor: _addTransCatColor,
                              foregroundColor: _actionTextColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
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

  Widget _buildTransactionsTab(
      List<Transaction> transactions, List<Category> categories) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshHomeData,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Fredoka',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        _showAddTransactionDialog(context, categories),
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(160, 40),
                        backgroundColor: _primaryActionColor,
                        foregroundColor: _actionTextColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: const Text('Add Transaction'),
                  ),
                ],
              ),
            ),
            _buildTransactionList(transactions, categories),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(List<Category> retrievedCats) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshHomeData,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Fredoka',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showAddThingDialog(context),
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(150, 40),
                        backgroundColor: _addTransCatColor,
                        foregroundColor: _actionTextColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: const Text('Add Category'),
                  ),
                ],
              ),
            ),
            _buildCategoryList(retrievedCats),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(_themeIcon),
              title: const Text('Theme'),
              subtitle: Text(_themeLabel),
              trailing: const Icon(Icons.chevron_right),
              onTap: _cycleThemeMode,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              await _logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeModeNotifier,
      builder: (context, _, __) {
        return FutureBuilder<_HomeData>(
          future: _homeDataFuture,
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

            final homeData = snapshot.data ??
                _HomeData(categories: const [], transactions: const []);
            final retrievedCats = homeData.categories;
            final transactions = homeData.transactions;

            if (currentPageIndex < 0 || currentPageIndex > 3) {
              currentPageIndex = 0;
            }
            final pages = [
              _buildHomeTab(retrievedCats, transactions),
              _buildTransactionsTab(transactions, retrievedCats),
              _buildCategoriesTab(retrievedCats),
              _buildSettingsTab()
            ];

            return Scaffold(
              backgroundColor: _homeBackgroundColor,
              bottomNavigationBar: NavigationBarTheme(
                data: NavigationBarThemeData(
                  iconTheme:
                      WidgetStateProperty.resolveWith<IconThemeData>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return IconThemeData(color: _navSelectedColor);
                    }
                    return IconThemeData(color: _navUnselectedColor);
                  }),

                  labelTextStyle:
                      WidgetStateProperty.resolveWith<TextStyle>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return TextStyle(color: _navSelectedColor);
                    }
                    return TextStyle(color: _navUnselectedColor);
                  }),

                  indicatorColor: Colors
                      .transparent, // removes the default highlight bubble
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
      },
    );
  }
}
