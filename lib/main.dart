// ignore_for_file: curly_braces_in_flow_control_structures, prefer_final_fields, use_build_context_synchronously, deprecated_member_use, prefer_const_constructors

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
  // 1. Initialize Bindings First (Crucial for plugins)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize FFI for Desktop (Windows/Linux/Mac)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 3. Initialize Database
  await DatabaseHelper.instance.database;

  // 4. Run App
  runApp(const WorkshopProApp());
}

// ==========================================
// 2️⃣ THEME & 3D CONFIGURATION
// ==========================================
class AppColors {
  static const primary = Color(0xFF1565C0); // Deep Blue
  static const secondary = Color(0xFFFFAB00); // Amber
  static const background = Color(0xFFEFF3F8); // Very Light Blue-Grey
  static const darkSidebar = Color(0xFF1A237E); // Deep Navy
  static const success = Color(0xFF2E7D32); // Green
  static const danger = Color(0xFFC62828); // Red
  
  // 3D Gradients
  static const Gradient loginGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)], 
    begin: Alignment.topLeft, 
    end: Alignment.bottomRight
  );
  
  static const Gradient sidebarGradient = LinearGradient(
    colors: [Color(0xFF283593), Color(0xFF1A237E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient blueGradient = LinearGradient(colors: [Color(0xFF64B5F6), Color(0xFF1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const Gradient orangeGradient = LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFA000)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const Gradient greenGradient = LinearGradient(colors: [Color(0xFF81C784), Color(0xFF388E3C)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  static const Gradient redGradient = LinearGradient(colors: [Color(0xFFE57373), Color(0xFFD32F2F)], begin: Alignment.topLeft, end: Alignment.bottomRight);
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
        
        // 3D Button Style
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 6,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shadowColor: Colors.black45,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        
        // Floating Action Button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          elevation: 8,
        ),

        // 3D Card Style (Explicitly defined properties on Widgets to avoid conflicts)
        cardColor: Colors.white,

        // Input Fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
// 3️⃣ DATABASE HELPER
// ==========================================
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('suhaimsoft_erp_final.db');
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
    await db.execute('CREATE TABLE expenses (id $idType, title $textType, amount $numType, date $textType)');
    await db.execute('CREATE TABLE warranties (id $idType, customer_name $textType, item_name $textType, expiry_date $textType)');
    await db.execute('CREATE TABLE manufacturing (id $idType, product_name $textType, quantity_made $intType, notes $textType, date $textType)');
  }

  Future<void> backupDatabase() async {
    try {
      final dbPath = await getApplicationDocumentsDirectory();
      final srcPath = p.join(dbPath.path, 'suhaimsoft_erp_final.db');
      final File srcFile = File(srcPath);
      if (!await srcFile.exists()) return;

      // Safe File Picker
      try {
        String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
        if (selectedDirectory != null) {
          final String destPath = p.join(selectedDirectory, 'backup_erp_final.db');
          await srcFile.copy(destPath);
        }
      } catch (e) { debugPrint("FilePicker Error: $e"); }
    } catch (e) { debugPrint("Backup Error: $e"); }
  }

  Future<void> restoreDatabase() async {
    try {
      FilePickerResult? result;
      try {
        result = await FilePicker.platform.pickFiles();
      } catch (e) { debugPrint("FilePicker Error: $e"); return; }

      if (result != null && result.files.single.path != null) {
        File source = File(result.files.single.path!);
        final dbPath = await getApplicationDocumentsDirectory();
        final String destPath = p.join(dbPath.path, 'suhaimsoft_erp_final.db');
        
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
    const SettingsPage(),
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
                AppBar(
                  title: Text(_getTitle(_idx)),
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
      decoration: active ? BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0,2))]
      ) : null,
      child: ListTile(
        leading: Icon(icon, color: active ? AppColors.primary : Colors.white70),
        title: Text(title, style: TextStyle(color: active ? AppColors.primary : Colors.white70, fontWeight: FontWeight.bold)),
        onTap: () => setState(() => _idx = i),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}

// Helper for Empty States
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

// ==========================================
// 6️⃣ DASHBOARD HOME
// ==========================================
class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});
  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  Map<String, dynamic> stats = {"sales": 0.0, "bills": 0, "stock": 0, "exp": 0.0};
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
    final db = await DatabaseHelper.instance.database;
    final bills = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM bills'));
    final stock = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM stock'));
    final salesRes = await db.rawQuery("SELECT SUM(grand_total) as total FROM bills");
    final expRes = await db.rawQuery("SELECT SUM(amount) as total FROM expenses");
    
    if (mounted) setState(() {
      stats = {
        "sales": (salesRes.first['total'] as num?)?.toDouble() ?? 0.0,
        "bills": bills,
        "stock": stock,
        "exp": (expRes.first['total'] as num?)?.toDouble() ?? 0.0,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4, childAspectRatio: 1.5, crossAxisSpacing: 25, mainAxisSpacing: 25,
      children: [
        _statCard("Total Sales", "₹${stats['sales']}", Icons.attach_money, AppColors.blueGradient),
        _statCard("Total Bills", "${stats['bills']}", Icons.receipt, AppColors.orangeGradient),
        _statCard("Stock Items", "${stats['stock']}", Icons.inventory, AppColors.greenGradient),
        _statCard("Expenses", "₹${stats['exp']}", Icons.money_off, AppColors.redGradient),
      ],
    );
  }

  Widget _statCard(String title, String val, IconData icon, Gradient gradient) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(5, 8))]
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 30)),
            const Spacer(),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
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
    final st = await db.query('stock'); 
    final cu = await db.query('customers');
    final wo = await db.query('employees');
    setState(() { _stock = st; _customers = cu; _workers = wo; });
  }

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      _cart.add({'id': item['id'], 'name': item['name'], 'unit_price': item['unit_price'], 'qty': 1, 'total': item['unit_price']});
    });
  }

  void _selectCustomer(Map<String, dynamic> cust) {
    setState(() {
      _customerCtrl.text = cust['name'];
      _phoneCtrl.text = cust['phone'];
      _carCtrl.text = cust['car_model'] ?? '';
      _plateCtrl.text = cust['number_plate'] ?? '';
    });
  }

  Future<void> _pickDate(BuildContext context, bool isInvoice) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: isInvoice ? _invoiceDate : _nextService, firstDate: DateTime(2000), lastDate: DateTime(2100)
    );
    if (picked != null) setState(() { if(isInvoice) _invoiceDate = picked; else _nextService = picked; });
  }

  void _saveBill() async {
    if (_customerCtrl.text.isEmpty || _cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Missing Customer or Items!")));
      return;
    }
    
    double subTotal = _cart.fold(0, (sum, i) => sum + (i['total'] as num));
    double discount = double.tryParse(_discountCtrl.text) ?? 0.0;
    double total = _serviceType == "Paid" ? (subTotal - discount) : 0.0;
    
    double paid = 0.0;
    if (_paymentMode == "Credit (Udhaar)") {
      paid = 0.0;
    } else if (_paymentMode == "Split") {
      paid = double.tryParse(_paidCtrl.text) ?? 0.0;
    } else {
      paid = total; 
    }
    double due = total - paid;

    final db = await DatabaseHelper.instance.database;

    // FIX: Check Customer by PHONE number to avoid duplicates
    final existingCust = await db.query('customers', where: 'phone = ?', whereArgs: [_phoneCtrl.text]);
    
    if (existingCust.isNotEmpty) {
      // Update existing customer info
      await db.update('customers', {
        'name': _customerCtrl.text,
        'car_model': _carCtrl.text,
        'number_plate': _plateCtrl.text
      }, where: 'phone = ?', whereArgs: [_phoneCtrl.text]);
    } else {
      // Create new customer
      if (_phoneCtrl.text.isNotEmpty) {
        await db.insert('customers', {
          'name': _customerCtrl.text,
          'phone': _phoneCtrl.text,
          'car_model': _carCtrl.text,
          'number_plate': _plateCtrl.text
        });
      }
    }

    int billId = await db.insert('bills', {
      'customer_name': _customerCtrl.text, 'customer_phone': _phoneCtrl.text, 'car_model': _carCtrl.text, 'number_plate': _plateCtrl.text,
      'grand_total': total, 'paid_amount': paid, 'due_amount': due,
      'date': DateFormat('yyyy-MM-dd').format(_invoiceDate),
      'service_type': _serviceType,
      'next_service_date': DateFormat('yyyy-MM-dd').format(_nextService),
      'worker_name': _selectedWorker ?? '',
      'payment_mode': _paymentMode,
      'notes': _notesCtrl.text,
      'status': _billStatus,
      'worker_status': _workerStatus
    });

    for (var item in _cart) {
      await db.insert('bill_items', {'bill_id': billId, 'item_name': item['name'], 'quantity': item['qty'], 'unit_price': item['unit_price'], 'total': item['total']});
      if(item['id'] != -1) await db.rawUpdate('UPDATE stock SET quantity = quantity - ? WHERE id = ?', [item['qty'], item['id']]);
    }

    _resetForm();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bill Saved Successfully!"), backgroundColor: Colors.green));
  }

  void _resetForm() {
    setState(() {
      _cart.clear(); _customerCtrl.clear(); _phoneCtrl.clear(); _carCtrl.clear(); _plateCtrl.clear(); 
      _paidCtrl.clear(); _discountCtrl.text="0"; _notesCtrl.clear();
      _selectedWorker = null; _serviceType = "Paid"; _paymentMode = "Cash";
    });
    _loadData();
  }

  double get _calculateTotal {
    double sub = _cart.fold(0, (sum, i) => sum + (i['total'] as num));
    double disc = double.tryParse(_discountCtrl.text) ?? 0.0;
    return _serviceType == "Paid" ? (sub - disc) : 0.0;
  }

  @override Widget build(BuildContext context) {
    double total = _calculateTotal;
    double paid = double.tryParse(_paidCtrl.text) ?? 0.0;
    double due = total - paid;

    return Row(children: [
      Expanded(flex: 2, child: Column(children: [
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          Row(children: [
            Expanded(child: Autocomplete<Map<String, dynamic>>(
              optionsBuilder: (v) => _customers.where((c) => c['name'].toString().toLowerCase().contains(v.text.toLowerCase())),
              displayStringForOption: (c) => c['name'],
              onSelected: _selectCustomer,
              fieldViewBuilder: (ctx, ctrl, focus, submit) {
                if(_customerCtrl.text.isEmpty && ctrl.text.isNotEmpty) _customerCtrl.text = ctrl.text;
                return TextField(controller: ctrl, focusNode: focus, decoration: const InputDecoration(labelText: "Search Customer", prefixIcon: Icon(Icons.search)), onChanged: (v) => _customerCtrl.text = v);
              },
            )),
            const SizedBox(width: 15),
            ElevatedButton.icon(onPressed: _resetForm, icon: const Icon(Icons.refresh), label: const Text("Reset"))
          ]),
          const SizedBox(height: 15),
          Row(children: [Expanded(child: TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: "Phone"))), const SizedBox(width: 15), Expanded(child: TextField(controller: _carCtrl, decoration: const InputDecoration(labelText: "Car Model"))), const SizedBox(width: 15), Expanded(child: TextField(controller: _plateCtrl, decoration: const InputDecoration(labelText: "Plate Number")))]),
          const SizedBox(height: 15),
          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(value: _serviceType, decoration: const InputDecoration(labelText: "Service Type"), items: ["Paid", "Free Service", "Warranty"].map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList(), onChanged: (v)=>setState(()=>_serviceType=v!))),
            const SizedBox(width: 15),
            Expanded(child: DropdownButtonFormField<String>(
              value: _selectedWorker, 
              decoration: const InputDecoration(labelText: "Assign Worker"), 
              items: _workers.map((e)=>DropdownMenuItem(value:e['name'].toString(), child: Text(e['name']))).toList(), 
              onChanged: (v)=>setState(()=>_selectedWorker=v)
            )),
            const SizedBox(width: 15),
            Expanded(child: DropdownButtonFormField<String>(value: _workerStatus, decoration: const InputDecoration(labelText: "Worker Status"), items: ["Working", "Not Working", "Completed"].map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList(), onChanged: (v)=>setState(()=>_workerStatus=v!))),
          ]),
          const SizedBox(height: 15),
          Row(children: [
            Expanded(child: InkWell(onTap: ()=>_pickDate(context, true), child: InputDecorator(decoration: const InputDecoration(labelText: "Invoice Date", prefixIcon: Icon(Icons.calendar_today)), child: Text(DateFormat('yyyy-MM-dd').format(_invoiceDate))))),
            const SizedBox(width: 15),
            Expanded(child: DropdownButtonFormField<String>(value: _billStatus, decoration: const InputDecoration(labelText: "Bill Status"), items: ["Pending", "Completed", "Cancelled"].map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList(), onChanged: (v)=>setState(()=>_billStatus=v!))),
          ]),
          const SizedBox(height: 15),
          TextField(controller: _notesCtrl, decoration: const InputDecoration(labelText: "Additional Notes (Warranty / Instructions)", prefixIcon: Icon(Icons.note)))
        ]))),
        Expanded(child: Card(child: ListView.builder(itemCount: _cart.length, itemBuilder: (c,i) => ListTile(
          leading: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.shopping_cart, color: Colors.white)),
          title: Text(_cart[i]['name'], style: const TextStyle(fontWeight: FontWeight.bold)), 
          subtitle: Text("Price: ₹${_cart[i]['unit_price']}"), 
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: (){
              showDialog(context: context, builder: (_)=>AlertDialog(
                title: const Text("Edit Qty"),
                content: TextField(keyboardType: TextInputType.number, onSubmitted: (val){
                  setState(() { _cart[i]['qty'] = int.tryParse(val)??1; _cart[i]['total'] = _cart[i]['qty']*_cart[i]['unit_price']; });
                  Navigator.pop(context);
                }),
              ));
            }),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: ()=>setState(()=>_cart.removeAt(i)))
          ]),
        )))),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]), child: Column(children: [
          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(
              value: _paymentMode, 
              decoration: const InputDecoration(labelText: "Payment Mode"), 
              items: _paymentOptions.map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList(), 
              onChanged: (v)=>setState(()=>_paymentMode=v!)
            )),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: _discountCtrl, decoration: const InputDecoration(labelText: "Discount (₹)"), keyboardType: TextInputType.number, onChanged: (v)=>setState((){}))),
            if(_paymentMode == "Split") ...[
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _paidCtrl, decoration: const InputDecoration(labelText: "Paid Amt"), keyboardType: TextInputType.number, onChanged: (v)=>setState((){}))),
            ],
            const SizedBox(width: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text("Total: ₹${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text("Due: ₹${due.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: due > 0 ? Colors.red : Colors.green)),
            ])
          ]),
          const SizedBox(height: 15),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _saveBill, icon: const Icon(Icons.save), label: const Text("SAVE BILL & PRINT", style: TextStyle(fontSize: 18))))
        ]))
      ])),
      Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(children: [
        const Text("Stock Search", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)), const SizedBox(height: 15),
        Autocomplete<Map<String, dynamic>>(optionsBuilder: (v) => _stock.where((o) => o['name'].toString().toLowerCase().contains(v.text.toLowerCase())), displayStringForOption: (o) => "${o['name']} (₹${o['unit_price']})", onSelected: _addToCart),
      ]))))
    ]);
  }
}

