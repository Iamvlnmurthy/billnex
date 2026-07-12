/// The merchant's real business identity (PRD BNX-0001). Captured at setup,
/// editable later, and printed on every invoice.
class BusinessProfile {
  final String bizType; // business-type key (kirana, pharmacy…)
  final String shopName;
  final String owner;
  final String phone;
  final String? gstin;
  final String address;
  final String stateCode; // GST state code, e.g. 36 (Telangana)
  final bool taxInclusive; // prices include tax vs. add tax on top

  const BusinessProfile({
    required this.bizType,
    required this.shopName,
    this.owner = '',
    this.phone = '',
    this.gstin,
    this.address = '',
    this.stateCode = '36',
    this.taxInclusive = true,
  });

  bool get hasGst => (gstin ?? '').trim().length >= 15;

  BusinessProfile copyWith({
    String? shopName,
    String? owner,
    String? phone,
    String? gstin,
    String? address,
    String? stateCode,
    bool? taxInclusive,
  }) =>
      BusinessProfile(
        bizType: bizType,
        shopName: shopName ?? this.shopName,
        owner: owner ?? this.owner,
        phone: phone ?? this.phone,
        gstin: gstin ?? this.gstin,
        address: address ?? this.address,
        stateCode: stateCode ?? this.stateCode,
        taxInclusive: taxInclusive ?? this.taxInclusive,
      );

  Map<String, dynamic> toJson() => {
        'type': bizType,
        'shop': shopName,
        'owner': owner,
        'phone': phone,
        'gstin': gstin,
        'addr': address,
        'state': stateCode,
        'taxIncl': taxInclusive,
      };

  factory BusinessProfile.fromJson(Map<String, dynamic> j) => BusinessProfile(
        bizType: j['type'] as String,
        shopName: (j['shop'] ?? '') as String,
        owner: (j['owner'] ?? '') as String,
        phone: (j['phone'] ?? '') as String,
        gstin: j['gstin'] as String?,
        address: (j['addr'] ?? '') as String,
        stateCode: (j['state'] ?? '36') as String,
        taxInclusive: j['taxIncl'] != false,
      );
}
