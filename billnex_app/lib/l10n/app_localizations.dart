import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('hi'), Locale('te')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'BillNex'**
  String get appName;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get navBilling;

  /// No description provided for @navSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get navSales;

  /// No description provided for @navCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get navCustomers;

  /// No description provided for @navInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get navInventory;

  /// No description provided for @navPurchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get navPurchases;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get navFeatures;

  /// No description provided for @navPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get navPrint;

  /// No description provided for @navAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get navAppointments;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @currentBill.
  ///
  /// In en, this message translates to:
  /// **'Current bill'**
  String get currentBill;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @chargeAndPrint.
  ///
  /// In en, this message translates to:
  /// **'Charge & print'**
  String get chargeAndPrint;

  /// No description provided for @walkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in customer · tap to attach'**
  String get walkInCustomer;

  /// No description provided for @startBilling.
  ///
  /// In en, this message translates to:
  /// **'Start billing'**
  String get startBilling;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @quickBill.
  ///
  /// In en, this message translates to:
  /// **'Quick Bill'**
  String get quickBill;

  /// No description provided for @tally.
  ///
  /// In en, this message translates to:
  /// **'Tally'**
  String get tally;

  /// No description provided for @itemized.
  ///
  /// In en, this message translates to:
  /// **'Itemized'**
  String get itemized;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @collect.
  ///
  /// In en, this message translates to:
  /// **'Collect'**
  String get collect;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @roundOff.
  ///
  /// In en, this message translates to:
  /// **'Round off'**
  String get roundOff;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @frequent.
  ///
  /// In en, this message translates to:
  /// **'FREQUENT'**
  String get frequent;

  /// No description provided for @cashReceived.
  ///
  /// In en, this message translates to:
  /// **'Cash received (optional)'**
  String get cashReceived;

  /// No description provided for @returnChange.
  ///
  /// In en, this message translates to:
  /// **'Return change'**
  String get returnChange;

  /// No description provided for @upi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get upi;

  /// No description provided for @khataCredit.
  ///
  /// In en, this message translates to:
  /// **'Khata (credit)'**
  String get khataCredit;

  /// No description provided for @clearBill.
  ///
  /// In en, this message translates to:
  /// **'Clear bill'**
  String get clearBill;

  /// No description provided for @amountToCollect.
  ///
  /// In en, this message translates to:
  /// **'Amount to collect'**
  String get amountToCollect;

  /// No description provided for @punchAmounts.
  ///
  /// In en, this message translates to:
  /// **'Punch each amount, then Collect'**
  String get punchAmounts;

  /// No description provided for @noCatalogueNeeded.
  ///
  /// In en, this message translates to:
  /// **'No item names or catalogue needed.'**
  String get noCatalogueNeeded;

  /// No description provided for @guidedSetup.
  ///
  /// In en, this message translates to:
  /// **'Guided setup · 60 seconds'**
  String get guidedSetup;

  /// No description provided for @businessType.
  ///
  /// In en, this message translates to:
  /// **'Business type'**
  String get businessType;

  /// No description provided for @chooseYourTrade.
  ///
  /// In en, this message translates to:
  /// **'Choose your trade'**
  String get chooseYourTrade;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @skipStandardStore.
  ///
  /// In en, this message translates to:
  /// **'Skip — start with a standard store'**
  String get skipStandardStore;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @myBusiness.
  ///
  /// In en, this message translates to:
  /// **'MY BUSINESS'**
  String get myBusiness;

  /// No description provided for @setupSection.
  ///
  /// In en, this message translates to:
  /// **'SETUP'**
  String get setupSection;

  /// No description provided for @businessDetails.
  ///
  /// In en, this message translates to:
  /// **'Business details'**
  String get businessDetails;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupRestore;

  /// No description provided for @everythingInOnePlace.
  ///
  /// In en, this message translates to:
  /// **'everything in one place'**
  String get everythingInOnePlace;

  /// No description provided for @inventoryPurchasesSection.
  ///
  /// In en, this message translates to:
  /// **'INVENTORY & PURCHASES'**
  String get inventoryPurchasesSection;

  /// No description provided for @reportsSection.
  ///
  /// In en, this message translates to:
  /// **'REPORTS'**
  String get reportsSection;

  /// No description provided for @billingCounter.
  ///
  /// In en, this message translates to:
  /// **'Billing counter'**
  String get billingCounter;

  /// No description provided for @salesInvoices.
  ///
  /// In en, this message translates to:
  /// **'Sales & invoices'**
  String get salesInvoices;

  /// No description provided for @customersKhata.
  ///
  /// In en, this message translates to:
  /// **'Customers & khata'**
  String get customersKhata;

  /// No description provided for @itemsStock.
  ///
  /// In en, this message translates to:
  /// **'Items & stock'**
  String get itemsStock;

  /// No description provided for @purchasesSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Purchases & suppliers'**
  String get purchasesSuppliers;

  /// No description provided for @reportsAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Reports & analytics'**
  String get reportsAnalytics;

  /// No description provided for @featuresToggles.
  ///
  /// In en, this message translates to:
  /// **'Features & toggles'**
  String get featuresToggles;

  /// No description provided for @printTemplates.
  ///
  /// In en, this message translates to:
  /// **'Print templates'**
  String get printTemplates;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @backupDue.
  ///
  /// In en, this message translates to:
  /// **'due'**
  String get backupDue;

  /// No description provided for @backupNone.
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get backupNone;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'saved'**
  String get backupSaved;

  /// No description provided for @activeFeatures.
  ///
  /// In en, this message translates to:
  /// **'Active features'**
  String get activeFeatures;

  /// No description provided for @greetMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetMorning;

  /// No description provided for @greetAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetAfternoon;

  /// No description provided for @greetEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetEvening;

  /// No description provided for @dashboardWord.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardWord;

  /// No description provided for @lowStockBanner.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 product low in stock} other{{count} products low in stock}}'**
  String lowStockBanner(int count);

  /// No description provided for @backupDueBanner.
  ///
  /// In en, this message translates to:
  /// **'Backup due — protect your data'**
  String get backupDueBanner;

  /// No description provided for @createNewBill.
  ///
  /// In en, this message translates to:
  /// **'Create New Bill'**
  String get createNewBill;

  /// No description provided for @todaysSummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get todaysSummary;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @todaysSales.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S SALES'**
  String get todaysSales;

  /// No description provided for @noBillsYet.
  ///
  /// In en, this message translates to:
  /// **'no bills yet'**
  String get noBillsYet;

  /// No description provided for @billsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 bill} other{{count} bills}}'**
  String billsCount(int count);

  /// No description provided for @totalBills.
  ///
  /// In en, this message translates to:
  /// **'Total Bills'**
  String get totalBills;

  /// No description provided for @cashReceived2.
  ///
  /// In en, this message translates to:
  /// **'Cash Received'**
  String get cashReceived2;

  /// No description provided for @upiCard.
  ///
  /// In en, this message translates to:
  /// **'UPI / Card'**
  String get upiCard;

  /// No description provided for @creditSales.
  ///
  /// In en, this message translates to:
  /// **'Credit Sales'**
  String get creditSales;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @viewStock.
  ///
  /// In en, this message translates to:
  /// **'View Stock'**
  String get viewStock;

  /// No description provided for @ledger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get ledger;

  /// No description provided for @dayClosing.
  ///
  /// In en, this message translates to:
  /// **'Day Closing'**
  String get dayClosing;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noBillsTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'No bills yet today'**
  String get noBillsTodayTitle;

  /// No description provided for @noBillsTodaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your posted bills will appear here. Tap “Create New Bill” to make your first sale.'**
  String get noBillsTodaySubtitle;

  /// No description provided for @billNo.
  ///
  /// In en, this message translates to:
  /// **'Bill {no}'**
  String billNo(String no);

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paid;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pending;

  /// No description provided for @salesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesTitle;

  /// No description provided for @salesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} bills · {total} total · every bill is immutable and reprintable.'**
  String salesSubtitle(int count, String total);

  /// No description provided for @auditedReprint.
  ///
  /// In en, this message translates to:
  /// **'Audited reprint'**
  String get auditedReprint;

  /// No description provided for @salesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No bills yet'**
  String get salesEmptyTitle;

  /// No description provided for @salesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Post a sale from Billing — it appears here.'**
  String get salesEmptySubtitle;

  /// No description provided for @returnDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Return this bill?'**
  String get returnDialogTitle;

  /// No description provided for @returnDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Create a credit note for {inv} ({amount}). Items go back into stock.'**
  String returnDialogBody(String inv, String amount);

  /// No description provided for @returnCreditKhataNote.
  ///
  /// In en, this message translates to:
  /// **'\n\nThis was a credit bill — adjust the customer\'s khata separately.'**
  String get returnCreditKhataNote;

  /// No description provided for @returnAction.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnAction;

  /// No description provided for @returnSnack.
  ///
  /// In en, this message translates to:
  /// **'{ret} · credit note for {inv} ✓'**
  String returnSnack(String ret, String inv);

  /// No description provided for @chipReturn.
  ///
  /// In en, this message translates to:
  /// **'RETURN'**
  String get chipReturn;

  /// No description provided for @chipPaidMode.
  ///
  /// In en, this message translates to:
  /// **'PAID · {mode}'**
  String chipPaidMode(String mode);

  /// No description provided for @saleItemsLine.
  ///
  /// In en, this message translates to:
  /// **'{date} · {items} items'**
  String saleItemsLine(String date, String items);

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @reprint.
  ///
  /// In en, this message translates to:
  /// **'Reprint'**
  String get reprint;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @returnCreditNote.
  ///
  /// In en, this message translates to:
  /// **'Return / credit note'**
  String get returnCreditNote;

  /// No description provided for @reprintFail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reprint — check the printer'**
  String get reprintFail;

  /// No description provided for @shareFail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share the PDF'**
  String get shareFail;

  /// No description provided for @invTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory & Stock'**
  String get invTitle;

  /// No description provided for @invSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{skus} SKUs · {low} low · {value} at cost.'**
  String invSubtitle(int skus, int low, String value);

  /// No description provided for @liveStockLedger.
  ///
  /// In en, this message translates to:
  /// **'Live stock ledger'**
  String get liveStockLedger;

  /// No description provided for @searchItem.
  ///
  /// In en, this message translates to:
  /// **'Search item…'**
  String get searchItem;

  /// No description provided for @lowFilter.
  ///
  /// In en, this message translates to:
  /// **'Low ({count})'**
  String lowFilter(int count);

  /// No description provided for @noProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsTitle;

  /// No description provided for @noMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noMatchesTitle;

  /// No description provided for @noProductsSub.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add product\" to build your catalogue.'**
  String get noProductsSub;

  /// No description provided for @noMatchesSub.
  ///
  /// In en, this message translates to:
  /// **'Try a different search.'**
  String get noMatchesSub;

  /// No description provided for @addProductBtn.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProductBtn;

  /// No description provided for @chipOut.
  ///
  /// In en, this message translates to:
  /// **'OUT'**
  String get chipOut;

  /// No description provided for @chipLow.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get chipLow;

  /// No description provided for @pricePerUnitReorder.
  ///
  /// In en, this message translates to:
  /// **'{price} / {unit} · reorder {reorder}'**
  String pricePerUnitReorder(String price, String unit, String reorder);

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'service'**
  String get service;

  /// No description provided for @newProduct.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get newProduct;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @enterProductName.
  ///
  /// In en, this message translates to:
  /// **'Enter a product name'**
  String get enterProductName;

  /// No description provided for @productExistsErr.
  ///
  /// In en, this message translates to:
  /// **'A product with this name already exists'**
  String get productExistsErr;

  /// No description provided for @fieldUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get fieldUnit;

  /// No description provided for @sellPrice.
  ///
  /// In en, this message translates to:
  /// **'Sell price'**
  String get sellPrice;

  /// No description provided for @enterPriceGt0.
  ///
  /// In en, this message translates to:
  /// **'Enter a price > 0'**
  String get enterPriceGt0;

  /// No description provided for @costOptional.
  ///
  /// In en, this message translates to:
  /// **'Cost (optional)'**
  String get costOptional;

  /// No description provided for @trackStock.
  ///
  /// In en, this message translates to:
  /// **'Track stock'**
  String get trackStock;

  /// No description provided for @trackStockSub.
  ///
  /// In en, this message translates to:
  /// **'Off for services (salon, repair)'**
  String get trackStockSub;

  /// No description provided for @openingQty.
  ///
  /// In en, this message translates to:
  /// **'Opening qty'**
  String get openingQty;

  /// No description provided for @geZero.
  ///
  /// In en, this message translates to:
  /// **'≥ 0'**
  String get geZero;

  /// No description provided for @reorderLevel.
  ///
  /// In en, this message translates to:
  /// **'Reorder level'**
  String get reorderLevel;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategory;

  /// No description provided for @hsnSac.
  ///
  /// In en, this message translates to:
  /// **'HSN/SAC'**
  String get hsnSac;

  /// No description provided for @barcodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Barcode (optional)'**
  String get barcodeOptional;

  /// No description provided for @barcodeUsedErr.
  ///
  /// In en, this message translates to:
  /// **'Barcode already used by another product'**
  String get barcodeUsedErr;

  /// No description provided for @addToCatalogue.
  ///
  /// In en, this message translates to:
  /// **'Add to catalogue'**
  String get addToCatalogue;

  /// No description provided for @gstPct.
  ///
  /// In en, this message translates to:
  /// **'GST %'**
  String get gstPct;

  /// No description provided for @addedSnack.
  ///
  /// In en, this message translates to:
  /// **'{name} added ✓'**
  String addedSnack(String name);

  /// No description provided for @addFailExists.
  ///
  /// In en, this message translates to:
  /// **'Could not add — name already exists'**
  String get addFailExists;

  /// No description provided for @onHand.
  ///
  /// In en, this message translates to:
  /// **'ON HAND'**
  String get onHand;

  /// No description provided for @reorderAtCost.
  ///
  /// In en, this message translates to:
  /// **'Reorder at {reorder} · cost {cost}'**
  String reorderAtCost(String reorder, String cost);

  /// No description provided for @reduce.
  ///
  /// In en, this message translates to:
  /// **'Reduce'**
  String get reduce;

  /// No description provided for @addStock.
  ///
  /// In en, this message translates to:
  /// **'Add stock'**
  String get addStock;

  /// No description provided for @batches.
  ///
  /// In en, this message translates to:
  /// **'Batches'**
  String get batches;

  /// No description provided for @chipExpired.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get chipExpired;

  /// No description provided for @chipNearExpiry.
  ///
  /// In en, this message translates to:
  /// **'NEAR EXPIRY'**
  String get chipNearExpiry;

  /// No description provided for @batchNo.
  ///
  /// In en, this message translates to:
  /// **'Batch {no}'**
  String batchNo(String no);

  /// No description provided for @expLabel.
  ///
  /// In en, this message translates to:
  /// **'exp {date}'**
  String expLabel(String date);

  /// No description provided for @movementHistory.
  ///
  /// In en, this message translates to:
  /// **'Movement history'**
  String get movementHistory;

  /// No description provided for @editProductTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProductTooltip;

  /// No description provided for @deleteProductTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get deleteProductTooltip;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterName;

  /// No description provided for @fieldReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get fieldReorder;

  /// No description provided for @fieldCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get fieldCost;

  /// No description provided for @gtZeroShort.
  ///
  /// In en, this message translates to:
  /// **'> 0'**
  String get gtZeroShort;

  /// No description provided for @usedByAnother.
  ///
  /// In en, this message translates to:
  /// **'Used by another product'**
  String get usedByAnother;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product updated ✓'**
  String get productUpdated;

  /// No description provided for @removeProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove product?'**
  String get removeProductTitle;

  /// No description provided for @removeProductBody.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from your catalogue? Past sales keep their records.'**
  String removeProductBody(String name);

  /// No description provided for @removeAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAction;

  /// No description provided for @addStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Add stock · {name}'**
  String addStockTitle(String name);

  /// No description provided for @reduceStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce stock · {name}'**
  String reduceStockTitle(String name);

  /// No description provided for @onHandLabel.
  ///
  /// In en, this message translates to:
  /// **'On hand: {qty} {unit}'**
  String onHandLabel(String qty, String unit);

  /// No description provided for @quantityUnit.
  ///
  /// In en, this message translates to:
  /// **'Quantity ({unit})'**
  String quantityUnit(String unit);

  /// No description provided for @reasonField.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reasonField;

  /// No description provided for @recordAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Record adjustment'**
  String get recordAdjustment;

  /// No description provided for @enterQtyGt0.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity greater than 0'**
  String get enterQtyGt0;

  /// No description provided for @stockAdded.
  ///
  /// In en, this message translates to:
  /// **'Stock added ✓'**
  String get stockAdded;

  /// No description provided for @stockReduced.
  ///
  /// In en, this message translates to:
  /// **'Stock reduced ✓'**
  String get stockReduced;

  /// No description provided for @purchaseRestock.
  ///
  /// In en, this message translates to:
  /// **'Purchase / restock'**
  String get purchaseRestock;

  /// No description provided for @damageCorrection.
  ///
  /// In en, this message translates to:
  /// **'Damage / correction'**
  String get damageCorrection;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports & Analytics'**
  String get reportsTitle;

  /// No description provided for @reportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything below is computed live from posted transactions.'**
  String get reportsSubtitle;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @exportReportFail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export the report'**
  String get exportReportFail;

  /// No description provided for @kpiNetSales.
  ///
  /// In en, this message translates to:
  /// **'Net sales'**
  String get kpiNetSales;

  /// No description provided for @kpiGstCollected.
  ///
  /// In en, this message translates to:
  /// **'GST collected'**
  String get kpiGstCollected;

  /// No description provided for @kpiBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get kpiBills;

  /// No description provided for @kpiAvgBill.
  ///
  /// In en, this message translates to:
  /// **'Avg bill'**
  String get kpiAvgBill;

  /// No description provided for @kpiItemsSold.
  ///
  /// In en, this message translates to:
  /// **'Items sold'**
  String get kpiItemsSold;

  /// No description provided for @kpiReceivable.
  ///
  /// In en, this message translates to:
  /// **'Receivable'**
  String get kpiReceivable;

  /// No description provided for @kpiPayable.
  ///
  /// In en, this message translates to:
  /// **'Payable'**
  String get kpiPayable;

  /// No description provided for @kpiStockAtCost.
  ///
  /// In en, this message translates to:
  /// **'Stock @ cost'**
  String get kpiStockAtCost;

  /// No description provided for @profitLoss.
  ///
  /// In en, this message translates to:
  /// **'Profit & Loss'**
  String get profitLoss;

  /// No description provided for @plSalesTaxable.
  ///
  /// In en, this message translates to:
  /// **'Sales (taxable)'**
  String get plSalesTaxable;

  /// No description provided for @plCogs.
  ///
  /// In en, this message translates to:
  /// **'Cost of goods sold'**
  String get plCogs;

  /// No description provided for @plGrossProfit.
  ///
  /// In en, this message translates to:
  /// **'Gross profit'**
  String get plGrossProfit;

  /// No description provided for @plGstNote.
  ///
  /// In en, this message translates to:
  /// **'GST collected {amt} is a pass-through, not income.'**
  String plGstNote(String amt);

  /// No description provided for @hsnSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale summary by HSN'**
  String get hsnSummaryTitle;

  /// No description provided for @csv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get csv;

  /// No description provided for @noSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No sales yet'**
  String get noSalesYet;

  /// No description provided for @hsnCol.
  ///
  /// In en, this message translates to:
  /// **'HSN'**
  String get hsnCol;

  /// No description provided for @gstCol.
  ///
  /// In en, this message translates to:
  /// **'GST'**
  String get gstCol;

  /// No description provided for @taxableCol.
  ///
  /// In en, this message translates to:
  /// **'TAXABLE'**
  String get taxableCol;

  /// No description provided for @taxCol.
  ///
  /// In en, this message translates to:
  /// **'TAX'**
  String get taxCol;

  /// No description provided for @dayBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Day book'**
  String get dayBookTitle;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactions;

  /// No description provided for @paymentMixTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment mix'**
  String get paymentMixTitle;

  /// No description provided for @topItems.
  ///
  /// In en, this message translates to:
  /// **'Top items'**
  String get topItems;

  /// No description provided for @qtySold.
  ///
  /// In en, this message translates to:
  /// **'{qty} sold'**
  String qtySold(String qty);

  /// No description provided for @saveFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Save {file}'**
  String saveFileTitle(String file);

  /// No description provided for @exportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled'**
  String get exportCancelled;

  /// No description provided for @savedFile.
  ///
  /// In en, this message translates to:
  /// **'Saved {file} ✓'**
  String savedFile(String file);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {err}'**
  String exportFailed(String err);

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add customer'**
  String get addCustomer;

  /// No description provided for @customersTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers & Credit'**
  String get customersTitle;

  /// No description provided for @customersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} customers · {receivable} receivable across {accounts} accounts.'**
  String customersSubtitle(int count, String receivable, int accounts);

  /// No description provided for @khataLedger.
  ///
  /// In en, this message translates to:
  /// **'Khata ledger'**
  String get khataLedger;

  /// No description provided for @noCustomersTitle.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get noCustomersTitle;

  /// No description provided for @noCustomersSub.
  ///
  /// In en, this message translates to:
  /// **'Add one here, or attach a customer on a credit sale.'**
  String get noCustomersSub;

  /// No description provided for @sectionOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get sectionOutstanding;

  /// No description provided for @sectionSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get sectionSettled;

  /// No description provided for @overLimit.
  ///
  /// In en, this message translates to:
  /// **'Over limit'**
  String get overLimit;

  /// No description provided for @noMobile.
  ///
  /// In en, this message translates to:
  /// **'No mobile'**
  String get noMobile;

  /// No description provided for @settledLabel.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settledLabel;

  /// No description provided for @outstandingLabel.
  ///
  /// In en, this message translates to:
  /// **'outstanding'**
  String get outstandingLabel;

  /// No description provided for @noDues.
  ///
  /// In en, this message translates to:
  /// **'no dues'**
  String get noDues;

  /// No description provided for @outstandingBalance.
  ///
  /// In en, this message translates to:
  /// **'OUTSTANDING BALANCE'**
  String get outstandingBalance;

  /// No description provided for @limitLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit {amt}'**
  String limitLabel(String amt);

  /// No description provided for @collectPayment.
  ///
  /// In en, this message translates to:
  /// **'Collect payment'**
  String get collectPayment;

  /// No description provided for @ledgerLabel.
  ///
  /// In en, this message translates to:
  /// **'LEDGER'**
  String get ledgerLabel;

  /// No description provided for @noLedgerEntries.
  ///
  /// In en, this message translates to:
  /// **'No ledger entries'**
  String get noLedgerEntries;

  /// No description provided for @balLabel.
  ///
  /// In en, this message translates to:
  /// **'bal {amt}'**
  String balLabel(String amt);

  /// No description provided for @collectFrom.
  ///
  /// In en, this message translates to:
  /// **'Collect from {name}'**
  String collectFrom(String name);

  /// No description provided for @outstandingSuffix.
  ///
  /// In en, this message translates to:
  /// **'{amt} outstanding'**
  String outstandingSuffix(String amt);

  /// No description provided for @recordCollection.
  ///
  /// In en, this message translates to:
  /// **'Record collection'**
  String get recordCollection;

  /// No description provided for @enterAmtGt0.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0'**
  String get enterAmtGt0;

  /// No description provided for @collectedSnack.
  ///
  /// In en, this message translates to:
  /// **'{ref} · {amt} collected ✓'**
  String collectedSnack(String ref, String amt);

  /// No description provided for @billingTitle.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get billingTitle;

  /// No description provided for @billingSubtitleWide.
  ///
  /// In en, this message translates to:
  /// **'Search or scan · live receipt updates as you go.'**
  String get billingSubtitleWide;

  /// No description provided for @billingSubtitlePhone.
  ///
  /// In en, this message translates to:
  /// **'Search or scan to add items.'**
  String get billingSubtitlePhone;

  /// No description provided for @itemCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemCountLabel(String count);

  /// No description provided for @viewBill.
  ///
  /// In en, this message translates to:
  /// **'View bill'**
  String get viewBill;

  /// No description provided for @noProductBarcode.
  ///
  /// In en, this message translates to:
  /// **'No product with barcode {code}'**
  String noProductBarcode(String code);

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'{name} is out of stock'**
  String outOfStock(String name);

  /// No description provided for @enterBarcodeSku.
  ///
  /// In en, this message translates to:
  /// **'Enter barcode / SKU'**
  String get enterBarcodeSku;

  /// No description provided for @barcodeHint.
  ///
  /// In en, this message translates to:
  /// **'Barcode or product code'**
  String get barcodeHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products…'**
  String get searchProducts;

  /// No description provided for @posNoProductsSub.
  ///
  /// In en, this message translates to:
  /// **'Add your shop\'s products in the Inventory tab, then bill them here.'**
  String get posNoProductsSub;

  /// No description provided for @noProductsMatch.
  ///
  /// In en, this message translates to:
  /// **'No products match \"{q}\"'**
  String noProductsMatch(String q);

  /// No description provided for @serviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceLabel;

  /// No description provided for @qtyBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} qty'**
  String qtyBadge(String count);

  /// No description provided for @tapProductToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap a product to start the bill'**
  String get tapProductToStart;

  /// No description provided for @taxable.
  ///
  /// In en, this message translates to:
  /// **'Taxable'**
  String get taxable;

  /// No description provided for @cgst.
  ///
  /// In en, this message translates to:
  /// **'CGST'**
  String get cgst;

  /// No description provided for @sgst.
  ///
  /// In en, this message translates to:
  /// **'SGST'**
  String get sgst;

  /// No description provided for @billDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'Bill discount'**
  String get billDiscountLabel;

  /// No description provided for @upiQr.
  ///
  /// In en, this message translates to:
  /// **'UPI QR'**
  String get upiQr;

  /// No description provided for @sendKot.
  ///
  /// In en, this message translates to:
  /// **'Send to Kitchen (KOT)'**
  String get sendKot;

  /// No description provided for @addItemsToCharge.
  ///
  /// In en, this message translates to:
  /// **'Add items to charge'**
  String get addItemsToCharge;

  /// No description provided for @chargePrintAmt.
  ///
  /// In en, this message translates to:
  /// **'Charge & print · {amt}'**
  String chargePrintAmt(String amt);

  /// No description provided for @liveReceipt.
  ///
  /// In en, this message translates to:
  /// **'Live receipt'**
  String get liveReceipt;

  /// No description provided for @addItemsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'— add items —'**
  String get addItemsPlaceholder;

  /// No description provided for @kotSent.
  ///
  /// In en, this message translates to:
  /// **'KOT sent to kitchen ✓'**
  String get kotSent;

  /// No description provided for @kotPrintFail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t print the kitchen ticket — check the printer'**
  String get kotPrintFail;

  /// No description provided for @addItemsFirst.
  ///
  /// In en, this message translates to:
  /// **'Add items first'**
  String get addItemsFirst;

  /// No description provided for @creditNeedsCustomer.
  ///
  /// In en, this message translates to:
  /// **'Credit sale needs a customer'**
  String get creditNeedsCustomer;

  /// No description provided for @creditLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Credit limit exceeded'**
  String get creditLimitExceeded;

  /// No description provided for @creditLimitBody.
  ///
  /// In en, this message translates to:
  /// **'{name} would exceed the {limit} limit. Post anyway?'**
  String creditLimitBody(String name, String limit);

  /// No description provided for @overrideAction.
  ///
  /// In en, this message translates to:
  /// **'Override'**
  String get overrideAction;

  /// No description provided for @salePostedPrefix.
  ///
  /// In en, this message translates to:
  /// **'{inv} posted · {mode} {amt}'**
  String salePostedPrefix(String inv, String mode, String amt);

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @quantityOf.
  ///
  /// In en, this message translates to:
  /// **'Quantity · {name}'**
  String quantityOf(String name);

  /// No description provided for @setLabel.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get setLabel;

  /// No description provided for @removeCustomer.
  ///
  /// In en, this message translates to:
  /// **'Remove customer'**
  String get removeCustomer;

  /// No description provided for @increaseQty.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get increaseQty;

  /// No description provided for @decreaseQty.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get decreaseQty;

  /// No description provided for @newPurchase.
  ///
  /// In en, this message translates to:
  /// **'New purchase'**
  String get newPurchase;

  /// No description provided for @purchasingTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchasing & Suppliers'**
  String get purchasingTitle;

  /// No description provided for @purchasingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} suppliers · {payable} payable · {purchases} purchases.'**
  String purchasingSubtitle(int count, String payable, int purchases);

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @noSuppliersTitle.
  ///
  /// In en, this message translates to:
  /// **'No suppliers yet'**
  String get noSuppliersTitle;

  /// No description provided for @noSuppliersSub.
  ///
  /// In en, this message translates to:
  /// **'Add a supplier, then record a purchase to stock-in.'**
  String get noSuppliersSub;

  /// No description provided for @noContact.
  ///
  /// In en, this message translates to:
  /// **'No contact'**
  String get noContact;

  /// No description provided for @payableLower.
  ///
  /// In en, this message translates to:
  /// **'payable'**
  String get payableLower;

  /// No description provided for @newSupplier.
  ///
  /// In en, this message translates to:
  /// **'New supplier'**
  String get newSupplier;

  /// No description provided for @phoneField.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneField;

  /// No description provided for @gstinOptional.
  ///
  /// In en, this message translates to:
  /// **'GSTIN (optional)'**
  String get gstinOptional;

  /// No description provided for @saveSupplier.
  ///
  /// In en, this message translates to:
  /// **'Save supplier'**
  String get saveSupplier;

  /// No description provided for @recordPurchase.
  ///
  /// In en, this message translates to:
  /// **'Record purchase'**
  String get recordPurchase;

  /// No description provided for @supplierInvoiceNo.
  ///
  /// In en, this message translates to:
  /// **'Supplier invoice no.'**
  String get supplierInvoiceNo;

  /// No description provided for @duplicateInvoiceSupplier.
  ///
  /// In en, this message translates to:
  /// **'Duplicate invoice for this supplier'**
  String get duplicateInvoiceSupplier;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @noItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get noItemsYet;

  /// No description provided for @totalInclGst.
  ///
  /// In en, this message translates to:
  /// **'Total (incl. GST)'**
  String get totalInclGst;

  /// No description provided for @paidNow.
  ///
  /// In en, this message translates to:
  /// **'Paid now'**
  String get paidNow;

  /// No description provided for @noPayableCreated.
  ///
  /// In en, this message translates to:
  /// **'No payable created'**
  String get noPayableCreated;

  /// No description provided for @addsToPayable.
  ///
  /// In en, this message translates to:
  /// **'Adds to supplier payable'**
  String get addsToPayable;

  /// No description provided for @duplicateChangeRef.
  ///
  /// In en, this message translates to:
  /// **'Duplicate invoice — change the ref'**
  String get duplicateChangeRef;

  /// No description provided for @recordPurchaseStockIn.
  ///
  /// In en, this message translates to:
  /// **'Record purchase & stock-in'**
  String get recordPurchaseStockIn;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get removeItem;

  /// No description provided for @amtPayable.
  ///
  /// In en, this message translates to:
  /// **'{amt} payable'**
  String amtPayable(String amt);

  /// No description provided for @onHandCost.
  ///
  /// In en, this message translates to:
  /// **'on hand {qty} · cost {cost}'**
  String onHandCost(String qty, String cost);

  /// No description provided for @qtyUnit.
  ///
  /// In en, this message translates to:
  /// **'Qty ({unit})'**
  String qtyUnit(String unit);

  /// No description provided for @addLine.
  ///
  /// In en, this message translates to:
  /// **'Add line'**
  String get addLine;

  /// No description provided for @purchaseRecordedSnack.
  ///
  /// In en, this message translates to:
  /// **'Purchase recorded · {count} items stocked-in ✓'**
  String purchaseRecordedSnack(String count);

  /// No description provided for @payableBalance.
  ///
  /// In en, this message translates to:
  /// **'PAYABLE BALANCE'**
  String get payableBalance;

  /// No description provided for @paySupplierBtn.
  ///
  /// In en, this message translates to:
  /// **'Pay supplier'**
  String get paySupplierBtn;

  /// No description provided for @purchasesUpper.
  ///
  /// In en, this message translates to:
  /// **'PURCHASES'**
  String get purchasesUpper;

  /// No description provided for @noPurchases.
  ///
  /// In en, this message translates to:
  /// **'No purchases'**
  String get noPurchases;

  /// No description provided for @creditChip.
  ///
  /// In en, this message translates to:
  /// **'CREDIT'**
  String get creditChip;

  /// No description provided for @noRef.
  ///
  /// In en, this message translates to:
  /// **'no ref'**
  String get noRef;

  /// No description provided for @purchaseLineInfo.
  ///
  /// In en, this message translates to:
  /// **'{ref} · {date} · {items} items'**
  String purchaseLineInfo(String ref, String date, String items);

  /// No description provided for @paySupplierTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay {name}'**
  String paySupplierTitle(String name);

  /// No description provided for @payableColon.
  ///
  /// In en, this message translates to:
  /// **'Payable: {amt}'**
  String payableColon(String amt);

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get recordPayment;

  /// No description provided for @paidToSnack.
  ///
  /// In en, this message translates to:
  /// **'Paid {amt} to {name} ✓'**
  String paidToSnack(String amt, String name);
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LEn();
    case 'hi':
      return LHi();
    case 'te':
      return LTe();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
