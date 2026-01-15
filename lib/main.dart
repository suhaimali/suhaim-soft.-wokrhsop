// --- START OF FILE Paste January 16, 2026 - 8:30AM ---

// ignore_for_file: curly_braces_in_flow_control_structures, prefer_final_fields, use_build_context_synchronously, deprecated_member_use, prefer_const_constructors, duplicate_ignore

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';

// ==========================================
// 1️⃣ MAIN ENTRY POINT
// ==========================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await DatabaseHelper.instance.database;
  runApp(const WorkshopProApp());
}

// ==========================================
// 2️⃣ THEME & CONFIGURATION
// ==========================================
class AppColors {
  static const primary = Color(0xFF1565C0);
  static const secondary = Color(0xFFFFAB00);
  static const background = Color(0xFFF3F6F9);
  static const darkSidebar = Color(0xFF1A237E);
  static const success = Color(0xFF2E7D32);
  static const danger = Color(0xFFC62828);
  
  static const Gradient loginGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)], 
    begin: Alignment.topLeft, 
    end: Alignment.bottomRight
  );
  
  static const Gradient sidebarGradient = LinearGradient(
    colors: [Color(0xFF283593), Color(0xFF1A237E)], 
    begin: Alignment.topCenter, 
    end: Alignment.bottomCenter
  );
  
  static const Gradient statusBarGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)], 
    begin: Alignment.centerLeft, 
    end: Alignment.centerRight
  );

  // Card Gradients
  static const Gradient blueCard = LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const Gradient orangeCard = LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFF57C00)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const Gradient greenCard = LinearGradient(colors: [Color(0xFF66BB6A), Color(0xFF388E3C)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const Gradient redCard = LinearGradient(colors: [Color(0xFFEF5350), Color(0xFFD32F2F)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const Gradient purpleCard = LinearGradient(colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const Gradient tealCard = LinearGradient(colors: [Color(0xFF26A69A), Color(0xFF00796B)], begin: Alignment.topLeft, end: Alignment.bottomRight);
}

class WorkshopProApp extends StatelessWidget {
  const WorkshopProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuhaimSoft ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
          secondary: AppColors.secondary,
          surface: AppColors.background,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 6,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          elevation: 8,
        ),
        cardColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: const TextStyle(color: Colors.grey),
          floatingLabelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: AppColors.darkSidebar, fontSize: 22, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: AppColors.darkSidebar),
        )
      ),
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// 3️⃣ DATABASE HELPER (v9)
// ==========================================
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('suhaimsoft_erp_final_v9.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = p.join(dbPath.path, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const numType = 'REAL';
    const intType = 'INTEGER';

    await db.execute('CREATE TABLE customers (id $idType, name $textType, phone $textType, car_model $textType, number_plate $textType)');
    await db.execute('CREATE TABLE stock (id $idType, item_code $textType, name $textType, quantity $intType, unit_price $numType, tax_percent $numType)');
    await db.execute('CREATE TABLE bills (id $idType, customer_name $textType, customer_phone $textType, car_model $textType, number_plate $textType, grand_total $numType, paid_amount $numType, due_amount $numType, date $textType, service_type $textType, next_service_date $textType, worker_name $textType, payment_mode $textType, notes $textType, status $textType, worker_status $textType)');
    await db.execute('CREATE TABLE bill_items (id $idType, bill_id $intType, item_name $textType, quantity $intType, unit_price $numType, total $numType)');
    await db.execute('CREATE TABLE employees (id $idType, name $textType, role $textType, salary $numType, status $textType)');
    await db.execute('CREATE TABLE salary_payments (id $idType, emp_name $textType, amount $numType, date $textType, notes $textType)');
    await db.execute('CREATE TABLE expenses (id $idType, title $textType, person_name $textType, description $textType, amount $numType, date $textType)');
    await db.execute('CREATE TABLE warranties (id $idType, customer_name $textType, item_name $textType, expiry_date $textType)');
    await db.execute('CREATE TABLE manufacturing (id $idType, product_name $textType, quantity_made $intType, notes $textType, date $textType)');
    // Removed Todos table
  }

  Future<void> backupDatabase() async {
    try {
      final dbPath = await getApplicationDocumentsDirectory();
      final srcPath = p.join(dbPath.path, 'suhaimsoft_erp_final_v9.db');
      final File srcFile = File(srcPath);
      if (!await srcFile.exists()) return;
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        final String destPath = p.join(selectedDirectory, 'backup_erp_final_v9.db');
        await srcFile.copy(destPath);
      }
    } catch (e) { debugPrint("Backup Error: $e"); }
  }

  Future<void> restoreDatabase() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        File source = File(result.files.single.path!);
        final dbPath = await getApplicationDocumentsDirectory();
        final String destPath = p.join(dbPath.path, 'suhaimsoft_erp_final_v9.db');
        if (_database != null && _database!.isOpen) await _database!.close();
        _database = null; 
        await source.copy(destPath);
      }
    } catch (e) { debugPrint("Restore Error: $e"); }
  }
}

// ==========================================
// 4️⃣ SPLASH SCREEN
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.loginGradient),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings_suggest, size: 120, color: Colors.white),
              SizedBox(height: 20),
              Text("SUHAIMSOFT ERP", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 3, shadows: [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(2,2))])),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.amber),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5️⃣ DASHBOARD & NAVIGATION
// ==========================================

Widget _buildEmptyState(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 15),
        Text(message, style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});
  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  int _idx = 0;
  final List<Widget> _pages = [
    const DashboardHome(), 
    const CreateBillPage(), 
    const BillHistoryPage(), 
    const StockPage(), 
    const MakingItemPage(), 
    const CustomersPage(), 
    const PayrollPage(), 
    const WarrantiesPage(), 
    const ExpensesPage(), 
    const SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 280,
            decoration: const BoxDecoration(
              gradient: AppColors.sidebarGradient,
              boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(4, 0))]
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(50)),
                  child: const Icon(Icons.settings_suggest, size: 50, color: AppColors.secondary),
                ),
                const SizedBox(height: 15),
                const Text("SUHAIMSOFT", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const Divider(color: Colors.white24, height: 40, indent: 20, endIndent: 20),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: [
                      _menuItem(0, Icons.dashboard, "Dashboard"),
                      _menuItem(1, Icons.post_add, "Create Bill"),
                      _menuItem(2, Icons.history, "Bill History"),
                      _menuItem(3, Icons.inventory_2, "Stock"),
                      _menuItem(4, Icons.precision_manufacturing, "Manufacturing"),
                      _menuItem(5, Icons.people, "Customers"),
                      _menuItem(6, Icons.payments, "Payroll"),
                      _menuItem(7, Icons.verified_user, "Warranties"),
                      _menuItem(8, Icons.money_off, "Expenses"),
                      _menuItem(9, Icons.settings_backup_restore, "Settings"),
                      const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.redAccent),
                        title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                // CUSTOM STATUS BAR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  decoration: const BoxDecoration(
                    gradient: AppColors.statusBarGradient,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_getTitle(_idx), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      StreamBuilder(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (context, snapshot) {
                          return Text("SuhaimSoft ERP | ${DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now())}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                        }
                      )
                    ],
                  ),
                ),
                Expanded(child: Padding(padding: const EdgeInsets.all(25), child: _pages[_idx])),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _getTitle(int i) => ["Dashboard", "Create Invoice", "Bill History", "Stock", "Manufacturing", "Customers", "Payroll", "Warranties", "Expenses", "Settings"][i];

  Widget _menuItem(int i, IconData icon, String title) {
    bool active = _idx == i;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: active ? BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0,2))]) : null,
      child: ListTile(
        leading: Icon(icon, color: active ? AppColors.primary : Colors.white70),
        title: Text(title, style: TextStyle(color: active ? AppColors.primary : Colors.white70, fontWeight: FontWeight.bold)),
        onTap: () => setState(() => _idx = i),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}