// ==========================================
// 8️⃣ BILL HISTORY
// ==========================================
class BillHistoryPage extends StatefulWidget { const BillHistoryPage({super.key}); @override State<BillHistoryPage> createState() => _BillHistoryPageState(); }
class _BillHistoryPageState extends State<BillHistoryPage> {
  List<Map<String, dynamic>> _allBills = [];
  List<Map<String, dynamic>> _filteredBills = [];
  final _searchCtrl = TextEditingController();
  DateTimeRange? _dateRange;
  Timer? _timer;

  @override void initState() { 
    super.initState(); 
    _load();
    _timer = Timer.periodic(const Duration(seconds: 2), (t) => _load());
  }

  @override void dispose() { _timer?.cancel(); super.dispose(); }

  void _load() async { 
    final db = await DatabaseHelper.instance.database; 
    final res = await db.query('bills', orderBy: "id DESC"); 
    if(mounted) setState(() { _allBills = res; _filter(); }); 
  }
  
  void _filter() {
    String query = _searchCtrl.text.toLowerCase();
    _filteredBills = _allBills.where((b) {
      bool matchName = b['customer_name'].toString().toLowerCase().contains(query) || b['id'].toString().contains(query);
      bool matchDate = true;
      if (_dateRange != null) {
        DateTime billDate = DateFormat('yyyy-MM-dd').parse(b['date']);
        matchDate = billDate.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) && billDate.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }
      return matchName && matchDate;
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null) { setState(() => _dateRange = picked); _filter(); }
  }

