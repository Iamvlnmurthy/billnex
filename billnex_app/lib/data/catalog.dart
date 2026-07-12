import 'package:flutter/material.dart';

/// Priority per the PRD (Must / Should / Could).
enum Priority { must, should, could }

extension PriorityLabel on Priority {
  String get label => switch (this) {
        Priority.must => 'Must',
        Priority.should => 'Should',
        Priority.could => 'Could',
      };
}

/// A single toggleable capability (maps to one or more PRD Feature IDs).
class Capability {
  final String key;
  final String name;
  final String category; // category key
  final Priority priority;
  final String desc;
  final bool pro; // requires a higher plan unless the preset includes it
  const Capability({
    required this.key,
    required this.name,
    required this.category,
    required this.priority,
    required this.desc,
    this.pro = false,
  });
}

class FeatureCategory {
  final String key;
  final String name;
  final IconData icon;
  const FeatureCategory(this.key, this.name, this.icon);
}

class BusinessType {
  final String key;
  final String name;
  final String edition;
  final IconData icon;
  final String tag;

  /// Capability keys auto-enabled by this preset
  /// (mirrors the 03_Business_Feature_Matrix workbook sheet).
  final List<String> on;
  const BusinessType({
    required this.key,
    required this.name,
    required this.edition,
    required this.icon,
    required this.tag,
    required this.on,
  });
}

class Product {
  final String name;
  final String unit;
  final double price;
  const Product(this.name, this.unit, this.price);
}

enum PaperSize { a4, mm80, mm58 }

extension PaperLabel on PaperSize {
  String get label => switch (this) {
        PaperSize.a4 => 'A4',
        PaperSize.mm80 => '80mm',
        PaperSize.mm58 => '58mm',
      };
}

class InvoiceTemplate {
  final String id;
  final String name;
  final PaperSize size;
  final String desc;
  const InvoiceTemplate(this.id, this.name, this.size, this.desc);
}

// ---------------------------------------------------------------------------
// CATEGORIES
// ---------------------------------------------------------------------------
const List<FeatureCategory> kCategories = [
  FeatureCategory('billing', 'Billing & Counter', Icons.point_of_sale_outlined),
  FeatureCategory('tax', 'GST, Tax & Compliance', Icons.receipt_long_outlined),
  FeatureCategory('inventory', 'Inventory & Stock', Icons.inventory_2_outlined),
  FeatureCategory('customers', 'Customers & Credit', Icons.groups_outlined),
  FeatureCategory('ops', 'Operations & Growth', Icons.hub_outlined),
];