// ==========================================
// 6️⃣ DASHBOARD HOME
// ==========================================
class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});
  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  Map<String, dynamic> stats = {"sales": 0.0, "bills": 0, "stock": 0, "exp": 0.0, "cash": 0.0, "online": 0.0};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) => _loadStats());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final bills = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM bills'));
      final stock = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM stock'));
      final salesRes = await db.rawQuery("SELECT SUM(grand_total) as total FROM bills");
      final expRes = await db.rawQuery("SELECT SUM(amount) as total FROM expenses");
      final cashRes = await db.rawQuery("SELECT SUM(grand_total) as total FROM bills WHERE payment_mode = 'Cash'");
      final onlineRes = await db.rawQuery("SELECT SUM(grand_total) as total FROM bills WHERE payment_mode != 'Cash' AND payment_mode != 'Credit (Udhaar)'");

      if (mounted) setState(() {
        stats = {
          "sales": (salesRes.first['total'] as num?)?.toDouble() ?? 0.0,
          "bills": bills,
          "stock": stock,
          "exp": (expRes.first['total'] as num?)?.toDouble() ?? 0.0,
          "cash": (cashRes.first['total'] as num?)?.toDouble() ?? 0.0,
          "online": (onlineRes.first['total'] as num?)?.toDouble() ?? 0.0,
        };
      });
    } catch(e) {
      debugPrint("DB Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3, childAspectRatio: 1.8, crossAxisSpacing: 25, mainAxisSpacing: 25,
      children: [
        _statCard("Total Sales", "₹${stats['sales']}", Icons.attach_money, AppColors.blueCard),
        _statCard("Total Bills", "${stats['bills']}", Icons.receipt, AppColors.orangeCard),
        _statCard("Stock Items", "${stats['stock']}", Icons.inventory, AppColors.greenCard),
        _statCard("Expenses", "₹${stats['exp']}", Icons.money_off, AppColors.redCard),
        _statCard("Cash Collected", "₹${stats['cash']}", Icons.payments, AppColors.purpleCard),
        _statCard("Online (GPay/Card)", "₹${stats['online']}", Icons.credit_card, AppColors.tealCard),
      ],
    );
  }

  Widget _statCard(String title, String val, IconData icon, Gradient gradient) {
    return Container(
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(25), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(5, 8))]),
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 30)), const Spacer(), Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold))]),
          const Spacer(),
          Text(val, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black26, blurRadius: 4)]))
        ],
      ),
    );
  }
}

// ==========================================
// 7️⃣ CREATE BILL
// ==========================================
class CreateBillPage extends StatefulWidget { const CreateBillPage({super.key}); @override State<CreateBillPage> createState() => _CreateBillPageState(); }
class _CreateBillPageState extends State<CreateBillPage> {
  final _customerCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _carCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  final _discountCtrl = TextEditingController(text: "0");
  final _notesCtrl = TextEditingController();
  final _customServiceTypeCtrl = TextEditingController();
  
  DateTime _invoiceDate = DateTime.now();
  DateTime _nextService = DateTime.now().add(const Duration(days: 90));
  String _serviceType = "Paid"; 
  String _paymentMode = "Cash"; 
  String? _selectedWorker;
  String _billStatus = "Completed";
  String _workerStatus = "Working";

  List<Map<String, dynamic>> _stock = [];
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _workers = [];
  List<Map<String, dynamic>> _cart = [];
  final List<String> _paymentOptions = ["Cash", "Google Pay", "PhonePe", "Bank Transfer", "Card", "Credit (Udhaar)", "Split"];

  @override void initState() { super.initState(); _loadData(); }
  void _loadData() async { 
    final db = await DatabaseHelper.instance.database; 
    final st = await db.query('stock'); final cu = await db.query('customers'); final wo = await db.query('employees');
    setState(() { _stock = st; _customers = cu; _workers = wo; });
  }

  void _addToCart(Map<String, dynamic> item) { setState(() { _cart.add({'id': item['id'], 'name': item['name'], 'unit_price': item['unit_price'], 'qty': 1, 'total': item['unit_price']}); }); }
  
