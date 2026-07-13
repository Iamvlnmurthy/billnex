import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Stable navigation ids — decoupled from index so feature-flagged tabs
/// (e.g. Customers) can appear/disappear without breaking callers.
enum NavId { dash, quickbill, billing, appointments, sales, customers, inventory, purchasing, reports, features, print, menu }

/// Localized label for a nav destination (falls back to the English spec).
String navLabel(BuildContext context, NavId id) {
  final l = L.of(context);
  return switch (id) {
    NavId.dash => l.navDashboard,
    NavId.quickbill => l.quickBill,
    NavId.billing => l.navBilling,
    NavId.appointments => l.navAppointments,
    NavId.sales => l.navSales,
    NavId.customers => l.navCustomers,
    NavId.inventory => l.navInventory,
    NavId.purchasing => l.navPurchases,
    NavId.reports => l.navReports,
    NavId.features => l.navFeatures,
    NavId.print => l.navPrint,
    NavId.menu => l.menu,
  };
}

class NavSpec {
  final NavId id;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const NavSpec(this.id, this.label, this.icon, this.activeIcon);
}

const Map<NavId, NavSpec> kNavSpecs = {
  NavId.dash: NavSpec(NavId.dash, 'Dashboard', Icons.dashboard_outlined, Icons.dashboard),
  NavId.quickbill: NavSpec(NavId.quickbill, 'Quick Bill', Icons.bolt_outlined, Icons.bolt),
  NavId.billing: NavSpec(NavId.billing, 'Billing', Icons.point_of_sale_outlined, Icons.point_of_sale),
  NavId.appointments: NavSpec(NavId.appointments, 'Appointments', Icons.event_outlined, Icons.event),
  NavId.sales: NavSpec(NavId.sales, 'Sales', Icons.receipt_long_outlined, Icons.receipt_long),
  NavId.customers: NavSpec(NavId.customers, 'Customers', Icons.groups_outlined, Icons.groups),
  NavId.inventory: NavSpec(NavId.inventory, 'Inventory', Icons.inventory_2_outlined, Icons.inventory_2),
  NavId.purchasing: NavSpec(NavId.purchasing, 'Purchases', Icons.local_shipping_outlined, Icons.local_shipping),
  NavId.reports: NavSpec(NavId.reports, 'Reports', Icons.bar_chart_outlined, Icons.bar_chart),
  NavId.features: NavSpec(NavId.features, 'Features', Icons.tune_outlined, Icons.tune),
  NavId.print: NavSpec(NavId.print, 'Print', Icons.print_outlined, Icons.print),
  NavId.menu: NavSpec(NavId.menu, 'Menu', Icons.menu, Icons.menu),
};
