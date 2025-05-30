import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // For unique key generation

// Data class for a single billable item
class BillableItem {
  final String uniqueKey; // To help with ListView.builder keying if needed
  TextEditingController descriptionController;
  TextEditingController quantityController;
  TextEditingController basePriceController;
  double gstRate; // e.g., 0.18 for 18%
  double itemTotalWithGst;

  BillableItem({
    required this.uniqueKey,
    String description = '',
    int quantity = 1,
    double basePrice = 0.0,
    this.gstRate = 0.18, // Default to 18% GST
    this.itemTotalWithGst = 0.0,
  })  : descriptionController = TextEditingController(text: description),
        quantityController = TextEditingController(text: quantity.toString()),
        basePriceController = TextEditingController(text: basePrice.toStringAsFixed(2));

  // Dispose method to clean up controllers
  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    basePriceController.dispose();
  }
}

class OpdInvoiceScreen extends StatefulWidget {
  final String patientId; // Placeholder
  final String patientName; // Placeholder
  final String patientContact; // Placeholder

  const OpdInvoiceScreen({
    Key? key,
    this.patientId = "PATXYZ123",
    this.patientName = "Ravi Kumar",
    this.patientContact = "9876543210",
  }) : super(key: key);

  @override
  _OpdInvoiceScreenState createState() => _OpdInvoiceScreenState();
}

class _OpdInvoiceScreenState extends State<OpdInvoiceScreen> {
  final _formKey = GlobalKey<FormState>(); // For potential future form validation

  // Clinic Details (Placeholders)
  final String _clinicName = "AyurWellness Clinic";
  final String _clinicAddress = "123, Green Valley, Wellness City, ST 543210";
  final String _clinicGstin = "29ABCDE1234F1Z5";

  // Invoice Details
  late String _invoiceId;
  late String _invoiceDate;

  // Billable Items
  final List<BillableItem> _billableItems = [];
  final List<double> _gstRateOptions = [0.0, 0.05, 0.12, 0.18, 0.28];

  // Summary Totals
  double _subTotal = 0.0;
  double _totalCgst = 0.0;
  double _totalSgst = 0.0;
  double _grandTotal = 0.0;