  void _manualAdd() {
    final nameCtrl = TextEditingController(); final priceCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Add Service/Labor"), IconButton(icon: const Icon(Icons.close), onPressed: ()=>Navigator.pop(context))]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Description (e.g., Labor, Service)")), const SizedBox(height: 10), TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Amount (₹)"), keyboardType: TextInputType.number)]), 
      actions: [ElevatedButton(onPressed: () { if (nameCtrl.text.isNotEmpty) { double p = double.tryParse(priceCtrl.text) ?? 0.0; setState(() { _cart.add({'id': -1, 'name': nameCtrl.text, 'unit_price': p, 'qty': 1, 'total': p}); }); Navigator.pop(context); } }, child: const Text("Add"))]));
  }
  
  void _selectCustomer(Map<String, dynamic> cust) { setState(() { _customerCtrl.text = cust['name']; _phoneCtrl.text = cust['phone']; _carCtrl.text = cust['car_model'] ?? ''; _plateCtrl.text = cust['number_plate'] ?? ''; }); }
  Future<void> _pickDate(BuildContext context, bool isInvoice) async { final DateTime? picked = await showDatePicker(context: context, initialDate: isInvoice ? _invoiceDate : _nextService, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (picked != null) setState(() { if(isInvoice) _invoiceDate = picked; else _nextService = picked; }); }

  void _saveBill() async {
    if (_customerCtrl.text.isEmpty || _cart.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Missing Customer or Items!"))); return; }
    double subTotal = _cart.fold(0, (sum, i) => sum + (i['total'] as num));
    double discount = double.tryParse(_discountCtrl.text) ?? 0.0;
    double total = subTotal - discount;
    double paid = (_paymentMode == "Credit (Udhaar)") ? 0.0 : (_paymentMode == "Split" ? (double.tryParse(_paidCtrl.text) ?? 0.0) : total);
    double due = total - paid;
    final db = await DatabaseHelper.instance.database;
    final serviceFinal = _serviceType == "Other" ? _customServiceTypeCtrl.text : _serviceType;

    final existingCust = await db.query('customers', where: 'phone = ?', whereArgs: [_phoneCtrl.text]);
    if (existingCust.isNotEmpty) { await db.update('customers', {'name': _customerCtrl.text, 'car_model': _carCtrl.text, 'number_plate': _plateCtrl.text}, where: 'phone = ?', whereArgs: [_phoneCtrl.text]); } 
    else { if (_phoneCtrl.text.isNotEmpty) await db.insert('customers', {'name': _customerCtrl.text, 'phone': _phoneCtrl.text, 'car_model': _carCtrl.text, 'number_plate': _plateCtrl.text}); }

    int billId = await db.insert('bills', {'customer_name': _customerCtrl.text, 'customer_phone': _phoneCtrl.text, 'car_model': _carCtrl.text, 'number_plate': _plateCtrl.text, 'grand_total': total, 'paid_amount': paid, 'due_amount': due, 'date': DateFormat('yyyy-MM-dd').format(_invoiceDate), 'service_type': serviceFinal, 'next_service_date': DateFormat('yyyy-MM-dd').format(_nextService), 'worker_name': _selectedWorker ?? '', 'payment_mode': _paymentMode, 'notes': _notesCtrl.text, 'status': _billStatus, 'worker_status': _workerStatus});
    for (var item in _cart) { await db.insert('bill_items', {'bill_id': billId, 'item_name': item['name'], 'quantity': item['qty'], 'unit_price': item['unit_price'], 'total': item['total']}); if(item['id'] != -1) await db.rawUpdate('UPDATE stock SET quantity = quantity - ? WHERE id = ?', [item['qty'], item['id']]); }

    final billMap = {'id': billId, 'customer_name': _customerCtrl.text, 'customer_phone': _phoneCtrl.text, 'car_model': _carCtrl.text, 'number_plate': _plateCtrl.text, 'grand_total': total, 'paid_amount': paid, 'due_amount': due, 'date': DateFormat('yyyy-MM-dd').format(_invoiceDate), 'next_service_date': DateFormat('yyyy-MM-dd').format(_nextService), 'notes': _notesCtrl.text, 'status': _billStatus};
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bill Saved! Generating PDF..."), backgroundColor: Colors.green));
    await Navigator.push(context, MaterialPageRoute(builder: (_) => PdfPreviewPage(bill: billMap)));
    _resetForm();
  }

  void _resetForm() { setState(() { _cart.clear(); _customerCtrl.clear(); _phoneCtrl.clear(); _carCtrl.clear(); _plateCtrl.clear(); _paidCtrl.clear(); _discountCtrl.text="0"; _notesCtrl.clear(); _selectedWorker = null; _serviceType = "Paid"; _paymentMode = "Cash"; _customServiceTypeCtrl.clear(); }); _loadData(); }
  double get _calculateTotal { double sub = _cart.fold(0, (sum, i) => sum + (i['total'] as num)); double disc = double.tryParse(_discountCtrl.text) ?? 0.0; return sub - disc; }

  @override Widget build(BuildContext context) {
    double total = _calculateTotal; double paid = double.tryParse(_paidCtrl.text) ?? 0.0; double due = total - paid;
    return Row(children: [
      Expanded(flex: 2, child: Column(children: [
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          Row(children: [
            Expanded(child: Autocomplete<Map<String, dynamic>>(optionsBuilder: (v) => _customers.where((c) => c['name'].toString().toLowerCase().contains(v.text.toLowerCase())), displayStringForOption: (c) => c['name'], onSelected: _selectCustomer, fieldViewBuilder: (ctx, ctrl, focus, submit) { if(_customerCtrl.text.isEmpty && ctrl.text.isNotEmpty) _customerCtrl.text = ctrl.text; return TextField(controller: ctrl, focusNode: focus, decoration: const InputDecoration(labelText: "Search Customer", prefixIcon: Icon(Icons.search)), onChanged: (v) => _customerCtrl.text = v); })),
            const SizedBox(width: 15), ElevatedButton.icon(onPressed: _resetForm, icon: const Icon(Icons.refresh), label: const Text("Reset"))
          ]),
          const SizedBox(height: 15),
          Row(children: [Expanded(child: TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: "Phone"))), const SizedBox(width: 15), Expanded(child: TextField(controller: _carCtrl, decoration: const InputDecoration(labelText: "Car Model"))), const SizedBox(width: 15), Expanded(child: TextField(controller: _plateCtrl, decoration: const InputDecoration(labelText: "Plate Number")))]),
          const SizedBox(height: 15),
          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(value: _serviceType, decoration: const InputDecoration(labelText: "Service Type"), items: ["Paid", "Free Service", "Warranty", "Other"].map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList(), onChanged: (v)=>setState(()=>_serviceType=v!))), 
            if(_serviceType == "Other") ...[const SizedBox(width: 15), Expanded(child: TextField(controller: _customServiceTypeCtrl, decoration: const InputDecoration(labelText: "Enter Type")))],
            const SizedBox(width: 15), Expanded(child: DropdownButtonFormField<String>(value: _selectedWorker, decoration: const InputDecoration(labelText: "Assign Worker"), items: _workers.map((e)=>DropdownMenuItem(value:e['name'].toString(), child: Text(e['name']))).toList(), onChanged: (v)=>setState(()=>_selectedWorker=v))), 
            const SizedBox(width: 15), Expanded(child: DropdownButtonFormField<String>(value: _workerStatus, decoration: const InputDecoration(labelText: "Worker Status"), items: ["Working", "Not Working", "Completed"].map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList(), onChanged: (v)=>setState(()=>_workerStatus=v!)))]),
          const SizedBox(height: 15),
          Row(children: [Expanded(child: InkWell(onTap: ()=>_pickDate(context, true), child: InputDecorator(decoration: const InputDecoration(labelText: "Invoice Date", prefixIcon: Icon(Icons.calendar_today)), child: Text(DateFormat('yyyy-MM-dd').format(_invoiceDate))))), const SizedBox(width: 15), Expanded(child: DropdownButtonFormField<String>(value: _billStatus, decoration: const InputDecoration(labelText: "Bill Status"), items: ["Pending", "Completed", "Cancelled"].map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList(), onChanged: (v)=>setState(()=>_billStatus=v!)))]),
          const SizedBox(height: 15), TextField(controller: _notesCtrl, decoration: const InputDecoration(labelText: "Additional Notes (Warranty / Instructions)", prefixIcon: Icon(Icons.note)))
        ]))),
        Expanded(child: Card(child: ListView.builder(itemCount: _cart.length, itemBuilder: (c,i) => ListTile(leading: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.shopping_cart, color: Colors.white)), title: Text(_cart[i]['name'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("Price: ₹${_cart[i]['unit_price']}"), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: (){ showDialog(context: context, builder: (_)=>AlertDialog(title: const Text("Edit Qty"), content: TextField(keyboardType: TextInputType.number, onSubmitted: (val){ setState(() { _cart[i]['qty'] = int.tryParse(val)??1; _cart[i]['total'] = _cart[i]['qty']*_cart[i]['unit_price']; }); Navigator.pop(context); }), )); }), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: ()=>setState(()=>_cart.removeAt(i))) ]), )))),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]), child: Column(children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _paymentMode, 
                  decoration: const InputDecoration(labelText: "Payment Mode"), 
                  items: _paymentOptions.map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList(), 
                  onChanged: (v)=>setState(()=>_paymentMode=v!)
                )
              ), 
              const SizedBox(width: 10), 
              Expanded(
                child: TextField(
                  controller: _discountCtrl, 
                  decoration: const InputDecoration(labelText: "Discount (₹)"), 
                  keyboardType: TextInputType.number, 
                  onChanged: (v)=>setState((){})
                )
              ), 
              if(_paymentMode == "Split") ...[
                const SizedBox(width: 10), 
                Expanded(
                  child: TextField(
                    controller: _paidCtrl, 
                    decoration: const InputDecoration(labelText: "Paid Amt"), 
                    keyboardType: TextInputType.number, 
                    onChanged: (v)=>setState((){})
                  )
                )
              ], 
              const SizedBox(width: 20), 
              Column(
                crossAxisAlignment: CrossAxisAlignment.end, 
                children: [
                  Text("Total: ₹${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)), 
                  Text("Due: ₹${due.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: due > 0 ? Colors.red : Colors.green))
                ]
              )
            ]
          ),
          const SizedBox(height: 15), SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _saveBill, icon: const Icon(Icons.save), label: const Text("SAVE BILL & PRINT", style: TextStyle(fontSize: 18))))
        ]))
      ])),
      Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Stock Search", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)), IconButton(onPressed: _manualAdd, icon: const Icon(Icons.add_shopping_cart, color: Colors.green), tooltip: "Add Service Charge")]),
        const SizedBox(height: 15), Autocomplete<Map<String, dynamic>>(optionsBuilder: (v) => _stock.where((o) => o['name'].toString().toLowerCase().contains(v.text.toLowerCase())), displayStringForOption: (o) => "${o['name']} (₹${o['unit_price']})", onSelected: _addToCart),
      ]))))
    ]);
  }
}

