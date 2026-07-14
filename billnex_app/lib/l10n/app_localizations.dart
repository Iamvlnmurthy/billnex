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

  /// No description provided for @quickQty.
  ///
  /// In en, this message translates to:
  /// **'QUICK QUANTITY'**
  String get quickQty;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Billing & khata for Indian businesses'**
  String get aboutTagline;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutBuild.
  ///
  /// In en, this message translates to:
  /// **'build'**
  String get aboutBuild;

  /// No description provided for @aboutPublisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get aboutPublisher;

  /// No description provided for @aboutLicence.
  ///
  /// In en, this message translates to:
  /// **'Licence'**
  String get aboutLicence;

  /// No description provided for @aboutLicenceFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get aboutLicenceFree;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 NexenLabs · Made in India'**
  String get aboutCopyright;

  /// No description provided for @lowStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Low stock · Reorder list'**
  String get lowStockTitle;

  /// No description provided for @lowStockSub.
  ///
  /// In en, this message translates to:
  /// **'Items at or below their reorder level, with a suggested order quantity.'**
  String get lowStockSub;

  /// No description provided for @inStockCol.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStockCol;

  /// No description provided for @reorderAtCol.
  ///
  /// In en, this message translates to:
  /// **'Reorder at'**
  String get reorderAtCol;

  /// No description provided for @suggestedCol.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get suggestedCol;

  /// No description provided for @shareReorderWa.
  ///
  /// In en, this message translates to:
  /// **'Send to supplier'**
  String get shareReorderWa;

  /// No description provided for @stockHealthy.
  ///
  /// In en, this message translates to:
  /// **'All stock is above its reorder level.'**
  String get stockHealthy;

  /// No description provided for @reorderShareFail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open WhatsApp'**
  String get reorderShareFail;

  /// No description provided for @gstr1Title.
  ///
  /// In en, this message translates to:
  /// **'GSTR-1 · Rate-wise (B2C)'**
  String get gstr1Title;

  /// No description provided for @gstr1Sub.
  ///
  /// In en, this message translates to:
  /// **'Outward supplies by GST rate. No buyer GSTIN is captured, so all sales are treated as B2C.'**
  String get gstr1Sub;

  /// No description provided for @cgstCol.
  ///
  /// In en, this message translates to:
  /// **'CGST'**
  String get cgstCol;

  /// No description provided for @sgstCol.
  ///
  /// In en, this message translates to:
  /// **'SGST'**
  String get sgstCol;

  /// No description provided for @invoicesCol.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get invoicesCol;

  /// No description provided for @exportGstPdf.
  ///
  /// In en, this message translates to:
  /// **'GST PDF'**
  String get exportGstPdf;

  /// No description provided for @gstReportFail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export the GST report'**
  String get gstReportFail;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @sendOnWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Send on WhatsApp'**
  String get sendOnWhatsApp;

  /// No description provided for @whatsappFail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open WhatsApp'**
  String get whatsappFail;

  /// No description provided for @balanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance {amt}'**
  String balanceDue(String amt);

  /// No description provided for @receivePayment.
  ///
  /// In en, this message translates to:
  /// **'Receive payment'**
  String get receivePayment;

  /// No description provided for @receivePaymentFor.
  ///
  /// In en, this message translates to:
  /// **'Receive payment · {invoice}'**
  String receivePaymentFor(String invoice);

  /// No description provided for @receive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receive;

  /// No description provided for @paymentRecordedLeft.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded · {amt} still due'**
  String paymentRecordedLeft(String amt);

  /// No description provided for @paymentRecordedPaid.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded · fully paid ✓'**
  String get paymentRecordedPaid;

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

  /// No description provided for @switchRole.
  ///
  /// In en, this message translates to:
  /// **'Switch role'**
  String get switchRole;

  /// No description provided for @securityAudit.
  ///
  /// In en, this message translates to:
  /// **'Security & audit'**
  String get securityAudit;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get toggleTheme;

  /// No description provided for @clearLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearLabel;

  /// No description provided for @toggleFlash.
  ///
  /// In en, this message translates to:
  /// **'Toggle flash'**
  String get toggleFlash;

  /// No description provided for @switchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get switchCamera;

  /// No description provided for @backLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backLabel;

  /// No description provided for @removeLine.
  ///
  /// In en, this message translates to:
  /// **'Remove line'**
  String get removeLine;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scanBarcode;

  /// No description provided for @notSupportedDevice.
  ///
  /// In en, this message translates to:
  /// **'Not supported on this device'**
  String get notSupportedDevice;

  /// No description provided for @pressBackToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressBackToExit;

  /// No description provided for @qbSalePosted.
  ///
  /// In en, this message translates to:
  /// **'{inv} · {mode} {amt}'**
  String qbSalePosted(String inv, String mode, String amt);

  /// No description provided for @qbReturnSuffix.
  ///
  /// In en, this message translates to:
  /// **' · return {amt}'**
  String qbReturnSuffix(String amt);

  /// No description provided for @printFail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t print'**
  String get printFail;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Seamless business management in one tap'**
  String get splashTagline;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts'**
  String get tooManyAttempts;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get wrongPin;

  /// No description provided for @lockedTryIn.
  ///
  /// In en, this message translates to:
  /// **'Locked · try in {sec}s'**
  String lockedTryIn(String sec);

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'BillNex is locked'**
  String get appLocked;

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

  /// No description provided for @featuresSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything is grouped by category with a master switch. Preset-enabled items were auto-allotted for {name} — override anything.'**
  String featuresSubtitle(String name);

  /// No description provided for @featuresEnabledCount.
  ///
  /// In en, this message translates to:
  /// **'{on} of {total} enabled'**
  String featuresEnabledCount(int on, int total);

  /// No description provided for @enableAll.
  ///
  /// In en, this message translates to:
  /// **'Enable all'**
  String get enableAll;

  /// No description provided for @disableAll.
  ///
  /// In en, this message translates to:
  /// **'Disable all'**
  String get disableAll;

  /// No description provided for @proBadge.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get proBadge;

  /// No description provided for @presetBadge.
  ///
  /// In en, this message translates to:
  /// **'preset'**
  String get presetBadge;

  /// No description provided for @proPlan.
  ///
  /// In en, this message translates to:
  /// **'Pro plan'**
  String get proPlan;

  /// No description provided for @templatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'11 ready designs for regular A4 printers and thermal rolls. Set one default per business — WYSIWYG with the live receipt in Billing.'**
  String get templatesSubtitle;

  /// No description provided for @demoProductLine.
  ///
  /// In en, this message translates to:
  /// **'Product one'**
  String get demoProductLine;

  /// No description provided for @demoServiceLine.
  ///
  /// In en, this message translates to:
  /// **'Service item'**
  String get demoServiceLine;

  /// No description provided for @printSample.
  ///
  /// In en, this message translates to:
  /// **'Print sample'**
  String get printSample;

  /// No description provided for @printSampleFail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t print the sample'**
  String get printSampleFail;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @defaultTemplateSet.
  ///
  /// In en, this message translates to:
  /// **'Default template set'**
  String get defaultTemplateSet;

  /// No description provided for @setDefault.
  ///
  /// In en, this message translates to:
  /// **'Set default'**
  String get setDefault;

  /// No description provided for @apptBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get apptBook;

  /// No description provided for @apptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} upcoming · book service, staff and slot.'**
  String apptSubtitle(String count);

  /// No description provided for @apptVerticalPack.
  ///
  /// In en, this message translates to:
  /// **'Vertical pack'**
  String get apptVerticalPack;

  /// No description provided for @apptEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No appointments yet'**
  String get apptEmptyTitle;

  /// No description provided for @apptStatusBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get apptStatusBooked;

  /// No description provided for @apptStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get apptStatusDone;

  /// No description provided for @apptStatusNoShow.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get apptStatusNoShow;

  /// No description provided for @apptMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get apptMarkDone;

  /// No description provided for @apptBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Book appointment'**
  String get apptBookTitle;

  /// No description provided for @apptCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get apptCustomer;

  /// No description provided for @apptEnterCustomer.
  ///
  /// In en, this message translates to:
  /// **'Enter a customer name'**
  String get apptEnterCustomer;

  /// No description provided for @apptStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get apptStaff;

  /// No description provided for @apptSlot.
  ///
  /// In en, this message translates to:
  /// **'Slot · {time}'**
  String apptSlot(String time);

  /// No description provided for @apptConfirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get apptConfirmBooking;

  /// No description provided for @apptBookedSnack.
  ///
  /// In en, this message translates to:
  /// **'Appointment booked ✓'**
  String get apptBookedSnack;

  /// No description provided for @backupNeverBackedUp.
  ///
  /// In en, this message translates to:
  /// **'Never backed up'**
  String get backupNeverBackedUp;

  /// No description provided for @backupJustNow.
  ///
  /// In en, this message translates to:
  /// **'Backed up just now'**
  String get backupJustNow;

  /// No description provided for @backupMinAgo.
  ///
  /// In en, this message translates to:
  /// **'Backed up {mins} min ago'**
  String backupMinAgo(String mins);

  /// No description provided for @backupHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Backed up {hours} h ago'**
  String backupHoursAgo(String hours);

  /// No description provided for @backupDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Backed up {days} d ago'**
  String backupDaysAgo(String days);

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your shop data stays yours. Save it to your device, PC, or your own Google Drive — and restore anytime.'**
  String get backupRestoreSubtitle;

  /// No description provided for @backupCountSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get backupCountSales;

  /// No description provided for @backupCountCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get backupCountCustomers;

  /// No description provided for @backupCountProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get backupCountProducts;

  /// No description provided for @backupCountSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get backupCountSuppliers;

  /// No description provided for @backupDataSummary.
  ///
  /// In en, this message translates to:
  /// **'{bills} bills · {customers} customers · {products} products'**
  String backupDataSummary(String bills, String customers, String products);

  /// No description provided for @saveBackupToFile.
  ///
  /// In en, this message translates to:
  /// **'Save backup to a file'**
  String get saveBackupToFile;

  /// No description provided for @saveDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Choose Google Drive, your PC, or Files in the save dialog.'**
  String get saveDialogHint;

  /// No description provided for @restoreFromFile.
  ///
  /// In en, this message translates to:
  /// **'Restore from a file'**
  String get restoreFromFile;

  /// No description provided for @inThisBackup.
  ///
  /// In en, this message translates to:
  /// **'In this backup'**
  String get inThisBackup;

  /// No description provided for @backupRestoreFootnote.
  ///
  /// In en, this message translates to:
  /// **'Restoring replaces the current data on this device. Keep a copy on Google Drive to move to a new phone or PC in one tap.'**
  String get backupRestoreFootnote;

  /// No description provided for @googleDrive.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get googleDrive;

  /// No description provided for @driveConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get driveConnected;

  /// No description provided for @driveConnectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Connect your account for one-tap backup'**
  String get driveConnectPrompt;

  /// No description provided for @connectGoogleDrive.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Drive'**
  String get connectGoogleDrive;

  /// No description provided for @backUpNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backUpNow;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @noDriveBackups.
  ///
  /// In en, this message translates to:
  /// **'No Drive backups yet.'**
  String get noDriveBackups;

  /// No description provided for @backupsOnYourDrive.
  ///
  /// In en, this message translates to:
  /// **'Backups on your Drive'**
  String get backupsOnYourDrive;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @backupSavedCheck.
  ///
  /// In en, this message translates to:
  /// **'Backup saved ✓'**
  String get backupSavedCheck;

  /// No description provided for @saveCancelled.
  ///
  /// In en, this message translates to:
  /// **'Save cancelled'**
  String get saveCancelled;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {err}'**
  String backupFailed(String err);

  /// No description provided for @dataRestored.
  ///
  /// In en, this message translates to:
  /// **'Data restored ✓'**
  String get dataRestored;

  /// No description provided for @restoreCancelled.
  ///
  /// In en, this message translates to:
  /// **'Restore cancelled'**
  String get restoreCancelled;

  /// No description provided for @notBillnexBackup.
  ///
  /// In en, this message translates to:
  /// **'That file is not a BillNex backup'**
  String get notBillnexBackup;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {err}'**
  String restoreFailed(String err);

  /// No description provided for @googleSignInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in cancelled'**
  String get googleSignInCancelled;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed: {err}'**
  String signInFailed(String err);

  /// No description provided for @backedUpToDrive.
  ///
  /// In en, this message translates to:
  /// **'Backed up to Google Drive ✓'**
  String get backedUpToDrive;

  /// No description provided for @driveBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Drive backup failed: {err}'**
  String driveBackupFailed(String err);

  /// No description provided for @restoredFromDrive.
  ///
  /// In en, this message translates to:
  /// **'Restored from Google Drive ✓'**
  String get restoredFromDrive;

  /// No description provided for @driveRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Drive restore failed: {err}'**
  String driveRestoreFailed(String err);

  /// No description provided for @restoreFromBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup?'**
  String get restoreFromBackupTitle;

  /// No description provided for @restoreFromBackupBody.
  ///
  /// In en, this message translates to:
  /// **'This replaces ALL current data on this device with the backup. This cannot be undone.'**
  String get restoreFromBackupBody;

  /// No description provided for @setUpYourBusiness.
  ///
  /// In en, this message translates to:
  /// **'Set up your business'**
  String get setUpYourBusiness;

  /// No description provided for @featuresRealignNote.
  ///
  /// In en, this message translates to:
  /// **'Features will re-align to this type. Your items, customers and bills stay as they are.'**
  String get featuresRealignNote;

  /// No description provided for @shopBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Shop / business name *'**
  String get shopBusinessName;

  /// No description provided for @shopNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Rajesh Kirana Store'**
  String get shopNameHint;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @ownerName.
  ///
  /// In en, this message translates to:
  /// **'Owner name'**
  String get ownerName;

  /// No description provided for @ownerNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Rajesh Kumar'**
  String get ownerNameHint;

  /// No description provided for @phone10DigitError.
  ///
  /// In en, this message translates to:
  /// **'Enter a 10-digit phone'**
  String get phone10DigitError;

  /// No description provided for @gstinHint.
  ///
  /// In en, this message translates to:
  /// **'15-character GST number'**
  String get gstinHint;

  /// No description provided for @gstin15Error.
  ///
  /// In en, this message translates to:
  /// **'GSTIN must be 15 characters'**
  String get gstin15Error;

  /// No description provided for @addressField.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressField;

  /// No description provided for @gstStateCode.
  ///
  /// In en, this message translates to:
  /// **'GST state code'**
  String get gstStateCode;

  /// No description provided for @gstStateCodeHint.
  ///
  /// In en, this message translates to:
  /// **'36 = Telangana'**
  String get gstStateCodeHint;

  /// No description provided for @stateCode2DigitError.
  ///
  /// In en, this message translates to:
  /// **'2-digit code (e.g. 36)'**
  String get stateCode2DigitError;

  /// No description provided for @pricesIncludeGst.
  ///
  /// In en, this message translates to:
  /// **'Prices include GST'**
  String get pricesIncludeGst;

  /// No description provided for @taxInsidePrice.
  ///
  /// In en, this message translates to:
  /// **'Tax is inside the price (MRP style)'**
  String get taxInsidePrice;

  /// No description provided for @taxAddedOnTop.
  ///
  /// In en, this message translates to:
  /// **'Tax is added on top at billing'**
  String get taxAddedOnTop;

  /// No description provided for @createMyShop.
  ///
  /// In en, this message translates to:
  /// **'Create my shop'**
  String get createMyShop;

  /// No description provided for @setupLaterNote.
  ///
  /// In en, this message translates to:
  /// **'You can change any of this later in Settings. Your catalogue starts empty — add your own products next.'**
  String get setupLaterNote;

  /// No description provided for @catBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing & Counter'**
  String get catBilling;

  /// No description provided for @catTax.
  ///
  /// In en, this message translates to:
  /// **'GST, Tax & Compliance'**
  String get catTax;

  /// No description provided for @catInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory & Stock'**
  String get catInventory;

  /// No description provided for @catCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers & Credit'**
  String get catCustomers;

  /// No description provided for @catOps.
  ///
  /// In en, this message translates to:
  /// **'Operations & Growth'**
  String get catOps;

  /// No description provided for @capFastposName.
  ///
  /// In en, this message translates to:
  /// **'Fast POS & counter billing'**
  String get capFastposName;

  /// No description provided for @capFastposDesc.
  ///
  /// In en, this message translates to:
  /// **'One-screen scan, cart, pay, print'**
  String get capFastposDesc;

  /// No description provided for @capBarcodeScanName.
  ///
  /// In en, this message translates to:
  /// **'Barcode / camera scan'**
  String get capBarcodeScanName;

  /// No description provided for @capBarcodeScanDesc.
  ///
  /// In en, this message translates to:
  /// **'Scanner + Android camera fallback'**
  String get capBarcodeScanDesc;

  /// No description provided for @capWeightScaleName.
  ///
  /// In en, this message translates to:
  /// **'Weight / scale billing'**
  String get capWeightScaleName;

  /// No description provided for @capWeightScaleDesc.
  ///
  /// In en, this message translates to:
  /// **'Decimal kg/g/litre + PLU'**
  String get capWeightScaleDesc;

  /// No description provided for @capMultiUnitName.
  ///
  /// In en, this message translates to:
  /// **'Multi-unit & loose sale'**
  String get capMultiUnitName;

  /// No description provided for @capMultiUnitDesc.
  ///
  /// In en, this message translates to:
  /// **'Buy pack, sell piece / cut-length'**
  String get capMultiUnitDesc;

  /// No description provided for @capQuotationName.
  ///
  /// In en, this message translates to:
  /// **'Quotation & estimate'**
  String get capQuotationName;

  /// No description provided for @capQuotationDesc.
  ///
  /// In en, this message translates to:
  /// **'Send, expire, convert to sale'**
  String get capQuotationDesc;

  /// No description provided for @capKotName.
  ///
  /// In en, this message translates to:
  /// **'KOT / table & kitchen'**
  String get capKotName;

  /// No description provided for @capKotDesc.
  ///
  /// In en, this message translates to:
  /// **'Floor plan, KOT, kitchen routing'**
  String get capKotDesc;

  /// No description provided for @capGstInvoiceName.
  ///
  /// In en, this message translates to:
  /// **'GST tax invoice'**
  String get capGstInvoiceName;

  /// No description provided for @capGstInvoiceDesc.
  ///
  /// In en, this message translates to:
  /// **'CGST/SGST/IGST, HSN, unique numbering'**
  String get capGstInvoiceDesc;

  /// No description provided for @capBillOfSupplyName.
  ///
  /// In en, this message translates to:
  /// **'Bill of supply / composition'**
  String get capBillOfSupplyName;

  /// No description provided for @capBillOfSupplyDesc.
  ///
  /// In en, this message translates to:
  /// **'Non-tax series for exempt sellers'**
  String get capBillOfSupplyDesc;

  /// No description provided for @capConsentName.
  ///
  /// In en, this message translates to:
  /// **'Customer consent & privacy'**
  String get capConsentName;

  /// No description provided for @capConsentDesc.
  ///
  /// In en, this message translates to:
  /// **'Opt-in/out, purpose, timestamp'**
  String get capConsentDesc;

  /// No description provided for @capEInvoiceName.
  ///
  /// In en, this message translates to:
  /// **'E-invoice (IRN) & e-way bill'**
  String get capEInvoiceName;

  /// No description provided for @capEInvoiceDesc.
  ///
  /// In en, this message translates to:
  /// **'IRP payload, signed QR'**
  String get capEInvoiceDesc;

  /// No description provided for @capBatchExpiryName.
  ///
  /// In en, this message translates to:
  /// **'Batch & expiry tracking'**
  String get capBatchExpiryName;

  /// No description provided for @capBatchExpiryDesc.
  ///
  /// In en, this message translates to:
  /// **'FEFO, near-expiry action list'**
  String get capBatchExpiryDesc;

  /// No description provided for @capSerialImeiName.
  ///
  /// In en, this message translates to:
  /// **'Serial / IMEI control'**
  String get capSerialImeiName;

  /// No description provided for @capSerialImeiDesc.
  ///
  /// In en, this message translates to:
  /// **'Unique unit at sale/return/service'**
  String get capSerialImeiDesc;

  /// No description provided for @capVariantMatrixName.
  ///
  /// In en, this message translates to:
  /// **'Variant matrix'**
  String get capVariantMatrixName;

  /// No description provided for @capVariantMatrixDesc.
  ///
  /// In en, this message translates to:
  /// **'Size-colour-style child SKUs'**
  String get capVariantMatrixDesc;

  /// No description provided for @capLabelName.
  ///
  /// In en, this message translates to:
  /// **'Label / tag printing'**
  String get capLabelName;

  /// No description provided for @capLabelDesc.
  ///
  /// In en, this message translates to:
  /// **'Barcode, shelf, garment, MRP labels'**
  String get capLabelDesc;

  /// No description provided for @capProductionName.
  ///
  /// In en, this message translates to:
  /// **'BOM / production'**
  String get capProductionName;

  /// No description provided for @capProductionDesc.
  ///
  /// In en, this message translates to:
  /// **'Recipe, work order, material issue'**
  String get capProductionDesc;

  /// No description provided for @capCreditLedgerName.
  ///
  /// In en, this message translates to:
  /// **'Credit / khata ledger'**
  String get capCreditLedgerName;

  /// No description provided for @capCreditLedgerDesc.
  ///
  /// In en, this message translates to:
  /// **'Due dates, limits, collection, ageing'**
  String get capCreditLedgerDesc;

  /// No description provided for @capLoyaltyName.
  ///
  /// In en, this message translates to:
  /// **'Loyalty & promotions'**
  String get capLoyaltyName;

  /// No description provided for @capLoyaltyDesc.
  ///
  /// In en, this message translates to:
  /// **'Points, coupons, combos'**
  String get capLoyaltyDesc;

  /// No description provided for @capMembershipName.
  ///
  /// In en, this message translates to:
  /// **'Membership & packages'**
  String get capMembershipName;

  /// No description provided for @capMembershipDesc.
  ///
  /// In en, this message translates to:
  /// **'Plans, sessions, renewals'**
  String get capMembershipDesc;

  /// No description provided for @capAppointmentsName.
  ///
  /// In en, this message translates to:
  /// **'Appointments & calendar'**
  String get capAppointmentsName;

  /// No description provided for @capAppointmentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Staff, chair/room, no-show policy'**
  String get capAppointmentsDesc;

  /// No description provided for @capJobCardName.
  ///
  /// In en, this message translates to:
  /// **'Job card / service workflow'**
  String get capJobCardName;

  /// No description provided for @capJobCardDesc.
  ///
  /// In en, this message translates to:
  /// **'Intake, estimate, status, delivery'**
  String get capJobCardDesc;

  /// No description provided for @capRentalName.
  ///
  /// In en, this message translates to:
  /// **'Rental assets & deposits'**
  String get capRentalName;

  /// No description provided for @capRentalDesc.
  ///
  /// In en, this message translates to:
  /// **'Booking, availability, late fee'**
  String get capRentalDesc;

  /// No description provided for @capDeliveryName.
  ///
  /// In en, this message translates to:
  /// **'Orders & delivery'**
  String get capDeliveryName;

  /// No description provided for @capDeliveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Status, proof, COD settlement'**
  String get capDeliveryDesc;

  /// No description provided for @capWholesaleName.
  ///
  /// In en, this message translates to:
  /// **'Wholesale / route sales'**
  String get capWholesaleName;

  /// No description provided for @capWholesaleDesc.
  ///
  /// In en, this message translates to:
  /// **'Price levels, salesman route, schemes'**
  String get capWholesaleDesc;

  /// No description provided for @capMultiStoreName.
  ///
  /// In en, this message translates to:
  /// **'Multi-store & transfers'**
  String get capMultiStoreName;

  /// No description provided for @capMultiStoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Branch stock, consolidated dashboard'**
  String get capMultiStoreDesc;

  /// No description provided for @capRecurringName.
  ///
  /// In en, this message translates to:
  /// **'Recurring / subscription billing'**
  String get capRecurringName;

  /// No description provided for @capRecurringDesc.
  ///
  /// In en, this message translates to:
  /// **'Instalments, AMC, auto-invoice'**
  String get capRecurringDesc;

  /// No description provided for @bizKiranaName.
  ///
  /// In en, this message translates to:
  /// **'Kirana / General Store'**
  String get bizKiranaName;

  /// No description provided for @bizKiranaEdition.
  ///
  /// In en, this message translates to:
  /// **'Retail Standard'**
  String get bizKiranaEdition;

  /// No description provided for @bizKiranaTag.
  ///
  /// In en, this message translates to:
  /// **'Fast counter B2C + khata credit'**
  String get bizKiranaTag;

  /// No description provided for @bizSupermarketName.
  ///
  /// In en, this message translates to:
  /// **'Supermarket / Mini-Mart'**
  String get bizSupermarketName;

  /// No description provided for @bizSupermarketEdition.
  ///
  /// In en, this message translates to:
  /// **'Retail Pro'**
  String get bizSupermarketEdition;

  /// No description provided for @bizSupermarketTag.
  ///
  /// In en, this message translates to:
  /// **'High-volume multi-counter POS'**
  String get bizSupermarketTag;

  /// No description provided for @bizPharmacyName.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy / Medical'**
  String get bizPharmacyName;

  /// No description provided for @bizPharmacyEdition.
  ///
  /// In en, this message translates to:
  /// **'Vertical Pro'**
  String get bizPharmacyEdition;

  /// No description provided for @bizPharmacyTag.
  ///
  /// In en, this message translates to:
  /// **'Batch, expiry, MRP, rack'**
  String get bizPharmacyTag;

  /// No description provided for @bizRestaurantName.
  ///
  /// In en, this message translates to:
  /// **'Restaurant / QSR'**
  String get bizRestaurantName;

  /// No description provided for @bizRestaurantEdition.
  ///
  /// In en, this message translates to:
  /// **'Vertical Pro'**
  String get bizRestaurantEdition;

  /// No description provided for @bizRestaurantTag.
  ///
  /// In en, this message translates to:
  /// **'Table, KOT, kitchen, delivery'**
  String get bizRestaurantTag;

  /// No description provided for @bizBakeryName.
  ///
  /// In en, this message translates to:
  /// **'Cafe / Bakery / Sweets'**
  String get bizBakeryName;

  /// No description provided for @bizBakeryEdition.
  ///
  /// In en, this message translates to:
  /// **'Vertical Standard'**
  String get bizBakeryEdition;

  /// No description provided for @bizBakeryTag.
  ///
  /// In en, this message translates to:
  /// **'Weighted + production batches'**
  String get bizBakeryTag;

  /// No description provided for @bizHardwareName.
  ///
  /// In en, this message translates to:
  /// **'Hardware / Electrical'**
  String get bizHardwareName;

  /// No description provided for @bizHardwareEdition.
  ///
  /// In en, this message translates to:
  /// **'Retail Pro'**
  String get bizHardwareEdition;

  /// No description provided for @bizHardwareTag.
  ///
  /// In en, this message translates to:
  /// **'Counter + quotation + credit'**
  String get bizHardwareTag;

  /// No description provided for @bizFashionName.
  ///
  /// In en, this message translates to:
  /// **'Apparel / Footwear'**
  String get bizFashionName;

  /// No description provided for @bizFashionEdition.
  ///
  /// In en, this message translates to:
  /// **'Vertical Standard'**
  String get bizFashionEdition;

  /// No description provided for @bizFashionTag.
  ///
  /// In en, this message translates to:
  /// **'Variant retail + exchanges'**
  String get bizFashionTag;

  /// No description provided for @bizJewelleryName.
  ///
  /// In en, this message translates to:
  /// **'Jewellery Store'**
  String get bizJewelleryName;

  /// No description provided for @bizJewelleryEdition.
  ///
  /// In en, this message translates to:
  /// **'Vertical Enterprise'**
  String get bizJewelleryEdition;

  /// No description provided for @bizJewelleryTag.
  ///
  /// In en, this message translates to:
  /// **'Weight, purity, making-charge'**
  String get bizJewelleryTag;

  /// No description provided for @bizElectronicsName.
  ///
  /// In en, this message translates to:
  /// **'Mobile / Electronics'**
  String get bizElectronicsName;

  /// No description provided for @bizElectronicsEdition.
  ///
  /// In en, this message translates to:
  /// **'Vertical Pro'**
  String get bizElectronicsEdition;

  /// No description provided for @bizElectronicsTag.
  ///
  /// In en, this message translates to:
  /// **'Serial/IMEI + warranty'**
  String get bizElectronicsTag;

  /// No description provided for @bizSalonName.
  ///
  /// In en, this message translates to:
  /// **'Salon / Spa / Beauty'**
  String get bizSalonName;

  /// No description provided for @bizSalonEdition.
  ///
  /// In en, this message translates to:
  /// **'Vertical Standard'**
  String get bizSalonEdition;

  /// No description provided for @bizSalonTag.
  ///
  /// In en, this message translates to:
  /// **'Appointments + service billing'**
  String get bizSalonTag;

  /// No description provided for @bizWholesaleName.
  ///
  /// In en, this message translates to:
  /// **'Wholesale / Distribution'**
  String get bizWholesaleName;

  /// No description provided for @bizWholesaleEdition.
  ///
  /// In en, this message translates to:
  /// **'Business Pro'**
  String get bizWholesaleEdition;

  /// No description provided for @bizWholesaleTag.
  ///
  /// In en, this message translates to:
  /// **'B2B, route sales, credit'**
  String get bizWholesaleTag;

  /// No description provided for @bizClinicName.
  ///
  /// In en, this message translates to:
  /// **'Clinic / Diagnostic'**
  String get bizClinicName;

  /// No description provided for @bizClinicEdition.
  ///
  /// In en, this message translates to:
  /// **'Vertical Pro'**
  String get bizClinicEdition;

  /// No description provided for @bizClinicTag.
  ///
  /// In en, this message translates to:
  /// **'Patient, service, package billing'**
  String get bizClinicTag;

  /// No description provided for @tplClassicName.
  ///
  /// In en, this message translates to:
  /// **'Classic GST'**
  String get tplClassicName;

  /// No description provided for @tplClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'Formal tax invoice, full HSN table'**
  String get tplClassicDesc;

  /// No description provided for @tplMinimalName.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get tplMinimalName;

  /// No description provided for @tplMinimalDesc.
  ///
  /// In en, this message translates to:
  /// **'Clean, whitespace-led, brand header'**
  String get tplMinimalDesc;

  /// No description provided for @tplModernName.
  ///
  /// In en, this message translates to:
  /// **'Modern Color'**
  String get tplModernName;

  /// No description provided for @tplModernDesc.
  ///
  /// In en, this message translates to:
  /// **'Accent band + card totals'**
  String get tplModernDesc;

  /// No description provided for @tplBilingualName.
  ///
  /// In en, this message translates to:
  /// **'Bilingual हिं/తె'**
  String get tplBilingualName;

  /// No description provided for @tplBilingualDesc.
  ///
  /// In en, this message translates to:
  /// **'Dual-language labels for local trade'**
  String get tplBilingualDesc;

  /// No description provided for @tplWholesaleName.
  ///
  /// In en, this message translates to:
  /// **'Wholesale B2B'**
  String get tplWholesaleName;

  /// No description provided for @tplWholesaleDesc.
  ///
  /// In en, this message translates to:
  /// **'Case/piece, scheme & credit terms'**
  String get tplWholesaleDesc;

  /// No description provided for @tplServiceName.
  ///
  /// In en, this message translates to:
  /// **'Service / Job Card'**
  String get tplServiceName;

  /// No description provided for @tplServiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Labour + parts, technician, warranty'**
  String get tplServiceDesc;

  /// No description provided for @tplQuotationName.
  ///
  /// In en, this message translates to:
  /// **'Quotation'**
  String get tplQuotationName;

  /// No description provided for @tplQuotationDesc.
  ///
  /// In en, this message translates to:
  /// **'Validity, terms, no stock impact'**
  String get tplQuotationDesc;

  /// No description provided for @tplThermal80Name.
  ///
  /// In en, this message translates to:
  /// **'Thermal 80mm'**
  String get tplThermal80Name;

  /// No description provided for @tplThermal80Desc.
  ///
  /// In en, this message translates to:
  /// **'Wide receipt + cutter + QR'**
  String get tplThermal80Desc;

  /// No description provided for @tplThermal58Name.
  ///
  /// In en, this message translates to:
  /// **'Thermal 58mm'**
  String get tplThermal58Name;

  /// No description provided for @tplThermal58Desc.
  ///
  /// In en, this message translates to:
  /// **'Compact kirana receipt'**
  String get tplThermal58Desc;

  /// No description provided for @tplKotName.
  ///
  /// In en, this message translates to:
  /// **'Kitchen KOT'**
  String get tplKotName;

  /// No description provided for @tplKotDesc.
  ///
  /// In en, this message translates to:
  /// **'Items only, no price, station route'**
  String get tplKotDesc;

  /// No description provided for @tplDeliveryName.
  ///
  /// In en, this message translates to:
  /// **'Delivery Challan'**
  String get tplDeliveryName;

  /// No description provided for @tplDeliveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Dispatch note, link invoice later'**
  String get tplDeliveryDesc;

  /// No description provided for @prioMust.
  ///
  /// In en, this message translates to:
  /// **'Must'**
  String get prioMust;

  /// No description provided for @prioShould.
  ///
  /// In en, this message translates to:
  /// **'Should'**
  String get prioShould;

  /// No description provided for @prioCould.
  ///
  /// In en, this message translates to:
  /// **'Could'**
  String get prioCould;

  /// No description provided for @dataIoMenu.
  ///
  /// In en, this message translates to:
  /// **'Data import / export'**
  String get dataIoMenu;

  /// No description provided for @dataIoTitle.
  ///
  /// In en, this message translates to:
  /// **'Data import / export'**
  String get dataIoTitle;

  /// No description provided for @dataIoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export your data as CSV, or bring products & customers in from a spreadsheet.'**
  String get dataIoSubtitle;

  /// No description provided for @dataIoExportSection.
  ///
  /// In en, this message translates to:
  /// **'Export (CSV)'**
  String get dataIoExportSection;

  /// No description provided for @dataIoImportSection.
  ///
  /// In en, this message translates to:
  /// **'Import (CSV)'**
  String get dataIoImportSection;

  /// No description provided for @dataIoExportHint.
  ///
  /// In en, this message translates to:
  /// **'Saved as a spreadsheet-ready .csv file you can open in Excel or Sheets.'**
  String get dataIoExportHint;

  /// No description provided for @dataIoImportHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a .csv file. Existing items are skipped, never overwritten.'**
  String get dataIoImportHint;

  /// No description provided for @exportInventoryCsv.
  ///
  /// In en, this message translates to:
  /// **'Export inventory (CSV)'**
  String get exportInventoryCsv;

  /// No description provided for @exportCustomersCsv.
  ///
  /// In en, this message translates to:
  /// **'Export customers (CSV)'**
  String get exportCustomersCsv;

  /// No description provided for @exportSalesCsv.
  ///
  /// In en, this message translates to:
  /// **'Export sales (CSV)'**
  String get exportSalesCsv;

  /// No description provided for @importInventoryCsv.
  ///
  /// In en, this message translates to:
  /// **'Import inventory (CSV)'**
  String get importInventoryCsv;

  /// No description provided for @importCustomersCsv.
  ///
  /// In en, this message translates to:
  /// **'Import customers (CSV)'**
  String get importCustomersCsv;

  /// No description provided for @exportNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing to export yet.'**
  String get exportNothing;

  /// No description provided for @importConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from CSV?'**
  String get importConfirmTitle;

  /// No description provided for @importConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Rows will be added to your existing data. Duplicates are skipped. This can\'t be undone.'**
  String get importConfirmBody;

  /// No description provided for @importConfirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importConfirmBtn;

  /// No description provided for @importSummary.
  ///
  /// In en, this message translates to:
  /// **'Added {added} · skipped {skipped} · {failed} failed'**
  String importSummary(int added, int skipped, int failed);

  /// No description provided for @importNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing to import — the file had no valid rows.'**
  String get importNothing;

  /// No description provided for @importResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Import complete'**
  String get importResultTitle;

  /// No description provided for @csvImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {err}'**
  String csvImportFailed(String err);

  /// No description provided for @wizardStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String wizardStepOf(int current, int total);

  /// No description provided for @wizardSkipSetup.
  ///
  /// In en, this message translates to:
  /// **'Skip setup'**
  String get wizardSkipSetup;

  /// No description provided for @wizardSkipStep.
  ///
  /// In en, this message translates to:
  /// **'Skip this step'**
  String get wizardSkipStep;

  /// No description provided for @wizardWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BillNex'**
  String get wizardWelcomeTitle;

  /// No description provided for @wizardWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your shop in a minute. Every step is optional — you can skip and change anything later.'**
  String get wizardWelcomeSubtitle;

  /// No description provided for @wizardContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get wizardContinueWithGoogle;

  /// No description provided for @wizardContinueWithoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Continue without account'**
  String get wizardContinueWithoutAccount;

  /// No description provided for @wizardGoogleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in isn\'t configured — continuing without an account'**
  String get wizardGoogleUnavailable;

  /// No description provided for @wizardSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String wizardSignedInAs(String email);

  /// No description provided for @wizardBusinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Your business'**
  String get wizardBusinessTitle;

  /// No description provided for @wizardBusinessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us your shop name and trade — we pre-configure the right features. Both are optional.'**
  String get wizardBusinessSubtitle;

  /// No description provided for @wizardSkipUseStandardStore.
  ///
  /// In en, this message translates to:
  /// **'Skip — use a standard store'**
  String get wizardSkipUseStandardStore;

  /// No description provided for @wizardGstTitle.
  ///
  /// In en, this message translates to:
  /// **'GST & pricing'**
  String get wizardGstTitle;

  /// No description provided for @wizardGstSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your GSTIN for tax invoices and choose how prices are quoted. You can set this later.'**
  String get wizardGstSubtitle;

  /// No description provided for @wizardInventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your products'**
  String get wizardInventoryTitle;

  /// No description provided for @wizardInventorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start with a ready-made catalogue, import your own, or skip and add products later.'**
  String get wizardInventorySubtitle;

  /// No description provided for @wizardLoadSample.
  ///
  /// In en, this message translates to:
  /// **'Load sample catalogue'**
  String get wizardLoadSample;

  /// No description provided for @wizardLoadSampleHint.
  ///
  /// In en, this message translates to:
  /// **'Ready-made items for your business type'**
  String get wizardLoadSampleHint;

  /// No description provided for @wizardImportCsvHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a .csv file of your products'**
  String get wizardImportCsvHint;

  /// No description provided for @wizardItemsInCatalogue.
  ///
  /// In en, this message translates to:
  /// **'{count} items in your catalogue'**
  String wizardItemsInCatalogue(int count);

  /// No description provided for @wizardSampleAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {count} products to your catalogue'**
  String wizardSampleAdded(int count);

  /// No description provided for @wizardSkipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get wizardSkipForNow;

  /// No description provided for @wizardDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set'**
  String get wizardDoneTitle;

  /// No description provided for @wizardDoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your shop is ready. You can fine-tune everything from Settings anytime.'**
  String get wizardDoneSubtitle;

  /// No description provided for @wizardEnterApp.
  ///
  /// In en, this message translates to:
  /// **'Enter BillNex'**
  String get wizardEnterApp;

  /// No description provided for @wizardStandardStore.
  ///
  /// In en, this message translates to:
  /// **'Standard store'**
  String get wizardStandardStore;

  /// No description provided for @wizardNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get wizardNotSet;

  /// Empty-state title for the tablet master-detail pane when nothing is selected
  ///
  /// In en, this message translates to:
  /// **'Select an item'**
  String get selectItemTitle;

  /// Empty-state subtitle for the tablet master-detail pane when nothing is selected
  ///
  /// In en, this message translates to:
  /// **'Choose from the list to see details here.'**
  String get selectItemSub;

  /// No description provided for @printerSettings.
  ///
  /// In en, this message translates to:
  /// **'Printer settings'**
  String get printerSettings;

  /// No description provided for @printerSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'Separate printers for A4 invoices and thermal receipts'**
  String get printerSettingsSub;

  /// No description provided for @thermalRollWidth.
  ///
  /// In en, this message translates to:
  /// **'Thermal roll width'**
  String get thermalRollWidth;

  /// No description provided for @invoicePrinterA4.
  ///
  /// In en, this message translates to:
  /// **'Invoice printer (A4)'**
  String get invoicePrinterA4;

  /// No description provided for @receiptPrinterThermal.
  ///
  /// In en, this message translates to:
  /// **'Receipt printer (thermal)'**
  String get receiptPrinterThermal;

  /// No description provided for @printerAskEachTime.
  ///
  /// In en, this message translates to:
  /// **'Ask each time (system dialog)'**
  String get printerAskEachTime;

  /// No description provided for @choosePrinter.
  ///
  /// In en, this message translates to:
  /// **'Choose printer'**
  String get choosePrinter;

  /// No description provided for @useSystemDialog.
  ///
  /// In en, this message translates to:
  /// **'Use system dialog'**
  String get useSystemDialog;

  /// No description provided for @printerSaved.
  ///
  /// In en, this message translates to:
  /// **'Default printer saved'**
  String get printerSaved;

  /// No description provided for @printerCleared.
  ///
  /// In en, this message translates to:
  /// **'Now using the system dialog'**
  String get printerCleared;

  /// No description provided for @noPrinterFound.
  ///
  /// In en, this message translates to:
  /// **'No printer selected'**
  String get noPrinterFound;

  /// No description provided for @printerSettingsNote.
  ///
  /// In en, this message translates to:
  /// **'With a default printer set, printing goes straight to it. Otherwise the system dialog opens, pre-set to the right paper size.'**
  String get printerSettingsNote;

  /// No description provided for @btThermalTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth thermal printer'**
  String get btThermalTitle;

  /// No description provided for @btThermalSub.
  ///
  /// In en, this message translates to:
  /// **'Print receipts straight to a paired 58/80mm Bluetooth printer (ESC-POS), skipping the system dialog.'**
  String get btThermalSub;

  /// No description provided for @btUseForReceipts.
  ///
  /// In en, this message translates to:
  /// **'Use Bluetooth for receipts'**
  String get btUseForReceipts;

  /// No description provided for @btPairedDevices.
  ///
  /// In en, this message translates to:
  /// **'Paired printers'**
  String get btPairedDevices;

  /// No description provided for @btNoDevices.
  ///
  /// In en, this message translates to:
  /// **'No paired Bluetooth printers found. Pair your printer in Android Settings first.'**
  String get btNoDevices;

  /// No description provided for @btBluetoothOff.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is off. Turn it on to connect a printer.'**
  String get btBluetoothOff;

  /// No description provided for @btRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get btRefresh;

  /// No description provided for @btTestPrint.
  ///
  /// In en, this message translates to:
  /// **'Test print'**
  String get btTestPrint;

  /// No description provided for @btConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get btConnected;

  /// No description provided for @btConnectFail.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect to the printer'**
  String get btConnectFail;

  /// No description provided for @btTestSent.
  ///
  /// In en, this message translates to:
  /// **'Test slip sent to the printer'**
  String get btTestSent;

  /// No description provided for @btPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permission is needed to find printers'**
  String get btPermissionNeeded;

  /// No description provided for @btConnectedTo.
  ///
  /// In en, this message translates to:
  /// **'Printing to {name}'**
  String btConnectedTo(Object name);
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