  void _openPdfPage(Map<String, dynamic> b) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PdfPreviewPage(bill: b)));
  }

  @override Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.all(8.0), child: Row(children: [
        Expanded(child: TextField(controller: _searchCtrl, onChanged: (v)=>setState(()=>_filter()), decoration: const InputDecoration(labelText: "Search by Customer Name or Bill ID", prefixIcon: Icon(Icons.search)))),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
          child: IconButton(icon: const Icon(Icons.date_range, color: AppColors.primary), onPressed: _pickDateRange, tooltip: "Filter by Date")
        ),
        if(_dateRange != null) IconButton(icon: const Icon(Icons.clear, color: Colors.red), onPressed: (){ setState(()=>_dateRange=null); _filter(); })
      ])),
      Expanded(child: _filteredBills.isEmpty ? _buildEmptyState("No Bills Found") : ListView.builder(itemCount: _filteredBills.length, itemBuilder: (c,i) {
        final b = _filteredBills[i];
        double due = (b['due_amount'] as num?)?.toDouble() ?? 0.0;
        return Card(
          child: ListTile(
          leading: CircleAvatar(backgroundColor: due > 0 ? Colors.redAccent : Colors.green, child: const Icon(Icons.receipt, color: Colors.white)),
          title: Text("${b['customer_name']} (Bill #${b['id']})", style: const TextStyle(fontWeight: FontWeight.bold)), 
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("${b['date']} | ${b['car_model']} | Status: ${b['status']??'Completed'}"),
            if(due > 0) Text("Due: ₹$due", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ]),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text("₹${b['grand_total']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 15),
            IconButton(icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary), tooltip: "View PDF", onPressed: ()=>_openPdfPage(b)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
               final db = await DatabaseHelper.instance.database; await db.delete('bills', where: 'id = ?', whereArgs: [b['id']]); _load();
            })
          ]),
        ));
      }))
    ]);
  }
}