// ==========================================
// 8️⃣ BILL HISTORY
// ==========================================
class BillHistoryPage extends StatefulWidget { const BillHistoryPage({super.key}); @override State<BillHistoryPage> createState() => _BillHistoryPageState(); }
class _BillHistoryPageState extends State<BillHistoryPage> {
  List<Map<String, dynamic>> _allBills = []; List<Map<String, dynamic>> _filteredBills = []; final _searchCtrl = TextEditingController(); DateTimeRange? _dateRange; Timer? _timer;
  @override void initState() { super.initState(); _load(); _timer = Timer.periodic(const Duration(seconds: 2), (t) => _load()); }
  @override void dispose() { _timer?.cancel(); super.dispose(); }
  void _load() async { 
    try {
      final db = await DatabaseHelper.instance.database; final res = await db.query('bills', orderBy: "id DESC"); if(mounted) setState(() { _allBills = res; _filter(); }); 
    } catch(e) { debugPrint("History Load Error: $e"); }
  }
  
  void _filter() { 
    String query = _searchCtrl.text.toLowerCase();
    _filteredBills = _allBills.where((b) {
      bool matchName = b['customer_name'].toString().toLowerCase().contains(query) || b['id'].toString().contains(query);
      bool matchDate = true;
      if (_dateRange != null) {
        DateTime billDate = DateFormat('yyyy-MM-dd').parse(b['date']);
        matchDate = billDate.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) && 
                    billDate.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }
      return matchName && matchDate;
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context, 
      firstDate: DateTime(2000), 
      lastDate: DateTime(2100)
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      _filter();
    }
  }

  void _openPdfPage(Map<String, dynamic> b) { Navigator.push(context, MaterialPageRoute(builder: (_) => PdfPreviewPage(bill: b))); }
  
  // EDIT BILL DETAILS (Expanded functionality)
  void _editBillDetails(Map<String, dynamic> b) {
    final nameCtrl = TextEditingController(text: b['customer_name']);
    final phoneCtrl = TextEditingController(text: b['customer_phone']);
    final carCtrl = TextEditingController(text: b['car_model']);
    final plateCtrl = TextEditingController(text: b['number_plate']);
    final totalCtrl = TextEditingController(text: b['grand_total'].toString());
    final paidCtrl = TextEditingController(text: b['paid_amount'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(children: [Text("Edit Bill Details #${b['id']}"), const Spacer(), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Customer Name")),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")),
            const SizedBox(height: 10),
            TextField(controller: carCtrl, decoration: const InputDecoration(labelText: "Car Model")),
            const SizedBox(height: 10),
            TextField(controller: plateCtrl, decoration: const InputDecoration(labelText: "Plate Number")),
            const SizedBox(height: 10),
            TextField(controller: totalCtrl, decoration: const InputDecoration(labelText: "Total Amount"), keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            TextField(controller: paidCtrl, decoration: const InputDecoration(labelText: "Paid Amount"), keyboardType: TextInputType.number),
          ]),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              double newTotal = double.tryParse(totalCtrl.text) ?? 0.0;
              double newPaid = double.tryParse(paidCtrl.text) ?? 0.0;
              double newDue = newTotal - newPaid;

              final db = await DatabaseHelper.instance.database;
              await db.update('bills', {
                'customer_name': nameCtrl.text,
                'customer_phone': phoneCtrl.text,
                'car_model': carCtrl.text,
                'number_plate': plateCtrl.text,
                'grand_total': newTotal,
                'paid_amount': newPaid,
                'due_amount': newDue
              }, where: 'id=?', whereArgs: [b['id']]);
              Navigator.pop(context);
              _load();
            },
            child: const Text("Save Changes")
          )
        ]
      )
    );
  }

  @override Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.all(8.0), child: Row(children: [
        Expanded(child: TextField(controller: _searchCtrl, onChanged: (v)=>setState(()=>_filter()), decoration: const InputDecoration(labelText: "Search by Customer Name or Bill ID", prefixIcon: Icon(Icons.search)))), 
        const SizedBox(width: 10), 
        Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: IconButton(icon: const Icon(Icons.date_range, color: AppColors.primary), onPressed: _pickDateRange, tooltip: "Filter by Date")), 
        if(_dateRange != null) IconButton(icon: const Icon(Icons.clear, color: Colors.red), onPressed: (){ setState(()=>_dateRange=null); _filter(); })
      ])),
      Expanded(child: _filteredBills.isEmpty ? _buildEmptyState("No Bills Found") : ListView.builder(itemCount: _filteredBills.length, itemBuilder: (c,i) { final b = _filteredBills[i]; double due = (b['due_amount'] as num?)?.toDouble() ?? 0.0; return Card(child: ListTile(
        leading: CircleAvatar(backgroundColor: due > 0 ? Colors.redAccent : Colors.green, child: const Icon(Icons.receipt, color: Colors.white)), 
        title: Text("${b['customer_name']} (Bill #${b['id']})", style: const TextStyle(fontWeight: FontWeight.bold)), 
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${b['date']} | ${b['car_model']} | Status: ${b['status']??'Completed'}"), if(due > 0) Text("Due: ₹$due", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))]), 
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text("₹${b['grand_total']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
          const SizedBox(width: 15), 
          IconButton(icon: const Icon(Icons.edit, color: Colors.orange), tooltip: "Edit Bill Details", onPressed: ()=>_editBillDetails(b)),
          IconButton(icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary), tooltip: "View/Print/Share PDF", onPressed: ()=>_openPdfPage(b)), 
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { final db = await DatabaseHelper.instance.database; await db.delete('bills', where: 'id = ?', whereArgs: [b['id']]); _load(); })
        ]),)); }))
    ]);
  }
}

class PdfPreviewPage extends StatelessWidget {
  final Map<String, dynamic> bill;
  const PdfPreviewPage({super.key, required this.bill});
  Future<List<Map<String, dynamic>>> _getItems() async { final db = await DatabaseHelper.instance.database; return await db.query('bill_items', where: 'bill_id = ?', whereArgs: [bill['id']]); }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Invoice View")), body: PdfPreview(build: (format) async {
      final items = await _getItems(); final doc = pw.Document();
      doc.addPage(pw.Page(build: (pw.Context context) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text("OZON Detailing & Car Wash", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
            pw.Text("Kolathakkara, Manipuram"), pw.Text("Puthoor (PO), Omassery 673582"), pw.Text("+91-9447405746"), pw.Text("info@ozondetailing.com")
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text("INVOICE", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text("Invoice Number: INV-${bill['id']}"), pw.Text("Date of Issue: ${bill['date']}"), pw.Text("Next Service: ${bill['next_service_date']}"),
          ])
        ]),
        pw.SizedBox(height: 20),
        pw.Text("Bill To:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(bill['customer_name']), pw.Text(bill['customer_phone']), pw.Text("Vehicle: ${bill['car_model']} (${bill['number_plate']})"),
        pw.SizedBox(height: 20),
        pw.TableHelper.fromTextArray(headers: ['Description', 'Quantity', 'Unit Price', 'Amount'], data: items.map((e) => [e['item_name'], e['quantity'].toString(), "${e['unit_price']}", "${e['total']}"]).toList(), border: null, headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white), headerDecoration: const pw.BoxDecoration(color: PdfColors.blue)),
        pw.SizedBox(height: 20),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Text("Subtotal: ${bill['grand_total']}"),
          pw.Text("Total Amount: ${bill['grand_total']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.Text("Paid: ${bill['paid_amount']}"), pw.Text("Due: ${bill['due_amount']}")
        ])]),
        pw.Spacer(),
        pw.Text("Generated by SuhaimSoft ERP", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey))
      ])));
      return doc.save();
    }));
  }
}

