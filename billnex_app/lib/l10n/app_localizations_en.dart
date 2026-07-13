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

  @override
  String get invTitle => 'Inventory & Stock';

  @override
  String invSubtitle(int skus, int low, String value) {
    return '$skus SKUs · $low low · $value at cost.';
  }

  @override
  String get liveStockLedger => 'Live stock ledger';

  @override
  String get searchItem => 'Search item…';

  @override
  String lowFilter(int count) {
    return 'Low ($count)';
  }

  @override
  String get noProductsTitle => 'No products yet';

  @override
  String get noMatchesTitle => 'No matches';

  @override
  String get noProductsSub => 'Tap \"Add product\" to build your catalogue.';

  @override
  String get noMatchesSub => 'Try a different search.';

  @override
  String get addProductBtn => 'Add product';

  @override
  String get chipOut => 'OUT';

  @override
  String get chipLow => 'LOW';

  @override
  String pricePerUnitReorder(String price, String unit, String reorder) {
    return '$price / $unit · reorder $reorder';
  }

  @override
  String get service => 'service';

  @override
  String get newProduct => 'New product';

  @override
  String get fieldName => 'Name';

  @override
  String get enterProductName => 'Enter a product name';

  @override
  String get productExistsErr => 'A product with this name already exists';

  @override
  String get fieldUnit => 'Unit';

  @override
  String get sellPrice => 'Sell price';

  @override
  String get enterPriceGt0 => 'Enter a price > 0';

  @override
  String get costOptional => 'Cost (optional)';

  @override
  String get trackStock => 'Track stock';

  @override
  String get trackStockSub => 'Off for services (salon, repair)';

  @override
  String get openingQty => 'Opening qty';

  @override
  String get geZero => '≥ 0';

  @override
  String get reorderLevel => 'Reorder level';

  @override
  String get fieldCategory => 'Category';

  @override
  String get hsnSac => 'HSN/SAC';

  @override
  String get barcodeOptional => 'Barcode (optional)';

  @override
  String get barcodeUsedErr => 'Barcode already used by another product';

  @override
  String get addToCatalogue => 'Add to catalogue';

  @override
  String get gstPct => 'GST %';

  @override
  String addedSnack(String name) {
    return '$name added ✓';
  }

  @override
  String get addFailExists => 'Could not add — name already exists';

  @override
  String get onHand => 'ON HAND';

  @override
  String reorderAtCost(String reorder, String cost) {
    return 'Reorder at $reorder · cost $cost';
  }

  @override
  String get reduce => 'Reduce';

  @override
  String get addStock => 'Add stock';

  @override
  String get batches => 'Batches';

  @override
  String get chipExpired => 'EXPIRED';

  @override
  String get chipNearExpiry => 'NEAR EXPIRY';

  @override
  String batchNo(String no) {
    return 'Batch $no';
  }

  @override
  String expLabel(String date) {
    return 'exp $date';
  }

  @override
  String get movementHistory => 'Movement history';

  @override
  String get editProductTooltip => 'Edit product';

  @override
  String get deleteProductTooltip => 'Delete product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get enterName => 'Enter a name';

  @override
  String get fieldReorder => 'Reorder';

  @override
  String get fieldCost => 'Cost';

  @override
  String get gtZeroShort => '> 0';

  @override
  String get usedByAnother => 'Used by another product';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get productUpdated => 'Product updated ✓';

  @override
  String get removeProductTitle => 'Remove product?';

  @override
  String removeProductBody(String name) {
    return 'Remove \"$name\" from your catalogue? Past sales keep their records.';
  }

  @override
  String get removeAction => 'Remove';

  @override
  String addStockTitle(String name) {
    return 'Add stock · $name';
  }

  @override
  String reduceStockTitle(String name) {
    return 'Reduce stock · $name';
  }

  @override
  String onHandLabel(String qty, String unit) {
    return 'On hand: $qty $unit';
  }

  @override
  String quantityUnit(String unit) {
    return 'Quantity ($unit)';
  }

  @override
  String get reasonField => 'Reason';

  @override
  String get recordAdjustment => 'Record adjustment';

  @override
  String get enterQtyGt0 => 'Enter a quantity greater than 0';

  @override
  String get stockAdded => 'Stock added ✓';

  @override
  String get stockReduced => 'Stock reduced ✓';

  @override
  String get purchaseRestock => 'Purchase / restock';

  @override
  String get damageCorrection => 'Damage / correction';

  @override
  String get reportsTitle => 'Reports & Analytics';

  @override
  String get reportsSubtitle => 'Everything below is computed live from posted transactions.';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get exportReportFail => 'Couldn\'t export the report';

  @override
  String get kpiNetSales => 'Net sales';

  @override
  String get kpiGstCollected => 'GST collected';

  @override
  String get kpiBills => 'Bills';

  @override
  String get kpiAvgBill => 'Avg bill';

  @override
  String get kpiItemsSold => 'Items sold';

  @override
  String get kpiReceivable => 'Receivable';

  @override
  String get kpiPayable => 'Payable';

  @override
  String get kpiStockAtCost => 'Stock @ cost';

  @override
  String get profitLoss => 'Profit & Loss';

  @override
  String get plSalesTaxable => 'Sales (taxable)';

  @override
  String get plCogs => 'Cost of goods sold';

  @override
  String get plGrossProfit => 'Gross profit';

  @override
  String plGstNote(String amt) {
    return 'GST collected $amt is a pass-through, not income.';
  }

  @override
  String get hsnSummaryTitle => 'Sale summary by HSN';

  @override
  String get csv => 'CSV';

  @override
  String get noSalesYet => 'No sales yet';

  @override
  String get hsnCol => 'HSN';

  @override
  String get gstCol => 'GST';

  @override
  String get taxableCol => 'TAXABLE';

  @override
  String get taxCol => 'TAX';

  @override
  String get dayBookTitle => 'Day book';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get paymentMixTitle => 'Payment mix';

  @override
  String get topItems => 'Top items';

  @override
  String qtySold(String qty) {
    return '$qty sold';
  }

  @override
  String saveFileTitle(String file) {
    return 'Save $file';
  }

  @override
  String get exportCancelled => 'Export cancelled';

  @override
  String savedFile(String file) {
    return 'Saved $file ✓';
  }

  @override
  String exportFailed(String err) {
    return 'Export failed: $err';
  }

  @override
  String get addCustomer => 'Add customer';

  @override
  String get customersTitle => 'Customers & Credit';

  @override
  String customersSubtitle(int count, String receivable, int accounts) {
    return '$count customers · $receivable receivable across $accounts accounts.';
  }

  @override
  String get khataLedger => 'Khata ledger';

  @override
  String get noCustomersTitle => 'No customers yet';

  @override
  String get noCustomersSub => 'Add one here, or attach a customer on a credit sale.';

  @override
  String get sectionOutstanding => 'Outstanding';

  @override
  String get sectionSettled => 'Settled';

  @override
  String get overLimit => 'Over limit';

  @override
  String get noMobile => 'No mobile';

  @override
  String get settledLabel => 'Settled';

  @override
  String get outstandingLabel => 'outstanding';

  @override
  String get noDues => 'no dues';

  @override
  String get outstandingBalance => 'OUTSTANDING BALANCE';

  @override
  String limitLabel(String amt) {
    return 'Limit $amt';
  }

  @override
  String get collectPayment => 'Collect payment';

  @override
  String get ledgerLabel => 'LEDGER';

  @override
  String get noLedgerEntries => 'No ledger entries';

  @override
  String balLabel(String amt) {
    return 'bal $amt';
  }

  @override
  String collectFrom(String name) {
    return 'Collect from $name';
  }

  @override
  String outstandingSuffix(String amt) {
    return '$amt outstanding';
  }

  @override
  String get recordCollection => 'Record collection';

  @override
  String get enterAmtGt0 => 'Enter an amount greater than 0';

  @override
  String collectedSnack(String ref, String amt) {
    return '$ref · $amt collected ✓';
  }

  @override
  String get billingTitle => 'Billing';

  @override
  String get billingSubtitleWide => 'Search or scan · live receipt updates as you go.';

  @override
  String get billingSubtitlePhone => 'Search or scan to add items.';

  @override
  String itemCountLabel(String count) {
    return '$count items';
  }

  @override
  String get viewBill => 'View bill';

  @override
  String noProductBarcode(String code) {
    return 'No product with barcode $code';
  }

  @override
  String outOfStock(String name) {
    return '$name is out of stock';
  }

  @override
  String get enterBarcodeSku => 'Enter barcode / SKU';

  @override
  String get barcodeHint => 'Barcode or product code';

  @override
  String get cancel => 'Cancel';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get searchProducts => 'Search products…';

  @override
  String get posNoProductsSub => 'Add your shop\'s products in the Inventory tab, then bill them here.';

  @override
  String noProductsMatch(String q) {
    return 'No products match \"$q\"';
  }

  @override
  String get serviceLabel => 'Service';

  @override
  String qtyBadge(String count) {
    return '$count qty';
  }

  @override
  String get tapProductToStart => 'Tap a product to start the bill';

  @override
  String get taxable => 'Taxable';

  @override
  String get cgst => 'CGST';

  @override
  String get sgst => 'SGST';

  @override
  String get billDiscountLabel => 'Bill discount';

  @override
  String get upiQr => 'UPI QR';

  @override
  String get sendKot => 'Send to Kitchen (KOT)';

  @override
  String get addItemsToCharge => 'Add items to charge';

  @override
  String chargePrintAmt(String amt) {
    return 'Charge & print · $amt';
  }

  @override
  String get liveReceipt => 'Live receipt';

  @override
  String get addItemsPlaceholder => '— add items —';

  @override
  String get kotSent => 'KOT sent to kitchen ✓';

  @override
  String get kotPrintFail => 'Couldn\'t print the kitchen ticket — check the printer';

  @override
  String get addItemsFirst => 'Add items first';

  @override
  String get creditNeedsCustomer => 'Credit sale needs a customer';

  @override
  String get creditLimitExceeded => 'Credit limit exceeded';

  @override
  String creditLimitBody(String name, String limit) {
    return '$name would exceed the $limit limit. Post anyway?';
  }

  @override
  String get overrideAction => 'Override';

  @override
  String salePostedPrefix(String inv, String mode, String amt) {
    return '$inv posted · $mode $amt';
  }

  @override
  String get share => 'Share';

  @override
  String quantityOf(String name) {
    return 'Quantity · $name';
  }

  @override
  String get setLabel => 'Set';

  @override
  String get removeCustomer => 'Remove customer';

  @override
  String get increaseQty => 'Increase quantity';

  @override
  String get decreaseQty => 'Decrease quantity';

  @override
  String get newPurchase => 'New purchase';

  @override
  String get purchasingTitle => 'Purchasing & Suppliers';

  @override
  String purchasingSubtitle(int count, String payable, int purchases) {
    return '$count suppliers · $payable payable · $purchases purchases.';
  }

  @override
  String get supplier => 'Supplier';

  @override
  String get noSuppliersTitle => 'No suppliers yet';

  @override
  String get noSuppliersSub => 'Add a supplier, then record a purchase to stock-in.';

  @override
  String get noContact => 'No contact';

  @override
  String get payableLower => 'payable';

  @override
  String get newSupplier => 'New supplier';

  @override
  String get phoneField => 'Phone';

  @override
  String get gstinOptional => 'GSTIN (optional)';

  @override
  String get saveSupplier => 'Save supplier';

  @override
  String get recordPurchase => 'Record purchase';

  @override
  String get supplierInvoiceNo => 'Supplier invoice no.';

  @override
  String get duplicateInvoiceSupplier => 'Duplicate invoice for this supplier';

  @override
  String get items => 'Items';

  @override
  String get noItemsYet => 'No items yet';

  @override
  String get totalInclGst => 'Total (incl. GST)';

  @override
  String get paidNow => 'Paid now';

  @override
  String get noPayableCreated => 'No payable created';

  @override
  String get addsToPayable => 'Adds to supplier payable';

  @override
  String get duplicateChangeRef => 'Duplicate invoice — change the ref';

  @override
  String get recordPurchaseStockIn => 'Record purchase & stock-in';

  @override
  String get removeItem => 'Remove item';

  @override
  String amtPayable(String amt) {
    return '$amt payable';
  }

  @override
  String onHandCost(String qty, String cost) {
    return 'on hand $qty · cost $cost';
  }

  @override
  String qtyUnit(String unit) {
    return 'Qty ($unit)';
  }

  @override
  String get addLine => 'Add line';

  @override
  String purchaseRecordedSnack(String count) {
    return 'Purchase recorded · $count items stocked-in ✓';
  }

  @override
  String get payableBalance => 'PAYABLE BALANCE';

  @override
  String get paySupplierBtn => 'Pay supplier';

  @override
  String get purchasesUpper => 'PURCHASES';

  @override
  String get noPurchases => 'No purchases';

  @override
  String get creditChip => 'CREDIT';

  @override
  String get noRef => 'no ref';

  @override
  String purchaseLineInfo(String ref, String date, String items) {
    return '$ref · $date · $items items';
  }

  @override
  String paySupplierTitle(String name) {
    return 'Pay $name';
  }

  @override
  String payableColon(String amt) {
    return 'Payable: $amt';
  }

  @override
  String get recordPayment => 'Record payment';

  @override
  String paidToSnack(String amt, String name) {
    return 'Paid $amt to $name ✓';
  }

  @override
  String featuresSubtitle(String name) {
    return 'Everything is grouped by category with a master switch. Preset-enabled items were auto-allotted for $name — override anything.';
  }

  @override
  String featuresEnabledCount(int on, int total) {
    return '$on of $total enabled';
  }

  @override
  String get enableAll => 'Enable all';

  @override
  String get disableAll => 'Disable all';

  @override
  String get proBadge => 'Pro';

  @override
  String get presetBadge => 'preset';

  @override
  String get proPlan => 'Pro plan';

  @override
  String get templatesSubtitle => '11 ready designs for regular A4 printers and thermal rolls. Set one default per business — WYSIWYG with the live receipt in Billing.';

  @override
  String get demoProductLine => 'Product one';

  @override
  String get demoServiceLine => 'Service item';

  @override
  String get printSample => 'Print sample';

  @override
  String get printSampleFail => 'Couldn\'t print the sample';

  @override
  String get defaultLabel => 'Default';

  @override
  String get defaultTemplateSet => 'Default template set';

  @override
  String get setDefault => 'Set default';

  @override
  String get apptBook => 'Book';

  @override
  String apptSubtitle(String count) {
    return '$count upcoming · book service, staff and slot.';
  }

  @override
  String get apptVerticalPack => 'Vertical pack';

  @override
  String get apptEmptyTitle => 'No appointments yet';

  @override
  String get apptStatusBooked => 'Booked';

  @override
  String get apptStatusDone => 'Done';

  @override
  String get apptStatusNoShow => 'No-show';

  @override
  String get apptMarkDone => 'Mark done';

  @override
  String get apptBookTitle => 'Book appointment';

  @override
  String get apptCustomer => 'Customer';

  @override
  String get apptEnterCustomer => 'Enter a customer name';

  @override
  String get apptStaff => 'Staff';

  @override
  String apptSlot(String time) {
    return 'Slot · $time';
  }

  @override
  String get apptConfirmBooking => 'Confirm booking';

  @override
  String get apptBookedSnack => 'Appointment booked ✓';
}