class PdfPreviewPage extends StatelessWidget {
  final Map<String, dynamic> bill;
  const PdfPreviewPage({super.key, required this.bill});

  Future<List<Map<String, dynamic>>> _getItems() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('bill_items', where: 'bill_id = ?', whereArgs: [bill['id']]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invoice View")),
      body: PdfPreview(
        build: (format) async {
          final items = await _getItems();
          final doc = pw.Document();
          doc.addPage(pw.Page(
            build: (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(level: 0, child: pw.Text("SUHAIMSOFT WORKSHOP", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900))),
                pw.SizedBox(height: 20),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text("Bill ID: #${bill['id']}"),
                    pw.Text("Date: ${bill['date']}"),
                    pw.Text("Next Service: ${bill['next_service_date'] ?? 'N/A'}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ]),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                    pw.Text("Customer: ${bill['customer_name']}"),
                    pw.Text("Phone: ${bill['customer_phone']}"),
                    pw.Text("Vehicle: ${bill['car_model']} (${bill['number_plate']})"),
                  ])
                ]),
                pw.Divider(color: PdfColors.blueGrey),
                pw.TableHelper.fromTextArray(
                  headers: ['Item', 'Qty', 'Price', 'Total'],
                  data: items.map((e) => [e['item_name'], e['quantity'].toString(), "₹${e['unit_price']}", "₹${e['total']}"]).toList(),
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
                ),
                pw.SizedBox(height: 20),
                pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text("Grand Total: ₹${bill['grand_total']}", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
                pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text("Paid: ₹${bill['paid_amount']}", style: pw.TextStyle(fontSize: 14))),
                pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text("Due: ₹${bill['due_amount']}", style: pw.TextStyle(fontSize: 14, color: PdfColors.red))),
                if(bill['notes'] != null && bill['notes'].isNotEmpty) ...[
                  pw.SizedBox(height: 10),
                  pw.Text("Notes: ${bill['notes']}", style: const pw.TextStyle(color: PdfColors.grey)),
                ],
                pw.Spacer(),
                pw.Text("Thank you for choosing SuhaimSoft!", style: const pw.TextStyle(color: PdfColors.grey)),
              ]
            )
          ));
          return doc.save();
        },
      ),
    );
  }
}

// ==========================================
// 9️⃣ PAYROLL SYSTEM
// ==========================================
class PayrollPage extends StatefulWidget { const PayrollPage({super.key}); @override State<PayrollPage> createState() => _PayrollPageState(); }
class _PayrollPageState extends State<PayrollPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override void initState() { super.initState(); _tabController = TabController(length: 2, vsync: this); }
  @override Widget build(BuildContext context) {
    return Column(children: [
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
        margin: const EdgeInsets.only(bottom: 10),
        child: TabBar(controller: _tabController, labelColor: AppColors.primary, unselectedLabelColor: Colors.grey, indicatorWeight: 4, tabs: const [Tab(text: "Employees"), Tab(text: "Salary Payments")]),
      ),
      Expanded(child: TabBarView(controller: _tabController, children: const [EmployeeTab(), SalaryPaymentTab()]))
    ]);
  }
}