// ==========================================
// 9️⃣ PAYROLL SYSTEM
// ==========================================
class PayrollPage extends StatefulWidget { const PayrollPage({super.key}); @override State<PayrollPage> createState() => _PayrollPageState(); }
class _PayrollPageState extends State<PayrollPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override void initState() { super.initState(); _tabController = TabController(length: 2, vsync: this); }
  @override Widget build(BuildContext context) { return Column(children: [Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]), margin: const EdgeInsets.only(bottom: 10), child: TabBar(controller: _tabController, labelColor: AppColors.primary, unselectedLabelColor: Colors.grey, indicatorWeight: 4, tabs: const [Tab(text: "Employees"), Tab(text: "Salary Payments")])), Expanded(child: TabBarView(controller: _tabController, children: const [EmployeeTab(), SalaryPaymentTab()]))]); }
}
class EmployeeTab extends StatefulWidget { const EmployeeTab({super.key}); @override State<EmployeeTab> createState() => _EmpTabState(); }
class _EmpTabState extends State<EmployeeTab> {
  List<Map<String, dynamic>> _data = []; Timer? _timer;
  @override void initState() { super.initState(); _load(); _timer=Timer.periodic(const Duration(seconds: 2), (t)=>_load()); }
  @override void dispose() { _timer?.cancel(); super.dispose(); }
  void _load() async { final db = await DatabaseHelper.instance.database; final res = await db.query('employees'); if(mounted) setState(() => _data = res); }
  
  void _add() { 
    final name=TextEditingController(); final role=TextEditingController(); final sal=TextEditingController(); 
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Add Employee"), IconButton(icon: const Icon(Icons.close), onPressed: ()=>Navigator.pop(context))]), 
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: "Name")), 
        TextField(controller: role, decoration: const InputDecoration(labelText: "Role")), 
        TextField(controller: sal, decoration: const InputDecoration(labelText: "Basic Salary"))
      ]), 
      actions: [ElevatedButton(onPressed: () async { 
        final db = await DatabaseHelper.instance.database; 
        await db.insert('employees', {'name': name.text, 'role': role.text, 'salary': double.tryParse(sal.text)??0}); 
        if(mounted){Navigator.pop(context); _load();} 
      }, child: const Text("Save"))]
    )); 
  }

  void _edit(Map<String, dynamic> item) { 
    final name=TextEditingController(text: item['name']); final role=TextEditingController(text: item['role']); final sal=TextEditingController(text: item['salary'].toString()); 
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Edit Employee"), IconButton(icon: const Icon(Icons.close), onPressed: ()=>Navigator.pop(context))]), 
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: "Name")), 
        TextField(controller: role, decoration: const InputDecoration(labelText: "Role")), 
        TextField(controller: sal, decoration: const InputDecoration(labelText: "Basic Salary"))
      ]), 
      actions: [ElevatedButton(onPressed: () async { 
        final db = await DatabaseHelper.instance.database; 
        await db.update('employees', {'name': name.text, 'role': role.text, 'salary': double.tryParse(sal.text)??0}, where: 'id = ?', whereArgs: [item['id']]); 
        if(mounted){Navigator.pop(context); _load();} 
      }, child: const Text("Update"))]
    )); 
  }

  @override Widget build(BuildContext context) { 
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)), 
      body: _data.isEmpty ? _buildEmptyState("No Employees Added") : ListView.builder(itemCount: _data.length, itemBuilder: (c,i)=>Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(_data[i]['name']), subtitle: Text("${_data[i]['role']} - ₹${_data[i]['salary']}"), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () => _edit(_data[i])), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { final db=await DatabaseHelper.instance.database; await db.delete('employees', where: 'id=?', whereArgs: [_data[i]['id']]); _load(); })]))))
    ); 
  }
}

class SalaryPaymentTab extends StatefulWidget { const SalaryPaymentTab({super.key}); @override State<SalaryPaymentTab> createState() => _SalTabState(); }
class _SalTabState extends State<SalaryPaymentTab> {
  List<Map<String, dynamic>> _logs = []; List<Map<String, dynamic>> _employees = []; String? _selectedEmp;
  @override void initState() { super.initState(); _load(); }
  void _load() async { final db = await DatabaseHelper.instance.database; final res = await db.query('salary_payments', orderBy: "id DESC"); final emps = await db.query('employees'); if(mounted) setState(() { _logs = res; _employees = emps; }); }
  
  void _pay() { 
    final amt=TextEditingController(); 
    showDialog(context: context, builder: (_)=>StatefulBuilder(builder: (context, setSt) => AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Pay Salary"), IconButton(icon: const Icon(Icons.close), onPressed: ()=>Navigator.pop(context))]), 
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(value: _selectedEmp, hint: const Text("Select Employee"), items: _employees.map((e) => DropdownMenuItem(value: e['name'].toString(), child: Text(e['name']))).toList(), onChanged: (v) => setSt(() => _selectedEmp = v)), 
        const SizedBox(height: 10), 
        TextField(controller: amt, decoration: const InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number)
      ]), 
      actions: [ElevatedButton(onPressed: () async { 
        if(_selectedEmp == null || amt.text.isEmpty) return; 
        final db = await DatabaseHelper.instance.database; 
        await db.insert('salary_payments', {'emp_name': _selectedEmp, 'amount': double.tryParse(amt.text)??0, 'date': DateFormat('yyyy-MM-dd').format(DateTime.now()), 'notes': 'Salary Payment'}); 
        if(mounted){Navigator.pop(context); _load();} 
      }, child: const Text("Pay"))]
    ))); 
  }

  void _editSalary(Map<String, dynamic> item) {
    final amt = TextEditingController(text: item['amount'].toString());
    showDialog(context: context, builder: (_) => AlertDialog(
      // ignore: prefer_const_constructors
      title: Row(children: [Text("Edit Salary"), const Spacer(), IconButton(icon: const Icon(Icons.close), onPressed: ()=>Navigator.pop(context))]),
      content: TextField(controller: amt, decoration: const InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),
      actions: [
        ElevatedButton(onPressed: () async {
          final db = await DatabaseHelper.instance.database;
          await db.update('salary_payments', {'amount': double.tryParse(amt.text)??0}, where: 'id=?', whereArgs: [item['id']]);
          Navigator.pop(context); _load();
        }, child: const Text("Update"))
      ]
    ));
  }

  void _deleteSalary(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('salary_payments', where: 'id=?', whereArgs: [id]);
    _load();
  }

  @override Widget build(BuildContext context) { 
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _pay, child: const Icon(Icons.payment)), 
      body: _logs.isEmpty ? _buildEmptyState("No Payments Made") : ListView.builder(itemCount: _logs.length, itemBuilder: (c,i)=>Card(child: ListTile(
        leading: const Icon(Icons.monetization_on, color: Colors.green), 
        title: Text(_logs[i]['emp_name']), 
        subtitle: Text(_logs[i]['date']), 
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text("₹${_logs[i]['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 10),
          IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () => _editSalary(_logs[i])),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteSalary(_logs[i]['id'])),
        ])
      )))
    ); 
  }
}

