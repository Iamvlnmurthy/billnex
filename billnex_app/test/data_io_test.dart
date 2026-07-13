import 'package:flutter_test/flutter_test.dart';
import 'package:billnex/models/stock.dart';
import 'package:billnex/models/customer.dart';
import 'package:billnex/services/data_io.dart';

void main() {
  group('CSV primitives', () {
    test('csvEscape quotes fields with comma, quote, or newline; doubles quotes', () {
      expect(csvEscape('plain'), 'plain');
      expect(csvEscape('a,b'), '"a,b"');
      expect(csvEscape('say "hi"'), '"say ""hi"""');
      expect(csvEscape('line1\nline2'), '"line1\nline2"');
    });

    test('parseCsv round-trips a field containing a comma, a quote and a newline', () {
      const tricky = 'Rice, "Premium"\nGrade';
      final csv = '${csvEscape('Name')}\n${csvEscape(tricky)}\n';
      final rows = parseCsv(csv);
      expect(rows.length, 1);
      expect(rows.first['name'], tricky);
    });

    test('numCsv drops trailing .0 but keeps real fractions', () {
      expect(numCsv(12.0), '12');
      expect(numCsv(0.5), '0.5');
    });
  });

  group('inventory export → import round-trip', () {
    test('names (incl. comma/quote), prices and quantities survive', () {
      final items = [
        StockItem(sku: 'A1', name: 'Toor Dal', unit: 'kg', price: 145, cost: 120, qty: 12.5, reorderLevel: 5),
        StockItem(sku: 'B2', name: 'Rice, "Premium"', unit: 'kg', price: 95),
      ];
      final csv = inventoryToCsv(items);

      final captured = <InventoryRow>[];
      final res = importInventoryCsv(
        csv,
        add: (row) {
          captured.add(row);
          return true;
        },
      );

      expect(res.failed, 0);
      expect(res.added, 2);
      expect(captured[0].name, 'Toor Dal');
      expect(captured[0].price, 145);
      expect(captured[0].qty, 12.5);
      expect(captured[1].name, 'Rice, "Premium"'); // escaping survived
    });

    test('skipped rows (duplicate) are counted, not failed', () {
      final csv = inventoryToCsv([StockItem(sku: 'A1', name: 'Dal', unit: 'kg', price: 10)]);
      final res = importInventoryCsv(csv, add: (_) => false); // simulate duplicate
      expect(res.added, 0);
      expect(res.skipped, 1);
      expect(res.failed, 0);
    });
  });

  group('customer export → import round-trip', () {
    test('name/mobile/limit/consent survive', () {
      final customers = [const Customer(id: 'c1', name: 'Anita', mobile: '9000000001', creditLimit: 5000, consent: true)];
      final csv = customersToCsv(customers);
      final captured = <CustomerRow>[];
      final res = importCustomersCsv(
        csv,
        add: (row) {
          captured.add(row);
          return true;
        },
      );
      expect(res.added, 1);
      expect(captured.single.name, 'Anita');
      expect(captured.single.mobile, '9000000001');
      expect(captured.single.creditLimit, 5000);
      expect(captured.single.consent, true);
    });
  });

  group('malformed import never throws and reports failures', () {
    test('missing Name and bad Price rows are failed, good rows added', () {
      const csv =
          'Name,Price,Quantity\n'
          'Good,50,3\n'
          ',20,1\n' // missing name → failed
          'BadPrice,notanumber,2\n' // unparseable price → failed
          'AlsoGood,10,\n';
      final added = <String>[];
      final res = importInventoryCsv(
        csv,
        add: (r) {
          added.add(r.name);
          return true;
        },
      );
      expect(added, ['Good', 'AlsoGood']);
      expect(res.added, 2);
      expect(res.failed, 2);
      expect(res.errors, isNotEmpty);
    });

    test('empty / header-only CSV yields an empty result, no throw', () {
      final res = importCustomersCsv('Name,Mobile\n', add: (_) => true);
      expect(res.isEmpty, true);
    });
  });
}