// ---------------------------------------------------------------------------
// CAPABILITIES
// ---------------------------------------------------------------------------
const List<Capability> kCapabilities = [
  // Billing
  Capability(key: 'fastPOS', name: 'Fast POS & counter billing', category: 'billing', priority: Priority.must, desc: 'One-screen scan, cart, pay, print'),
  Capability(key: 'barcodeScan', name: 'Barcode / camera scan', category: 'billing', priority: Priority.must, desc: 'Scanner + Android camera fallback'),
  Capability(key: 'weightScale', name: 'Weight / scale billing', category: 'billing', priority: Priority.should, desc: 'Decimal kg/g/litre + PLU'),
  Capability(key: 'multiUnit', name: 'Multi-unit & loose sale', category: 'billing', priority: Priority.should, desc: 'Buy pack, sell piece / cut-length'),
  Capability(key: 'quotation', name: 'Quotation & estimate', category: 'billing', priority: Priority.should, desc: 'Send, expire, convert to sale'),
  Capability(key: 'kot', name: 'KOT / table & kitchen', category: 'billing', priority: Priority.could, desc: 'Floor plan, KOT, kitchen routing', pro: true),
  // Tax
  Capability(key: 'gstInvoice', name: 'GST tax invoice', category: 'tax', priority: Priority.must, desc: 'CGST/SGST/IGST, HSN, unique numbering'),
  Capability(key: 'billOfSupply', name: 'Bill of supply / composition', category: 'tax', priority: Priority.should, desc: 'Non-tax series for exempt sellers'),
  Capability(key: 'consent', name: 'Customer consent & privacy', category: 'tax', priority: Priority.must, desc: 'Opt-in/out, purpose, timestamp'),
  Capability(key: 'eInvoice', name: 'E-invoice (IRN) & e-way bill', category: 'tax', priority: Priority.could, desc: 'IRP payload, signed QR', pro: true),
  // Inventory
  Capability(key: 'batchExpiry', name: 'Batch & expiry tracking', category: 'inventory', priority: Priority.should, desc: 'FEFO, near-expiry action list'),
  Capability(key: 'serialImei', name: 'Serial / IMEI control', category: 'inventory', priority: Priority.should, desc: 'Unique unit at sale/return/service'),
  Capability(key: 'variantMatrix', name: 'Variant matrix', category: 'inventory', priority: Priority.should, desc: 'Size-colour-style child SKUs'),
  Capability(key: 'label', name: 'Label / tag printing', category: 'inventory', priority: Priority.should, desc: 'Barcode, shelf, garment, MRP labels'),
  Capability(key: 'production', name: 'BOM / production', category: 'inventory', priority: Priority.could, desc: 'Recipe, work order, material issue', pro: true),
  // Customers
  Capability(key: 'creditLedger', name: 'Credit / khata ledger', category: 'customers', priority: Priority.must, desc: 'Due dates, limits, collection, ageing'),
  Capability(key: 'loyalty', name: 'Loyalty & promotions', category: 'customers', priority: Priority.could, desc: 'Points, coupons, combos'),
  Capability(key: 'membership', name: 'Membership & packages', category: 'customers', priority: Priority.should, desc: 'Plans, sessions, renewals'),
  Capability(key: 'appointments', name: 'Appointments & calendar', category: 'customers', priority: Priority.should, desc: 'Staff, chair/room, no-show policy'),
  // Ops
  Capability(key: 'jobCard', name: 'Job card / service workflow', category: 'ops', priority: Priority.should, desc: 'Intake, estimate, status, delivery'),
  Capability(key: 'rental', name: 'Rental assets & deposits', category: 'ops', priority: Priority.should, desc: 'Booking, availability, late fee'),
  Capability(key: 'delivery', name: 'Orders & delivery', category: 'ops', priority: Priority.should, desc: 'Status, proof, COD settlement'),
  Capability(key: 'wholesale', name: 'Wholesale / route sales', category: 'ops', priority: Priority.should, desc: 'Price levels, salesman route, schemes'),
  Capability(key: 'multiStore', name: 'Multi-store & transfers', category: 'ops', priority: Priority.could, desc: 'Branch stock, consolidated dashboard', pro: true),
  Capability(key: 'recurring', name: 'Recurring / subscription billing', category: 'ops', priority: Priority.could, desc: 'Instalments, AMC, auto-invoice', pro: true),
];

Capability capabilityByKey(String key) => kCapabilities.firstWhere((c) => c.key == key);

// ---------------------------------------------------------------------------
// BUSINESS TYPES  (preset -> auto-enabled capabilities)
// ---------------------------------------------------------------------------
const List<BusinessType> kBusinessTypes = [
  BusinessType(key: 'kirana', name: 'Kirana / General Store', edition: 'Retail Standard', icon: Icons.storefront_outlined, tag: 'Fast counter B2C + khata credit',
      on: ['fastPOS', 'barcodeScan', 'weightScale', 'multiUnit', 'gstInvoice', 'consent', 'creditLedger', 'batchExpiry', 'label', 'delivery']),
  BusinessType(key: 'supermarket', name: 'Supermarket / Mini-Mart', edition: 'Retail Pro', icon: Icons.shopping_cart_outlined, tag: 'High-volume multi-counter POS',
      on: ['fastPOS', 'barcodeScan', 'weightScale', 'multiUnit', 'gstInvoice', 'consent', 'variantMatrix', 'label', 'loyalty', 'delivery', 'multiStore']),
  BusinessType(key: 'pharmacy', name: 'Pharmacy / Medical', edition: 'Vertical Pro', icon: Icons.local_pharmacy_outlined, tag: 'Batch, expiry, MRP, rack',
      on: ['fastPOS', 'barcodeScan', 'gstInvoice', 'consent', 'creditLedger', 'batchExpiry', 'label', 'multiUnit']),
  BusinessType(key: 'restaurant', name: 'Restaurant / QSR', edition: 'Vertical Pro', icon: Icons.restaurant_outlined, tag: 'Table, KOT, kitchen, delivery',
      on: ['fastPOS', 'gstInvoice', 'consent', 'kot', 'production', 'delivery', 'loyalty']),
  BusinessType(key: 'bakery', name: 'Cafe / Bakery / Sweets', edition: 'Vertical Standard', icon: Icons.cake_outlined, tag: 'Weighted + production batches',
      on: ['fastPOS', 'weightScale', 'gstInvoice', 'consent', 'batchExpiry', 'label', 'production', 'multiUnit']),
  BusinessType(key: 'hardware', name: 'Hardware / Electrical', edition: 'Retail Pro', icon: Icons.handyman_outlined, tag: 'Counter + quotation + credit',
      on: ['fastPOS', 'barcodeScan', 'multiUnit', 'gstInvoice', 'consent', 'creditLedger', 'quotation', 'variantMatrix', 'wholesale']),
  BusinessType(key: 'fashion', name: 'Apparel / Footwear', edition: 'Vertical Standard', icon: Icons.checkroom_outlined, tag: 'Variant retail + exchanges',
      on: ['fastPOS', 'barcodeScan', 'gstInvoice', 'consent', 'variantMatrix', 'label', 'loyalty']),
  BusinessType(key: 'jewellery', name: 'Jewellery Store', edition: 'Vertical Enterprise', icon: Icons.diamond_outlined, tag: 'Weight, purity, making-charge',
      on: ['fastPOS', 'gstInvoice', 'consent', 'weightScale', 'serialImei', 'label', 'creditLedger']),
  BusinessType(key: 'electronics', name: 'Mobile / Electronics', edition: 'Vertical Pro', icon: Icons.smartphone_outlined, tag: 'Serial/IMEI + warranty',
      on: ['fastPOS', 'barcodeScan', 'gstInvoice', 'consent', 'serialImei', 'variantMatrix', 'creditLedger', 'recurring']),
  BusinessType(key: 'salon', name: 'Salon / Spa / Beauty', edition: 'Vertical Standard', icon: Icons.content_cut_outlined, tag: 'Appointments + service billing',
      on: ['fastPOS', 'gstInvoice', 'consent', 'appointments', 'membership', 'loyalty']),
  BusinessType(key: 'wholesale', name: 'Wholesale / Distribution', edition: 'Business Pro', icon: Icons.local_shipping_outlined, tag: 'B2B, route sales, credit',
      on: ['fastPOS', 'barcodeScan', 'gstInvoice', 'consent', 'creditLedger', 'multiUnit', 'wholesale', 'delivery', 'multiStore', 'quotation']),
  BusinessType(key: 'clinic', name: 'Clinic / Diagnostic', edition: 'Vertical Pro', icon: Icons.medical_services_outlined, tag: 'Patient, service, package billing',
      on: ['fastPOS', 'gstInvoice', 'consent', 'appointments', 'creditLedger', 'membership']),
];