// ==========================================
// 🔟 MAKING ITEM, STOCK, CUSTOMERS, ETC.
// ==========================================
class MakingItemPage extends StatefulWidget { const MakingItemPage({super.key}); @override State<MakingItemPage> createState() => _MakingItemPageState(); }
class _MakingItemPageState extends State<MakingItemPage> {
  final _prodNameCtrl = TextEditingController(); final _qtyCtrl = TextEditingController(); final _partsCtrl = TextEditingController(); final _searchCtrl = TextEditingController(); List<Map<String, dynamic>> _madeItems = [];
  @override void initState() { super.initState(); _refresh(); }
  void _refresh() async { final db = await DatabaseHelper.instance.database; final res = await db.query('manufacturing'); setState(() => _madeItems = res); }
  void _save() async { if (_prodNameCtrl.text.isEmpty) return; final db = await DatabaseHelper.instance.database; await db.insert('manufacturing', {'product_name': _prodNameCtrl.text, 'quantity_made': int.tryParse(_qtyCtrl.text) ?? 0, 'notes': _partsCtrl.text, 'date': DateFormat('yyyy-MM-dd').format(DateTime.now())}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Production Recorded!"))); _prodNameCtrl.clear(); _qtyCtrl.clear(); _partsCtrl.clear(); _refresh(); }
  
  void _edit(Map<String, dynamic> item) { 
    final prod = TextEditingController(text: item['product_name']); 
    final qty = TextEditingController(text: item['quantity_made'].toString()); 
    final notes = TextEditingController(text: item['notes']); 
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Edit Production"), IconButton(icon: const Icon(Icons.close), onPressed: ()=>Navigator.pop(context))]), 
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: prod, decoration: const InputDecoration(labelText: "Product")), 
        TextField(controller: qty, decoration: const InputDecoration(labelText: "Qty")), 
        TextField(controller: notes, decoration: const InputDecoration(labelText: "Notes"))
      ]), 
      actions: [ElevatedButton(onPressed: () async { 
        final db = await DatabaseHelper.instance.database; 
        await db.update('manufacturing', {'product_name': prod.text, 'quantity_made': int.tryParse(qty.text)??0, 'notes': notes.text}, where: 'id = ?', whereArgs: [item['id']]); 
        if(mounted){Navigator.pop(context); _refresh();} 
      }, child: const Text("Update"))]
    )); 
  }

  @override Widget build(BuildContext context) { 
    final filtered = _madeItems.where((e) => e['product_name'].toString().toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();
    return Row(children: [Expanded(flex: 1, child: Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [const Text("Production Entry", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 20), TextField(controller: _prodNameCtrl, decoration: const InputDecoration(labelText: "Product Name")), TextField(controller: _qtyCtrl, decoration: const InputDecoration(labelText: "Quantity")), TextField(controller: _partsCtrl, decoration: const InputDecoration(labelText: "Notes")), const SizedBox(height: 20), ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.build), label: const Text("Record"))])))), Expanded(flex: 1, child: Column(children: [Padding(padding: const EdgeInsets.all(8), child: TextField(controller: _searchCtrl, onChanged: (v)=>setState((){}), decoration: const InputDecoration(labelText: "Search Production", prefixIcon: Icon(Icons.search)))), Expanded(child: Card(child: filtered.isEmpty ? _buildEmptyState("No History") : ListView.builder(itemCount: filtered.length, itemBuilder: (c,i) => ListTile(title: Text(filtered[i]['product_name']), subtitle: Text("Qty: ${filtered[i]['quantity_made']}"), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () => _edit(filtered[i])), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { final db = await DatabaseHelper.instance.database; await db.delete('manufacturing', where: 'id = ?', whereArgs: [filtered[i]['id']]); _refresh(); })]))))) ]))]); 
  }
}

class StockPage extends StatefulWidget { const StockPage({super.key}); @override State<StockPage> createState() => _StockPageState(); }
class _StockPageState extends State<StockPage> {
  List<Map<String, dynamic>> _data = []; final _searchCtrl = TextEditingController();
  @override void initState() { super.initState(); _refresh(); }
  void _refresh() async { final db = await DatabaseHelper.instance.database; final res = await db.query('stock'); setState(() => _data = res); }
  
  void _add() { 
    final code=TextEditingController(); final name=TextEditingController(); final qty=TextEditingController(); final price=TextEditingController(); 
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Add Stock"), IconButton(icon: const Icon(Icons.close), onPressed: ()=>Navigator.pop(context))]), 
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: code, decoration: const InputDecoration(labelText: "Code")), 
        TextField(controller: name, decoration: const InputDecoration(labelText: "Name")), 
        TextField(controller: qty, decoration: const InputDecoration(labelText: "Qty"), keyboardType: TextInputType.number), 
        TextField(controller: price, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number)
      ]), 
      actions: [ElevatedButton(onPressed: () async { 
        final db = await DatabaseHelper.instance.database; 
        await db.insert('stock', {'item_code': code.text, 'name': name.text, 'quantity': int.tryParse(qty.text)??0, 'unit_price': double.tryParse(price.text)??0}); 
        if(mounted){Navigator.pop(context); _refresh();} 
      }, child: const Text("Save"))]
    )); 
  }

  void _edit(Map<String, dynamic> item) { 
    final code=TextEditingController(text: item['item_code']); final name=TextEditingController(text: item['name']); final qty=TextEditingController(text: item['quantity'].toString()); final price=TextEditingController(text: item['unit_price'].toString()); 
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Edit Stock"), IconButton(icon: const Icon(Icons.close), onPressed: ()=>Navigator.pop(context))]), 
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: code, decoration: const InputDecoration(labelText: "Code")), 
        TextField(controller: name, decoration: const InputDecoration(labelText: "Name")), 
        TextField(controller: qty, decoration: const InputDecoration(labelText: "Qty"), keyboardType: TextInputType.number), 
        TextField(controller: price, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number)
      ]), 
      actions: [ElevatedButton(onPressed: () async { 
        final db = await DatabaseHelper.instance.database; 
        await db.update('stock', {'item_code': code.text, 'name': name.text, 'quantity': int.tryParse(qty.text)??0, 'unit_price': double.tryParse(price.text)??0}, where: 'id = ?', whereArgs: [item['id']]); 
        if(mounted){Navigator.pop(context); _refresh();} 
      }, child: const Text("Update"))]
    )); 
  }

  @override Widget build(BuildContext context) { 
    List<Map<String, dynamic>> filtered = _data.where((e) => e['name'].toString().toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList(); 
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)), 
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(8.0), child: TextField(controller: _searchCtrl, onChanged: (v)=>setState((){}), decoration: const InputDecoration(labelText: "Search Stock", prefixIcon: Icon(Icons.search)))), 
        Expanded(child: filtered.isEmpty ? _buildEmptyState("No Stock Found") : ListView.builder(itemCount: filtered.length, itemBuilder: (c,i) { 
          return Card(elevation: 4, color: Colors.white, child: ListTile(title: Text(filtered[i]['name']), subtitle: Text("Qty: ${filtered[i]['quantity']} | Price: ₹${filtered[i]['unit_price']}"), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () => _edit(filtered[i])), IconButton(icon: const Icon(Icons.delete, color: AppColors.danger), onPressed: () async { final db = await DatabaseHelper.instance.database; await db.delete('stock', where: 'id = ?', whereArgs: [filtered[i]['id']]); _refresh(); })]))); 
        }))
      ])
    ); 
  }
}

class WarrantiesPage extends StatefulWidget { const WarrantiesPage({super.key}); @override State<WarrantiesPage> createState() => _WarrantiesPageState(); }
class _WarrantiesPageState extends State<WarrantiesPage> {
  List<Map<String, dynamic>> _data = []; final _searchCtrl = TextEditingController();
  @override void initState() { super.initState(); _refresh(); }
  void _refresh() async { final db = await DatabaseHelper.instance.database; final res = await db.query('warranties'); setState(() => _data = res); }
  
