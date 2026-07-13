// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class LHi extends L {
  LHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'बिलनेक्स';

  @override
  String get navDashboard => 'डैशबोर्ड';

  @override
  String get navBilling => 'बिलिंग';

  @override
  String get navSales => 'बिक्री';

  @override
  String get navCustomers => 'ग्राहक';

  @override
  String get navInventory => 'स्टॉक';

  @override
  String get navPurchases => 'खरीद';

  @override
  String get navReports => 'रिपोर्ट';

  @override
  String get navFeatures => 'फ़ीचर';

  @override
  String get navPrint => 'प्रिंट';

  @override
  String get navAppointments => 'अपॉइंटमेंट';

  @override
  String get online => 'ऑनलाइन';

  @override
  String get offline => 'ऑफ़लाइन';

  @override
  String get queue => 'कतार';

  @override
  String get backup => 'बैकअप';

  @override
  String get currentBill => 'वर्तमान बिल';

  @override
  String get subtotal => 'उप-योग';

  @override
  String get total => 'कुल';

  @override
  String get cash => 'नकद';

  @override
  String get credit => 'उधार';

  @override
  String get chargeAndPrint => 'भुगतान और प्रिंट';

  @override
  String get walkInCustomer => 'वॉक-इन ग्राहक · जोड़ने के लिए टैप करें';

  @override
  String get startBilling => 'बिलिंग शुरू करें';

  @override
  String get language => 'भाषा';

  @override
  String get goodEvening => 'नमस्ते';

  @override
  String get quickBill => 'क्विक बिल';

  @override
  String get tally => 'टैली';

  @override
  String get itemized => 'आइटम-वार';

  @override
  String get amount => 'राशि';

  @override
  String get add => 'जोड़ें';

  @override
  String get collect => 'वसूल करें';

  @override
  String get discount => 'छूट';

  @override
  String get roundOff => 'राउंड ऑफ';

  @override
  String get item => 'वस्तु';

  @override
  String get unit => 'इकाई';

  @override
  String get qty => 'मात्रा';

  @override
  String get rate => 'दर';

  @override
  String get addItem => 'वस्तु जोड़ें';

  @override
  String get frequent => 'अक्सर';

  @override
  String get cashReceived => 'नकद प्राप्त (वैकल्पिक)';

  @override
  String get returnChange => 'बाकी लौटाएं';

  @override
  String get upi => 'UPI';

  @override
  String get khataCredit => 'खाता (उधार)';

  @override
  String get clearBill => 'बिल साफ़ करें';

  @override
  String get amountToCollect => 'वसूलने की राशि';

  @override
  String get punchAmounts => 'हर राशि दर्ज करें, फिर वसूल करें';

  @override
  String get noCatalogueNeeded => 'वस्तु के नाम या कैटलॉग की ज़रूरत नहीं।';

  @override
  String get guidedSetup => 'निर्देशित सेटअप · 60 सेकंड';

  @override
  String get businessType => 'व्यवसाय प्रकार';

  @override
  String get chooseYourTrade => 'अपना व्यापार चुनें';

  @override
  String get continueLabel => 'जारी रखें';

  @override
  String get skipStandardStore => 'छोड़ें — मानक स्टोर से शुरू करें';

  @override
  String get menu => 'मेन्यू';

  @override
  String get myBusiness => 'मेरा व्यवसाय';

  @override
  String get setupSection => 'सेटअप';

  @override
  String get businessDetails => 'व्यवसाय विवरण';

  @override
  String get backupRestore => 'बैकअप और रिस्टोर';

  @override
  String get everythingInOnePlace => 'सब कुछ एक जगह';

  @override
  String get inventoryPurchasesSection => 'स्टॉक और खरीद';

  @override
  String get reportsSection => 'रिपोर्ट';

  @override
  String get billingCounter => 'बिलिंग काउंटर';

  @override
  String get salesInvoices => 'बिक्री और बिल';

  @override
  String get customersKhata => 'ग्राहक और खाता';

  @override
  String get itemsStock => 'वस्तुएँ और स्टॉक';

  @override
  String get purchasesSuppliers => 'खरीद और आपूर्तिकर्ता';

  @override
  String get reportsAnalytics => 'रिपोर्ट और विश्लेषण';

  @override
  String get featuresToggles => 'फ़ीचर और टॉगल';

  @override
  String get printTemplates => 'प्रिंट टेम्पलेट';

  @override
  String get syncNow => 'अभी सिंक करें';

  @override
  String get backupDue => 'बाकी';

  @override
  String get backupNone => 'नहीं';

  @override
  String get backupSaved => 'सहेजा';

  @override
  String get activeFeatures => 'सक्रिय फ़ीचर';

  @override
  String get greetMorning => 'सुप्रभात';

  @override
  String get greetAfternoon => 'नमस्ते';

  @override
  String get greetEvening => 'शुभ संध्या';

  @override
  String get dashboardWord => 'डैशबोर्ड';

  @override
  String lowStockBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count वस्तुओं का स्टॉक कम', one: '1 वस्तु का स्टॉक कम');
    return '$_temp0';
  }

  @override
  String get backupDueBanner => 'बैकअप बाकी — अपना डेटा सुरक्षित करें';

  @override
  String get createNewBill => 'नया बिल बनाएं';

  @override
  String get todaysSummary => 'आज का सारांश';

  @override
  String get details => 'विवरण';

  @override
  String get todaysSales => 'आज की बिक्री';

  @override
  String get noBillsYet => 'अभी कोई बिल नहीं';

  @override
  String billsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count बिल', one: '1 बिल');
    return '$_temp0';
  }

  @override
  String get totalBills => 'कुल बिल';

  @override
  String get cashReceived2 => 'नकद प्राप्त';

  @override
  String get upiCard => 'UPI / कार्ड';

  @override
  String get creditSales => 'उधार बिक्री';

  @override
  String get addProduct => 'वस्तु जोड़ें';

  @override
  String get viewStock => 'स्टॉक देखें';

  @override
  String get ledger => 'खाता';

  @override
  String get dayClosing => 'दिन का समापन';

  @override
  String get recentActivity => 'हाल की गतिविधि';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get noBillsTodayTitle => 'आज अभी कोई बिल नहीं';

  @override
  String get noBillsTodaySubtitle => 'आपके बनाए बिल यहाँ दिखेंगे। पहली बिक्री के लिए “नया बिल बनाएं” पर टैप करें।';

  @override
  String billNo(String no) {
    return 'बिल $no';
  }

  @override
  String get paid => 'चुकता';

  @override
  String get pending => 'बाकी';

  @override
  String get salesTitle => 'बिक्री';

  @override
  String salesSubtitle(int count, String total) {
    return '$count बिल · कुल $total · हर बिल अपरिवर्तनीय और पुनः प्रिंट-योग्य है।';
  }

  @override
  String get auditedReprint => 'ऑडिटेड पुनः प्रिंट';

  @override
  String get salesEmptyTitle => 'अभी कोई बिल नहीं';

  @override
  String get salesEmptySubtitle => 'बिलिंग से बिक्री पोस्ट करें — यह यहाँ दिखेगी।';

  @override
  String get returnDialogTitle => 'इस बिल को लौटाएं?';

  @override
  String returnDialogBody(String inv, String amount) {
    return '$inv ($amount) के लिए क्रेडिट नोट बनाएं। वस्तुएं वापस स्टॉक में जाएंगी।';
  }

  @override
  String get returnCreditKhataNote => '\n\nयह एक उधार बिल था — ग्राहक का खाता अलग से समायोजित करें।';

  @override
  String get returnAction => 'लौटाएं';

  @override
  String returnSnack(String ret, String inv) {
    return '$ret · $inv के लिए क्रेडिट नोट ✓';
  }

  @override
  String get chipReturn => 'वापसी';

  @override
  String chipPaidMode(String mode) {
    return 'चुकता · $mode';
  }

  @override
  String saleItemsLine(String date, String items) {
    return '$date · $items वस्तुएं';
  }

  @override
  String get more => 'और';

  @override
  String get reprint => 'पुनः प्रिंट';

  @override
  String get sharePdf => 'PDF शेयर करें';

  @override
  String get returnCreditNote => 'वापसी / क्रेडिट नोट';

  @override
  String get reprintFail => 'पुनः प्रिंट नहीं हो सका — प्रिंटर जांचें';

  @override
  String get shareFail => 'PDF शेयर नहीं हो सका';
}