BusinessType businessByKey(String key) => kBusinessTypes.firstWhere((b) => b.key == key);
final Set<String> kBusinessKeys = kBusinessTypes.map((b) => b.key).toSet();

/// Maps a business-type key to its Codex illustration slug (assets/biztypes/*).
const Map<String, String> kBizIconSlug = {
  'kirana': 'biztype-kirana-24',
  'supermarket': 'biztype-supermarket-24',
  'pharmacy': 'biztype-pharmacy-24',
  'restaurant': 'biztype-restaurant-24',
  'bakery': 'biztype-cafe-bakery-24',
  'hardware': 'biztype-hardware-24',
  'fashion': 'biztype-apparel-24',
  'jewellery': 'biztype-jewellery-24',
  'electronics': 'biztype-electronics-mobile-24',
  'salon': 'biztype-salon-spa-24',
  'wholesale': 'biztype-wholesale-distribution-24',
  'clinic': 'biztype-clinic-diagnostic-24',
};

// ---------------------------------------------------------------------------
// SAMPLE PRODUCTS per business (demo catalogue)
// ---------------------------------------------------------------------------
const Map<String, List<Product>> kProducts = {
  '_default': [
    Product('Item A', 'Piece', 120), Product('Item B', 'Piece', 60), Product('Item C', 'kg', 85),
    Product('Item D', 'Pack', 240), Product('Item E', 'Piece', 35), Product('Item F', 'Litre', 180),
  ],
  'kirana': [
    Product('Toor Dal', 'kg', 145), Product('Sunflower Oil', 'Litre', 180), Product('Basmati Rice', 'kg', 95),
    Product('Sugar', 'kg', 44), Product('Parle-G', 'Pack', 10), Product('Tea Powder', '250g', 130),
    Product('Wheat Atta', 'kg', 42), Product('Detergent', 'Pack', 95), Product('Milk', 'Litre', 56),
  ],
  'pharmacy': [
    Product('Paracetamol 500', 'Strip', 22), Product('Amoxicillin 250', 'Strip', 68), Product('Cough Syrup', 'Bottle', 95),
    Product('ORS Sachet', 'Piece', 18), Product('Vitamin C', 'Strip', 45), Product('Bandage Roll', 'Piece', 30),
    Product('Antacid', 'Strip', 28), Product('Hand Sanitizer', 'Bottle', 75), Product('Thermometer', 'Piece', 180),
  ],
  'restaurant': [
    Product('Masala Dosa', 'Plate', 90), Product('Paneer Butter Masala', 'Plate', 220), Product('Veg Biryani', 'Plate', 180),
    Product('Butter Naan', 'Piece', 35), Product('Cold Coffee', 'Glass', 120), Product('Gulab Jamun', 'Plate', 70),
    Product('Filter Coffee', 'Cup', 40), Product('Chicken 65', 'Plate', 240), Product('Fresh Lime', 'Glass', 50),
  ],
  'fashion': [
    Product('Cotton Shirt M', 'Piece', 899), Product('Denim Jeans 32', 'Piece', 1499), Product('Kurti L', 'Piece', 1199),
    Product('Sneakers 9', 'Pair', 2499), Product('Silk Saree', 'Piece', 3499), Product('T-Shirt S', 'Piece', 499),
    Product('Leather Belt', 'Piece', 699), Product('Socks Pack', 'Pack', 299), Product('Cap', 'Piece', 349),
  ],
  'jewellery': [
    Product('Gold Ring 22K', '4.2g', 31500), Product('Gold Chain 22K', '12g', 90000), Product('Silver Anklet', '28g', 2800),
    Product('Diamond Pendant', 'Piece', 45000), Product('Gold Bangle', '15g', 112000), Product('Silver Coin 10g', 'Piece', 950),
    Product('Nose Pin 18K', '1.1g', 6800), Product('Ear Studs 22K', '3g', 22500),
  ],
  'electronics': [
    Product('Redmi 13C', 'Piece', 9999), Product('USB-C Cable', 'Piece', 249), Product('65W Charger', 'Piece', 1299),
    Product('Bluetooth Buds', 'Pair', 1999), Product('Screen Guard', 'Piece', 199), Product('Power Bank 10K', 'Piece', 1499),
    Product('Smart Watch', 'Piece', 2999), Product('Phone Case', 'Piece', 349),
  ],
  'salon': [
    Product('Haircut - Men', 'Service', 250), Product('Hair Spa', 'Service', 1200), Product('Facial - Gold', 'Service', 1800),
    Product('Threading', 'Service', 80), Product('Beard Trim', 'Service', 150), Product('Hair Color', 'Service', 2200),
    Product('Manicure', 'Service', 600), Product('Head Massage', 'Service', 400),
  ],
};

