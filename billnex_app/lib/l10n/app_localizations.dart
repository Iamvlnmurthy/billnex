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
