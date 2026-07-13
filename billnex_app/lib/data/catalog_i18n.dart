// Localization layer for the const catalog data in catalog.dart.
//
// catalog.dart keeps its stable English `const` data (keys/ids never change).
// These helpers take the active localizations `L` plus a stable key/id and
// return the display string in the user's language. Unknown keys fall back to
// the raw English value from catalog.dart so nothing ever crashes.
//
// NOTE: kProducts (demo inventory) and PaperSize labels (A4/80mm/58mm) are
// intentionally NOT localized.

import '../l10n/app_localizations.dart';
import 'catalog.dart';

// ---------------------------------------------------------------------------
// Categories
// ---------------------------------------------------------------------------
String categoryName(L l, String key) => switch (key) {
  'billing' => l.catBilling,
  'tax' => l.catTax,
  'inventory' => l.catInventory,
  'customers' => l.catCustomers,
  'ops' => l.catOps,
  _ => _categoryFallback(key),
};

String _categoryFallback(String key) {
  for (final c in kCategories) {
    if (c.key == key) return c.name;
  }
  return key;
}

// ---------------------------------------------------------------------------
// Capabilities
// ---------------------------------------------------------------------------
String capabilityName(L l, String key) => switch (key) {
  'fastPOS' => l.capFastposName,
  'barcodeScan' => l.capBarcodeScanName,
  'weightScale' => l.capWeightScaleName,
  'multiUnit' => l.capMultiUnitName,
  'quotation' => l.capQuotationName,
  'kot' => l.capKotName,
  'gstInvoice' => l.capGstInvoiceName,
  'billOfSupply' => l.capBillOfSupplyName,
  'consent' => l.capConsentName,
  'eInvoice' => l.capEInvoiceName,
  'batchExpiry' => l.capBatchExpiryName,
  'serialImei' => l.capSerialImeiName,
  'variantMatrix' => l.capVariantMatrixName,
  'label' => l.capLabelName,
  'production' => l.capProductionName,
  'creditLedger' => l.capCreditLedgerName,
  'loyalty' => l.capLoyaltyName,
  'membership' => l.capMembershipName,
  'appointments' => l.capAppointmentsName,
  'jobCard' => l.capJobCardName,
  'rental' => l.capRentalName,
  'delivery' => l.capDeliveryName,
  'wholesale' => l.capWholesaleName,
  'multiStore' => l.capMultiStoreName,
  'recurring' => l.capRecurringName,
  _ => _capabilityFallback(key)?.name ?? key,
};

String capabilityDesc(L l, String key) => switch (key) {
  'fastPOS' => l.capFastposDesc,
  'barcodeScan' => l.capBarcodeScanDesc,
  'weightScale' => l.capWeightScaleDesc,
  'multiUnit' => l.capMultiUnitDesc,
  'quotation' => l.capQuotationDesc,
  'kot' => l.capKotDesc,
  'gstInvoice' => l.capGstInvoiceDesc,
  'billOfSupply' => l.capBillOfSupplyDesc,
  'consent' => l.capConsentDesc,
  'eInvoice' => l.capEInvoiceDesc,
  'batchExpiry' => l.capBatchExpiryDesc,
  'serialImei' => l.capSerialImeiDesc,
  'variantMatrix' => l.capVariantMatrixDesc,
  'label' => l.capLabelDesc,
  'production' => l.capProductionDesc,
  'creditLedger' => l.capCreditLedgerDesc,
  'loyalty' => l.capLoyaltyDesc,
  'membership' => l.capMembershipDesc,
  'appointments' => l.capAppointmentsDesc,
  'jobCard' => l.capJobCardDesc,
  'rental' => l.capRentalDesc,
  'delivery' => l.capDeliveryDesc,
  'wholesale' => l.capWholesaleDesc,
  'multiStore' => l.capMultiStoreDesc,
  'recurring' => l.capRecurringDesc,
  _ => _capabilityFallback(key)?.desc ?? key,
};