  final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    _generateInvoiceIdAndDate();
    // Add one default item to start with
    if (_billableItems.isEmpty) {
      _addNewBillableItem();
    }
    _calculateTotals();
  }

  void _generateInvoiceIdAndDate() {
    final now = DateTime.now();
    _invoiceId = "INV-${DateFormat('yyyyMMdd-HHmmss').format(now)}";
    _invoiceDate = DateFormat('dd-MM-yyyy').format(now);
  }

  void _addNewBillableItem() {
    setState(() {
      final newItem = BillableItem(uniqueKey: UniqueKey().toString());
      _billableItems.add(newItem);
      // Attach listeners to new item's controllers
      newItem.quantityController.addListener(_onItemChanged);
      newItem.basePriceController.addListener(_onItemChanged);
      // No need to listen to descriptionController for calculation
    });
    _calculateTotals(); // Recalculate when a new item is added
  }

  void _removeBillableItem(int index) {
    setState(() {
      // Dispose controllers before removing
      _billableItems[index].dispose();
      _billableItems.removeAt(index);
    });
    _calculateTotals();
  }

  void _onItemChanged() {
    // This is a general listener, specific updates handled by _calculateTotals
    // Debouncing could be added here if performance becomes an issue with many items
    _calculateTotals();
  }
  
  void _onGstRateChanged(int index, double? newRate) {
    if (newRate != null) {
      setState(() {
        _billableItems[index].gstRate = newRate;
      });
      _calculateTotals();
    }
  }


  void _calculateTotals() {
    double subTotal = 0.0;
    double totalCgst = 0.0;
    double totalSgst = 0.0;

    for (var item in _billableItems) {
      int quantity = int.tryParse(item.quantityController.text) ?? 0;
      double basePrice = double.tryParse(item.basePriceController.text) ?? 0.0;
      double itemSubTotal = quantity * basePrice;
      
      subTotal += itemSubTotal;
      
      double itemGstAmount = itemSubTotal * item.gstRate;
      totalCgst += itemGstAmount / 2; // Assuming CGST = SGST
      totalSgst += itemGstAmount / 2;

      item.itemTotalWithGst = itemSubTotal + itemGstAmount;
    }

    setState(() {
      _subTotal = subTotal;
      _totalCgst = totalCgst;
      _totalSgst = totalSgst;
      _grandTotal = subTotal + totalCgst + totalSgst;
    });
  }

  @override
  void dispose() {
    for (var item in _billableItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _saveInvoice() {
    // Conceptual: print data or send to backend
    print("--- Saving Invoice ---");
    print("Invoice ID: $_invoiceId, Date: $_invoiceDate");
    print("Patient: ${widget.patientName} (ID: ${widget.patientId})");
    print("--- Items ---");
    for (var item in _billableItems) {
      print(
          "Desc: ${item.descriptionController.text}, Qty: ${item.quantityController.text}, "
          "Price: ${item.basePriceController.text}, GST: ${(item.gstRate * 100).toStringAsFixed(0)}%, "
          "Total: ${_currencyFormatter.format(item.itemTotalWithGst)}");
    }
    print("--- Summary ---");
    print("Sub-Total: ${_currencyFormatter.format(_subTotal)}");
    print("Total CGST: ${_currencyFormatter.format(_totalCgst)}");
    print("Total SGST: ${_currencyFormatter.format(_totalSgst)}");
    print("Grand Total: ${_currencyFormatter.format(_grandTotal)}");
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice data logged to console.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OPD Invoice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form( // Added Form for potential future use
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildClinicHeader(),
              const Divider(height: 20, thickness: 1),
              _buildPatientDetails(),
              const Divider(height: 20, thickness: 1),
              _buildBillableItemsSection(),
              const Divider(height: 20, thickness: 1),
              _buildSummarySection(),
              const SizedBox(height: 24.0),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClinicHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_clinicName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(_clinicAddress),
        Text("GSTIN: $_clinicGstin"),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Invoice ID: $_invoiceId", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Date: $_invoiceDate", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildPatientDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Bill To:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(widget.patientName),
        Text("Patient ID: ${widget.patientId}"),
        Text("Contact: ${widget.patientContact}"),
      ],
    );
  }

  Widget _buildBillableItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Items:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_billableItems.isEmpty)
          const Center(child: Text("No items added yet.")),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _billableItems.length,
          itemBuilder: (context, index) {
            return _buildBillableItemRow(_billableItems[index], index);
          },
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add Item"),
            onPressed: _addNewBillableItem,
          ),
        ),
      ],
    );
  }

  Widget _buildBillableItemRow(BillableItem item, int index) {
    // Recalculate item total whenever this row rebuilds due to state changes
    // This is important if setState is called without _calculateTotals for some reason
    // though _calculateTotals should be comprehensive.
    int quantity = int.tryParse(item.quantityController.text) ?? 0;
    double basePrice = double.tryParse(item.basePriceController.text) ?? 0.0;
    item.itemTotalWithGst = (quantity * basePrice) * (1 + item.gstRate);


    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: item.descriptionController,
              decoration: const InputDecoration(labelText: "Description", hintText: "e.g., Consultation Fee"),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: item.quantityController,
                    decoration: const InputDecoration(labelText: "Quantity"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _onItemChanged(), // Trigger recalculation
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Req';
                      if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: item.basePriceController,
                    decoration: const InputDecoration(labelText: "Base Price (₹)", prefixText: "₹"),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _onItemChanged(), // Trigger recalculation
                     validator: (value) {
                      if (value == null || value.isEmpty) return 'Req';
                      if (double.tryParse(value) == null || double.parse(value) < 0) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
             Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<double>(
                    value: item.gstRate,
                    decoration: const InputDecoration(labelText: "GST Rate"),
                    items: _gstRateOptions.map((rate) {
                      return DropdownMenuItem<double>(
                        value: rate,
                        child: Text("${(rate * 100).toStringAsFixed(0)}%"),
                      );
                    }).toList(),
                    onChanged: (newRate) => _onGstRateChanged(index, newRate),
                  ),
                ),
                const SizedBox(width: 8),
                 Expanded(
                  flex: 2,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Item Total',
                      border: InputBorder.none, // Or OutlineInputBorder()
                      contentPadding: EdgeInsets.symmetric(vertical: 8)
                    ),
                    child: Text(
                      _currencyFormatter.format(item.itemTotalWithGst),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _removeBillableItem(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildSummaryRow("Sub-Total:", _currencyFormatter.format(_subTotal)),
          _buildSummaryRow("Total CGST:", _currencyFormatter.format(_totalCgst)),
          _buildSummaryRow("Total SGST:", _currencyFormatter.format(_totalSgst)),
          const Divider(),
          _buildSummaryRow("Grand Total:", _currencyFormatter.format(_grandTotal), isGrandTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isGrandTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isGrandTotal ? 18 : 16, fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isGrandTotal ? 18 : 16, fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _saveInvoice,
          child: const Text("Save Invoice"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        ),
        ElevatedButton(
          onPressed: () {
            _saveInvoice(); // First save (log)
            // Conceptual: Then proceed to payment
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Proceeding to Payment... (Conceptual)')),
            );
          },
          child: const Text("Generate & Proceed to Pay"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }
}

// Example Usage:
// void main() {
//   runApp(MaterialApp(
//     title: 'OPD Invoice Demo',
//     theme: ThemeData(
//       primarySwatch: Colors.teal,
//       visualDensity: VisualDensity.adaptivePlatformDensity,
//        inputDecorationTheme: const InputDecorationTheme(
//         border: OutlineInputBorder(),
//         contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
//       ),
//     ),
//     home: const OpdInvoiceScreen(
//       patientId: "PAT2024001",
//       patientName: "Suresh Mehta",
//       patientContact: "9123456780",
//     ),
//   ));
// }
```
