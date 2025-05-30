import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// --- Data Models ---
class MedicineBatch {
  final String medicineId;
  final String batchId;
  final String medicineName;
  final String unit; // e.g., "strip of 10s", "bottle 100ml"
  int stockQuantity;
  final double salePrice; // Price per unit
  final double gstPercent; // e.g., 0.05 for 5%
  final DateTime expiryDate;
  final String? manufacturer;

  MedicineBatch({
    required this.medicineId,
    required this.batchId,
    required this.medicineName,
    required this.unit,
    required this.stockQuantity,
    required this.salePrice,
    required this.gstPercent,
    required this.expiryDate,
    this.manufacturer,
  });
}

class BillItem {
  final MedicineBatch medicineBatch;
  final TextEditingController quantityController;
  double lineItemTotalWithGst; // Calculated

  BillItem({
    required this.medicineBatch,
    int quantity = 1,
    this.lineItemTotalWithGst = 0.0,
  }) : quantityController = TextEditingController(text: quantity.toString());

  void dispose() {
    quantityController.dispose();
  }
}

// --- Main Screen Widget ---
class PharmacyPosScreen extends StatefulWidget {
  const PharmacyPosScreen({Key? key}) : super(key: key);

  @override
  _PharmacyPosScreenState createState() => _PharmacyPosScreenState();
}

class _PharmacyPosScreenState extends State<PharmacyPosScreen> {
  final _formKey = GlobalKey<FormState>(); // For potential overall form validation

  // Patient/Customer Context
  bool _isWalkInCustomer = true;
  String _patientName = "Walk-in Customer"; // Placeholder
  String _patientId = "N/A"; // Placeholder

  // Medicine Search
  final _searchController = TextEditingController();
  List<MedicineBatch> _searchResults = [];
  final List<MedicineBatch> _allMedicineBatches = _getPlaceholderMedicineBatches();

  // Current Bill
  final List<BillItem> _billItems = [];

  // Summary Totals
  double _subTotal = 0.0;
  double _totalCgst = 0.0;
  double _totalSgst = 0.0;
  double _grandTotal = 0.0;

