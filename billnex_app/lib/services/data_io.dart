import '../models/customer.dart';
import '../models/sale.dart';
import '../models/stock.dart';

/// Pure CSV import/export helpers for BillNex merchant data (no UI, no state).
///
/// CSV is treated as machine data: column *data* is never localized (raw model
/// names / numbers), and headers stay in English. Export uses RFC-4180 quoting;
/// [parseCsv] is a tolerant RFC-4180-ish reader that survives quoted fields with
/// embedded commas, quotes and newlines. Row mappers never throw on a bad row —
/// they skip it and record the reason in an [ImportResult].

// ─────────────────────────────────────────────────────────────────────────
// CSV primitives
// ─────────────────────────────────────────────────────────────────────────

/// Quotes a single field if it contains a comma, quote, CR or LF; embedded
/// quotes are doubled per RFC-4180.
String csvEscape(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

/// Joins one row of already-stringified cells into a CSV line.
String _row(List<Object?> cells) => cells.map((c) => csvEscape(c?.toString() ?? '')).join(',');

/// Formats a number without a trailing `.0` for whole values, so a round-trip
/// keeps quantities/prices readable (e.g. `12` not `12.0`, but `0.5` stays).
String numCsv(num v) {
  if (v == v.roundToDouble() && v.abs() < 1e15) return v.toInt().toString();
  return v.toString();
}

/// RFC-4180-ish parser → list of rows, each a list of string fields. Tolerates
/// `\n`, `\r\n` and `\r` line endings and quoted fields spanning newlines. A
/// trailing empty line is ignored. Never throws on malformed input — an unclosed
/// quote simply consumes to end-of-input.
List<List<String>> parseCsvRows(String input) {
  final rows = <List<String>>[];
  var field = StringBuffer();
  var row = <String>[];
  var inQuotes = false;
  var sawAny = false; // any char on the current record (to keep genuine blanks)

  void endField() {
    row.add(field.toString());
    field = StringBuffer();
  }

  void endRow() {
    endField();
    rows.add(row);
    row = <String>[];
    sawAny = false;
  }

  for (var i = 0; i < input.length; i++) {
    final ch = input[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < input.length && input[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(ch);
      }
      sawAny = true;
      continue;
    }
    switch (ch) {
      case '"':
        inQuotes = true;
        sawAny = true;
      case ',':
        endField();
        sawAny = true;
      case '\r':
        if (i + 1 < input.length && input[i + 1] == '\n') i++;
        endRow();
      case '\n':
        endRow();
      default:
        field.write(ch);
        sawAny = true;
    }
  }
  // Flush the final record unless the input ended exactly on a newline.
  if (sawAny || field.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}

/// Parses CSV into a list of maps keyed by the header row. Header names are
/// trimmed and lower-cased so importing tolerates casing/spacing differences.
/// Extra columns are kept; missing columns simply won't appear on a row.
List<Map<String, String>> parseCsv(String input) {
  final rows = parseCsvRows(input);
  if (rows.isEmpty) return const [];
  final header = rows.first.map((h) => h.trim().toLowerCase()).toList();
  final out = <Map<String, String>>[];
  for (var r = 1; r < rows.length; r++) {
    final cells = rows[r];
    // Skip fully-blank lines (e.g. a trailing newline artefact).
    if (cells.every((c) => c.trim().isEmpty)) continue;
    final map = <String, String>{};
    for (var c = 0; c < header.length && c < cells.length; c++) {
      map[header[c]] = cells[c];
    }
    out.add(map);
  }
  return out;
}

// ─────────────────────────────────────────────────────────────────────────
// Export
// ─────────────────────────────────────────────────────────────────────────

const _inventoryHeader = ['Name', 'Unit', 'Price', 'Cost', 'Quantity', 'ReorderLevel', 'GstRate', 'Barcode', 'Category', 'HSN', 'StockTracked'];

String inventoryToCsv(List<StockItem> items) {
  final b = StringBuffer(_row(_inventoryHeader))..write('\n');
  for (final it in items) {
    b
      ..write(
        _row([it.name, it.unit, numCsv(it.price), numCsv(it.cost), numCsv(it.qty), numCsv(it.reorderLevel), numCsv(it.gstRate), it.barcode ?? '', it.category ?? '', it.hsn ?? '', it.stockTracked]),
      )
      ..write('\n');
  }
  return b.toString();
}

const _customersHeader = ['Name', 'Mobile', 'GSTIN', 'CreditLimit', 'Consent'];

String customersToCsv(List<Customer> customers) {
  final b = StringBuffer(_row(_customersHeader))..write('\n');
  for (final c in customers) {
    b
      ..write(_row([c.name, c.mobile, c.gstin ?? '', numCsv(c.creditLimit), c.consent]))
      ..write('\n');
  }
  return b.toString();
}

const _salesHeader = ['InvoiceNo', 'Date', 'PaymentMode', 'ItemName', 'SKU', 'Qty', 'Price', 'GstRate', 'Discount', 'LineAmount', 'InvoiceSubtotal', 'InvoiceGst', 'InvoiceTotal'];

/// One row per sale line; invoice-level totals are repeated on the first line of
/// each invoice (blank on subsequent lines) so the file stays spreadsheet-legible.
String salesToCsv(List<Sale> sales) {
  final b = StringBuffer(_row(_salesHeader))..write('\n');
  String isoDate(int ms) => DateTime.fromMillisecondsSinceEpoch(ms).toIso8601String();
  for (final s in sales) {
    if (s.lines.isEmpty) {
      b
        ..write(_row([s.invoiceNo, isoDate(s.epochMs), s.paymentMode, '', '', '', '', '', '', '', numCsv(s.subtotal), numCsv(s.gst), numCsv(s.total)]))
        ..write('\n');
      continue;
    }
    for (var i = 0; i < s.lines.length; i++) {
      final l = s.lines[i];
      final first = i == 0;
      b
        ..write(
          _row([
            s.invoiceNo,
            isoDate(s.epochMs),
            s.paymentMode,
            l.name,
            l.sku,
            numCsv(l.qty),
            numCsv(l.price),
            numCsv(l.gstRate),
            numCsv(l.discount),
            numCsv(l.amount),
            first ? numCsv(s.subtotal) : '',
            first ? numCsv(s.gst) : '',
            first ? numCsv(s.total) : '',
          ]),
        )
        ..write('\n');
    }
  }
  return b.toString();
}

// ─────────────────────────────────────────────────────────────────────────
// Import
// ─────────────────────────────────────────────────────────────────────────

/// Outcome of a CSV import: how many rows were added, skipped (e.g. duplicate),
/// or failed to parse, plus a few human-readable error strings.
class ImportResult {
  int added;
  int skipped;
  int failed;
  final List<String> errors;
  ImportResult({this.added = 0, this.skipped = 0, this.failed = 0, List<String>? errors}) : errors = errors ?? [];

  bool get isEmpty => added == 0 && skipped == 0 && failed == 0;

  /// Records an error, capping the retained list so a huge broken file can't
  /// blow up memory (the [failed] count still reflects every failure).
  void addError(String message) {
    if (errors.length < 20) errors.add(message);
  }
}

double? _num(String? s) {
  if (s == null) return null;
  final t = s.trim();
  if (t.isEmpty) return null;
  return double.tryParse(t.replaceAll(',', ''));
}

bool _bool(String? s, {bool fallback = true}) {
  final t = (s ?? '').trim().toLowerCase();
  if (t.isEmpty) return fallback;
  return t == 'true' || t == '1' || t == 'yes' || t == 'y';
}

/// A parsed inventory row ready to hand to `AppState.addStockItem`.
class InventoryRow {
  final String name;
  final String unit;
  final double price;
  final double cost;
  final double qty;
  final double reorder;
  final double gstRate;
  final String? barcode;
  final String? category;
  final String? hsn;
  final bool stockTracked;
  InventoryRow({
    required this.name,
    required this.unit,
    required this.price,
    this.cost = 0,
    this.qty = 0,
    this.reorder = 10,
    this.gstRate = 5,
    this.barcode,
    this.category,
    this.hsn,
    this.stockTracked = true,
  });
}

String? _str(Map<String, String> row, String key) {
  final v = row[key.toLowerCase()]?.trim();
  return (v == null || v.isEmpty) ? null : v;
}

/// Maps a parsed CSV row to an [InventoryRow], or null if it's unusable (missing
/// name, or a present-but-unparseable price). Reason is appended to [errors].
InventoryRow? mapInventoryRow(Map<String, String> row, {required int lineNo, List<String>? errors}) {
  final name = _str(row, 'name');
  if (name == null) {
    errors?.add('Row $lineNo: missing Name');
    return null;
  }
  final priceRaw = _str(row, 'price');
  final price = _num(priceRaw);
  if (priceRaw != null && price == null) {
    errors?.add('Row $lineNo: bad Price "$priceRaw"');
    return null;
  }
  return InventoryRow(
    name: name,
    unit: _str(row, 'unit') ?? 'Piece',
    price: price ?? 0,
    cost: _num(_str(row, 'cost')) ?? 0,
    qty: _num(_str(row, 'quantity')) ?? _num(_str(row, 'qty')) ?? 0,
    reorder: _num(_str(row, 'reorderlevel')) ?? _num(_str(row, 'reorder')) ?? 10,
    gstRate: _num(_str(row, 'gstrate')) ?? 5,
    barcode: _str(row, 'barcode'),
    category: _str(row, 'category'),
    hsn: _str(row, 'hsn'),
    stockTracked: _bool(row['stocktracked']),
  );
}

/// A parsed customer row ready to hand to `AppState.addCustomer`.
class CustomerRow {
  final String name;
  final String mobile;
  final String? gstin;
  final double creditLimit;
  final bool consent;
  CustomerRow({required this.name, this.mobile = '', this.gstin, this.creditLimit = 0, this.consent = false});
}

CustomerRow? mapCustomerRow(Map<String, String> row, {required int lineNo, List<String>? errors}) {
  final name = _str(row, 'name');
  if (name == null) {
    errors?.add('Row $lineNo: missing Name');
    return null;
  }
  final limitRaw = _str(row, 'creditlimit');
  final limit = _num(limitRaw);
  if (limitRaw != null && limit == null) {
    errors?.add('Row $lineNo: bad CreditLimit "$limitRaw"');
    return null;
  }
  return CustomerRow(name: name, mobile: _str(row, 'mobile') ?? '', gstin: _str(row, 'gstin'), creditLimit: limit ?? 0, consent: _bool(row['consent'], fallback: false));
}

/// Parses inventory CSV and applies each row via [add], which must return true
/// when the item was added and false when it was skipped (e.g. duplicate SKU —
/// mirror `AppState.addStockItem` returning null). Never throws.
ImportResult importInventoryCsv(String csv, {required bool Function(InventoryRow) add}) {
  final result = ImportResult();
  final List<Map<String, String>> rows;
  try {
    rows = parseCsv(csv);
  } catch (e) {
    result.failed += 1;
    result.addError('Could not read file: $e');
    return result;
  }
  var lineNo = 1;
  for (final row in rows) {
    lineNo++;
    final parsed = mapInventoryRow(row, lineNo: lineNo, errors: result.errors.length < 20 ? result.errors : null);
    if (parsed == null) {
      result.failed += 1;
      continue;
    }
    try {
      add(parsed) ? result.added++ : result.skipped++;
    } catch (e) {
      result.failed += 1;
      result.addError('Row $lineNo: $e');
    }
  }
  return result;
}

/// Parses customer CSV and applies each row via [add] (true = added, false =
/// skipped). Never throws.
ImportResult importCustomersCsv(String csv, {required bool Function(CustomerRow) add}) {
  final result = ImportResult();
  final List<Map<String, String>> rows;
  try {
    rows = parseCsv(csv);
  } catch (e) {
    result.failed += 1;
    result.addError('Could not read file: $e');
    return result;
  }
  var lineNo = 1;
  for (final row in rows) {
    lineNo++;
    final parsed = mapCustomerRow(row, lineNo: lineNo, errors: result.errors.length < 20 ? result.errors : null);
    if (parsed == null) {
      result.failed += 1;
      continue;
    }
    try {
      add(parsed) ? result.added++ : result.skipped++;
    } catch (e) {
      result.failed += 1;
      result.addError('Row $lineNo: $e');
    }
  }
  return result;
}