class EmployeeTab extends StatefulWidget { const EmployeeTab({super.key}); @override State<EmployeeTab> createState() => _EmpTabState(); }
class _EmpTabState extends State<EmployeeTab> {
  List<Map<String, dynamic>> _data = [];
  Timer? _timer;
  @override void initState() { super.initState(); _load(); _timer=Timer.periodic(const Duration(seconds: 2), (t)=>_load()); }
  @override void dispose() { _timer?.cancel(); super.dispose(); }
  void _load() async { final db = await DatabaseHelper.instance.database; final res = await db.query('employees'); if(mounted) setState(() => _data = res); }
  
  void _add() {
    final name=TextEditingController(), role=TextEditingController(), sal=TextEditingController();
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: const Text("Add Employee"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: "Name")), TextField(controller: role, decoration: const InputDecoration(labelText: "Role")), TextField(controller: sal, decoration: const InputDecoration(labelText: "Basic Salary"))]),
      actions: [ElevatedButton(onPressed: () async {
        final db = await DatabaseHelper.instance.database; await db.insert('employees', {'name': name.text, 'role': role.text, 'salary': double.tryParse(sal.text)??0});
        if(mounted){Navigator.pop(context); _load();}
      }, child: const Text("Save"))]
    ));
  }

  void _edit(Map<String, dynamic> item) {
    final name=TextEditingController(text: item['name']), role=TextEditingController(text: item['role']), sal=TextEditingController(text: item['salary'].toString());
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: const Text("Edit Employee"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: "Name")), TextField(controller: role, decoration: const InputDecoration(labelText: "Role")), TextField(controller: sal, decoration: const InputDecoration(labelText: "Basic Salary"))]),
      actions: [ElevatedButton(onPressed: () async {
        final db = await DatabaseHelper.instance.database; await db.update('employees', {'name': name.text, 'role': role.text, 'salary': double.tryParse(sal.text)??0}, where: 'id = ?', whereArgs: [item['id']]);
        if(mounted){Navigator.pop(context); _load();}
      }, child: const Text("Update"))]
    ));
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)), 
      body: _data.isEmpty ? _buildEmptyState("No Employees Added") : ListView.builder(itemCount: _data.length, itemBuilder: (c,i)=>Card(child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(_data[i]['name']), subtitle: Text("${_data[i]['role']} - ₹${_data[i]['salary']}"), 
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () => _edit(_data[i])),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { final db=await DatabaseHelper.instance.database; await db.delete('employees', where: 'id=?', whereArgs: [_data[i]['id']]); _load(); })
        ])
      )))
    );
  }
}

class SalaryPaymentTab extends StatefulWidget { const SalaryPaymentTab({super.key}); @override State<SalaryPaymentTab> createState() => _SalTabState(); }
class _SalTabState extends State<SalaryPaymentTab> {
  List<Map<String, dynamic>> _logs = [];
  @override void initState() { super.initState(); _load(); }
  void _load() async { final db = await DatabaseHelper.instance.database; final res = await db.query('salary_payments', orderBy: "id DESC"); setState(() => _logs = res); }
  void _pay() {
    final name=TextEditingController(), amt=TextEditingController();
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: const Text("Pay Salary"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: "Employee Name")), TextField(controller: amt, decoration: const InputDecoration(labelText: "Amount"))]),
      actions: [ElevatedButton(onPressed: () async {
        final db = await DatabaseHelper.instance.database; await db.insert('salary_payments', {'emp_name': name.text, 'amount': double.tryParse(amt.text)??0, 'date': DateFormat('yyyy-MM-dd').format(DateTime.now()), 'notes': 'Salary Payment'});
        if(mounted){Navigator.pop(context); _load();}
      }, child: const Text("Pay"))]
    ));
  }
  @override Widget build(BuildContext context) {
    return Scaffold(floatingActionButton: FloatingActionButton(onPressed: _pay, child: const Icon(Icons.payment)), body: _logs.isEmpty ? _buildEmptyState("No Payments Made") : ListView.builder(itemCount: _logs.length, itemBuilder: (c,i)=>Card(child: ListTile(leading: const Icon(Icons.monetization_on, color: Colors.green), title: Text(_logs[i]['emp_name']), subtitle: Text(_logs[i]['date']), trailing: Text("₹${_logs[i]['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))))));
  }
}

// ==========================================
// 🔟 MAKING ITEM & GENERIC PAGES
// ==========================================
class MakingItemPage extends StatefulWidget { const MakingItemPage({super.key}); @override State<MakingItemPage> createState() => _MakingItemPageState(); }
class _MakingItemPageState extends State<MakingItemPage> {
  final _prodNameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _partsCtrl = TextEditingController();
  List<Map<String, dynamic>> _madeItems = [];
  @override void initState() { super.initState(); _refresh(); }
  void _refresh() async { final db = await DatabaseHelper.instance.database; final res = await db.query('manufacturing'); setState(() => _madeItems = res); }
  void _save() async {
    if (_prodNameCtrl.text.isEmpty) return;
    final db = await DatabaseHelper.instance.database;
    await db.insert('manufacturing', {'product_name': _prodNameCtrl.text, 'quantity_made': int.tryParse(_qtyCtrl.text) ?? 0, 'notes': _partsCtrl.text, 'date': DateFormat('yyyy-MM-dd').format(DateTime.now())});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Production Recorded!")));
    _prodNameCtrl.clear(); _qtyCtrl.clear(); _partsCtrl.clear(); _refresh();
  }

  void _edit(Map<String, dynamic> item) {
    final prod = TextEditingController(text: item['product_name']);
    final qty = TextEditingController(text: item['quantity_made'].toString());
    final notes = TextEditingController(text: item['notes']);
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: const Text("Edit Production"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: prod, decoration: const InputDecoration(labelText: "Product")), TextField(controller: qty, decoration: const InputDecoration(labelText: "Qty")), TextField(controller: notes, decoration: const InputDecoration(labelText: "Notes"))]),
      actions: [ElevatedButton(onPressed: () async {
        final db = await DatabaseHelper.instance.database; await db.update('manufacturing', {'product_name': prod.text, 'quantity_made': int.tryParse(qty.text)??0, 'notes': notes.text}, where: 'id = ?', whereArgs: [item['id']]);
        if(mounted){Navigator.pop(context); _refresh();}
      }, child: const Text("Update"))]
    ));
  }

  @override Widget build(BuildContext context) {
    return Row(children: [
      Expanded(flex: 1, child: Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [const Text("Production Entry", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 20), TextField(controller: _prodNameCtrl, decoration: const InputDecoration(labelText: "Product Name")), TextField(controller: _qtyCtrl, decoration: const InputDecoration(labelText: "Quantity")), TextField(controller: _partsCtrl, decoration: const InputDecoration(labelText: "Notes")), const SizedBox(height: 20), ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.build), label: const Text("Record"))])))),
      Expanded(flex: 1, child: Card(child: _madeItems.isEmpty ? _buildEmptyState("No History") : ListView.builder(itemCount: _madeItems.length, itemBuilder: (c,i) => ListTile(
        title: Text(_madeItems[i]['product_name']), subtitle: Text("Qty: ${_madeItems[i]['quantity_made']}"), 
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () => _edit(_madeItems[i])),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { final db = await DatabaseHelper.instance.database; await db.delete('manufacturing', where: 'id = ?', whereArgs: [_madeItems[i]['id']]); _refresh(); })
        ])
      ))))
    ]);
  }
}