List<Product> productsFor(String bizKey) => kProducts[bizKey] ?? kProducts['_default']!;

// ---------------------------------------------------------------------------
// INVOICE TEMPLATES
// ---------------------------------------------------------------------------
const List<InvoiceTemplate> kTemplates = [
  InvoiceTemplate('classic', 'Classic GST', PaperSize.a4, 'Formal tax invoice, full HSN table'),
  InvoiceTemplate('minimal', 'Minimal', PaperSize.a4, 'Clean, whitespace-led, brand header'),
  InvoiceTemplate('modern', 'Modern Color', PaperSize.a4, 'Accent band + card totals'),
  InvoiceTemplate('bilingual', 'Bilingual हिं/తె', PaperSize.a4, 'Dual-language labels for local trade'),
  InvoiceTemplate('wholesale', 'Wholesale B2B', PaperSize.a4, 'Case/piece, scheme & credit terms'),
  InvoiceTemplate('service', 'Service / Job Card', PaperSize.a4, 'Labour + parts, technician, warranty'),
  InvoiceTemplate('quotation', 'Quotation', PaperSize.a4, 'Validity, terms, no stock impact'),
  InvoiceTemplate('thermal80', 'Thermal 80mm', PaperSize.mm80, 'Wide receipt + cutter + QR'),
  InvoiceTemplate('thermal58', 'Thermal 58mm', PaperSize.mm58, 'Compact kirana receipt'),
  InvoiceTemplate('kot', 'Kitchen KOT', PaperSize.mm80, 'Items only, no price, station route'),
  InvoiceTemplate('delivery', 'Delivery Challan', PaperSize.a4, 'Dispatch note, link invoice later'),
];

InvoiceTemplate templateById(String id) => kTemplates.firstWhere((t) => t.id == id);

/// Default print template chosen by a preset.
String defaultTemplateFor(String bizKey) => switch (bizKey) {
      'restaurant' => 'modern',
      'wholesale' => 'wholesale',
      'electronics' => 'service',
      'clinic' => 'service',
      'jewellery' => 'classic',
      _ => 'classic',
    };

/// Default POS live-receipt template chosen by a preset.
String defaultPosTemplateFor(String bizKey) =>
    (bizKey == 'kirana' || bizKey == 'pharmacy' || bizKey == 'bakery') ? 'thermal58' : 'thermal80';
