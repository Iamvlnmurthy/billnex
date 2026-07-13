// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BillNex';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navBilling => 'Billing';

  @override
  String get navSales => 'Sales';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navInventory => 'Inventory';

  @override
  String get navPurchases => 'Purchases';

  @override
  String get navReports => 'Reports';

  @override
  String get navFeatures => 'Features';

  @override
  String get navPrint => 'Print';

  @override
  String get navAppointments => 'Appointments';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get queue => 'Queue';

  @override
  String get backup => 'Backup';

  @override
  String get currentBill => 'Current bill';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get total => 'Total';

  @override
  String get cash => 'Cash';

  @override
  String get credit => 'Credit';

  @override
  String get chargeAndPrint => 'Charge & print';

  @override
  String get walkInCustomer => 'Walk-in customer · tap to attach';

  @override
  String get startBilling => 'Start billing';

  @override
  String get language => 'Language';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get quickBill => 'Quick Bill';

  @override
  String get tally => 'Tally';

  @override
  String get itemized => 'Itemized';

  @override
  String get amount => 'Amount';

  @override
  String get add => 'Add';

  @override
  String get collect => 'Collect';

  @override
  String get discount => 'Discount';

  @override
  String get roundOff => 'Round off';

  @override
  String get item => 'Item';

  @override
  String get unit => 'Unit';

  @override
  String get qty => 'Qty';

  @override
  String get rate => 'Rate';

  @override
  String get addItem => 'Add item';

  @override
  String get frequent => 'FREQUENT';

  @override
  String get cashReceived => 'Cash received (optional)';

  @override
  String get returnChange => 'Return change';

  @override
  String get upi => 'UPI';

  @override
  String get khataCredit => 'Khata (credit)';

  @override
  String get clearBill => 'Clear bill';

  @override
  String get amountToCollect => 'Amount to collect';

  @override
  String get punchAmounts => 'Punch each amount, then Collect';

  @override
  String get noCatalogueNeeded => 'No item names or catalogue needed.';

  @override
  String get guidedSetup => 'Guided setup · 60 seconds';

  @override
  String get businessType => 'Business type';

  @override
  String get chooseYourTrade => 'Choose your trade';

  @override
  String get continueLabel => 'Continue';

  @override
  String get skipStandardStore => 'Skip — start with a standard store';

  @override
  String get menu => 'Menu';

  @override
  String get myBusiness => 'MY BUSINESS';

  @override
  String get setupSection => 'SETUP';

  @override
  String get businessDetails => 'Business details';

  @override
  String get backupRestore => 'Backup & restore';

  @override
  String get everythingInOnePlace => 'everything in one place';

  @override
  String get inventoryPurchasesSection => 'INVENTORY & PURCHASES';

  @override
  String get reportsSection => 'REPORTS';

  @override
  String get billingCounter => 'Billing counter';

  @override
  String get salesInvoices => 'Sales & invoices';

  @override
  String get customersKhata => 'Customers & khata';

  @override
  String get itemsStock => 'Items & stock';

  @override
  String get purchasesSuppliers => 'Purchases & suppliers';

  @override
  String get reportsAnalytics => 'Reports & analytics';

  @override
  String get featuresToggles => 'Features & toggles';

  @override
  String get printTemplates => 'Print templates';

  @override
  String get syncNow => 'Sync now';

  @override
  String get backupDue => 'due';

  @override
  String get backupNone => 'none';

  @override
  String get backupSaved => 'saved';

  @override
  String get activeFeatures => 'Active features';

  @override
  String get greetMorning => 'Good morning';

  @override
  String get greetAfternoon => 'Good afternoon';

  @override
  String get greetEvening => 'Good evening';

  @override
  String get dashboardWord => 'Dashboard';

  @override
  String lowStockBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count products low in stock', one: '1 product low in stock');
    return '$_temp0';
  }

  @override
  String get backupDueBanner => 'Backup due — protect your data';

  @override
  String get createNewBill => 'Create New Bill';

  @override
  String get todaysSummary => 'Today\'s Summary';

  @override
  String get details => 'Details';

  @override
  String get todaysSales => 'TODAY\'S SALES';

  @override
  String get noBillsYet => 'no bills yet';

  @override
  String billsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count bills', one: '1 bill');
    return '$_temp0';
  }

  @override
  String get totalBills => 'Total Bills';

  @override
  String get cashReceived2 => 'Cash Received';

  @override
  String get upiCard => 'UPI / Card';

  @override
  String get creditSales => 'Credit Sales';

  @override
  String get addProduct => 'Add Product';

  @override
  String get viewStock => 'View Stock';

  @override
  String get ledger => 'Ledger';

  @override
  String get dayClosing => 'Day Closing';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get viewAll => 'View all';

  @override
  String get noBillsTodayTitle => 'No bills yet today';

  @override
  String get noBillsTodaySubtitle => 'Your posted bills will appear here. Tap “Create New Bill” to make your first sale.';

  @override
  String billNo(String no) {
    return 'Bill $no';
  }

  @override
  String get paid => 'PAID';

  @override
  String get pending => 'PENDING';

  @override
  String get salesTitle => 'Sales';

  @override
  String salesSubtitle(int count, String total) {
    return '$count bills · $total total · every bill is immutable and reprintable.';
  }

  @override
  String get auditedReprint => 'Audited reprint';

  @override
  String get salesEmptyTitle => 'No bills yet';

  @override
  String get salesEmptySubtitle => 'Post a sale from Billing — it appears here.';

  @override
  String get returnDialogTitle => 'Return this bill?';

  @override
  String returnDialogBody(String inv, String amount) {
    return 'Create a credit note for $inv ($amount). Items go back into stock.';
  }

  @override
  String get returnCreditKhataNote => '\n\nThis was a credit bill — adjust the customer\'s khata separately.';

  @override
  String get returnAction => 'Return';

  @override
  String returnSnack(String ret, String inv) {
    return '$ret · credit note for $inv ✓';
  }

  @override
  String get chipReturn => 'RETURN';

  @override
  String chipPaidMode(String mode) {
    return 'PAID · $mode';
  }

  @override
  String saleItemsLine(String date, String items) {
    return '$date · $items items';
  }

  @override
  String get more => 'More';

  @override
  String get reprint => 'Reprint';

  @override
  String get sharePdf => 'Share PDF';

  @override
  String get returnCreditNote => 'Return / credit note';

  @override
  String get reprintFail => 'Couldn\'t reprint — check the printer';

  @override
  String get shareFail => 'Couldn\'t share the PDF';
}