class StockPage extends StatefulWidget { const StockPage({super.key}); @override State<StockPage> createState() => _StockPageState(); }
class _StockPageState extends State<StockPage> {
  List<Map<String, dynamic>> _data = [];
  final _searchCtrl = TextEditingController();
  @override void initState() { super.initState(); _refresh(); }
  void _refresh() async { final db = await DatabaseHelper.instance.database; final res = await db.query('stock'); setState(() => _data = res); }
  void _add() {
    final code=TextEditingController(), name=TextEditingController(), qty=TextEditingController(), price=TextEditingController();
    showDialog(context: context, builder: (_)=>AlertDialog(title: const Text("Add Stock"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: code, decoration: const InputDecoration(labelText: "Code")), TextField(controller: name, decoration: const InputDecoration(labelText: "Name")), TextField(controller: qty, decoration: const InputDecoration(labelText: "Qty"), keyboardType: TextInputType.number), TextField(controller: price, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number)]), actions: [ElevatedButton(onPressed: () async {
        final db = await DatabaseHelper.instance.database; await db.insert('stock', {'item_code': code.text, 'name': name.text, 'quantity': int.tryParse(qty.text)??0, 'unit_price': double.tryParse(price.text)??0});
        if(mounted){Navigator.pop(context); _refresh();}
      }, child: const Text("Save"))]));
  }
  void _edit(Map<String, dynamic> item) {
    final code=TextEditingController(text: item['item_code']), name=TextEditingController(text: item['name']), qty=TextEditingController(text: item['quantity'].toString()), price=TextEditingController(text: item['unit_price'].toString());
    showDialog(context: context, builder: (_)=>AlertDialog(title: const Text("Edit Stock"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: code, decoration: const InputDecoration(labelText: "Code")), TextField(controller: name, decoration: const InputDecoration(labelText: "Name")), TextField(controller: qty, decoration: const InputDecoration(labelText: "Qty"), keyboardType: TextInputType.number), TextField(controller: price, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number)]), actions: [ElevatedButton(onPressed: () async {
        final db = await DatabaseHelper.instance.database; await db.update('stock', {'item_code': code.text, 'name': name.text, 'quantity': int.tryParse(qty.text)??0, 'unit_price': double.tryParse(price.text)??0}, where: 'id = ?', whereArgs: [item['id']]);
        if(mounted){Navigator.pop(context); _refresh();}
      }, child: const Text("Update"))]));
  }
  @override Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = _data.where((e) => e['name'].toString().toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();
    return Scaffold(floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)), body: Column(children: [Padding(padding: const EdgeInsets.all(8.0), child: TextField(controller: _searchCtrl, onChanged: (v)=>setState((){}), decoration: const InputDecoration(labelText: "Search Stock", prefixIcon: Icon(Icons.search)))), Expanded(child: filtered.isEmpty ? _buildEmptyState("No Stock Found") : ListView.builder(itemCount: filtered.length, itemBuilder: (c,i) { return Card(elevation: 4, color: Colors.white, child: ListTile(title: Text(filtered[i]['name']), subtitle: Text("Qty: ${filtered[i]['quantity']} | Price: ₹${filtered[i]['unit_price']}"), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () => _edit(filtered[i])), IconButton(icon: const Icon(Icons.delete, color: AppColors.danger), onPressed: () async { final db = await DatabaseHelper.instance.database; await db.delete('stock', where: 'id = ?', whereArgs: [filtered[i]['id']]); _refresh(); })]))); }))]));
  }
}