  void _add() { 
    final cust=TextEditingController(); final item=TextEditingController(); DateTime date = DateTime.now(); 
    showDialog(context: context, builder: (_)=>StatefulBuilder(builder: (context, setSt) => AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Add Warranty"), IconButton(icon: const Icon(Icons.close), onPressed: ()=>Navigator.pop(context))]), 
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: cust, decoration: const InputDecoration(labelText: "Customer")), 
        TextField(controller: item, decoration: const InputDecoration(labelText: "Item")), 
        ListTile(title: Text("Expiry: ${DateFormat('yyyy-MM-dd').format(date)}"), trailing: const Icon(Icons.calendar_today), onTap: () async { final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100)); if(picked!=null) setSt(()=>date=picked); })
      ]), 
      actions: [ElevatedButton(onPressed: () async { 
        final db = await DatabaseHelper.instance.database; 
        await db.insert('warranties', {'customer_name': cust.text, 'item_name': item.text, 'expiry_date': DateFormat('yyyy-MM-dd').format(date)}); 
        if(mounted){Navigator.pop(context); _refresh();} 
      }, child: const Text("Save"))]
    ))); 
  }

  void _edit(Map<String, dynamic> data) { 
    final cust=TextEditingController(text: data['customer_name']); final item=TextEditingController(text: data['item_name']); DateTime date = DateFormat('yyyy-MM-dd').parse(data['expiry_date']); 
    showDialog(context: context, builder: (_)=>StatefulBuilder(builder: (context, setSt) => AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Edit Warranty"), IconButton(icon: const Icon(Icons.close), onPressed: ()=>Navigator.pop(context))]), 
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: cust, decoration: const InputDecoration(labelText: "Customer")), 
        TextField(controller: item, decoration: const InputDecoration(labelText: "Item")), 
        ListTile(title: Text("Expiry: ${DateFormat('yyyy-MM-dd').format(date)}"), trailing: const Icon(Icons.calendar_today), onTap: () async { final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100)); if(picked!=null) setSt(()=>date=picked); })
      ]), 
      actions: [ElevatedButton(onPressed: () async { 
        final db = await DatabaseHelper.instance.database; 
        await db.update('warranties', {'customer_name': cust.text, 'item_name': item.text, 'expiry_date': DateFormat('yyyy-MM-dd').format(date)}, where: 'id = ?', whereArgs: [data['id']]); 
        if(mounted){Navigator.pop(context); _refresh();} 
      }, child: const Text("Update"))]
    ))); 
  }

  @override Widget build(BuildContext context) { 
    final filtered = _data.where((e) => e['customer_name'].toString().toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)), 
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(8), child: TextField(controller: _searchCtrl, onChanged: (v)=>setState((){}), decoration: const InputDecoration(labelText: "Search Warranties", prefixIcon: Icon(Icons.search)))), 
        Expanded(child: filtered.isEmpty ? _buildEmptyState("No Warranties") : ListView.builder(itemCount: filtered.length, itemBuilder: (c,i) => Card(elevation: 4, color: Colors.white, child: ListTile(title: Text(filtered[i]['customer_name']), subtitle: Text("${filtered[i]['item_name']} (Exp: ${filtered[i]['expiry_date']})"), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () => _edit(filtered[i])), IconButton(icon: const Icon(Icons.delete, color: AppColors.danger), onPressed: () async { final db = await DatabaseHelper.instance.database; await db.delete('warranties', where: 'id = ?', whereArgs: [filtered[i]['id']]); _refresh(); })]))))) 
      ])
    ); 
  }
}

// ==========================================
// 1️⃣1️⃣ EXPENSES PAGE (With Search & New Fields)
// ==========================================
class ExpensesPage extends StatefulWidget { const ExpensesPage({super.key}); @override State<ExpensesPage> createState() => _ExpensesPageState(); }
class _ExpensesPageState extends State<ExpensesPage> {
  List<Map<String, dynamic>> _data = []; final _searchCtrl = TextEditingController();
  @override void initState() { super.initState(); _refresh(); }
  void _refresh() async { final db = await DatabaseHelper.instance.database; final res = await db.query('expenses', orderBy: "date DESC"); setState(() => _data = res); }
  
  void _add() { 
    final title=TextEditingController(); final amount=TextEditingController(); 
    final name=TextEditingController(); final desc=TextEditingController();
    DateTime date = DateTime.now(); 
    showDialog(context: context, builder: (_)=>StatefulBuilder(builder: (context, setSt) => AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Add Expense"), IconButton(icon: const Icon(Icons.close), onPressed: ()=>Navigator.pop(context))]), 
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: "Title (e.g. Electricity)")),
        const SizedBox(height: 10),
        TextField(controller: name, decoration: const InputDecoration(labelText: "Person Name (Who spent?)")),
        const SizedBox(height: 10),
        TextField(controller: desc, decoration: const InputDecoration(labelText: "Description (Details)")),
        const SizedBox(height: 10),
        TextField(controller: amount, decoration: const InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),
        ListTile(title: Text("Date: ${DateFormat('yyyy-MM-dd').format(date)}"), trailing: const Icon(Icons.calendar_today), onTap: () async { final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100)); if(picked!=null) setSt(()=>date=picked); })
      ])), 
      actions: [ElevatedButton(onPressed: () async { 
        final db = await DatabaseHelper.instance.database; 
        await db.insert('expenses', {'title': title.text, 'person_name': name.text, 'description': desc.text, 'amount': double.tryParse(amount.text)??0, 'date': DateFormat('yyyy-MM-dd').format(date)}); 
        if(mounted){Navigator.pop(context); _refresh();} 
      }, child: const Text("Save"))]
    ))); 
  }

  void _edit(Map<String, dynamic> data) { 
    final title=TextEditingController(text: data['title']); final amount=TextEditingController(text: data['amount'].toString());
    final name=TextEditingController(text: data['person_name']); final desc=TextEditingController(text: data['description']);
    DateTime date = DateFormat('yyyy-MM-dd').parse(data['date']); 
    showDialog(context: context, builder: (_)=>StatefulBuilder(builder: (context, setSt) => AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Edit Expense"), IconButton(icon: const Icon(Icons.close), onPressed: ()=>Navigator.pop(context))]), 
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: "Title")),
        const SizedBox(height: 10),
        TextField(controller: name, decoration: const InputDecoration(labelText: "Person Name")),
        const SizedBox(height: 10),
        TextField(controller: desc, decoration: const InputDecoration(labelText: "Description")),
        const SizedBox(height: 10),
        TextField(controller: amount, decoration: const InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),
        ListTile(title: Text("Date: ${DateFormat('yyyy-MM-dd').format(date)}"), trailing: const Icon(Icons.calendar_today), onTap: () async { final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100)); if(picked!=null) setSt(()=>date=picked); })
      ])), 
      actions: [ElevatedButton(onPressed: () async { 
        final db = await DatabaseHelper.instance.database; 
        await db.update('expenses', {'title': title.text, 'person_name': name.text, 'description': desc.text, 'amount': double.tryParse(amount.text)??0, 'date': DateFormat('yyyy-MM-dd').format(date)}, where: 'id = ?', whereArgs: [data['id']]); 
        if(mounted){Navigator.pop(context); _refresh();} 
      }, child: const Text("Update"))]
    ))); 
  }

  @override Widget build(BuildContext context) { 
    final filtered = _data.where((e) => e['title'].toString().toLowerCase().contains(_searchCtrl.text.toLowerCase()) || (e['person_name']??'').toString().toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();
    final List<Gradient> cardColors = [AppColors.blueCard, AppColors.orangeCard, AppColors.greenCard, AppColors.purpleCard, AppColors.tealCard];
    
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)), 
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(8.0), child: TextField(controller: _searchCtrl, onChanged: (v)=>setState((){}), decoration: const InputDecoration(labelText: "Search Expenses", prefixIcon: Icon(Icons.search)))),
        Expanded(child: filtered.isEmpty ? _buildEmptyState("No Expenses") : ListView.builder(itemCount: filtered.length, itemBuilder: (c,i) {
          final item = filtered[i];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
            decoration: BoxDecoration(gradient: cardColors[i % cardColors.length], borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2,2))]),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              title: Text(item['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), 
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if(item['person_name'] != null && item['person_name'].toString().isNotEmpty)
                  Row(children: [const Icon(Icons.person, color: Colors.white70, size: 16), const SizedBox(width: 5), Text(item['person_name'], style: const TextStyle(color: Colors.white70))]),
                if(item['description'] != null && item['description'].toString().isNotEmpty)
                  Text(item['description'], style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                const SizedBox(height: 5),
                Text(item['date'], style: const TextStyle(color: Colors.white60, fontSize: 12))
              ]),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text("₹${item['amount']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(width: 10),
                IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: () => _edit(item)), 
                IconButton(icon: const Icon(Icons.delete, color: Colors.white), onPressed: () async { final db = await DatabaseHelper.instance.database; await db.delete('expenses', where: 'id = ?', whereArgs: [item['id']]); _refresh(); })
              ])
            )
          );
        }))
      ])
    ); 
  }
}

