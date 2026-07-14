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
  String get quickQty => 'त्वरित मात्रा';

  @override
  String get gstr1Title => 'GSTR-1 · दर-वार (B2C)';

  @override
  String get gstr1Sub => 'GST दर के अनुसार बिक्री। खरीदार GSTIN दर्ज नहीं है, इसलिए सभी बिक्री B2C मानी गई हैं।';

  @override
  String get cgstCol => 'CGST';

  @override
  String get sgstCol => 'SGST';

  @override
  String get invoicesCol => 'बिल';

  @override
  String get exportGstPdf => 'GST PDF';

  @override
  String get gstReportFail => 'GST रिपोर्ट निर्यात नहीं हो सकी';

  @override
  String get totalLabel => 'कुल';

  @override
  String get sendOnWhatsApp => 'WhatsApp पर भेजें';

  @override
  String get whatsappFail => 'WhatsApp नहीं खुल सका';

  @override
  String balanceDue(String amt) {
    return 'बकाया $amt';
  }

  @override
  String get receivePayment => 'भुगतान प्राप्त करें';

  @override
  String receivePaymentFor(String invoice) {
    return 'भुगतान प्राप्त करें · $invoice';
  }

  @override
  String get receive => 'प्राप्त करें';

  @override
  String paymentRecordedLeft(String amt) {
    return 'भुगतान दर्ज · $amt अभी बाकी';
  }

  @override
  String get paymentRecordedPaid => 'भुगतान दर्ज · पूरा भुगतान ✓';

  @override
  String get returnCreditNote => 'वापसी / क्रेडिट नोट';

  @override
  String get reprintFail => 'पुनः प्रिंट नहीं हो सका — प्रिंटर जांचें';

  @override
  String get shareFail => 'PDF शेयर नहीं हो सका';

  @override
  String get invTitle => 'स्टॉक और इन्वेंट्री';

  @override
  String invSubtitle(int skus, int low, String value) {
    return '$skus SKU · $low कम · लागत पर $value।';
  }

  @override
  String get liveStockLedger => 'लाइव स्टॉक बही';

  @override
  String get searchItem => 'वस्तु खोजें…';

  @override
  String lowFilter(int count) {
    return 'कम ($count)';
  }

  @override
  String get noProductsTitle => 'अभी कोई वस्तु नहीं';

  @override
  String get noMatchesTitle => 'कोई मेल नहीं';

  @override
  String get noProductsSub => 'अपनी सूची बनाने के लिए \"वस्तु जोड़ें\" पर टैप करें।';

  @override
  String get noMatchesSub => 'कोई और खोज आज़माएं।';

  @override
  String get addProductBtn => 'वस्तु जोड़ें';

  @override
  String get chipOut => 'खत्म';

  @override
  String get chipLow => 'कम';

  @override
  String pricePerUnitReorder(String price, String unit, String reorder) {
    return '$price / $unit · पुनःऑर्डर $reorder';
  }

  @override
  String get service => 'सेवा';

  @override
  String get newProduct => 'नई वस्तु';

  @override
  String get fieldName => 'नाम';

  @override
  String get enterProductName => 'वस्तु का नाम दर्ज करें';

  @override
  String get productExistsErr => 'इस नाम की वस्तु पहले से मौजूद है';

  @override
  String get fieldUnit => 'इकाई';

  @override
  String get sellPrice => 'बिक्री मूल्य';

  @override
  String get enterPriceGt0 => 'मूल्य > 0 दर्ज करें';

  @override
  String get costOptional => 'लागत (वैकल्पिक)';

  @override
  String get trackStock => 'स्टॉक ट्रैक करें';

  @override
  String get trackStockSub => 'सेवाओं के लिए बंद करें (सैलून, मरम्मत)';

  @override
  String get openingQty => 'प्रारंभिक मात्रा';

  @override
  String get geZero => '≥ 0';

  @override
  String get reorderLevel => 'पुनःऑर्डर स्तर';

  @override
  String get fieldCategory => 'श्रेणी';

  @override
  String get hsnSac => 'HSN/SAC';

  @override
  String get barcodeOptional => 'बारकोड (वैकल्पिक)';

  @override
  String get barcodeUsedErr => 'बारकोड पहले से किसी अन्य वस्तु में उपयोग में है';

  @override
  String get addToCatalogue => 'सूची में जोड़ें';

  @override
  String get gstPct => 'GST %';

  @override
  String addedSnack(String name) {
    return '$name जोड़ा गया ✓';
  }

  @override
  String get addFailExists => 'जोड़ नहीं सके — नाम पहले से मौजूद है';

  @override
  String get onHand => 'उपलब्ध';

  @override
  String reorderAtCost(String reorder, String cost) {
    return '$reorder पर पुनःऑर्डर · लागत $cost';
  }

  @override
  String get reduce => 'घटाएं';

  @override
  String get addStock => 'स्टॉक जोड़ें';

  @override
  String get batches => 'बैच';

  @override
  String get chipExpired => 'समाप्त';

  @override
  String get chipNearExpiry => 'जल्द समाप्त';

  @override
  String batchNo(String no) {
    return 'बैच $no';
  }

  @override
  String expLabel(String date) {
    return 'समाप्ति $date';
  }

  @override
  String get movementHistory => 'गतिविधि इतिहास';

  @override
  String get editProductTooltip => 'वस्तु संपादित करें';

  @override
  String get deleteProductTooltip => 'वस्तु हटाएं';

  @override
  String get editProduct => 'वस्तु संपादित करें';

  @override
  String get enterName => 'नाम दर्ज करें';

  @override
  String get fieldReorder => 'पुनःऑर्डर';

  @override
  String get fieldCost => 'लागत';

  @override
  String get gtZeroShort => '> 0';

  @override
  String get usedByAnother => 'किसी अन्य वस्तु द्वारा उपयोग में';

  @override
  String get saveChanges => 'बदलाव सहेजें';

  @override
  String get productUpdated => 'वस्तु अपडेट हुई ✓';

  @override
  String get removeProductTitle => 'वस्तु हटाएं?';

  @override
  String removeProductBody(String name) {
    return '\"$name\" को अपनी सूची से हटाएं? पिछली बिक्री के रिकॉर्ड बने रहेंगे।';
  }

  @override
  String get removeAction => 'हटाएं';

  @override
  String addStockTitle(String name) {
    return 'स्टॉक जोड़ें · $name';
  }

  @override
  String reduceStockTitle(String name) {
    return 'स्टॉक घटाएं · $name';
  }

  @override
  String onHandLabel(String qty, String unit) {
    return 'उपलब्ध: $qty $unit';
  }

  @override
  String quantityUnit(String unit) {
    return 'मात्रा ($unit)';
  }

  @override
  String get reasonField => 'कारण';

  @override
  String get recordAdjustment => 'समायोजन दर्ज करें';

  @override
  String get enterQtyGt0 => '0 से अधिक मात्रा दर्ज करें';

  @override
  String get stockAdded => 'स्टॉक जोड़ा गया ✓';

  @override
  String get stockReduced => 'स्टॉक घटाया गया ✓';

  @override
  String get purchaseRestock => 'खरीद / पुनःस्टॉक';

  @override
  String get damageCorrection => 'क्षति / सुधार';

  @override
  String get reportsTitle => 'रिपोर्ट और विश्लेषण';

  @override
  String get reportsSubtitle => 'नीचे सब कुछ पोस्ट किए गए लेनदेन से लाइव गणना किया गया है।';

  @override
  String get exportPdf => 'PDF निर्यात करें';

  @override
  String get exportReportFail => 'रिपोर्ट निर्यात नहीं हो सकी';

  @override
  String get kpiNetSales => 'शुद्ध बिक्री';

  @override
  String get kpiGstCollected => 'GST एकत्रित';

  @override
  String get kpiBills => 'बिल';

  @override
  String get kpiAvgBill => 'औसत बिल';

  @override
  String get kpiItemsSold => 'बिकी वस्तुएं';

  @override
  String get kpiReceivable => 'प्राप्य';

  @override
  String get kpiPayable => 'देय';

  @override
  String get kpiStockAtCost => 'स्टॉक (लागत)';

  @override
  String get profitLoss => 'लाभ और हानि';

  @override
  String get plSalesTaxable => 'बिक्री (कर-योग्य)';

  @override
  String get plCogs => 'बेची वस्तुओं की लागत';

  @override
  String get plGrossProfit => 'सकल लाभ';

  @override
  String plGstNote(String amt) {
    return 'एकत्रित GST $amt पास-थ्रू है, आय नहीं।';
  }

  @override
  String get hsnSummaryTitle => 'HSN अनुसार बिक्री सारांश';

  @override
  String get csv => 'CSV';

  @override
  String get noSalesYet => 'अभी कोई बिक्री नहीं';

  @override
  String get hsnCol => 'HSN';

  @override
  String get gstCol => 'GST';

  @override
  String get taxableCol => 'कर-योग्य';

  @override
  String get taxCol => 'कर';

  @override
  String get dayBookTitle => 'दैनिक बही';

  @override
  String get noTransactions => 'अभी कोई लेनदेन नहीं';

  @override
  String get paymentMixTitle => 'भुगतान मिश्रण';

  @override
  String get topItems => 'शीर्ष वस्तुएं';

  @override
  String qtySold(String qty) {
    return '$qty बिके';
  }

  @override
  String saveFileTitle(String file) {
    return '$file सहेजें';
  }

  @override
  String get exportCancelled => 'निर्यात रद्द';

  @override
  String savedFile(String file) {
    return '$file सहेजा गया ✓';
  }

  @override
  String exportFailed(String err) {
    return 'निर्यात विफल: $err';
  }

  @override
  String get addCustomer => 'ग्राहक जोड़ें';

  @override
  String get customersTitle => 'ग्राहक और उधार';

  @override
  String customersSubtitle(int count, String receivable, int accounts) {
    return '$count ग्राहक · $accounts खातों में $receivable प्राप्य।';
  }

  @override
  String get khataLedger => 'खाता बही';

  @override
  String get noCustomersTitle => 'अभी कोई ग्राहक नहीं';

  @override
  String get noCustomersSub => 'यहाँ एक जोड़ें, या उधार बिक्री पर ग्राहक जोड़ें।';

  @override
  String get sectionOutstanding => 'बकाया';

  @override
  String get sectionSettled => 'निपटाया';

  @override
  String get overLimit => 'सीमा से अधिक';

  @override
  String get noMobile => 'कोई मोबाइल नहीं';

  @override
  String get settledLabel => 'निपटाया';

  @override
  String get outstandingLabel => 'बकाया';

  @override
  String get noDues => 'कोई बकाया नहीं';

  @override
  String get outstandingBalance => 'बकाया राशि';

  @override
  String limitLabel(String amt) {
    return 'सीमा $amt';
  }

  @override
  String get collectPayment => 'भुगतान वसूल करें';

  @override
  String get ledgerLabel => 'बही';

  @override
  String get noLedgerEntries => 'कोई बही प्रविष्टि नहीं';

  @override
  String balLabel(String amt) {
    return 'शेष $amt';
  }

  @override
  String collectFrom(String name) {
    return '$name से वसूल करें';
  }

  @override
  String outstandingSuffix(String amt) {
    return '$amt बकाया';
  }

  @override
  String get recordCollection => 'वसूली दर्ज करें';

  @override
  String get enterAmtGt0 => '0 से अधिक राशि दर्ज करें';

  @override
  String collectedSnack(String ref, String amt) {
    return '$ref · $amt वसूल किया ✓';
  }

  @override
  String get billingTitle => 'बिलिंग';

  @override
  String get billingSubtitleWide => 'खोजें या स्कैन करें · रसीद लाइव अपडेट होती है।';

  @override
  String get billingSubtitlePhone => 'वस्तु जोड़ने के लिए खोजें या स्कैन करें।';

  @override
  String itemCountLabel(String count) {
    return '$count वस्तुएं';
  }

  @override
  String get viewBill => 'बिल देखें';

  @override
  String noProductBarcode(String code) {
    return 'बारकोड $code वाली कोई वस्तु नहीं';
  }

  @override
  String outOfStock(String name) {
    return '$name स्टॉक में नहीं है';
  }

  @override
  String get enterBarcodeSku => 'बारकोड / SKU दर्ज करें';

  @override
  String get barcodeHint => 'बारकोड या वस्तु कोड';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get clearSearch => 'खोज साफ़ करें';

  @override
  String get searchProducts => 'वस्तुएं खोजें…';

  @override
  String get posNoProductsSub => 'अपनी दुकान की वस्तुएं इन्वेंट्री टैब में जोड़ें, फिर यहाँ बिल करें।';

  @override
  String noProductsMatch(String q) {
    return '\"$q\" से कोई वस्तु मेल नहीं खाती';
  }

  @override
  String get serviceLabel => 'सेवा';

  @override
  String qtyBadge(String count) {
    return '$count मात्रा';
  }

  @override
  String get tapProductToStart => 'बिल शुरू करने के लिए वस्तु पर टैप करें';

  @override
  String get taxable => 'कर-योग्य';

  @override
  String get cgst => 'CGST';

  @override
  String get sgst => 'SGST';

  @override
  String get billDiscountLabel => 'बिल छूट';

  @override
  String get upiQr => 'UPI QR';

  @override
  String get sendKot => 'किचन को भेजें (KOT)';

  @override
  String get addItemsToCharge => 'चार्ज करने के लिए वस्तुएं जोड़ें';

  @override
  String chargePrintAmt(String amt) {
    return 'भुगतान और प्रिंट · $amt';
  }

  @override
  String get liveReceipt => 'लाइव रसीद';

  @override
  String get addItemsPlaceholder => '— वस्तुएं जोड़ें —';

  @override
  String get kotSent => 'KOT किचन को भेजा गया ✓';

  @override
  String get kotPrintFail => 'किचन टिकट प्रिंट नहीं हो सका — प्रिंटर जांचें';

  @override
  String get addItemsFirst => 'पहले वस्तुएं जोड़ें';

  @override
  String get creditNeedsCustomer => 'उधार बिक्री के लिए ग्राहक चाहिए';

  @override
  String get creditLimitExceeded => 'उधार सीमा पार';

  @override
  String creditLimitBody(String name, String limit) {
    return '$name $limit सीमा पार कर जाएगा। फिर भी पोस्ट करें?';
  }

  @override
  String get overrideAction => 'फिर भी करें';

  @override
  String salePostedPrefix(String inv, String mode, String amt) {
    return '$inv पोस्ट हुआ · $mode $amt';
  }

  @override
  String get share => 'शेयर करें';

  @override
  String quantityOf(String name) {
    return 'मात्रा · $name';
  }

  @override
  String get setLabel => 'सेट करें';

  @override
  String get removeCustomer => 'ग्राहक हटाएं';

  @override
  String get increaseQty => 'मात्रा बढ़ाएं';

  @override
  String get decreaseQty => 'मात्रा घटाएं';

  @override
  String get switchRole => 'भूमिका बदलें';

  @override
  String get securityAudit => 'सुरक्षा और ऑडिट';

  @override
  String get toggleTheme => 'थीम बदलें';

  @override
  String get clearLabel => 'साफ़ करें';

  @override
  String get toggleFlash => 'फ़्लैश चालू/बंद';

  @override
  String get switchCamera => 'कैमरा बदलें';

  @override
  String get backLabel => 'वापस';

  @override
  String get removeLine => 'पंक्ति हटाएं';

  @override
  String get scanBarcode => 'बारकोड स्कैन करें';

  @override
  String get notSupportedDevice => 'इस डिवाइस पर समर्थित नहीं';

  @override
  String get pressBackToExit => 'बाहर निकलने के लिए फिर से बैक दबाएं';

  @override
  String qbSalePosted(String inv, String mode, String amt) {
    return '$inv · $mode $amt';
  }

  @override
  String qbReturnSuffix(String amt) {
    return ' · वापसी $amt';
  }

  @override
  String get printFail => 'प्रिंट नहीं हो सका';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get splashTagline => 'एक टैप में आसान व्यवसाय प्रबंधन';

  @override
  String get enterPin => 'PIN दर्ज करें';

  @override
  String get tooManyAttempts => 'बहुत अधिक प्रयास';

  @override
  String get wrongPin => 'गलत PIN';

  @override
  String lockedTryIn(String sec) {
    return 'लॉक · $secसे में पुनः प्रयास करें';
  }

  @override
  String get appLocked => 'बिलनेक्स लॉक है';

  @override
  String get newPurchase => 'नई खरीद';

  @override
  String get purchasingTitle => 'खरीद और आपूर्तिकर्ता';

  @override
  String purchasingSubtitle(int count, String payable, int purchases) {
    return '$count आपूर्तिकर्ता · $payable देय · $purchases खरीद।';
  }

  @override
  String get supplier => 'आपूर्तिकर्ता';

  @override
  String get noSuppliersTitle => 'अभी कोई आपूर्तिकर्ता नहीं';

  @override
  String get noSuppliersSub => 'एक आपूर्तिकर्ता जोड़ें, फिर स्टॉक-इन के लिए खरीद दर्ज करें।';

  @override
  String get noContact => 'कोई संपर्क नहीं';

  @override
  String get payableLower => 'देय';

  @override
  String get newSupplier => 'नया आपूर्तिकर्ता';

  @override
  String get phoneField => 'फ़ोन';

  @override
  String get gstinOptional => 'GSTIN (वैकल्पिक)';

  @override
  String get saveSupplier => 'आपूर्तिकर्ता सहेजें';

  @override
  String get recordPurchase => 'खरीद दर्ज करें';

  @override
  String get supplierInvoiceNo => 'आपूर्तिकर्ता चालान नं.';

  @override
  String get duplicateInvoiceSupplier => 'इस आपूर्तिकर्ता के लिए डुप्लिकेट चालान';

  @override
  String get items => 'वस्तुएं';

  @override
  String get noItemsYet => 'अभी कोई वस्तु नहीं';

  @override
  String get totalInclGst => 'कुल (GST सहित)';

  @override
  String get paidNow => 'अभी भुगतान किया';

  @override
  String get noPayableCreated => 'कोई देय नहीं बना';

  @override
  String get addsToPayable => 'आपूर्तिकर्ता देय में जुड़ता है';

  @override
  String get duplicateChangeRef => 'डुप्लिकेट चालान — संदर्भ बदलें';

  @override
  String get recordPurchaseStockIn => 'खरीद दर्ज करें और स्टॉक-इन';

  @override
  String get removeItem => 'वस्तु हटाएं';

  @override
  String amtPayable(String amt) {
    return '$amt देय';
  }

  @override
  String onHandCost(String qty, String cost) {
    return 'स्टॉक में $qty · लागत $cost';
  }

  @override
  String qtyUnit(String unit) {
    return 'मात्रा ($unit)';
  }

  @override
  String get addLine => 'लाइन जोड़ें';

  @override
  String purchaseRecordedSnack(String count) {
    return 'खरीद दर्ज हुई · $count वस्तुएं स्टॉक-इन ✓';
  }

  @override
  String get payableBalance => 'देय शेष';

  @override
  String get paySupplierBtn => 'आपूर्तिकर्ता को भुगतान करें';

  @override
  String get purchasesUpper => 'खरीद';

  @override
  String get noPurchases => 'कोई खरीद नहीं';

  @override
  String get creditChip => 'उधार';

  @override
  String get noRef => 'कोई संदर्भ नहीं';

  @override
  String purchaseLineInfo(String ref, String date, String items) {
    return '$ref · $date · $items वस्तुएं';
  }

  @override
  String paySupplierTitle(String name) {
    return '$name को भुगतान करें';
  }

  @override
  String payableColon(String amt) {
    return 'देय: $amt';
  }

  @override
  String get recordPayment => 'भुगतान दर्ज करें';

  @override
  String paidToSnack(String amt, String name) {
    return '$name को $amt भुगतान किया ✓';
  }

  @override
  String featuresSubtitle(String name) {
    return 'सब कुछ एक मास्टर स्विच के साथ श्रेणी के अनुसार समूहित है। प्रीसेट वाली सुविधाएँ $name के लिए अपने-आप आवंटित की गई हैं — किसी को भी बदल सकते हैं।';
  }

  @override
  String featuresEnabledCount(int on, int total) {
    return '$total में से $on चालू';
  }

  @override
  String get enableAll => 'सभी चालू करें';

  @override
  String get disableAll => 'सभी बंद करें';

  @override
  String get proBadge => 'Pro';

  @override
  String get presetBadge => 'प्रीसेट';

  @override
  String get proPlan => 'Pro प्लान';

  @override
  String get templatesSubtitle => 'सामान्य A4 प्रिंटर और थर्मल रोल के लिए 11 तैयार डिज़ाइन। हर व्यवसाय के लिए एक डिफ़ॉल्ट चुनें — बिलिंग की लाइव रसीद जैसा ही दिखेगा।';

  @override
  String get demoProductLine => 'उत्पाद एक';

  @override
  String get demoServiceLine => 'सेवा वस्तु';

  @override
  String get printSample => 'नमूना प्रिंट करें';

  @override
  String get printSampleFail => 'नमूना प्रिंट नहीं हो सका';

  @override
  String get defaultLabel => 'डिफ़ॉल्ट';

  @override
  String get defaultTemplateSet => 'डिफ़ॉल्ट टेम्पलेट सेट हो गया';

  @override
  String get setDefault => 'डिफ़ॉल्ट बनाएं';

  @override
  String get apptBook => 'बुक करें';

  @override
  String apptSubtitle(String count) {
    return '$count आगामी · सेवा, स्टाफ और स्लॉट बुक करें।';
  }

  @override
  String get apptVerticalPack => 'वर्टिकल पैक';

  @override
  String get apptEmptyTitle => 'अभी कोई अपॉइंटमेंट नहीं';

  @override
  String get apptStatusBooked => 'बुक';

  @override
  String get apptStatusDone => 'पूर्ण';

  @override
  String get apptStatusNoShow => 'नहीं आए';

  @override
  String get apptMarkDone => 'पूर्ण चिह्नित करें';

  @override
  String get apptBookTitle => 'अपॉइंटमेंट बुक करें';

  @override
  String get apptCustomer => 'ग्राहक';

  @override
  String get apptEnterCustomer => 'ग्राहक का नाम दर्ज करें';

  @override
  String get apptStaff => 'स्टाफ';

  @override
  String apptSlot(String time) {
    return 'स्लॉट · $time';
  }

  @override
  String get apptConfirmBooking => 'बुकिंग पक्की करें';

  @override
  String get apptBookedSnack => 'अपॉइंटमेंट बुक हो गई ✓';

  @override
  String get backupNeverBackedUp => 'कभी बैकअप नहीं लिया';

  @override
  String get backupJustNow => 'अभी-अभी बैकअप लिया';

  @override
  String backupMinAgo(String mins) {
    return '$mins मिनट पहले बैकअप लिया';
  }

  @override
  String backupHoursAgo(String hours) {
    return '$hours घंटे पहले बैकअप लिया';
  }

  @override
  String backupDaysAgo(String days) {
    return '$days दिन पहले बैकअप लिया';
  }

  @override
  String get backupRestoreTitle => 'बैकअप और रिस्टोर';

  @override
  String get backupRestoreSubtitle => 'आपका दुकान डेटा आपका ही रहता है। इसे अपने फ़ोन, PC या अपने Google Drive में सेव करें — और कभी भी रिस्टोर करें।';

  @override
  String get backupCountSales => 'बिक्री';

  @override
  String get backupCountCustomers => 'ग्राहक';

  @override
  String get backupCountProducts => 'प्रोडक्ट';

  @override
  String get backupCountSuppliers => 'सप्लायर';

  @override
  String backupDataSummary(String bills, String customers, String products) {
    return '$bills बिल · $customers ग्राहक · $products प्रोडक्ट';
  }

  @override
  String get saveBackupToFile => 'फ़ाइल में बैकअप सेव करें';

  @override
  String get saveDialogHint => 'सेव डायलॉग में Google Drive, अपना PC या Files चुनें।';

  @override
  String get restoreFromFile => 'फ़ाइल से रिस्टोर करें';

  @override
  String get inThisBackup => 'इस बैकअप में';

  @override
  String get backupRestoreFootnote => 'रिस्टोर करने से इस डिवाइस का मौजूदा डेटा बदल जाता है। नए फ़ोन या PC पर एक टैप में ले जाने के लिए Google Drive पर एक कॉपी रखें।';

  @override
  String get googleDrive => 'Google Drive';

  @override
  String get driveConnected => 'कनेक्टेड';

  @override
  String get driveConnectPrompt => 'एक-टैप बैकअप के लिए अपना अकाउंट कनेक्ट करें';

  @override
  String get connectGoogleDrive => 'Google Drive कनेक्ट करें';

  @override
  String get backUpNow => 'अभी बैकअप लें';

  @override
  String get disconnect => 'डिस्कनेक्ट करें';

  @override
  String get noDriveBackups => 'अभी कोई Drive बैकअप नहीं।';

  @override
  String get backupsOnYourDrive => 'आपके Drive पर बैकअप';

  @override
  String get restore => 'रिस्टोर करें';

  @override
  String get backupSavedCheck => 'बैकअप सेव हो गया ✓';

  @override
  String get saveCancelled => 'सेव रद्द किया गया';

  @override
  String backupFailed(String err) {
    return 'बैकअप विफल: $err';
  }

  @override
  String get dataRestored => 'डेटा रिस्टोर हो गया ✓';

  @override
  String get restoreCancelled => 'रिस्टोर रद्द किया गया';

  @override
  String get notBillnexBackup => 'यह फ़ाइल BillNex बैकअप नहीं है';

  @override
  String restoreFailed(String err) {
    return 'रिस्टोर विफल: $err';
  }

  @override
  String get googleSignInCancelled => 'Google साइन-इन रद्द किया गया';

  @override
  String signInFailed(String err) {
    return 'साइन-इन विफल: $err';
  }

  @override
  String get backedUpToDrive => 'Google Drive पर बैकअप हो गया ✓';

  @override
  String driveBackupFailed(String err) {
    return 'Drive बैकअप विफल: $err';
  }

  @override
  String get restoredFromDrive => 'Google Drive से रिस्टोर हो गया ✓';

  @override
  String driveRestoreFailed(String err) {
    return 'Drive रिस्टोर विफल: $err';
  }

  @override
  String get restoreFromBackupTitle => 'बैकअप से रिस्टोर करें?';

  @override
  String get restoreFromBackupBody => 'यह इस डिवाइस का सारा मौजूदा डेटा बैकअप से बदल देगा। इसे वापस नहीं किया जा सकता।';

  @override
  String get setUpYourBusiness => 'अपना व्यवसाय सेट करें';

  @override
  String get featuresRealignNote => 'फ़ीचर इस प्रकार के अनुसार बदल जाएंगे। आपकी वस्तुएं, ग्राहक और बिल जैसे हैं वैसे ही रहेंगे।';

  @override
  String get shopBusinessName => 'दुकान / व्यवसाय का नाम *';

  @override
  String get shopNameHint => 'जैसे राजेश किराना स्टोर';

  @override
  String get requiredField => 'आवश्यक';

  @override
  String get ownerName => 'मालिक का नाम';

  @override
  String get ownerNameHint => 'जैसे राजेश कुमार';

  @override
  String get phone10DigitError => '10 अंकों का फ़ोन नंबर दर्ज करें';

  @override
  String get gstinHint => '15 अंकों का GST नंबर';

  @override
  String get gstin15Error => 'GSTIN 15 अक्षरों का होना चाहिए';

  @override
  String get addressField => 'पता';

  @override
  String get gstStateCode => 'GST राज्य कोड';

  @override
  String get gstStateCodeHint => '36 = तेलंगाना';

  @override
  String get stateCode2DigitError => '2 अंकों का कोड (जैसे 36)';

  @override
  String get pricesIncludeGst => 'कीमतों में GST शामिल है';

  @override
  String get taxInsidePrice => 'कर कीमत में शामिल है (MRP शैली)';

  @override
  String get taxAddedOnTop => 'बिलिंग के समय कर ऊपर से जोड़ा जाता है';

  @override
  String get createMyShop => 'मेरी दुकान बनाएं';

  @override
  String get setupLaterNote => 'आप यह सब बाद में सेटिंग्स में बदल सकते हैं। आपकी सूची खाली शुरू होती है — आगे अपनी वस्तुएं जोड़ें।';

  @override
  String get catBilling => 'बिलिंग और काउंटर';

  @override
  String get catTax => 'GST, कर और अनुपालन';

  @override
  String get catInventory => 'इन्वेंट्री और स्टॉक';

  @override
  String get catCustomers => 'ग्राहक और उधार';

  @override
  String get catOps => 'संचालन और विकास';

  @override
  String get capFastposName => 'तेज़ POS और काउंटर बिलिंग';

  @override
  String get capFastposDesc => 'एक स्क्रीन पर स्कैन, कार्ट, भुगतान, प्रिंट';

  @override
  String get capBarcodeScanName => 'बारकोड / कैमरा स्कैन';

  @override
  String get capBarcodeScanDesc => 'स्कैनर + एंड्रॉइड कैमरा विकल्प';

  @override
  String get capWeightScaleName => 'वज़न / तराज़ू बिलिंग';

  @override
  String get capWeightScaleDesc => 'दशमलव kg/g/लीटर + PLU';

  @override
  String get capMultiUnitName => 'मल्टी-यूनिट और खुली बिक्री';

  @override
  String get capMultiUnitDesc => 'पैक खरीदें, पीस / कटाई में बेचें';

  @override
  String get capQuotationName => 'कोटेशन और अनुमान';

  @override
  String get capQuotationDesc => 'भेजें, समाप्ति, बिक्री में बदलें';

  @override
  String get capKotName => 'KOT / टेबल और रसोई';

  @override
  String get capKotDesc => 'फ्लोर प्लान, KOT, रसोई रूटिंग';

  @override
  String get capGstInvoiceName => 'GST कर चालान';

  @override
  String get capGstInvoiceDesc => 'CGST/SGST/IGST, HSN, अद्वितीय नंबरिंग';

  @override
  String get capBillOfSupplyName => 'बिल ऑफ सप्लाई / कंपोज़िशन';

  @override
  String get capBillOfSupplyDesc => 'छूट वाले विक्रेताओं के लिए कर-रहित श्रृंखला';

  @override
  String get capConsentName => 'ग्राहक सहमति और गोपनीयता';

  @override
  String get capConsentDesc => 'ऑप्ट-इन/आउट, उद्देश्य, टाइमस्टैम्प';

  @override
  String get capEInvoiceName => 'ई-चालान (IRN) और ई-वे बिल';

  @override
  String get capEInvoiceDesc => 'IRP पेलोड, हस्ताक्षरित QR';

  @override
  String get capBatchExpiryName => 'बैच और एक्सपायरी ट्रैकिंग';

  @override
  String get capBatchExpiryDesc => 'FEFO, जल्द-एक्सपायरी कार्य सूची';

  @override
  String get capSerialImeiName => 'सीरियल / IMEI नियंत्रण';

  @override
  String get capSerialImeiDesc => 'बिक्री/वापसी/सर्विस पर अद्वितीय यूनिट';

  @override
  String get capVariantMatrixName => 'वैरिएंट मैट्रिक्स';

  @override
  String get capVariantMatrixDesc => 'साइज़-रंग-स्टाइल चाइल्ड SKU';

  @override
  String get capLabelName => 'लेबल / टैग प्रिंटिंग';

  @override
  String get capLabelDesc => 'बारकोड, शेल्फ, कपड़ा, MRP लेबल';

  @override
  String get capProductionName => 'BOM / उत्पादन';

  @override
  String get capProductionDesc => 'रेसिपी, वर्क ऑर्डर, सामग्री जारी';

  @override
  String get capCreditLedgerName => 'उधार / खाता बही';

  @override
  String get capCreditLedgerDesc => 'देय तिथि, सीमा, वसूली, बकाया अवधि';

  @override
  String get capLoyaltyName => 'लॉयल्टी और प्रमोशन';

  @override
  String get capLoyaltyDesc => 'पॉइंट, कूपन, कॉम्बो';

  @override
  String get capMembershipName => 'सदस्यता और पैकेज';

  @override
  String get capMembershipDesc => 'प्लान, सेशन, नवीनीकरण';

  @override
  String get capAppointmentsName => 'अपॉइंटमेंट और कैलेंडर';

  @override
  String get capAppointmentsDesc => 'स्टाफ, चेयर/रूम, नो-शो नीति';

  @override
  String get capJobCardName => 'जॉब कार्ड / सर्विस वर्कफ़्लो';

  @override
  String get capJobCardDesc => 'इनटेक, अनुमान, स्थिति, डिलीवरी';

  @override
  String get capRentalName => 'किराया संपत्ति और जमा';

  @override
  String get capRentalDesc => 'बुकिंग, उपलब्धता, विलंब शुल्क';

  @override
  String get capDeliveryName => 'ऑर्डर और डिलीवरी';

  @override
  String get capDeliveryDesc => 'स्थिति, प्रमाण, COD निपटान';

  @override
  String get capWholesaleName => 'थोक / रूट बिक्री';

  @override
  String get capWholesaleDesc => 'मूल्य स्तर, सेल्समैन रूट, स्कीम';

  @override
  String get capMultiStoreName => 'मल्टी-स्टोर और ट्रांसफर';

  @override
  String get capMultiStoreDesc => 'ब्रांच स्टॉक, समेकित डैशबोर्ड';

  @override
  String get capRecurringName => 'आवर्ती / सब्सक्रिप्शन बिलिंग';

  @override
  String get capRecurringDesc => 'किस्तें, AMC, ऑटो-चालान';

  @override
  String get bizKiranaName => 'किराना / जनरल स्टोर';

  @override
  String get bizKiranaEdition => 'रिटेल स्टैंडर्ड';

  @override
  String get bizKiranaTag => 'तेज़ काउंटर B2C + खाता उधार';

  @override
  String get bizSupermarketName => 'सुपरमार्केट / मिनी-मार्ट';

  @override
  String get bizSupermarketEdition => 'रिटेल प्रो';

  @override
  String get bizSupermarketTag => 'अधिक-वॉल्यूम मल्टी-काउंटर POS';

  @override
  String get bizPharmacyName => 'फार्मेसी / मेडिकल';

  @override
  String get bizPharmacyEdition => 'वर्टिकल प्रो';

  @override
  String get bizPharmacyTag => 'बैच, एक्सपायरी, MRP, रैक';

  @override
  String get bizRestaurantName => 'रेस्टोरेंट / QSR';

  @override
  String get bizRestaurantEdition => 'वर्टिकल प्रो';

  @override
  String get bizRestaurantTag => 'टेबल, KOT, रसोई, डिलीवरी';

  @override
  String get bizBakeryName => 'कैफे / बेकरी / मिठाई';

  @override
  String get bizBakeryEdition => 'वर्टिकल स्टैंडर्ड';

  @override
  String get bizBakeryTag => 'वज़नी + उत्पादन बैच';

  @override
  String get bizHardwareName => 'हार्डवेयर / इलेक्ट्रिकल';

  @override
  String get bizHardwareEdition => 'रिटेल प्रो';

  @override
  String get bizHardwareTag => 'काउंटर + कोटेशन + उधार';

  @override
  String get bizFashionName => 'परिधान / फुटवियर';

  @override
  String get bizFashionEdition => 'वर्टिकल स्टैंडर्ड';

  @override
  String get bizFashionTag => 'वैरिएंट रिटेल + एक्सचेंज';

  @override
  String get bizJewelleryName => 'ज्वेलरी स्टोर';

  @override
  String get bizJewelleryEdition => 'वर्टिकल एंटरप्राइज़';

  @override
  String get bizJewelleryTag => 'वज़न, शुद्धता, मेकिंग चार्ज';

  @override
  String get bizElectronicsName => 'मोबाइल / इलेक्ट्रॉनिक्स';

  @override
  String get bizElectronicsEdition => 'वर्टिकल प्रो';

  @override
  String get bizElectronicsTag => 'सीरियल/IMEI + वारंटी';

  @override
  String get bizSalonName => 'सैलून / स्पा / ब्यूटी';

  @override
  String get bizSalonEdition => 'वर्टिकल स्टैंडर्ड';

  @override
  String get bizSalonTag => 'अपॉइंटमेंट + सर्विस बिलिंग';

  @override
  String get bizWholesaleName => 'थोक / वितरण';

  @override
  String get bizWholesaleEdition => 'बिज़नेस प्रो';

  @override
  String get bizWholesaleTag => 'B2B, रूट बिक्री, उधार';

  @override
  String get bizClinicName => 'क्लिनिक / डायग्नोस्टिक';

  @override
  String get bizClinicEdition => 'वर्टिकल प्रो';

  @override
  String get bizClinicTag => 'मरीज़, सेवा, पैकेज बिलिंग';

  @override
  String get tplClassicName => 'क्लासिक GST';

  @override
  String get tplClassicDesc => 'औपचारिक कर चालान, पूरी HSN तालिका';

  @override
  String get tplMinimalName => 'मिनिमल';

  @override
  String get tplMinimalDesc => 'साफ़, स्पेस-केंद्रित, ब्रांड हेडर';

  @override
  String get tplModernName => 'मॉडर्न कलर';

  @override
  String get tplModernDesc => 'एक्सेंट बैंड + कार्ड कुल';

  @override
  String get tplBilingualName => 'द्विभाषी हिं/తె';

  @override
  String get tplBilingualDesc => 'स्थानीय व्यापार के लिए दो-भाषी लेबल';

  @override
  String get tplWholesaleName => 'थोक B2B';

  @override
  String get tplWholesaleDesc => 'केस/पीस, स्कीम और उधार शर्तें';

  @override
  String get tplServiceName => 'सर्विस / जॉब कार्ड';

  @override
  String get tplServiceDesc => 'श्रम + पुर्ज़े, तकनीशियन, वारंटी';

  @override
  String get tplQuotationName => 'कोटेशन';

  @override
  String get tplQuotationDesc => 'वैधता, शर्तें, स्टॉक पर असर नहीं';

  @override
  String get tplThermal80Name => 'थर्मल 80mm';

  @override
  String get tplThermal80Desc => 'चौड़ी रसीद + कटर + QR';

  @override
  String get tplThermal58Name => 'थर्मल 58mm';

  @override
  String get tplThermal58Desc => 'कॉम्पैक्ट किराना रसीद';

  @override
  String get tplKotName => 'किचन KOT';

  @override
  String get tplKotDesc => 'केवल वस्तुएं, बिना दाम, स्टेशन रूट';

  @override
  String get tplDeliveryName => 'डिलीवरी चालान';

  @override
  String get tplDeliveryDesc => 'डिस्पैच नोट, बाद में चालान जोड़ें';

  @override
  String get prioMust => 'अनिवार्य';

  @override
  String get prioShould => 'ज़रूरी';

  @override
  String get prioCould => 'वैकल्पिक';

  @override
  String get dataIoMenu => 'डेटा इम्पोर्ट / एक्सपोर्ट';

  @override
  String get dataIoTitle => 'डेटा इम्पोर्ट / एक्सपोर्ट';

  @override
  String get dataIoSubtitle => 'अपना डेटा CSV में एक्सपोर्ट करें, या स्प्रेडशीट से प्रोडक्ट और ग्राहक इम्पोर्ट करें।';

  @override
  String get dataIoExportSection => 'एक्सपोर्ट (CSV)';

  @override
  String get dataIoImportSection => 'इम्पोर्ट (CSV)';

  @override
  String get dataIoExportHint => 'एक्सेल या शीट्स में खुलने वाली .csv फ़ाइल के रूप में सहेजा गया।';

  @override
  String get dataIoImportHint => '.csv फ़ाइल चुनें। मौजूदा आइटम छोड़ दिए जाते हैं, कभी अधिलेखित नहीं होते।';

  @override
  String get exportInventoryCsv => 'इन्वेंटरी एक्सपोर्ट (CSV)';

  @override
  String get exportCustomersCsv => 'ग्राहक एक्सपोर्ट (CSV)';

  @override
  String get exportSalesCsv => 'बिक्री एक्सपोर्ट (CSV)';

  @override
  String get importInventoryCsv => 'इन्वेंटरी इम्पोर्ट (CSV)';

  @override
  String get importCustomersCsv => 'ग्राहक इम्पोर्ट (CSV)';

  @override
  String get exportNothing => 'अभी एक्सपोर्ट करने के लिए कुछ नहीं है।';

  @override
  String get importConfirmTitle => 'CSV से इम्पोर्ट करें?';

  @override
  String get importConfirmBody => 'पंक्तियाँ आपके मौजूदा डेटा में जोड़ी जाएँगी। डुप्लिकेट छोड़ दिए जाते हैं। इसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get importConfirmBtn => 'इम्पोर्ट';

  @override
  String importSummary(int added, int skipped, int failed) {
    return '$added जोड़े · $skipped छोड़े · $failed विफल';
  }

  @override
  String get importNothing => 'इम्पोर्ट करने के लिए कुछ नहीं — फ़ाइल में कोई मान्य पंक्ति नहीं थी।';

  @override
  String get importResultTitle => 'इम्पोर्ट पूरा हुआ';

  @override
  String csvImportFailed(String err) {
    return 'इम्पोर्ट विफल: $err';
  }

  @override
  String wizardStepOf(int current, int total) {
    return 'चरण $current / $total';
  }

  @override
  String get wizardSkipSetup => 'सेटअप छोड़ें';

  @override
  String get wizardSkipStep => 'यह चरण छोड़ें';

  @override
  String get wizardWelcomeTitle => 'BillNex में आपका स्वागत है';

  @override
  String get wizardWelcomeSubtitle => 'आइए एक मिनट में आपकी दुकान सेट करें। हर चरण वैकल्पिक है — आप बाद में कुछ भी बदल सकते हैं।';

  @override
  String get wizardContinueWithGoogle => 'Google के साथ जारी रखें';

  @override
  String get wizardContinueWithoutAccount => 'बिना खाते के जारी रखें';

  @override
  String get wizardGoogleUnavailable => 'Google साइन-इन कॉन्फ़िगर नहीं है — बिना खाते के जारी रख रहे हैं';

  @override
  String wizardSignedInAs(String email) {
    return '$email के रूप में साइन इन';
  }

  @override
  String get wizardBusinessTitle => 'आपका व्यवसाय';

  @override
  String get wizardBusinessSubtitle => 'अपनी दुकान का नाम और व्यापार बताएं — हम सही सुविधाएँ पहले से सेट कर देंगे। दोनों वैकल्पिक हैं।';

  @override
  String get wizardSkipUseStandardStore => 'छोड़ें — मानक स्टोर उपयोग करें';

  @override
  String get wizardGstTitle => 'GST और मूल्य';

  @override
  String get wizardGstSubtitle => 'टैक्स इनवॉइस के लिए अपना GSTIN जोड़ें और चुनें कि कीमतें कैसे बताई जाएँ। यह बाद में भी सेट कर सकते हैं।';

  @override
  String get wizardInventoryTitle => 'अपने उत्पाद जोड़ें';

  @override
  String get wizardInventorySubtitle => 'तैयार कैटलॉग से शुरू करें, अपना इम्पोर्ट करें, या छोड़कर बाद में उत्पाद जोड़ें।';

  @override
  String get wizardLoadSample => 'नमूना कैटलॉग लोड करें';

  @override
  String get wizardLoadSampleHint => 'आपके व्यवसाय प्रकार के लिए तैयार आइटम';

  @override
  String get wizardImportCsvHint => 'अपने उत्पादों की .csv फ़ाइल चुनें';

  @override
  String wizardItemsInCatalogue(int count) {
    return 'आपके कैटलॉग में $count आइटम';
  }

  @override
  String wizardSampleAdded(int count) {
    return 'आपके कैटलॉग में $count उत्पाद जोड़े गए';
  }

  @override
  String get wizardSkipForNow => 'अभी के लिए छोड़ें';

  @override
  String get wizardDoneTitle => 'सब तैयार है';

  @override
  String get wizardDoneSubtitle => 'आपकी दुकान तैयार है। आप कभी भी सेटिंग्स से सब कुछ ठीक कर सकते हैं।';

  @override
  String get wizardEnterApp => 'BillNex खोलें';

  @override
  String get wizardStandardStore => 'मानक स्टोर';

  @override
  String get wizardNotSet => 'सेट नहीं';

  @override
  String get selectItemTitle => 'कोई आइटम चुनें';

  @override
  String get selectItemSub => 'विवरण यहाँ देखने के लिए सूची से चुनें।';

  @override
  String get printerSettings => 'प्रिंटर सेटिंग्स';

  @override
  String get printerSettingsSub => 'A4 बिल और थर्मल रसीद के लिए अलग-अलग प्रिंटर';

  @override
  String get thermalRollWidth => 'थर्मल रोल चौड़ाई';

  @override
  String get invoicePrinterA4 => 'बिल प्रिंटर (A4)';

  @override
  String get receiptPrinterThermal => 'रसीद प्रिंटर (थर्मल)';

  @override
  String get printerAskEachTime => 'हर बार पूछें (सिस्टम डायलॉग)';

  @override
  String get choosePrinter => 'प्रिंटर चुनें';

  @override
  String get useSystemDialog => 'सिस्टम डायलॉग उपयोग करें';

  @override
  String get printerSaved => 'डिफ़ॉल्ट प्रिंटर सहेजा गया';

  @override
  String get printerCleared => 'अब सिस्टम डायलॉग का उपयोग हो रहा है';

  @override
  String get noPrinterFound => 'कोई प्रिंटर नहीं चुना गया';

  @override
  String get printerSettingsNote => 'डिफ़ॉल्ट प्रिंटर सेट होने पर प्रिंट सीधे उसी पर जाता है। अन्यथा सही पेपर आकार के साथ सिस्टम डायलॉग खुलता है।';
}