class WarrantiesPage extends StatefulWidget { const WarrantiesPage({super.key}); @override State<WarrantiesPage> createState() => _WarrantiesPageState(); }
class _WarrantiesPageState extends State<WarrantiesPage> {
  List<Map<String, dynamic>> _data = [];
  @override void initState() { super.initState(); _refresh(); }
  void _refresh() async { final db = await DatabaseHelper.instance.database; final res = await db.query('warranties'); setState(() => _data = res); }
  void _add() {
    final cust=TextEditingController(), item=TextEditingController();
    DateTime date = DateTime.now();
    showDialog(context: context, builder: (_)=>StatefulBuilder(builder: (context, setSt) => AlertDialog(title: const Text("Add Warranty"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: cust, decoration: const InputDecoration(labelText: "Customer")), TextField(controller: item, decoration: const InputDecoration(labelText: "Item")), ListTile(title: Text("Expiry: ${DateFormat('yyyy-MM-dd').format(date)}"), trailing: const Icon(Icons.calendar_today), onTap: () async { final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100)); if(picked!=null) setSt(()=>date=picked); })]), actions: [ElevatedButton(onPressed: () async { final db = await DatabaseHelper.instance.database; await db.insert('warranties', {'customer_name': cust.text, 'item_name': item.text, 'expiry_date': DateFormat('yyyy-MM-dd').format(date)}); if(mounted){Navigator.pop(context); _refresh();} }, child: const Text("Save"))])));
  }

  void _edit(Map<String, dynamic> data) {
    final cust=TextEditingController(text: data['customer_name']), item=TextEditingController(text: data['item_name']);
    DateTime date = DateFormat('yyyy-MM-dd').parse(data['expiry_date']);
    showDialog(context: context, builder: (_)=>StatefulBuilder(builder: (context, setSt) => AlertDialog(title: const Text("Edit Warranty"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: cust, decoration: const InputDecoration(labelText: "Customer")), TextField(controller: item, decoration: const InputDecoration(labelText: "Item")), ListTile(title: Text("Expiry: ${DateFormat('yyyy-MM-dd').format(date)}"), trailing: const Icon(Icons.calendar_today), onTap: () async { final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100)); if(picked!=null) setSt(()=>date=picked); })]), actions: [ElevatedButton(onPressed: () async { final db = await DatabaseHelper.instance.database; await db.update('warranties', {'customer_name': cust.text, 'item_name': item.text, 'expiry_date': DateFormat('yyyy-MM-dd').format(date)}, where: 'id = ?', whereArgs: [data['id']]); if(mounted){Navigator.pop(context); _refresh();} }, child: const Text("Update"))])));
  }

  @override Widget build(BuildContext context) { return Scaffold(floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)), body: _data.isEmpty ? _buildEmptyState("No Warranties") : ListView.builder(itemCount: _data.length, itemBuilder: (c,i) => Card(elevation: 4, color: Colors.white, child: ListTile(title: Text(_data[i]['customer_name']), subtitle: Text("${_data[i]['item_name']} (Exp: ${_data[i]['expiry_date']})"), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () => _edit(_data[i])), IconButton(icon: const Icon(Icons.delete, color: AppColors.danger), onPressed: () async { final db = await DatabaseHelper.instance.database; await db.delete('warranties', where: 'id = ?', whereArgs: [_data[i]['id']]); _refresh(); })]))))); }
}

class ExpensesPage extends StatefulWidget { const ExpensesPage({super.key}); @override State<ExpensesPage> createState() => _ExpensesPageState(); }
class _ExpensesPageState extends State<ExpensesPage> {
  List<Map<String, dynamic>> _data = [];
  @override void initState() { super.initState(); _refresh(); }
  void _refresh() async { final db = await DatabaseHelper.instance.database; final res = await db.query('expenses'); setState(() => _data = res); }
  void _add() {
    final title=TextEditingController(), amount=TextEditingController();
    DateTime date = DateTime.now();
    showDialog(context: context, builder: (_)=>StatefulBuilder(builder: (context, setSt) => AlertDialog(title: const Text("Add Expense"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, decoration: const InputDecoration(labelText: "Title")), TextField(controller: amount, decoration: const InputDecoration(labelText: "Amount")), ListTile(title: Text("Date: ${DateFormat('yyyy-MM-dd').format(date)}"), trailing: const Icon(Icons.calendar_today), onTap: () async { final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100)); if(picked!=null) setSt(()=>date=picked); })]), actions: [ElevatedButton(onPressed: () async { final db = await DatabaseHelper.instance.database; await db.insert('expenses', {'title': title.text, 'amount': double.tryParse(amount.text)??0, 'date': DateFormat('yyyy-MM-dd').format(date)}); if(mounted){Navigator.pop(context); _refresh();} }, child: const Text("Save"))])));
  }

  void _edit(Map<String, dynamic> data) {
    final title=TextEditingController(text: data['title']), amount=TextEditingController(text: data['amount'].toString());
    DateTime date = DateFormat('yyyy-MM-dd').parse(data['date']);
    showDialog(context: context, builder: (_)=>StatefulBuilder(builder: (context, setSt) => AlertDialog(title: const Text("Edit Expense"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, decoration: const InputDecoration(labelText: "Title")), TextField(controller: amount, decoration: const InputDecoration(labelText: "Amount")), ListTile(title: Text("Date: ${DateFormat('yyyy-MM-dd').format(date)}"), trailing: const Icon(Icons.calendar_today), onTap: () async { final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100)); if(picked!=null) setSt(()=>date=picked); })]), actions: [ElevatedButton(onPressed: () async { final db = await DatabaseHelper.instance.database; await db.update('expenses', {'title': title.text, 'amount': double.tryParse(amount.text)??0, 'date': DateFormat('yyyy-MM-dd').format(date)}, where: 'id = ?', whereArgs: [data['id']]); if(mounted){Navigator.pop(context); _refresh();} }, child: const Text("Update"))])));
  }

  @override Widget build(BuildContext context) { return Scaffold(floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)), body: _data.isEmpty ? _buildEmptyState("No Expenses") : ListView.builder(itemCount: _data.length, itemBuilder: (c,i) => Card(elevation: 4, color: Colors.white, child: ListTile(title: Text(_data[i]['title']), subtitle: Text("${_data[i]['date']} | ₹${_data[i]['amount']}"), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () => _edit(_data[i])), IconButton(icon: const Icon(Icons.delete, color: AppColors.danger), onPressed: () async { final db = await DatabaseHelper.instance.database; await db.delete('expenses', where: 'id = ?', whereArgs: [_data[i]['id']]); _refresh(); })]))))); }
}