Capability? _capabilityFallback(String key) {
  for (final c in kCapabilities) {
    if (c.key == key) return c;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Business types
// ---------------------------------------------------------------------------
String businessTypeName(L l, String key) => switch (key) {
  'kirana' => l.bizKiranaName,
  'supermarket' => l.bizSupermarketName,
  'pharmacy' => l.bizPharmacyName,
  'restaurant' => l.bizRestaurantName,
  'bakery' => l.bizBakeryName,
  'hardware' => l.bizHardwareName,
  'fashion' => l.bizFashionName,
  'jewellery' => l.bizJewelleryName,
  'electronics' => l.bizElectronicsName,
  'salon' => l.bizSalonName,
  'wholesale' => l.bizWholesaleName,
  'clinic' => l.bizClinicName,
  _ => _businessFallback(key)?.name ?? key,
};

String businessTypeTag(L l, String key) => switch (key) {
  'kirana' => l.bizKiranaTag,
  'supermarket' => l.bizSupermarketTag,
  'pharmacy' => l.bizPharmacyTag,
  'restaurant' => l.bizRestaurantTag,
  'bakery' => l.bizBakeryTag,
  'hardware' => l.bizHardwareTag,
  'fashion' => l.bizFashionTag,
  'jewellery' => l.bizJewelleryTag,
  'electronics' => l.bizElectronicsTag,
  'salon' => l.bizSalonTag,
  'wholesale' => l.bizWholesaleTag,
  'clinic' => l.bizClinicTag,
  _ => _businessFallback(key)?.tag ?? key,
};

String businessTypeEdition(L l, String key) => switch (key) {
  'kirana' => l.bizKiranaEdition,
  'supermarket' => l.bizSupermarketEdition,
  'pharmacy' => l.bizPharmacyEdition,
  'restaurant' => l.bizRestaurantEdition,
  'bakery' => l.bizBakeryEdition,
  'hardware' => l.bizHardwareEdition,
  'fashion' => l.bizFashionEdition,
  'jewellery' => l.bizJewelleryEdition,
  'electronics' => l.bizElectronicsEdition,
  'salon' => l.bizSalonEdition,
  'wholesale' => l.bizWholesaleEdition,
  'clinic' => l.bizClinicEdition,
  _ => _businessFallback(key)?.edition ?? key,
};

BusinessType? _businessFallback(String key) {
  for (final b in kBusinessTypes) {
    if (b.key == key) return b;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Invoice templates
// ---------------------------------------------------------------------------
String templateName(L l, String id) => switch (id) {
  'classic' => l.tplClassicName,
  'minimal' => l.tplMinimalName,
  'modern' => l.tplModernName,
  'bilingual' => l.tplBilingualName,
  'wholesale' => l.tplWholesaleName,
  'service' => l.tplServiceName,
  'quotation' => l.tplQuotationName,
  'thermal80' => l.tplThermal80Name,
  'thermal58' => l.tplThermal58Name,
  'kot' => l.tplKotName,
  'delivery' => l.tplDeliveryName,
  _ => _templateFallback(id)?.name ?? id,
};

String templateDesc(L l, String id) => switch (id) {
  'classic' => l.tplClassicDesc,
  'minimal' => l.tplMinimalDesc,
  'modern' => l.tplModernDesc,
  'bilingual' => l.tplBilingualDesc,
  'wholesale' => l.tplWholesaleDesc,
  'service' => l.tplServiceDesc,
  'quotation' => l.tplQuotationDesc,
  'thermal80' => l.tplThermal80Desc,
  'thermal58' => l.tplThermal58Desc,
  'kot' => l.tplKotDesc,
  'delivery' => l.tplDeliveryDesc,
  _ => _templateFallback(id)?.desc ?? id,
};

InvoiceTemplate? _templateFallback(String id) {
  for (final t in kTemplates) {
    if (t.id == id) return t;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Priority labels (Must / Should / Could)
// ---------------------------------------------------------------------------
String priorityLabel(L l, Priority p) => switch (p) {
  Priority.must => l.prioMust,
  Priority.should => l.prioShould,
  Priority.could => l.prioCould,
};