  final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  final DateFormat _dateFormatter = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterMedicines);
    _filterMedicines(); // Initial filter (shows all available if search is empty)
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (var item in _billItems) {
      item.dispose();
    }
    super.dispose();
  }

  static List<MedicineBatch> _getPlaceholderMedicineBatches() {
    return [
      MedicineBatch(medicineId: "MED001", batchId: "B001A", medicineName: "Paracetamol 500mg Tabs", unit: "Strip of 10", stockQuantity: 50, salePrice: 20.0, gstPercent: 0.12, expiryDate: DateTime(2025, 12, 31), manufacturer: "Cipla"),
      MedicineBatch(medicineId: "MED002", batchId: "B002B", medicineName: "Amoxicillin 250mg Syrup", unit: "Bottle 60ml", stockQuantity: 30, salePrice: 45.0, gstPercent: 0.12, expiryDate: DateTime(2024, 10, 30), manufacturer: "GSK"),
      MedicineBatch(medicineId: "MED003", batchId: "B003C", medicineName: "Antacid Gel", unit: "Bottle 170ml", stockQuantity: 75, salePrice: 80.0, gstPercent: 0.18, expiryDate: DateTime(2025, 8, 31), manufacturer: "Abbott"),
      MedicineBatch(medicineId: "MED004", batchId: "B004D", medicineName: "Vitamin C 500mg Chewable", unit: "Bottle of 30", stockQuantity: 0, salePrice: 120.0, gstPercent: 0.05, expiryDate: DateTime(2024, 6, 30), manufacturer: "Sun Pharma"), // Expired/Out of stock
      MedicineBatch(medicineId: "MED005", batchId: "B005E", medicineName: "Pain Relief Spray", unit: "Can 50g", stockQuantity: 40, salePrice: 150.0, gstPercent: 0.18, expiryDate: DateTime(2026, 3, 31)),
      MedicineBatch(medicineId: "MED001", batchId: "B001F", medicineName: "Paracetamol 500mg Tabs", unit: "Strip of 10", stockQuantity: 100, salePrice: 22.0, gstPercent: 0.12, expiryDate: DateTime(2026, 5, 31), manufacturer: "Mankind"), // Different batch of Paracetamol
    ];
  }

  void _filterMedicines() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchResults = _allMedicineBatches.where((batch) {
        return batch.stockQuantity > 0 && // Only show if in stock
               (batch.medicineName.toLowerCase().contains(query) || 
                (batch.manufacturer?.toLowerCase().contains(query) ?? false));
      }).toList();
    });
  }

  void _addMedicineToBill(MedicineBatch batch) {
    setState(() {
      // Check if same medicine batch already exists, if so, could increment quantity
      // For simplicity, this version adds as a new line item.
      final newItem = BillItem(medicineBatch: batch, quantity: 1);
      newItem.quantityController.addListener(() => _onBillItemQuantityChanged(newItem));
      _billItems.add(newItem);
    });
    _calculateTotals();
     _searchController.clear(); // Clear search after adding
  }

  void _removeMedicineFromBill(int index) {
    setState(() {
      _billItems[index].dispose();
      _billItems.removeAt(index);
    });
    _calculateTotals();
  }

  void _onBillItemQuantityChanged(BillItem item) {
     // Basic validation against stock (can be enhanced)
    int currentQty = int.tryParse(item.quantityController.text) ?? 1;
    if (currentQty > item.medicineBatch.stockQuantity) {
      currentQty = item.medicineBatch.stockQuantity;
      item.quantityController.text = currentQty.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantity cannot exceed available stock: ${item.medicineBatch.stockQuantity}')),
      );
    }
     if (currentQty <= 0) { // Prevent zero or negative quantity
      currentQty = 1;
      item.quantityController.text = currentQty.toString();
    }
    _calculateTotals();
  }

  void _calculateTotals() {
    double subTotal = 0.0;
    double totalCgst = 0.0;
    double totalSgst = 0.0;

    for (var item in _billItems) {
      int quantity = int.tryParse(item.quantityController.text) ?? 0;
      double salePrice = item.medicineBatch.salePrice;
      double itemSubTotal = quantity * salePrice;

      subTotal += itemSubTotal;

      double itemGstAmount = itemSubTotal * item.medicineBatch.gstPercent;
      totalCgst += itemGstAmount / 2; // Assuming CGST = SGST
      totalSgst += itemGstAmount / 2;

      item.lineItemTotalWithGst = itemSubTotal + itemGstAmount;
    }

    setState(() {
      _subTotal = subTotal;
      _totalCgst = totalCgst;
      _totalSgst = totalSgst;
      _grandTotal = subTotal + totalCgst + totalSgst;
    });
  }

  void _finalizeBill() {
    if (_billItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot finalize an empty bill.')),
      );
      return;
    }
    // Conceptual: print data or send to backend
    print("--- Finalizing Bill ---");
    print("Customer: $_patientName (ID: $_patientId)");
    print("--- Items ---");
    for (var item in _billItems) {
      print(
          "Medicine: ${item.medicineBatch.medicineName}, Batch: ${item.medicineBatch.batchId}, "
          "Qty: ${item.quantityController.text}, Price: ${_currencyFormatter.format(item.medicineBatch.salePrice)}, "
          "GST: ${(item.medicineBatch.gstPercent * 100).toStringAsFixed(0)}%, "
          "Total: ${_currencyFormatter.format(item.lineItemTotalWithGst)}");
    }
    print("--- Summary ---");
    print("Sub-Total: ${_currencyFormatter.format(_subTotal)}");
    print("Total CGST: ${_currencyFormatter.format(_totalCgst)}");
    print("Total SGST: ${_currencyFormatter.format(_totalSgst)}");
    print("Grand Total: ${_currencyFormatter.format(_grandTotal)}");
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bill finalized and data logged to console.')),
    );
     // Here you would typically proceed to a payment screen or process payment
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Sales (POS)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildCustomerSelection(),
              const SizedBox(height: 16),
              _buildMedicineSearch(),
              if (_searchResults.isNotEmpty && _searchController.text.isNotEmpty)
                _buildSearchResultsList(),
              const SizedBox(height: 16),
              const Divider(thickness: 1),
              _buildCurrentBillSection(),
              const Divider(thickness: 1),
              _buildBillingSummary(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSelection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(_patientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Text(_isWalkInCustomer ? "Walk-in" : "Registered"),
                Switch(
                  value: !_isWalkInCustomer, // Switch is ON for Registered Patient
                  onChanged: (value) {
                    setState(() {
                      _isWalkInCustomer = !value;
                      if (_isWalkInCustomer) {
                        _patientName = "Walk-in Customer";
                        _patientId = "N/A";
                      } else {
                        // Placeholder: In a real app, you'd open a patient search dialog
                        _patientName = "Rajesh Kumar"; // Example registered patient
                        _patientId = "PAT001";
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search Medicine by Name/Manufacturer',
          hintText: 'Type to search...',
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSearchResultsList() {
    return SizedBox(
      height: 200, // Constrain height of search results
      child: Card(
        elevation: 2,
        child: ListView.builder(
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final batch = _searchResults[index];
            return ListTile(
              title: Text(batch.medicineName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Batch: ${batch.batchId} | Mfr: ${batch.manufacturer ?? 'N/A'}"),
                  Text("Unit: ${batch.unit} | Price: ${_currencyFormatter.format(batch.salePrice)}"),
                  Text("Stock: ${batch.stockQuantity} | Expiry: ${_dateFormatter.format(batch.expiryDate)}"),
                ],
              ),
              trailing: ElevatedButton(
                child: const Text("Add"),
                onPressed: () => _addMedicineToBill(batch),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentBillSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text("Current Bill Items (${_billItems.length})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        if (_billItems.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("No items added to bill yet."))),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _billItems.length,
          itemBuilder: (context, index) {
            final item = _billItems[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.medicineBatch.medicineName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeMedicineFromBill(index),
                        ),
                      ],
                    ),
                    Text("Batch: ${item.medicineBatch.batchId} | Exp: ${_dateFormatter.format(item.medicineBatch.expiryDate)}"),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: item.quantityController,
                            decoration: InputDecoration(
                              labelText: "Qty (${item.medicineBatch.unit})",
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Req';
                              final qty = int.tryParse(value);
                              if (qty == null || qty <= 0) return 'Invalid';
                              if (qty > item.medicineBatch.stockQuantity) return 'Max: ${item.medicineBatch.stockQuantity}';
                              return null;
                            },
                            // onChanged already handled by listener in _addMedicineToBill
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Price/Unit',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8)
                            ),
                            child: Text(_currencyFormatter.format(item.medicineBatch.salePrice)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                           child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Line Total',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8)
                            ),
                            child: Text(
                              _currencyFormatter.format(item.lineItemTotalWithGst),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                     Text("GST: ${(item.medicineBatch.gstPercent * 100).toStringAsFixed(0)}%", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBillingSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Bill Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildSummaryRow("Sub-Total:", _currencyFormatter.format(_subTotal)),
              _buildSummaryRow("Total CGST:", _currencyFormatter.format(_totalCgst)),
              _buildSummaryRow("Total SGST:", _currencyFormatter.format(_totalSgst)),
              const Divider(height: 10, thickness: 1),
              _buildSummaryRow("Grand Total:", _currencyFormatter.format(_grandTotal), isGrandTotal: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isGrandTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isGrandTotal ? 17 : 15, fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isGrandTotal ? 17 : 15, fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.pause_circle_outline),
            label: const Text("Hold Bill"),
            onPressed: () {
              // Conceptual: Save current bill state to resume later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bill Hold - Conceptual')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.payment),
            label: const Text("Finalize & Pay"),
            onPressed: _finalizeBill,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
          ),
        ],
      ),
    );
  }
}

// Example Usage:
// void main() {
//   runApp(MaterialApp(
//     title: 'Pharmacy POS Demo',
//     theme: ThemeData(
//       primarySwatch: Colors.teal,
//       visualDensity: VisualDensity.adaptivePlatformDensity,
//       inputDecorationTheme: const InputDecorationTheme(
//         border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
//         contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
//       ),
//     ),
//     home: const PharmacyPosScreen(),
//   ));
// }
```