class CustomersPage extends StatefulWidget { const CustomersPage({super.key}); @override State<CustomersPage> createState() => _CustPageState(); }
class _CustPageState extends State<CustomersPage> {
  List<Map<String, dynamic>> _data = [];
  @override void initState() { super.initState(); _refresh(); }
  void _refresh() async { final db = await DatabaseHelper.instance.database; final res = await db.query('customers'); setState(() => _data = res); }
  void _edit(Map<String, dynamic> item) {
    final name=TextEditingController(text: item['name']), phone=TextEditingController(text: item['phone']), car=TextEditingController(text: item['car_model']), plate=TextEditingController(text: item['number_plate']);
    showDialog(context: context, builder: (_)=>AlertDialog(title: const Text("Edit Customer"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: "Name")), TextField(controller: phone, decoration: const InputDecoration(labelText: "Phone")), TextField(controller: car, decoration: const InputDecoration(labelText: "Car")), TextField(controller: plate, decoration: const InputDecoration(labelText: "Plate"))]), actions: [ElevatedButton(onPressed: () async { final db = await DatabaseHelper.instance.database; await db.update('customers', {'name': name.text, 'phone': phone.text, 'car_model': car.text, 'number_plate': plate.text}, where: 'id=?', whereArgs: [item['id']]); if(mounted){Navigator.pop(context); _refresh();} }, child: const Text("Update"))]));
  }
  @override Widget build(BuildContext context) { return _data.isEmpty ? _buildEmptyState("No Customers Found") : ListView.builder(itemCount: _data.length, itemBuilder: (c,i) => Card(elevation: 4, color: Colors.white, child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(_data[i]['name']), subtitle: Text("${_data[i]['phone']} | ${_data[i]['car_model']}"), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () => _edit(_data[i])), IconButton(icon: const Icon(Icons.delete, color: AppColors.danger), onPressed: () async { final db = await DatabaseHelper.instance.database; await db.delete('customers', where: 'id = ?', whereArgs: [_data[i]['id']]); _refresh(); })])))); }
}

// ==========================================
// 1️⃣2️⃣ SETTINGS & LOGIN
// ==========================================
class SettingsPage extends StatelessWidget { const SettingsPage({super.key}); @override Widget build(BuildContext context) {
  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Card(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.settings, size: 50, color: AppColors.primary),
      const SizedBox(height: 20),
      ElevatedButton.icon(onPressed: () async { await DatabaseHelper.instance.backupDatabase(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Backup Process Started..."))); }, icon: const Icon(Icons.upload), label: const Text("Backup Database")),
      const SizedBox(height: 20),
      ElevatedButton.icon(onPressed: () async { await DatabaseHelper.instance.restoreDatabase(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Restore Process Started..."))); }, icon: const Icon(Icons.download), label: const Text("Restore Database")),
    ])))
  ]));
}}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override Widget build(BuildContext context) {
    final u=TextEditingController(), p=TextEditingController();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.loginGradient),
        child: Center(
          child: Card(
            elevation: 20,
            shadowColor: Colors.black45,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(40),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.lock_outline, size: 60, color: AppColors.primary),
                const SizedBox(height: 20),
                const Text("SUHAIMSOFT ERP", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.5)),
                const SizedBox(height: 30),
                TextField(controller: u, decoration: const InputDecoration(labelText: "Username", prefixIcon: Icon(Icons.person))),
                const SizedBox(height: 20),
                TextField(controller: p, obscureText: true, decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock))),
                const SizedBox(height: 40),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  style: ElevatedButton.styleFrom(elevation: 10, shadowColor: Colors.blueAccent),
                  onPressed: (){ if(u.text=='admin' && p.text=='admin123') Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const DashboardLayout())); }, 
                  child: const Text("LOGIN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2))
                ))
              ]),
            ),
          ),
        ),
      )
    );
  }
}