class CustomersPage extends StatefulWidget { const CustomersPage({super.key}); @override State<CustomersPage> createState() => _CustPageState(); }
class _CustPageState extends State<CustomersPage> {
  List<Map<String, dynamic>> _data = []; final _searchCtrl = TextEditingController();
  @override void initState() { super.initState(); _refresh(); }
  void _refresh() async { final db = await DatabaseHelper.instance.database; final res = await db.query('customers'); setState(() => _data = res); }
  
  void _add() { 
    final name=TextEditingController(); final phone=TextEditingController(); final car=TextEditingController(); final plate=TextEditingController(); 
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Add New Customer"), IconButton(icon: const Icon(Icons.close), onPressed: ()=>Navigator.pop(context))]), 
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: "Name")), 
        TextField(controller: phone, decoration: const InputDecoration(labelText: "Phone")), 
        TextField(controller: car, decoration: const InputDecoration(labelText: "Car Model")), 
        TextField(controller: plate, decoration: const InputDecoration(labelText: "Number Plate"))
      ]), 
      actions: [ElevatedButton(onPressed: () async { 
        final db = await DatabaseHelper.instance.database; 
        await db.insert('customers', {'name': name.text, 'phone': phone.text, 'car_model': car.text, 'number_plate': plate.text}); 
        if(mounted){Navigator.pop(context); _refresh();} 
      }, child: const Text("Save"))]
    )); 
  }

  void _edit(Map<String, dynamic> item) { 
    final name=TextEditingController(text: item['name']); final phone=TextEditingController(text: item['phone']); final car=TextEditingController(text: item['car_model']); final plate=TextEditingController(text: item['number_plate']); 
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Edit Customer"), IconButton(icon: const Icon(Icons.close), onPressed: ()=>Navigator.pop(context))]), 
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: "Name")), 
        TextField(controller: phone, decoration: const InputDecoration(labelText: "Phone")), 
        TextField(controller: car, decoration: const InputDecoration(labelText: "Car")), 
        TextField(controller: plate, decoration: const InputDecoration(labelText: "Plate"))
      ]), 
      actions: [ElevatedButton(onPressed: () async { 
        final db = await DatabaseHelper.instance.database; 
        await db.update('customers', {'name': name.text, 'phone': phone.text, 'car_model': car.text, 'number_plate': plate.text}, where: 'id=?', whereArgs: [item['id']]); 
        if(mounted){Navigator.pop(context); _refresh();} 
      }, child: const Text("Update"))]
    )); 
  }

  @override Widget build(BuildContext context) { 
    final filtered = _data.where((e) => e['name'].toString().toLowerCase().contains(_searchCtrl.text.toLowerCase()) || e['phone'].toString().contains(_searchCtrl.text)).toList();
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)), 
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(8), child: TextField(controller: _searchCtrl, onChanged: (v)=>setState((){}), decoration: const InputDecoration(labelText: "Search Customers", prefixIcon: Icon(Icons.search)))), 
        Expanded(child: filtered.isEmpty ? _buildEmptyState("No Customers Found") : ListView.builder(itemCount: filtered.length, itemBuilder: (c,i) => Card(elevation: 4, color: Colors.white, child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(filtered[i]['name']), subtitle: Text("${filtered[i]['phone']} | ${filtered[i]['car_model']}"), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () => _edit(filtered[i])), IconButton(icon: const Icon(Icons.delete, color: AppColors.danger), onPressed: () async { final db = await DatabaseHelper.instance.database; await db.delete('customers', where: 'id = ?', whereArgs: [filtered[i]['id']]); _refresh(); })]))))) 
      ])
    ); 
  }
}

// ==========================================
// 1️⃣3️⃣ SETTINGS & LOGIN
// ==========================================
class SettingsPage extends StatelessWidget { const SettingsPage({super.key}); @override Widget build(BuildContext context) {
  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    GridView.count(crossAxisCount: 2, shrinkWrap: true, padding: const EdgeInsets.all(20), mainAxisSpacing: 20, crossAxisSpacing: 20, children: [
      _settingCard(Icons.upload, "Backup Data", AppColors.blueCard, () async { await DatabaseHelper.instance.backupDatabase(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Backup Process Started..."))); }),
      _settingCard(Icons.download, "Restore Data", AppColors.orangeCard, () async { await DatabaseHelper.instance.restoreDatabase(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Restore Process Started..."))); }),
    ]),
    const SizedBox(height: 30),
    Card(color: Colors.white, elevation: 4, child: Padding(padding: const EdgeInsets.all(30), child: Column(children: const [
      Text("About SuhaimSoft", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkSidebar)),
      SizedBox(height: 15),
      Text("Address: Pathappiriyam, Edavanna\nMalappuram, Kerala", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
      SizedBox(height: 10),
      Text("Phone: +91 8891 479 505", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      Text("Email: info@suhaimsoft.com", style: TextStyle(color: Colors.blue, fontSize: 16)),
    ])))
  ]));
}
Widget _settingCard(IconData icon, String title, Gradient gradient, VoidCallback onTap) {
  return InkWell(onTap: onTap, child: Container(decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 50, color: Colors.white), const SizedBox(height: 10), Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))])));
}}

class LoginScreen extends StatelessWidget { const LoginScreen({super.key}); @override Widget build(BuildContext context) { final u=TextEditingController(), p=TextEditingController(); return Scaffold(body: Container(decoration: const BoxDecoration(gradient: AppColors.loginGradient), child: Center(child: Card(elevation: 20, shadowColor: Colors.black45, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), child: Container(width: 380, padding: const EdgeInsets.all(40), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.lock_outline, size: 60, color: AppColors.primary), const SizedBox(height: 20), const Text("SUHAIMSOFT ERP", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.5)), const SizedBox(height: 30), TextField(controller: u, decoration: const InputDecoration(labelText: "Username", prefixIcon: Icon(Icons.person))), const SizedBox(height: 20), TextField(controller: p, obscureText: true, decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock))), const SizedBox(height: 40), SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(elevation: 10, shadowColor: Colors.blueAccent), onPressed: (){ if(u.text=='admin' && p.text=='admin123') Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const DashboardLayout())); }, child: const Text("LOGIN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2))))])))))); } }
