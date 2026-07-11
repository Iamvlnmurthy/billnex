# BillNex Master Product Requirements Document

**Product:** BillNex by Nexen Labs  
**Version:** 1.0  
**Document date:** 2026-07-11  
**Companion artefact:** `BillNex_Master_Features_and_Customizations.xlsx`  
**Primary audience:** Claude, product management, engineering, QA, implementation, support and commercial teams

> This PRD is designed as an implementation-grade specification. It is intentionally detailed. Statutory, tax and regulated-industry requirements must be revalidated before production deployment.

## Claude Implementation Directive
- Treat this PRD and the companion Excel workbook as a joint source of truth. The PRD governs product behaviour and architecture; the workbook governs feature completeness and traceability.
- Do not invent features, compliance rules or business logic when a requirement is ambiguous. Record the ambiguity and request a decision.
- Build modularly using feature flags, business templates and entitlements. Do not fork the entire application for each vertical.
- Implement MVP and P1 before P2/P3. Reliability, offline operation, printing and support tooling have priority over visual extras.
- Every write operation must be auditable, duplicate-safe and reversible through an explicit business document, never through silent database deletion.
- Generate database migrations, OpenAPI contracts, test cases and implementation notes that reference the Feature ID from this PRD/workbook.
- Use approved printer profiles only. Add a new printer model only after test-print certification and failure-case testing.
- Keep tax rates, thresholds, statutory integrations and regulated-business rules configurable and professionally validated; do not hard-code assumptions that may change.
- Protect merchant and customer data using least privilege, consent-based support access and data minimisation.
- At the end of each implementation milestone, produce: completed Feature IDs, deferred items, known risks, migration impact, test evidence and release notes.

## 1. Executive Summary
BillNex is an Android-first, offline-capable billing and small-business operations platform sold with optional approved thermal-printer hardware, onboarding, catalogue assistance and controlled after-sales support. The product begins as a dependable retail billing kit and expands through configuration-driven vertical packs for pharmacy, restaurant, hardware, fashion, services, wholesale, rental, membership, manufacturing and other business types.

The product must compete through rapid deployment, local-language usability, reliable offline billing, tested printer compatibility, catalogue onboarding and accountable local support—not merely through a longer software feature list.

## 2. Product Vision, Goals and Non-Goals
### 2.1 Vision
Enable any small business counter to begin professional billing, inventory and business control with minimal hardware cost, minimal training and dependable support.

### 2.2 Product goals
- Launch a reliable standard retail edition that works for kirana, hardware, stationery, gift and general retail shops.
- Make the annual ₹5,999 Smart Shop Kit commercially viable through entitlement-controlled support and catalogue operations.
- Provide offline-first billing and duplicate-safe sync suitable for unstable connectivity.
- Standardise thermal-printer support through certified device profiles.
- Use one modular platform with business templates rather than separate codebases per industry.
- Give owners clear daily visibility into sales, cash, UPI, credit, stock and exceptions.
- Create a path from starter retail to vertical packs, Retail Pro, multi-branch and distribution editions.

### 2.3 Non-goals
- BillNex is not intended to become a full enterprise ERP in the first release.
- The product must not provide medical, pharmaceutical, agricultural or legal advice.
- The product must not store full card numbers, CVV, internet-banking credentials or merchant secrets in logs.
- The base subscription does not include unlimited custom development, unlimited catalogue work or unlimited on-site visits.
- Unsupported printer models and undocumented integrations must not be advertised as compatible.
- Medical records, laboratory workflows and clinical decision support are outside the initial clinic billing pack.
- Automatic statutory filing without merchant/accountant verification is outside the initial release.

## 3. Commercial Model and Packaging
### Monthly Flex Plan
- **Indicative price:** ₹499/month
- **Target customer:** Small shops; low commitment
- **Software:** Core software
- **Printer:** Printer extra: approx ₹1,999
- **Catalogue assistance:** 1 request/month up to 100 additions/updates*
- **Remote support:** Phone + WhatsApp + remote during business hours*
- **On-site support:** Scheduled/chargeable*
- **Limits/scope:** 1 business; 1 branch; suggested 2 users — Core retail
- **Condition:** No annual lock-in; Taxes extra if applicable

### Annual Smart Shop Kit
- **Indicative price:** ₹5,999/year
- **Target customer:** Shops wanting full starter kit
- **Software:** Core software for 1 year
- **Printer:** Approved 58mm printer included*
- **Catalogue assistance:** Initial loading + 1 request/month up to 100 additions/updates*
- **Remote support:** Phone + WhatsApp + remote + training*
- **On-site support:** Limited to serviceable area/policy*
- **Limits/scope:** 1 business; 1 branch; suggested 2 users — Core retail
- **Condition:** Full annual advance required for printer; Taxes extra if applicable

### Retail Pro Add-on
- **Indicative price:** Indicative ₹2,999–₹5,999/year
- **Target customer:** Supermarkets and advanced retailers
- **Software:** Requires base plan
- **Printer:** Additional hardware separate
- **Catalogue assistance:** Base quota unless upgraded
- **Remote support:** Priority remote support
- **On-site support:** Chargeable or SLA plan
- **Limits/scope:** Multi-counter; approvals; promotions; advanced inventory — Retail Pro
- **Condition:** Validate after pilot economics; Taxes extra if applicable

### Vertical Pack
- **Indicative price:** Indicative ₹1,999–₹9,999/year
- **Target customer:** Pharmacy, restaurant, service, salon, etc.
- **Software:** Requires base plan
- **Printer:** Vertical hardware separate
- **Catalogue assistance:** Vertical catalogue template may be included
- **Remote support:** Vertical knowledge-base support
- **On-site support:** As per vertical pack
- **Limits/scope:** Special workflows and reports — Vertical add-on
- **Condition:** Compliance/domain validation required; Taxes extra if applicable

### Multi-Branch Add-on
- **Indicative price:** Per additional branch
- **Target customer:** Growing retailers/distributors
- **Software:** Requires Pro/Business
- **Printer:** Per counter/branch
- **Catalogue assistance:** Central catalogue assistance
- **Remote support:** Priority remote support
- **On-site support:** SLA optional
- **Limits/scope:** Branch, warehouse, transfer and consolidated analytics — Business Pro
- **Condition:** Price by active branch/user; Taxes extra if applicable

## 4. Target Users and Business Segments
### 4.1 Personas
- **Owner / Proprietor:** Needs remote visibility, pricing control, cash and credit discipline, low-stock alerts, reliable backup and simple renewal.
- **Cashier / Counter Staff:** Needs extremely fast billing, clear search, stable printing, simple payments and minimal training.
- **Manager / Supervisor:** Approves exceptions, monitors shifts, purchases, stock adjustments, returns and staff performance.
- **Stock Keeper / Purchase User:** Maintains catalogue, receiving, batch/serial data, counts, transfers and supplier records.
- **Accountant:** Needs correct GST configuration, exports, ledgers, tax summaries, period controls and traceable adjustments.
- **Field Technician / Support Agent:** Needs diagnostic visibility with merchant consent, approved playbooks, ticket history and entitlement controls.
- **Delivery / Field Sales User:** Needs offline orders, route or delivery status, collections and proof of fulfilment.

### 4.2 Supported business segments
- **Kirana / General Store — Retail Standard / Kirana Pack:** Fast counter B2C; credit sales; High SKU; loose + packaged. Typical hardware: 58mm printer; scanner; optional scale.
- **Supermarket / Mini-Mart — Retail Pro / Supermarket Pack:** High-volume barcode POS; Very high SKU; multiple counters. Typical hardware: 80mm printer; scanner; drawer; display; scale.
- **Pharmacy / Medical Shop — Vertical Pro / Pharmacy Pack:** OTC/prescription-linked retail; Batch, expiry, MRP, rack. Typical hardware: 58/80mm printer; scanner; label printer.
- **Restaurant / QSR — Vertical Pro / Restaurant Pack:** Table/KOT/takeaway/delivery; Ingredients + menu recipes. Typical hardware: 80mm POS + kitchen printer.
- **Cafe / Bakery / Sweet Shop — Vertical Standard / Bakery Pack:** Counter/token/weighted billing; Production batches; shelf life. Typical hardware: 58/80mm printer; scale; label printer.
- **Hardware / Electrical / Plumbing — Retail Pro / Hardware Pack:** Counter + quotation + contractor credit; Brand/size/length variants. Typical hardware: 58/80mm printer; scanner.
- **Apparel / Footwear / Boutique — Vertical Standard / Fashion Pack:** Variant retail + exchanges; Style-colour-size matrix. Typical hardware: Printer; scanner; tag printer.
- **Jewellery Store — Vertical Enterprise / Jewellery Pack:** Weight/rate/making-charge billing; Unique tags; purity; stones. Typical hardware: 80mm; tag printer; precision scale.
- **Mobile / Electronics Store — Vertical Pro / Electronics Pack:** Device + accessories + warranty; Serial/IMEI/model/colour. Typical hardware: 80mm; scanner; label printer.
- **Stationery / Book / Gift Store — Retail Standard / Stationery Pack:** Counter retail + seasonal bundles; Many low-value SKUs. Typical hardware: 58mm; scanner; label printer.
- **Salon / Spa / Beauty — Vertical Standard / Salon Pack:** Appointments + service billing; Services + consumables + retail. Typical hardware: 58mm printer; tablet.
- **Repair / Service Centre — Vertical Standard / Service Centre Pack:** Job card + estimate + labour/parts; Spares + customer devices. Typical hardware: 58/80mm; label printer.
- **Wholesale / Distribution — Business Pro / Wholesale Pack:** B2B, route sales, credit; Cases/pieces; warehouse/van. Typical hardware: 80mm/A4; scanner; mobile printer.
- **Auto Parts / Garage — Vertical Pro / Auto Service Pack:** Part sale + vehicle service; Part compatibility + job parts. Typical hardware: 80mm; scanner.
- **Optical Store — Vertical Standard / Optical Pack:** Prescription + frame/lens order; Frames + lens specs. Typical hardware: 58/80mm; scanner.
- **Agri Input Store — Vertical Pro / Agri Input Pack:** Seasonal retail + credit; Batch/expiry/crop/pack size. Typical hardware: 58/80mm; scanner.
- **Fresh Produce / Meat / Fish — Vertical Standard / Fresh Retail Pack:** Fast weight-based billing; Perishable lots + wastage. Typical hardware: Scale; 58mm; label printer.
- **Laundry / Dry Cleaning — Vertical Standard / Laundry Pack:** Garment intake + status + delivery; Customer garments. Typical hardware: 58mm; tag printer.
- **Gym / Membership Business — Vertical Standard / Membership Pack:** Membership + recurring fees; Plans + attendance. Typical hardware: 58mm; QR/biometric optional.
- **Rental Business — Vertical Pro / Rental Pack:** Booking + deposit + return; Unique rentable assets. Typical hardware: 58/80mm; QR/scanner.
- **Clinic / Diagnostic Centre — Vertical Pro / Clinic Billing Pack:** Patient/service/package billing; Consumables + services. Typical hardware: 80mm/A4; label optional.
- **Small Manufacturing / Assembly — Business Pro / Manufacturing Pack:** Order-to-production-to-invoice; Raw/WIP/finished/BOM. Typical hardware: A4/80mm; barcode/label.
- **Home Services / Contractor — Vertical Standard / Field Service Pack:** Estimate + field job + invoice; Technician stock. Typical hardware: Android + mobile printer.
- **Tuition / Training Institute — Vertical Standard / Institute Billing Pack:** Course fee + instalments + receipts; Courses, batches, kits. Typical hardware: 58mm/A4 printer.

## 5. Product Principles
- Billing reliability is more important than feature breadth.
- Offline-first does not mean uncontrolled data divergence; conflicts must be visible and resolvable.
- Configuration and feature flags are preferred to merchant-specific code forks.
- Every critical financial, stock and configuration action is attributable and auditable.
- The merchant owns their data and can export it, subject to access and legal controls.
- Support access is explicit, time-bound and least-privileged.
- Printer and integration compatibility is certified, not assumed.
- Regulated vertical packs require specialist validation before broad sale.

## 6. Success Metrics and Product SLAs
- **Billing speed:** A trained cashier should complete a typical five-item cash/UPI sale in 20 seconds or less, excluding customer decision time.
- **Print reliability:** At least 98% of print attempts should succeed on approved printer models without manual app restart.
- **Offline continuity:** Core billing must continue during internet loss, with clear queue status and duplicate-safe later sync.
- **Data integrity:** No duplicate invoice numbers, duplicate posted payments or silent transaction deletion.
- **Crash-free usage:** Target at least 99.5% crash-free production sessions before broad rollout.
- **Onboarding efficiency:** After a validated catalogue is available, a standard retail installation should be completed in 60 minutes or less.
- **Support efficiency:** Target at least 70% remote resolution before authorising on-site visits.
- **Catalogue SLA:** Valid monthly catalogue requests should be completed within two business days, subject to plan limits.
- **Merchant retention:** Track annual renewal rate, active billing days and merchant support cost as core commercial KPIs.

## 7. User Journeys
- **Merchant onboarding:** Sales order → subscription activation → business/tax setup → approved printer pairing → catalogue import → sample bill → backup verification → staff training → sign-off.
- **Standard sale:** Login/PIN → scan/search items → quantity/discount/customer → payment → post locally → print/share → sync → owner dashboard.
- **Offline sale:** Connectivity loss shown → invoice uses collision-safe local sequence → transaction posts locally → receipt prints → outbox queues → reconnect syncs idempotently → conflicts resolved.
- **Credit sale and collection:** Identify customer → validate limit/overdue → post part/unpaid balance → due reminder → later receipt allocated to invoices → updated statement.
- **Purchase and receiving:** PO/direct purchase → receive quantity/batch/serial → record supplier invoice and charges → update stock/payable → reconcile payment.
- **Return/exchange:** Locate original invoice → validate policy → select lines and disposition → approval if required → generate return/credit document → refund/exchange → stock/ledger update.
- **Monthly catalogue assistance:** Merchant submits structured file → entitlement validates quota → support validates rows → merchant reviews changes → approved activation → audit and SLA metric.
- **Support incident:** Merchant opens ticket → consented diagnostics → remote playbook → resolution or serviceable-area visit → closure confirmation → recurring issue classification.

## 8. Reference Architecture
- **Client:** Flutter/Dart Android-first application. Tablet and desktop-compatible layouts may be added without compromising phone usability.
- **Local data:** SQLite through a typed persistence layer such as Drift. All critical posted transactions use local durable storage before UI success confirmation.
- **Backend:** PostgreSQL-based multi-tenant service with row-level tenant isolation, REST APIs and background job workers. Supabase may accelerate implementation, but business services must not be tightly coupled to one vendor.
- **Sync:** Outbox/inbox pattern with idempotency keys, per-entity revisions, retry backoff, conflict classification and an operator resolution queue.
- **Printing:** ESC/POS abstraction with approved model profiles for connection type, line width, code page, raster logo, QR, barcode and cutter commands.
- **Files:** Object storage for invoices, attachments, logos and support artefacts with tenant-scoped signed access.
- **Authentication:** Owner/admin secure login, refresh tokens, device registration and cashier PIN sessions tied to named users.
- **APIs:** OpenAPI 3.1 contract. Every write endpoint must support idempotency and return stable error codes.
- **Background jobs:** Use durable queues for invoice sharing, backups, exports, scheduled reports, messaging and integration retries.
- **Observability:** Structured logs, crash reporting, printer diagnostics, sync health, audit events and merchant-safe support telemetry.

### 8.1 Required architectural qualities
- Multi-tenant isolation with business and branch scope.
- Deterministic tax and rounding calculations with automated regression tests.
- Immutable source documents and explicit reversal documents.
- Versioned database migrations and API contracts.
- Feature entitlements evaluated both client-side for UX and server-side for enforcement.
- No critical dependency on real-time internet connectivity for billing.
- Printer operations separated from transaction posting.
- Observability without collecting unnecessary customer information.

## 9. Roles and Permission Model
- **Owner:** Full business control, subscription, exports, sensitive reports and role administration.
- **Administrator:** Configuration, users, devices and integrations; financial access may be separately restricted.
- **Manager:** Operational oversight and approval of discounts, returns, cancellations, adjustments and shifts.
- **Cashier:** POS, permitted customers, payments, holds and own shift; no unrestricted cost/margin/export access.
- **Stock Keeper:** Receiving, counts, transfers, labels and stock reports.
- **Purchase User:** Supplier, PO, receipt and purchase entry within approval limits.
- **Accountant:** Tax, ledgers, expenses, period controls and exports.
- **Delivery/Field User:** Assigned orders, collections, route and proof actions.
- **Support Agent:** Ticket and consent-limited diagnostic access; no permanent merchant data access.

## 10. Functional Requirements — Core Platform
### 10.1 Setup & Configuration
#### Business Profile
- **BNX-0001 — Business registration** `[Priority: Must | Phase: MVP | Complexity: S]`  
  Capture legal/trade name, address, contact, GST status, GSTIN, state and business category.
- **BNX-0002 — Logo and invoice branding** `[Priority: Should | Phase: MVP | Complexity: S]`  
  Upload logo, invoice header/footer, support details and theme settings.
- **BNX-0003 — Multiple invoice series** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Configure separate series by branch, document, channel or financial year.
- **BNX-0004 — Financial-year rollover** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Open a new year while retaining masters and controlled opening balances.
- **BNX-0005 — Branch profile** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Maintain branch code, address, tax identity, price list and warehouse mapping.
#### Regional
- **BNX-0006 — English, Telugu and Hindi interface** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Provide translatable UI labels and language preference by user/device.
- **BNX-0007 — Currency and Indian number format** `[Priority: Must | Phase: MVP | Complexity: S]`  
  Configure currency, decimal precision, rounding and Indian digit grouping.
- **BNX-0008 — Date/time/timezone** `[Priority: Must | Phase: MVP | Complexity: S]`  
  Apply configurable date format, business timezone and 12/24-hour display.
#### Business Rules
- **BNX-0009 — Tax-inclusive or exclusive pricing** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Store and bill prices according to merchant-selected tax mode.
- **BNX-0010 — Walk-in customer** `[Priority: Must | Phase: MVP | Complexity: S]`  
  Use a configurable default customer for fast B2C billing.
- **BNX-0011 — Negative-stock policy** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Block, warn or allow billing when available stock is insufficient.
- **BNX-0012 — Return policy** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Configure return days, original-invoice rule, approval and refund modes.
- **BNX-0013 — Credit policy** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Set credit limits, due days, grace periods and overdue blocking.
- **BNX-0014 — Discount approval limits** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Set cashier and manager discount thresholds and mandatory reasons.
- **BNX-0015 — Business-day close** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Define daily close time for late-night operations.
#### Import & Migration
- **BNX-0016 — Excel catalogue import** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Import products, stock, price, tax, HSN/SAC, barcode and category through a validated template.
- **BNX-0017 — Customer and opening balance import** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Import customer details, credit terms and outstanding balances.
- **BNX-0018 — Supplier and payable import** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Import supplier masters and opening dues.
- **BNX-0019 — Duplicate detection** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Detect duplicate products, barcodes, customers, suppliers and invoice references.
- **BNX-0020 — Import validation report** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Return row-level errors and allow corrected rows to be re-uploaded.

**Module acceptance gates**
- A new merchant can complete guided setup without engineering intervention.
- Critical business, tax and invoice settings are effective-dated or audited.
- Invalid imports return row-level errors without partially corrupting production data.

### 10.2 Catalogue & Pricing
#### Product Master
- **BNX-0021 — Simple stock item** `[Priority: Must | Phase: MVP | Complexity: S]`  
  Create item with name, SKU, category, unit, price, tax, opening stock and status.
- **BNX-0022 — Service item** `[Priority: Must | Phase: MVP | Complexity: S]`  
  Create non-stock service with SAC, duration, staff and rate.
- **BNX-0023 — Multiple barcodes** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Store manufacturer, internal and unit-level alternate barcodes.
- **BNX-0024 — Automatic barcode generation** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Generate internal barcodes for unlabelled products.
- **BNX-0025 — SKU and quick code** `[Priority: Should | Phase: MVP | Complexity: S]`  
  Support alphanumeric SKU and numeric fast-entry code.
#### Classification
- **BNX-0026 — Category hierarchy** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Maintain category, subcategory and optional department.
- **BNX-0027 — Brand and manufacturer** `[Priority: Should | Phase: P1 | Complexity: S]`  
  Maintain searchable brand/manufacturer masters.
- **BNX-0028 — HSN/SAC mapping** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Map products/services to effective-dated tax classification.
#### Units
- **BNX-0029 — Unit master** `[Priority: Must | Phase: MVP | Complexity: S]`  
  Support piece, pack, kg, gram, litre, metre, hour, service and custom units.
- **BNX-0030 — Multi-unit conversion** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Buy and sell in different units with conversion, barcode and price.
#### Pricing
- **BNX-0031 — MRP, selling and minimum price** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Maintain MRP, active selling price and controlled minimum price.
- **BNX-0032 — Multiple price lists** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Retail, wholesale, dealer, member, branch and contract pricing.
- **BNX-0033 — Scheduled price activation** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Prepare future price changes with effective date/time.
- **BNX-0034 — Branch price override** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Allow controlled location-specific price variation.
#### Variants
- **BNX-0035 — Variant matrix** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Manage size, colour, style, flavour, capacity and other attributes as child SKUs.
- **BNX-0036 — Variant name generation** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Generate readable product names from parent + attributes.
#### Lifecycle
- **BNX-0037 — Active/inactive/discontinued status** `[Priority: Must | Phase: MVP | Complexity: S]`  
  Stop purchase or sale without deleting historical records.
- **BNX-0038 — Product merge** `[Priority: Could | Phase: P3 | Complexity: XL]`  
  Merge duplicate products with audited transaction reassignment.
#### Catalogue UX
- **BNX-0039 — Favourites and fast keys** `[Priority: Should | Phase: MVP | Complexity: M]`  
  Pin frequent products by cashier, counter or category.
- **BNX-0040 — Product images** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Use compressed images on POS tiles and catalogues.
- **BNX-0041 — Aliases and local names** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Search using abbreviations, synonyms and local-language aliases.
- **BNX-0042 — Recent/frequent products** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Show recent and top-selling items during billing.
#### Maintenance
- **BNX-0043 — Bulk edit** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Bulk-change tax, price, category, supplier, reorder and status using filters.
- **BNX-0044 — Monthly catalogue request** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Submit, validate, approve and audit the included monthly catalogue request.
- **BNX-0045 — Catalogue change audit** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Log changes to price, tax, unit, barcode and status.

**Module acceptance gates**
- Items are searchable by name, SKU, barcode and aliases.
- Price/tax/unit changes preserve historical invoices.
- Bulk changes and support-entered catalogue updates are auditable.

### 10.3 POS & Billing
#### Sale Entry
- **BNX-0046 — Fast bill screen** `[Priority: Must | Phase: MVP | Complexity: L]`  
  Touch-friendly item search, cart, totals and payment on one screen.
- **BNX-0047 — Barcode scan billing** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Add item immediately through approved barcode scanner.
- **BNX-0048 — Camera barcode scan** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Use Android camera as low-cost scanner fallback.
- **BNX-0049 — Quick quantity edit** `[Priority: Must | Phase: MVP | Complexity: S]`  
  Change quantity with keypad or +/- without leaving cart.
- **BNX-0050 — Decimal and weight quantity** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Allow product-specific decimal precision for kg, litre, metre and similar units.
- **BNX-0051 — Manual miscellaneous line** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Add controlled ad-hoc item/service with description, rate and tax.
- **BNX-0052 — Hold and resume bill** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Save incomplete carts and resume by token, customer or user.
- **BNX-0053 — Multiple parked bills** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Park several carts with timestamp and cashier ownership.
#### Customer
- **BNX-0054 — Optional customer capture** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Request customer details only when credit, warranty, amount or policy requires them.
- **BNX-0055 — Customer search** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Find by mobile, name, code, GSTIN or recent bill.
#### Discount
- **BNX-0056 — Line discount** `[Priority: Should | Phase: MVP | Complexity: M]`  
  Apply amount/percentage discount with role limits.
- **BNX-0057 — Bill discount** `[Priority: Should | Phase: MVP | Complexity: L]`  
  Allocate invoice-level discount correctly across taxable lines.
- **BNX-0058 — Reason and manager PIN** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Require reason and approval above threshold.
#### Charges
- **BNX-0059 — Additional charges** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Add delivery, packing, service, labour and installation charges with tax treatment.
- **BNX-0060 — Round-off** `[Priority: Must | Phase: MVP | Complexity: S]`  
  Apply configured invoice round-off and display separately.
#### Price Control
- **BNX-0061 — Price override** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Allow authorised override within minimum/maximum range.
- **BNX-0062 — Price mismatch warning** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Warn when barcode, catalogue or selected price list differs.
#### Stock Control
- **BNX-0063 — Availability display** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Show on-hand, available, reserved and branch stock.
- **BNX-0064 — Batch/serial selection** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Require batch, serial or IMEI when product is controlled.
#### Payment
- **BNX-0065 — Single payment** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Complete bill with cash, UPI, card, bank, credit or custom mode.
- **BNX-0066 — Split payment** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Use multiple payment modes on one invoice.
- **BNX-0067 — Partial payment and due** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Post balance to customer ledger.
- **BNX-0068 — Cash tendered/change due** `[Priority: Must | Phase: MVP | Complexity: S]`  
  Calculate change and optionally assist denomination count.
#### Invoice Output
- **BNX-0069 — 58mm thermal receipt** `[Priority: Must | Phase: MVP | Complexity: L]`  
  Print optimised receipt through approved ESC/POS profile.
- **BNX-0070 — 80mm receipt** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Print wider receipt with tax detail and cutter support.
- **BNX-0071 — A4 invoice** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Generate professional A4 tax invoice and quotation.
- **BNX-0072 — WhatsApp invoice** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Share PDF/image invoice and record share status.
- **BNX-0073 — Email invoice** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Email invoice PDF with template.
- **BNX-0074 — Audited reprint** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Reprint as copy with user, timestamp and reason log.
#### Documents
- **BNX-0075 — Quotation** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Create, send, expire and convert quotation to sale.
- **BNX-0076 — Proforma invoice** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Create non-posting proforma and convert to invoice.
- **BNX-0077 — Sales order** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Capture ordered quantity, promised date, advance and status.
- **BNX-0078 — Delivery challan** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Deliver before invoicing and link later.
- **BNX-0079 — Receipt voucher** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Issue numbered receipt for advance or account collection.
#### Returns
- **BNX-0080 — Return against invoice** `[Priority: Must | Phase: P1 | Complexity: L]`  
  Select original lines, enforce policy and reverse stock/financial effect.
- **BNX-0081 — Exchange** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Apply return value to replacement items and collect/refund difference.
- **BNX-0082 — Return without invoice** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Permit manager-approved exception with evidence and reason.
- **BNX-0083 — Returned stock disposition** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Mark saleable, damaged, quarantine, repair or supplier-return.
#### Cancellation
- **BNX-0084 — Void open cart** `[Priority: Must | Phase: MVP | Complexity: S]`  
  Cancel before posting without stock/financial impact.
- **BNX-0085 — Cancel posted invoice** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Create controlled reversal; never silently delete.
#### Cashier UX
- **BNX-0086 — Keyboard shortcuts** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Configure shortcuts for search, hold, payment, discount and print.
- **BNX-0087 — Touch mode** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Large category tiles and controls for mobile/tablet.
- **BNX-0088 — Offline status** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Show connectivity, last sync, queued transactions and backup state.
- **BNX-0089 — Training/demo company** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Allow non-posting practice transactions.

**Module acceptance gates**
- A posted sale creates consistent invoice, payment, tax and stock records.
- Printing failure never duplicates the sale.
- Returns and cancellations create explicit reversal documents and audit events.

### 10.4 GST, Tax & Documents
#### GST Setup
- **BNX-0090 — Registration mode** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Support registered, composition, exempt and unregistered configurations.
- **BNX-0091 — State and place of supply** `[Priority: Must | Phase: MVP | Complexity: L]`  
  Determine intra/inter-state treatment with controlled override.
- **BNX-0092 — Effective-dated tax rates** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Configure CGST, SGST, IGST and cess by tax category.
#### GST Invoice
- **BNX-0093 — Mandatory invoice fields** `[Priority: Must | Phase: MVP | Complexity: L]`  
  Validate supplier, number, date, recipient where applicable, HSN/SAC, quantity, value and tax.
- **BNX-0094 — Unique financial-year numbering** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Enforce unique sequential number by series and year.
- **BNX-0095 — B2B recipient validation** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Validate GSTIN format, state and address before B2B invoice.
- **BNX-0096 — B2C recipient/state fields** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Capture customer/state when merchant reporting rules require them.
- **BNX-0097 — Reverse charge flag** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Support configured reverse-charge disclosure.
- **BNX-0098 — Exempt/nil/non-GST classification** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Report zero-tax categories separately.
- **BNX-0099 — Cess calculation** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Support configured percentage or unit-based cess.
#### Tax Documents
- **BNX-0100 — Bill of supply** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Generate applicable bill of supply with separate series.
- **BNX-0101 — Credit note** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Link to original invoice and adjust stock/tax/ledger.
- **BNX-0102 — Debit note** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Issue upward adjustment document with reference and reason.
- **BNX-0103 — Advance receipt/adjustment** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Record advance and adjust against final invoice.
#### Tax Calculation
- **BNX-0104 — Line/invoice tax breakup** `[Priority: Must | Phase: MVP | Complexity: L]`  
  Reconcile taxable value and tax by line and document.
- **BNX-0105 — Discount tax allocation** `[Priority: Must | Phase: MVP | Complexity: L]`  
  Allocate invoice discount proportionally and recalculate tax.
- **BNX-0106 — Tax rounding control** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Use configurable precision while reconciling totals.
#### Returns
- **BNX-0107 — GSTR-1-ready export** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Export validated outward invoice/note data in structured format.
- **BNX-0108 — HSN/SAC summary** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Summarise quantity, taxable value and tax by HSN/SAC.
- **BNX-0109 — Tax liability summary** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Summarise tax by rate, state and document type.
#### E-Invoice
- **BNX-0110 — Eligibility configuration** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Maintain AATO/eligibility settings and warnings.
- **BNX-0111 — IRP integration** `[Priority: Could | Phase: P3 | Complexity: XL]`  
  Generate payload, obtain IRN, signed QR and acknowledgement through approved integration.
- **BNX-0112 — IRN cancellation** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Control cancellation and prevent unauthorised post-IRN edits.
- **BNX-0113 — Reporting-age warning** `[Priority: Could | Phase: P3 | Complexity: M]`  
  Warn eligible businesses about configured reporting time limits.
#### E-Way Bill
- **BNX-0114 — Movement data capture** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Capture transporter, vehicle, distance, dispatch and delivery fields.
- **BNX-0115 — API integration** `[Priority: Could | Phase: P3 | Complexity: XL]`  
  Generate/update EWB and retain number/status through approved integration.
#### Audit
- **BNX-0116 — Tax configuration audit** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Log tax, HSN/SAC, numbering and registration changes.

**Module acceptance gates**
- Mandatory configured fields block finalisation when missing.
- Tax totals reconcile at line and document level.
- Statutory integrations remain configurable and are not assumed for all merchants.

### 10.5 Payments, Cash & Credit
#### Payment Modes
- **BNX-0117 — Configurable modes** `[Priority: Must | Phase: MVP | Complexity: S]`  
  Enable cash, UPI, card, bank, wallet, cheque, credit and custom modes.
#### UPI
- **BNX-0118 — Static QR on receipt** `[Priority: Should | Phase: MVP | Complexity: M]`  
  Print merchant UPI QR and payee details.
- **BNX-0119 — Dynamic payment request** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Generate amount-specific UPI intent/QR through supported provider.
- **BNX-0120 — Payment confirmation** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Capture provider confirmation or controlled manual UTR/reference.
#### Card
- **BNX-0121 — Card reference** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Record terminal/type/reference without sensitive card data.
#### Cash
- **BNX-0122 — Opening float** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Record opening cash per shift.
- **BNX-0123 — Cash in/out** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Record petty cash movement with reason.
- **BNX-0124 — Shift close count** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Compare physical cash with expected and record variance.
- **BNX-0125 — Denomination count** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Calculate cash from note/coin quantities.
#### Settlement
- **BNX-0126 — Payment-mode reconciliation** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Compare cash/UPI/card/bank expected and settled values.
- **BNX-0127 — Bank deposit tracking** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Link cash deposit to day/shift collection.
#### Credit
- **BNX-0128 — Customer credit sale** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Post unpaid amount to ledger with due date/limit check.
- **BNX-0129 — Collection receipt** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Allocate customer payment to invoices or on-account.
- **BNX-0130 — Ageing and reminders** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Bucket dues and trigger consented reminders.
- **BNX-0131 — Credit limit/block** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Warn or block when overdue/limit exceeded.
#### Refund
- **BNX-0132 — Cash refund** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Process authorised refund against return/credit note.
- **BNX-0133 — Digital refund status** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Record mode, reference and pending/completed status.
#### Advance
- **BNX-0134 — Customer advance** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Accept deposit and adjust against later invoice.
#### Deposit
- **BNX-0135 — Security deposit** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Track refundable liability separately from sale.
#### Reconciliation
- **BNX-0136 — Unmatched payment queue** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Show payment references not linked to invoices.

**Module acceptance gates**
- Every payment/refund is attributable to user, time, mode, amount and reference where applicable.
- Shift closing identifies expected versus counted differences.
- Credit limits and due controls are enforced consistently online and offline.

### 10.6 Inventory Control
#### Stock Ledger
- **BNX-0137 — Real-time balance** `[Priority: Must | Phase: MVP | Complexity: L]`  
  Maintain item/location/batch/serial/status quantity from posted movements.
- **BNX-0138 — Movement history** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Show every receipt, sale, return, adjustment and transfer with source.
#### Opening Stock
- **BNX-0139 — Quantity and value** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Import opening quantity, cost, batch/serial and location.
#### Availability
- **BNX-0140 — Available-to-sell** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Calculate on-hand less reserved, damaged and quarantine stock.
#### Reorder
- **BNX-0141 — Minimum/reorder level** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Set minimum, maximum, reorder point and quantity.
- **BNX-0142 — Low-stock alerts** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Notify and list items below configured level.
- **BNX-0143 — Purchase suggestion** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Suggest quantity/supplier from velocity, lead time and open orders.
#### Counting
- **BNX-0144 — Physical stock count** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Create count session, record actual and post approved variance.
- **BNX-0145 — Cycle counting** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Count selected category/rack/value class without closing store.
- **BNX-0146 — Blind count** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Hide expected quantity until submission.
#### Adjustment
- **BNX-0147 — Stock adjustment** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Increase/decrease with reason, value and approval.
- **BNX-0148 — Damage and wastage** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Move quantity to damaged/waste status and capture value impact.
#### Location
- **BNX-0149 — Rack/bin location** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Assign items to rack/bin/shelf and support search.
- **BNX-0150 — Warehouse/vehicle location** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Maintain stores, warehouses, vehicles and virtual locations.
#### Transfer
- **BNX-0151 — Stock transfer** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Request, dispatch, in-transit and receive between locations.
- **BNX-0152 — Transfer discrepancy** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Record shortage, excess and damage on receipt.
#### Reservation
- **BNX-0153 — Stock reservation** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Reserve against order, repair, rental or customer hold.
#### Batch
- **BNX-0154 — Batch/lot tracking** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Store batch, manufacture/expiry, cost, supplier and quantity.
- **BNX-0155 — FEFO/FIFO issue suggestion** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Suggest issue batch by expiry or configured rule.
- **BNX-0156 — Near-expiry alerts** `[Priority: Should | Phase: P2 | Complexity: M]`  
  List batches for markdown, transfer or supplier return.
#### Serial
- **BNX-0157 — Serial/IMEI tracking** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Capture unique serial during purchase, sale, return, transfer and service.
- **BNX-0158 — Serial lifecycle status** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Available, sold, returned, repair, scrapped or transferred.
#### Valuation
- **BNX-0159 — Weighted-average cost** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Calculate moving average by company/location policy.
- **BNX-0160 — FIFO valuation report** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Produce FIFO-based valuation for review.
- **BNX-0161 — Landed cost allocation** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Allocate freight/handling to received items.
#### Expiry
- **BNX-0162 — Expired-stock block** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Prevent sale of expired batch unless exceptional controlled workflow exists.
#### Bundle
- **BNX-0163 — Kit/component stock** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Sell bundle and consume configured components.
#### Packing
- **BNX-0164 — Pack conversion** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Break carton/case into smaller selling units.
#### Labels
- **BNX-0165 — Barcode labels** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Print barcode, item, MRP, price, batch and date on templates.
- **BNX-0166 — Shelf labels** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Print shelf label and track active price batch.
#### Demand
- **BNX-0167 — Sales velocity** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Classify fast, slow and non-moving products.
- **BNX-0168 — Dead stock** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Identify no-sale items by configurable period/value.
- **BNX-0169 — Stock-out history** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Record out-of-stock days and demand signals.
#### Audit
- **BNX-0170 — Inventory audit** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Log all manual quantity-affecting actions.
#### Offline
- **BNX-0171 — Offline stock conflicts** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Flag negative, duplicate serial or reservation conflicts after sync.

**Module acceptance gates**
- Stock balance is derived from posted movements.
- Batch/serial uniqueness and state transitions are enforced.
- Offline conflicts are visible and resolvable rather than silently overwritten.

### 10.7 Purchasing & Suppliers
#### Supplier
- **BNX-0172 — Supplier master** `[Priority: Must | Phase: MVP | Complexity: S]`  
  Maintain contact, GSTIN, state, terms, categories and status.
- **BNX-0173 — Supplier item mapping** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Map supplier code, pack, last rate, lead time and MOQ.
#### Purchase
- **BNX-0174 — Purchase order** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Create PO with items, rates, tax, expected date and terms.
- **BNX-0175 — PO approval** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Route purchase order by value/category for approval.
- **BNX-0176 — Goods receipt** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Receive full/partial PO with accepted/rejected quantity and batch/serial.
- **BNX-0177 — Purchase invoice** `[Priority: Must | Phase: P1 | Complexity: L]`  
  Record supplier invoice, tax, charges, due date and reference.
- **BNX-0178 — Direct purchase** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Record purchase without PO for small merchants.
- **BNX-0179 — Purchase return** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Return goods by invoice/batch/serial with payable effect.
- **BNX-0180 — Rate comparison** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Compare supplier rates, schemes and lead times.
- **BNX-0181 — Free quantity/scheme** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Capture buy-X-get-Y, free units and cash discount.
- **BNX-0182 — Additional cost allocation** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Allocate freight/loading/transport to item cost.
- **BNX-0183 — Duplicate invoice warning** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Detect same supplier invoice/date/amount.
- **BNX-0184 — Three-way match** `[Priority: Could | Phase: P3 | Complexity: XL]`  
  Compare PO, receipt and supplier invoice.
#### Payables
- **BNX-0185 — Supplier ledger** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Track invoices, payments, returns and advances.
- **BNX-0186 — Supplier payment** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Allocate cash/bank/UPI/cheque payment to invoices.
- **BNX-0187 — Due reminders** `[Priority: Should | Phase: P1 | Complexity: S]`  
  Show upcoming and overdue supplier dues.
- **BNX-0188 — Statement reconciliation** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Compare supplier statement and mark differences.
#### Procurement
- **BNX-0189 — Reorder to PO** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Convert approved reorder suggestion to supplier PO.
- **BNX-0190 — Preferred supplier** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Set preferred/fallback supplier by product/category.
#### Documents
- **BNX-0191 — Attachment** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Attach invoice image/PDF and delivery note.
#### OCR
- **BNX-0192 — Purchase scan assist** `[Priority: Could | Phase: P3 | Complexity: XL]`  
  Extract fields for user verification, never auto-post blindly.
#### Returns
- **BNX-0193 — Return-to-supplier suggestion** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Recommend expiry/damage-based return.
#### Analytics
- **BNX-0194 — Purchase trends** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Analyse quantity, value, rate change and supplier concentration.

**Module acceptance gates**
- Posted purchase updates stock, tax and supplier payable consistently.
- Duplicate supplier invoice warnings are active.
- Returns reverse the appropriate stock and payable values.

### 10.8 Accounting & Expenses
#### Ledger
- **BNX-0195 — Customer ledger** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Show invoices, receipts, returns, adjustments and running balance.
- **BNX-0196 — Supplier ledger** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Show purchases, payments, returns and running balance.
- **BNX-0197 — General-ledger mapping** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Map transaction types and payment modes to configurable accounts.
#### Expenses
- **BNX-0198 — Expense entry** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Record category, vendor, tax, payment, attachment and approval.
- **BNX-0199 — Recurring expense** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Schedule rent, salary and subscriptions for confirmation.
- **BNX-0200 — Petty cash** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Maintain petty cash account, voucher, custodian and limits.
#### Income
- **BNX-0201 — Other income** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Record non-sales income separately.
#### Banking
- **BNX-0202 — Bank account master** `[Priority: Should | Phase: P1 | Complexity: S]`  
  Maintain business bank accounts and opening balances.
- **BNX-0203 — Bank statement import** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Import CSV statement and prepare matching suggestions.
- **BNX-0204 — Bank reconciliation** `[Priority: Could | Phase: P3 | Complexity: XL]`  
  Match deposits, settlements, withdrawals and transfers.
#### Accounting
- **BNX-0205 — Journal voucher** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Create balanced accountant-authorised journal entry.
- **BNX-0206 — Opening balances** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Load accounts, parties, cash and bank balances.
#### Profit
- **BNX-0207 — Gross profit estimate** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Calculate sales less configured inventory cost.
- **BNX-0208 — Net operating summary** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Combine gross profit, expenses and other income.
#### Receivables
- **BNX-0209 — Ageing report** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Bucket customer outstanding by age/due date.
#### Payables
- **BNX-0210 — Ageing report** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Bucket supplier dues by age/due date.
#### Cash Flow
- **BNX-0211 — Daily cash flow** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Opening, collections, payments, deposits and closing.
- **BNX-0212 — Projected dues** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Show expected receipts and payments by date.
#### Export
- **BNX-0213 — Accountant export** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Export sales, purchases, expenses, ledgers and tax summaries.
- **BNX-0214 — Accounting-platform mapping** `[Priority: Could | Phase: P3 | Complexity: XL]`  
  Provide configurable export/sync mapping for supported accounting software.
#### Controls
- **BNX-0215 — Backdated-entry policy** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Allow, warn or block by role and closed period.
- **BNX-0216 — Period lock** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Lock reviewed date range and audit reopening.
- **BNX-0217 — Approval workflow** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Approve large expense, refund, discount, journal and write-off.
#### Statements
- **BNX-0218 — Customer statement** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Generate/share opening, transactions, balance and ageing.
- **BNX-0219 — Supplier statement** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Generate internal supplier statement.

**Module acceptance gates**
- Management reports reconcile to operational documents and authorised adjustments.
- Closed periods cannot be modified without privileged reopening.
- Exports preserve source document references.

### 10.9 CRM, Loyalty & Promotions
#### Customer Master
- **BNX-0220 — Customer profile** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Maintain name, mobile, address, GSTIN, tags, credit and consent.
- **BNX-0221 — Duplicate detection/merge** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Identify duplicate mobile/GSTIN/name and merge with audit.
- **BNX-0222 — Internal notes** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Record timestamped role-restricted notes.
#### History
- **BNX-0223 — Purchase history** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Show invoices, returns, frequent items, average bill and last visit.
#### Segmentation
- **BNX-0224 — Customer tags** `[Priority: Should | Phase: P1 | Complexity: S]`  
  Create retail, wholesale, VIP, contractor, farmer and member tags.
- **BNX-0225 — Automatic segments** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Generate new, inactive, high-value, overdue and at-risk segments.
#### Loyalty
- **BNX-0226 — Points earning** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Award points by spend, item/category and promotion with expiry.
- **BNX-0227 — Points redemption** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Redeem under limits and show balance on receipt.
- **BNX-0228 — Tier membership** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Maintain Silver/Gold/VIP benefits and prices.
#### Promotions
- **BNX-0229 — Coupon codes** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Create amount/percentage coupons with restrictions.
- **BNX-0230 — Buy-X-get-Y** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Configure quantity-based free item or discount.
- **BNX-0231 — Combo pricing** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Sell selected item group at bundle price.
- **BNX-0232 — Time-based offer** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Apply offers by date/day/time/channel.
#### Communication
- **BNX-0233 — Transactional messages** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Send invoice, receipt, status and due reminder using approved channels.
- **BNX-0234 — Campaign audience export** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Export consented segments for approved outreach.
- **BNX-0235 — Opt-in/opt-out** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Record purpose/channel/timestamp of consent and withdrawal.
#### Feedback
- **BNX-0236 — Feedback QR/link** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Print or send transaction-linked feedback URL.
#### Referral
- **BNX-0237 — Referral code** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Track referrer and reward after qualifying sale.
#### Warranty
- **BNX-0238 — Customer warranty record** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Link serial/invoice to warranty period and service history.
#### Analytics
- **BNX-0239 — Customer lifetime metrics** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Visits, revenue, margin estimate, return and outstanding.

**Module acceptance gates**
- Customer communication respects recorded consent.
- Promotion conflicts are deterministic.
- Loyalty earning/redemption creates an immutable ledger.

### 10.10 Orders & Delivery
#### Order
- **BNX-0240 — Customer order** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Capture items, promised date, address, advance, notes and source.
- **BNX-0241 — Status workflow** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Draft, confirmed, preparing, ready, dispatched, delivered, cancelled and returned.
- **BNX-0242 — Partial fulfilment** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Invoice/deliver available quantity and retain balance.
- **BNX-0243 — Advance allocation** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Apply customer advance to one or more order invoices.
#### Delivery
- **BNX-0244 — Zones and charges** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Configure serviceability, charge and free-delivery threshold.
- **BNX-0245 — Delivery assignment** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Assign person/vehicle and route sequence.
- **BNX-0246 — Proof of delivery** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Capture OTP/signature/photo/status according to merchant policy.
- **BNX-0247 — COD settlement** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Reconcile cash collected by delivery staff.
- **BNX-0248 — Failed delivery** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Record reason, next action and stock/payment reversal.
#### Channel
- **BNX-0249 — Phone/WhatsApp order source** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Enter external orders into one queue and retain source.
- **BNX-0250 — Online catalogue link** `[Priority: Could | Phase: P3 | Complexity: XL]`  
  Publish selected items/prices for order enquiry.
- **BNX-0251 — Marketplace order import** `[Priority: Could | Phase: P3 | Complexity: XL]`  
  Import supported external orders and map products/status.
#### Quotation
- **BNX-0252 — Approval/conversion tracking** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Track sent, accepted, expired and converted quote.
#### Backorder
- **BNX-0253 — Backorder tracking** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Retain demand and notify when stock arrives.
#### Subscription
- **BNX-0254 — Recurring order/invoice** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Schedule repeat order or service with pause/confirmation.
#### Packing
- **BNX-0255 — Pick list** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Generate location-wise picking list.
- **BNX-0256 — Packing checklist** `[Priority: Could | Phase: P3 | Complexity: M]`  
  Confirm items, packages, weight and dispatch note.
#### Returns
- **BNX-0257 — Delivery return** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Reverse rejected/undelivered order stock/payment status.

**Module acceptance gates**
- Order, reservation, invoice, delivery and payment states remain consistent through partial fulfilment and failure.
- COD collection is reconciled to a named user.
- Proof data is collected only under merchant policy and consent.

### 10.11 Users, Roles & Multi-Store
#### Users
- **BNX-0258 — Named user account** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Use unique accounts; no shared default admin.
- **BNX-0259 — Cashier PIN** `[Priority: Should | Phase: MVP | Complexity: M]`  
  Fast PIN login tied to user/device/session.
#### Roles
- **BNX-0260 — Role templates** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Owner, manager, cashier, accountant, stock, purchase, delivery and support.
- **BNX-0261 — Granular permission** `[Priority: Should | Phase: P1 | Complexity: L]`  
  View/create/edit/cancel/approve/export by module and scope.
- **BNX-0262 — Amount-based approval** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Require approval above discount/refund/expense/purchase limit.
#### Scope
- **BNX-0263 — Branch access** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Restrict user to branches, warehouses and counters.
- **BNX-0264 — Own-shift visibility** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Cashier sees only own shift where configured.
#### Sessions
- **BNX-0265 — Device registration** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Track trusted device, app version, last access and sync.
- **BNX-0266 — Remote logout** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Revoke user/device session.
- **BNX-0267 — Automatic lock** `[Priority: Should | Phase: P1 | Complexity: S]`  
  Lock after inactivity.
#### Audit
- **BNX-0268 — Immutable audit log** `[Priority: Must | Phase: P1 | Complexity: L]`  
  Record login, configuration, price, tax, cancel, refund, export and permission changes.
- **BNX-0269 — Audit search/export** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Filter by date, user, action, entity and device.
#### Multi-store
- **BNX-0270 — Central catalogue** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Control shared product data with branch overrides.
- **BNX-0271 — Consolidated dashboard** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Company and branch comparison with drill-down.
- **BNX-0272 — Inter-branch transfer** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Request, dispatch, transit and receive workflow.
- **BNX-0273 — Branch replenishment** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Suggest transfer from surplus before purchase.
#### Counter
- **BNX-0274 — Counter/register master** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Map counter, printer, cash drawer, invoice series and shift.
- **BNX-0275 — Shift handover** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Close one cashier and hand over float/status.
#### Owner
- **BNX-0276 — Owner mobile dashboard** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Concise sales, cash, credit, stock and exceptions.
- **BNX-0277 — Sensitive-data masking** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Mask cost, margin, contact and bank data by role.

**Module acceptance gates**
- Denied permissions are enforced in UI, API, exports and offline actions.
- All critical actions are attributable to a named user/device.
- Branch data is isolated according to scope.

### 10.12 Reports & Dashboards
#### Sales
- **BNX-0278 — Daily sales summary** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Gross sales, returns, net, tax, discount, charge and bill count.
- **BNX-0279 — Hourly sales** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Bills, revenue and average bill by hour/day.
- **BNX-0280 — Item sales** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Quantity, value, discount, tax and margin by item.
- **BNX-0281 — Category/brand sales** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Aggregate by category, subcategory and brand.
- **BNX-0282 — Cashier sales** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Bills, revenue, discounts, returns and voids by cashier.
- **BNX-0283 — Customer sales** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Revenue, visits, average bill, returns and dues by customer.
- **BNX-0284 — Branch comparison** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Revenue, bills, average bill, margin and growth by branch.
- **BNX-0285 — Trend comparison** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Daily/weekly/monthly trend and prior-period comparison.
- **BNX-0286 — Average bill/items per bill** `[Priority: Should | Phase: P1 | Complexity: S]`  
  Basket value and item count per transaction.
- **BNX-0287 — Discount analysis** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Discount by item, user, reason, customer and approval.
- **BNX-0288 — Return/cancellation analysis** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Rate, reason, user, product and refund mode.
#### Inventory
- **BNX-0289 — Stock summary** `[Priority: Must | Phase: P1 | Complexity: M]`  
  On-hand, available, reserved, damaged and value.
- **BNX-0290 — Low/out-of-stock** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Items below minimum or zero with action.
- **BNX-0291 — Fast/slow/non-moving** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Classification by configurable period/threshold.
- **BNX-0292 — Stock ageing** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Age inventory by receipt date/batch.
- **BNX-0293 — Expiry report** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Expired/near-expiry quantity and value by batch/supplier.
- **BNX-0294 — Stock valuation** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Quantity/value under configured method.
- **BNX-0295 — Negative stock** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Transactions causing negative stock.
#### Purchase
- **BNX-0296 — Purchase summary** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Purchase, return, tax and charge by supplier/category.
- **BNX-0297 — Rate variance** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Current rate vs last/average/best.
- **BNX-0298 — Supplier performance** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Delivery, fill rate, rate variance and returns.
#### Finance
- **BNX-0299 — Payment-mode report** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Cash, UPI, card, bank, credit, refund and variance.
- **BNX-0300 — Receivables ageing** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Customer dues, due date, limit and last payment.
- **BNX-0301 — Payables ageing** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Supplier dues by age/due date.
- **BNX-0302 — Expense analysis** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Expense by category, vendor, branch and mode.
- **BNX-0303 — Gross profit** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Estimate by period, item, category, customer and branch.
- **BNX-0304 — Cash closing** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Expected vs counted cash with reason/approval.
#### Tax
- **BNX-0305 — GST sales summary** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Taxable, exempt, nil, non-GST and tax by rate/document.
- **BNX-0306 — HSN/SAC summary** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Quantity, taxable value and tax by classification.
#### Operations
- **BNX-0307 — Open orders** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Backlog, promised date, reservation and delay.
- **BNX-0308 — Support usage** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Tickets, visits, catalogue requests and resolution time.
#### Owner
- **BNX-0309 — Daily WhatsApp summary** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Send concise owner report through approved workflow.
- **BNX-0310 — Exception dashboard** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Unusual discount, cancel, cash variance, negative stock, overdue and sync failures.
#### Export
- **BNX-0311 — Excel/PDF export** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Export filtered report with filters, date and user.
#### Scheduling
- **BNX-0312 — Scheduled delivery** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Send selected reports to authorised recipients.

**Module acceptance gates**
- Every report shows filters, period, branch context and generation time.
- Summary figures drill down to source transactions.
- Exports respect role and data-scope permissions.

### 10.13 Hardware & Integrations
#### Printing
- **BNX-0313 — 58mm Bluetooth printer** `[Priority: Must | Phase: MVP | Complexity: L]`  
  Pair approved model, test and reconnect reliably.
- **BNX-0314 — 58mm USB/OTG printer** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Support approved USB/OTG profiles.
- **BNX-0315 — 80mm printer** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Support wider layout and auto-cutter.
- **BNX-0316 — Printer profile abstraction** `[Priority: Must | Phase: MVP | Complexity: L]`  
  Model-specific command, line width, code page, logo, QR and cut settings.
- **BNX-0317 — Print queue/retry** `[Priority: Must | Phase: MVP | Complexity: L]`  
  Queue jobs, show failure reason and retry without duplicate sale.
- **BNX-0318 — Printer health test** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Test text, logo, QR, barcode, cut and connectivity.
- **BNX-0319 — Kitchen routing** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Route KOT items by category to kitchen/bar printer.
#### Barcode
- **BNX-0320 — USB/Bluetooth scanner** `[Priority: Should | Phase: MVP | Complexity: M]`  
  Support keyboard-mode scanner prefixes/suffixes.
- **BNX-0321 — 2D/QR scanner** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Read QR/2D codes for product, serial, customer or asset.
#### Weighing
- **BNX-0322 — Scale integration** `[Priority: Could | Phase: P2 | Complexity: XL]`  
  Read stable weight and optional PLU from approved scale.
#### Cash Drawer
- **BNX-0323 — Drawer trigger** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Open approved drawer through printer command.
#### Display
- **BNX-0324 — Customer display** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Show item, quantity, price, discount and total.
#### Labels
- **BNX-0325 — Label printer** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Support barcode, shelf, batch, garment, job and asset labels.
#### Documents
- **BNX-0326 — A4 printer** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Print PDF to installed/network printer.
#### Payments
- **BNX-0327 — Payment gateway** `[Priority: Could | Phase: P3 | Complexity: XL]`  
  Secure tokenised integration for dynamic UPI/payment status.
#### Accounting
- **BNX-0328 — Accounting integration** `[Priority: Could | Phase: P3 | Complexity: XL]`  
  Map and sync/export with supported accounting system.
#### Messaging
- **BNX-0329 — WhatsApp provider** `[Priority: Could | Phase: P3 | Complexity: XL]`  
  Approved business messaging templates and delivery status.
- **BNX-0330 — SMS provider** `[Priority: Could | Phase: P3 | Complexity: L]`  
  OTP, invoice link, due and status messages.
#### E-commerce
- **BNX-0331 — Online store connector** `[Priority: Could | Phase: P3 | Complexity: XL]`  
  Sync selected products, prices, stock and orders.
#### Marketplace
- **BNX-0332 — Marketplace connector** `[Priority: Could | Phase: P3 | Complexity: XL]`  
  Import orders and update fulfilment.
#### API
- **BNX-0333 — Public API** `[Priority: Could | Phase: P3 | Complexity: XL]`  
  Scoped APIs for products, customers, sales, stock and reports.
- **BNX-0334 — Signed webhooks** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Publish retryable sale, payment, stock and order events.
#### Import
- **BNX-0335 — Saved CSV mapping** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Reusable import mapping and validation.
#### Export
- **BNX-0336 — Scheduled secure export** `[Priority: Could | Phase: P3 | Complexity: L]`  
  Encrypted scheduled export to authorised destination.
#### Support
- **BNX-0337 — Remote diagnostics** `[Priority: Must | Phase: P1 | Complexity: L]`  
  Collect app/device/printer/sync/error details with consent.
- **BNX-0338 — Remote-session handoff** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Consent-based handoff to approved remote support tool.

**Module acceptance gates**
- Only certified hardware is shown as supported.
- Integration failures are retryable and visible.
- Credentials are never exposed in logs or client code.

### 10.14 Offline, Cloud, Security & Privacy
#### Offline
- **BNX-0339 — Offline-first transaction store** `[Priority: Must | Phase: MVP | Complexity: XL]`  
  Bill and access essential catalogue/customer data without internet.
- **BNX-0340 — Background sync queue** `[Priority: Must | Phase: MVP | Complexity: XL]`  
  Queue local writes with retry and idempotency.
- **BNX-0341 — Conflict resolution** `[Priority: Should | Phase: P1 | Complexity: XL]`  
  Handle edit, stock, serial and invoice-number collisions.
- **BNX-0342 — Offline numbering** `[Priority: Must | Phase: MVP | Complexity: XL]`  
  Allocate collision-safe invoice sequence/block.
#### Backup
- **BNX-0343 — Automatic cloud backup** `[Priority: Must | Phase: MVP | Complexity: L]`  
  Back up when online and show last success.
- **BNX-0344 — Point-in-time restore** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Restore verified backup under controlled workflow.
- **BNX-0345 — Restore integrity test** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Periodically test backup usability.
#### Security
- **BNX-0346 — Encryption in transit** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Use modern TLS and reject insecure endpoints.
- **BNX-0347 — Encryption at rest** `[Priority: Must | Phase: P1 | Complexity: L]`  
  Encrypt sensitive local/cloud data with secure key handling.
- **BNX-0348 — Password/PIN protection** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Rate-limit attempts and protect owner/admin access.
- **BNX-0349 — Multi-factor authentication** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Offer MFA for owner/admin web access.
- **BNX-0350 — Secure credential storage** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Never store API secrets in plain text or logs.
- **BNX-0351 — Role-based data access** `[Priority: Must | Phase: P1 | Complexity: L]`  
  Apply least privilege to customer, cost, margin and export.
- **BNX-0352 — Security event log** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Log suspicious login, export, permission and device events.
- **BNX-0353 — Patch/update process** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Dependency scanning, patch release, rollback and supported-version policy.
#### Privacy
- **BNX-0354 — Data minimisation** `[Priority: Must | Phase: P1 | Complexity: M]`  
  Collect customer data only for billing, credit, warranty or consented communication.
- **BNX-0355 — Consent/notice record** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Retain purpose, channel, status, timestamp and withdrawal.
- **BNX-0356 — Merchant data export** `[Priority: Should | Phase: P2 | Complexity: M]`  
  Allow controlled export of merchant-owned data.
- **BNX-0357 — Retention/deletion policy** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Configure retention subject to legal/accounting requirements.
- **BNX-0358 — Incident response** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Classify, contain, document and communicate data incidents.
- **BNX-0359 — Support access consent** `[Priority: Must | Phase: P1 | Complexity: L]`  
  Time-bound approved support access with audit and auto-revoke.
#### Availability
- **BNX-0360 — Service monitoring** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Monitor API, sync, messaging and backup components.
- **BNX-0361 — Graceful degradation** `[Priority: Must | Phase: MVP | Complexity: L]`  
  Keep billing active if cloud/messaging/analytics fails.
- **BNX-0362 — Incident/status view** `[Priority: Could | Phase: P2 | Complexity: M]`  
  Show known incident and workaround to support/merchant.
#### Data Quality
- **BNX-0363 — Central validation** `[Priority: Must | Phase: MVP | Complexity: L]`  
  Consistent required fields, decimals, tax and state transitions.
- **BNX-0364 — Duplicate transaction protection** `[Priority: Must | Phase: MVP | Complexity: L]`  
  Use idempotency and unique constraints.
- **BNX-0365 — Controlled repair tool** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Audited before/after correction workflow.

**Module acceptance gates**
- Core billing remains usable without connectivity.
- Every sync write is idempotent.
- Support access is time-bound, consented and audited.

### 10.15 Onboarding & Support Operations
#### Onboarding
- **BNX-0366 — Guided setup wizard** `[Priority: Must | Phase: MVP | Complexity: L]`  
  Business, tax, printer, invoice, catalogue and users with completion checklist.
- **BNX-0367 — Installation checklist** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Printer test, sample bill, backup, training and merchant sign-off.
- **BNX-0368 — Initial catalogue loading** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Import agreed scope and obtain merchant approval before go-live.
- **BNX-0369 — Training videos/demo** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Role-based short tutorials and practice company.
#### Help
- **BNX-0370 — In-app help centre** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Searchable articles and printer troubleshooting by app version.
- **BNX-0371 — WhatsApp support handoff** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Open support chat with merchant/device ID but no sensitive data.
#### Tickets
- **BNX-0372 — Support ticket** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Category, priority, status, consent, owner and SLA.
- **BNX-0373 — Ticket history** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Open, waiting, resolved, reopened and closure notes.
#### Remote
- **BNX-0374 — Diagnostic package** `[Priority: Must | Phase: P1 | Complexity: L]`  
  Collect approved logs/settings snapshot after consent.
#### Field Support
- **BNX-0375 — Serviceable-area validation** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Check pin code/distance before promising visit.
- **BNX-0376 — Visit scheduling** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Technician, slot, issue, chargeability and proof.
- **BNX-0377 — Additional visit billing** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Apply plan allowance and charge outside inclusion.
#### Catalogue Service
- **BNX-0378 — Monthly quota** `[Priority: Must | Phase: MVP | Complexity: M]`  
  One request/subscription month with item limit and carry-forward policy.
- **BNX-0379 — Structured request template** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Require item, unit, price, tax, barcode and effective date.
- **BNX-0380 — Approval/audit** `[Priority: Should | Phase: P1 | Complexity: M]`  
  Merchant approves support-entered changes before activation.
#### Entitlement
- **BNX-0381 — Plan engine** `[Priority: Must | Phase: MVP | Complexity: XL]`  
  Control printer, cloud, users, branches, catalogue quota, support and add-ons.
- **BNX-0382 — Renewal/grace** `[Priority: Should | Phase: P1 | Complexity: L]`  
  Notify expiry, grace period and read-only/export after suspension.
- **BNX-0383 — Printer eligibility** `[Priority: Must | Phase: MVP | Complexity: M]`  
  Annual advance + approved model + delivery acknowledgement.
#### Metrics
- **BNX-0384 — Support-cost dashboard** `[Priority: Should | Phase: P2 | Complexity: L]`  
  Tickets, minutes, visits, items and replacements by merchant.
- **BNX-0385 — Recurring issue detection** `[Priority: Could | Phase: P2 | Complexity: L]`  
  Group repeated errors into product fixes/knowledge base.

**Module acceptance gates**
- Every commercial promise maps to an entitlement, quota or charge.
- Installation has a signed checklist.
- Support metrics can show cost and recurring issues by merchant.

## 11. Business-Specific Vertical Packs
Vertical packs must be implemented as feature-flagged workflows, fields, templates, reports and entitlements on the same core platform. A vertical pack must not copy or independently reimplement shared billing, payment, stock or security logic.

### 11.1 Kirana / General Store — Kirana Pack
**Edition:** Retail Standard  
**Typical hardware:** 58mm printer; scanner; optional scale  
**Operational context:** Fast counter B2C; credit sales; High SKU; loose + packaged

- **VTX-0001 — Loose quantity billing** `[Priority: Must | Phase: P1]`  
  Sell loose rice, pulses, oil and similar products using decimal kg/gram/litre quantities.
- **VTX-0002 — Pack/piece conversion** `[Priority: Must | Phase: P1]`  
  Buy cartons or packs and sell individual pieces with automatic conversion and cost.
- **VTX-0003 — Quick PLU favourites** `[Priority: Must | Phase: P1]`  
  One-touch buttons and numeric PLU for frequent unbarcoded items.
- **VTX-0004 — Customer khata** `[Priority: Should | Phase: P2]`  
  Fast credit sale, receipt, running balance and shareable statement.
- **VTX-0005 — Daily local purchase** `[Priority: Should | Phase: P2]`  
  Simplified cash/credit purchase and stock receipt from local suppliers.
- **VTX-0006 — Preloaded common catalogue** `[Priority: Should | Phase: P2]`  
  Optional standard grocery catalogue for merchant approval and editing.
- **VTX-0007 — Home delivery order** `[Priority: Could | Phase: P3]`  
  Capture local order, address, charge, COD and delivery status.
- **VTX-0008 — Kirana stock insights** `[Priority: Could | Phase: P3]`  
  Fast/slow staples, reorder list and expiry alerts for packaged items.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.2 Supermarket / Mini-Mart — Supermarket Pack
**Edition:** Retail Pro  
**Typical hardware:** 80mm printer; scanner; drawer; display; scale  
**Operational context:** High-volume barcode POS; Very high SKU; multiple counters

- **VTX-0009 — Multi-counter POS** `[Priority: Must | Phase: P1]`  
  Multiple cashiers/counters with central catalogue, stock and independent shifts.
- **VTX-0010 — Promotion engine** `[Priority: Must | Phase: P1]`  
  Combo, buy-X-get-Y, coupon, member price and time-bound promotion rules.
- **VTX-0011 — Price-check mode** `[Priority: Must | Phase: P1]`  
  Scan an item to show active price without adding it to cart.
- **VTX-0012 — Shelf-price control** `[Priority: Should | Phase: P2]`  
  Generate shelf labels and identify mismatch with active POS price.
- **VTX-0013 — Supervisor override** `[Priority: Should | Phase: P2]`  
  Manager PIN for discount, return, cancellation and price exceptions.
- **VTX-0014 — Aisle cycle counting** `[Priority: Should | Phase: P2]`  
  Count by aisle/category without closing the full store.
- **VTX-0015 — Goods receiving scan** `[Priority: Could | Phase: P3]`  
  Receive PO by scan with quantity and discrepancy handling.
- **VTX-0016 — Shrinkage dashboard** `[Priority: Could | Phase: P3]`  
  Analyse stock adjustments, voids, returns and cashier exceptions.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.3 Pharmacy / Medical Shop — Pharmacy Pack
**Edition:** Vertical Pro  
**Typical hardware:** 58/80mm printer; scanner; label printer  
**Operational context:** OTC/prescription-linked retail; Batch, expiry, MRP, rack

- **VTX-0017 — Medicine master** `[Priority: Must | Phase: P1]`  
  Store brand/generic name, manufacturer, strength, dosage form, pack and rack.
- **VTX-0018 — Batch and expiry** `[Priority: Must | Phase: P1]`  
  Select and track batch, expiry, purchase rate, MRP and closing quantity.
- **VTX-0019 — Near-expiry action list** `[Priority: Must | Phase: P1]`  
  Create supplier-return, transfer or markdown list by expiry window.
- **VTX-0020 — Prescription attachment** `[Priority: Should | Phase: P2]`  
  Attach prescription reference/image where merchant policy requires, with restricted access.
- **VTX-0021 — Generic/substitute search** `[Priority: Should | Phase: P2]`  
  Show merchant-configured generic or substitute mapping; never provide autonomous medical advice.
- **VTX-0022 — Purchase scheme** `[Priority: Should | Phase: P2]`  
  Capture free strips/units, scheme discount and effective cost.
- **VTX-0023 — Controlled medicine returns** `[Priority: Could | Phase: P3]`  
  Require original bill, batch and manager approval based on policy.
- **VTX-0024 — Regulatory traceability export** `[Priority: Could | Phase: P3]`  
  Export batch-wise purchase, sale and stock history for review.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.4 Restaurant / QSR — Restaurant Pack
**Edition:** Vertical Pro  
**Typical hardware:** 80mm POS + kitchen printer  
**Operational context:** Table/KOT/takeaway/delivery; Ingredients + menu recipes

- **VTX-0025 — Table and floor plan** `[Priority: Must | Phase: P1]`  
  Create tables, sections, seating and live order status.
- **VTX-0026 — KOT workflow** `[Priority: Must | Phase: P1]`  
  Send item and cooking/modifier notes to kitchen without price where configured.
- **VTX-0027 — Kitchen routing** `[Priority: Must | Phase: P1]`  
  Route food, beverage and dessert items to separate printers.
- **VTX-0028 — Menu modifiers** `[Priority: Should | Phase: P2]`  
  Size, spice, topping, cooking notes and paid add-ons.
- **VTX-0029 — Split/merge bill** `[Priority: Should | Phase: P2]`  
  Split by item, guest or amount and merge tables under approval.
- **VTX-0030 — Recipe consumption** `[Priority: Should | Phase: P2]`  
  Deduct configured ingredient quantities from menu-item sales.
- **VTX-0031 — Channel workflow** `[Priority: Could | Phase: P3]`  
  Separate dine-in, takeaway and delivery charges/status.
- **VTX-0032 — Void and wastage control** `[Priority: Could | Phase: P3]`  
  Record complimentary, cancelled and wasted items with reason.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.5 Cafe / Bakery / Sweet Shop — Bakery Pack
**Edition:** Vertical Standard  
**Typical hardware:** 58/80mm printer; scale; label printer  
**Operational context:** Counter/token/weighted billing; Production batches; shelf life

- **VTX-0033 — Weight and piece billing** `[Priority: Must | Phase: P1]`  
  Sell sweets, cakes and bakery goods by weight or piece.
- **VTX-0034 — Daily production batch** `[Priority: Must | Phase: P1]`  
  Record produced quantity, batch time, shelf life and location.
- **VTX-0035 — Freshness alert** `[Priority: Must | Phase: P1]`  
  Warn for products nearing configured shelf life.
- **VTX-0036 — Custom cake order** `[Priority: Should | Phase: P2]`  
  Capture flavour, weight, message, design note, date and advance.
- **VTX-0037 — Assorted box builder** `[Priority: Should | Phase: P2]`  
  Build mixed sweet/gift boxes by selected items and weight/value.
- **VTX-0038 — Recipe costing** `[Priority: Should | Phase: P2]`  
  Estimate ingredient cost and gross margin per product.
- **VTX-0039 — Packed-on/use-by label** `[Priority: Could | Phase: P3]`  
  Print approved batch, weight and shelf-life label.
- **VTX-0040 — Wastage register** `[Priority: Could | Phase: P3]`  
  Record unsold, damaged and production waste by reason/value.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.6 Hardware / Electrical / Plumbing — Hardware Pack
**Edition:** Retail Pro  
**Typical hardware:** 58/80mm printer; scanner  
**Operational context:** Counter + quotation + contractor credit; Brand/size/length variants

- **VTX-0041 — Technical variants** `[Priority: Must | Phase: P1]`  
  Search brand, size, diameter, gauge, wattage, colour, model and grade.
- **VTX-0042 — Cut-length billing** `[Priority: Must | Phase: P1]`  
  Sell cable, wire, pipe, chain or sheet by metre/foot and track remainder.
- **VTX-0043 — Alternative units** `[Priority: Must | Phase: P1]`  
  Buy box/roll and sell piece/metre with conversion.
- **VTX-0044 — Contractor price and credit** `[Priority: Should | Phase: P2]`  
  Apply dealer/contractor rates, credit limit and due rules.
- **VTX-0045 — Quotation/project list** `[Priority: Should | Phase: P2]`  
  Prepare itemised quotation and convert accepted lines to invoice.
- **VTX-0046 — Equivalent alternatives** `[Priority: Should | Phase: P2]`  
  Show merchant-configured substitute items when stock is unavailable.
- **VTX-0047 — Quantity slab price** `[Priority: Could | Phase: P3]`  
  Apply quantity-based rate tiers.
- **VTX-0048 — Special-order tracking** `[Priority: Could | Phase: P3]`  
  Track customer-specific ordered material and advance.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.7 Apparel / Footwear / Boutique — Fashion Pack
**Edition:** Vertical Standard  
**Typical hardware:** Printer; scanner; tag printer  
**Operational context:** Variant retail + exchanges; Style-colour-size matrix

- **VTX-0049 — Style-colour-size matrix** `[Priority: Must | Phase: P1]`  
  View and manage stock by parent style and variants.
- **VTX-0050 — Barcode tag printing** `[Priority: Must | Phase: P1]`  
  Print SKU, size, colour, price and barcode garment tags.
- **VTX-0051 — Exchange policy workflow** `[Priority: Must | Phase: P1]`  
  Apply exchange days, condition, reason and price difference.
- **VTX-0052 — Season/collection tagging** `[Priority: Should | Phase: P2]`  
  Classify inventory by season, collection and launch.
- **VTX-0053 — Alteration order** `[Priority: Should | Phase: P2]`  
  Capture measurements, alterations, due date and charges.
- **VTX-0054 — Trial/reservation** `[Priority: Should | Phase: P2]`  
  Reserve selected item until configured time.
- **VTX-0055 — Markdown schedule** `[Priority: Could | Phase: P3]`  
  Plan clearance price by ageing/season.
- **VTX-0056 — Salesperson incentive** `[Priority: Could | Phase: P3]`  
  Calculate commission by category, revenue or margin.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.8 Jewellery Store — Jewellery Pack
**Edition:** Vertical Enterprise  
**Typical hardware:** 80mm; tag printer; precision scale  
**Operational context:** Weight/rate/making-charge billing; Unique tags; purity; stones

- **VTX-0057 — Metal rate board** `[Priority: Must | Phase: P1]`  
  Maintain effective-dated gold, silver and platinum rates by purity.
- **VTX-0058 — Tag-level inventory** `[Priority: Must | Phase: P1]`  
  Track each ornament using unique tag, status and location.
- **VTX-0059 — Weight breakup** `[Priority: Must | Phase: P1]`  
  Gross weight, stone weight, net metal weight and unit.
- **VTX-0060 — Purity/hallmark fields** `[Priority: Should | Phase: P2]`  
  Capture purity, hallmark and certificate identifiers.
- **VTX-0061 — Making-charge formula** `[Priority: Should | Phase: P2]`  
  Percentage, per-gram or fixed making charge with wastage.
- **VTX-0062 — Stone valuation** `[Priority: Should | Phase: P2]`  
  Record stone count, weight, rate and amount separately.
- **VTX-0063 — Old-gold exchange** `[Priority: Could | Phase: P3]`  
  Record tested weight/purity/value and settlement under merchant policy.
- **VTX-0064 — Approval memo** `[Priority: Could | Phase: P3]`  
  Issue tagged goods on approval with due date and return/convert status.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.9 Mobile / Electronics Store — Electronics Pack
**Edition:** Vertical Pro  
**Typical hardware:** 80mm; scanner; label printer  
**Operational context:** Device + accessories + warranty; Serial/IMEI/model/colour

- **VTX-0065 — IMEI/serial control** `[Priority: Must | Phase: P1]`  
  Require unique serial at receiving, sale, return and service.
- **VTX-0066 — Device variants** `[Priority: Must | Phase: P1]`  
  Manage model, colour, capacity and condition variants.
- **VTX-0067 — Warranty record** `[Priority: Must | Phase: P1]`  
  Link serial, invoice, warranty period and service history.
- **VTX-0068 — Accessory bundle** `[Priority: Should | Phase: P2]`  
  Bundle device, accessories, insurance or service.
- **VTX-0069 — Device exchange** `[Priority: Should | Phase: P2]`  
  Record old device serial, condition, valuation and adjustment.
- **VTX-0070 — Finance/EMI reference** `[Priority: Should | Phase: P2]`  
  Capture lender/reference and down payment without storing prohibited credentials.
- **VTX-0071 — Demo/open-box stock** `[Priority: Could | Phase: P3]`  
  Separate sealed, display, open-box and damaged stock.
- **VTX-0072 — Serial return validation** `[Priority: Could | Phase: P3]`  
  Accept return only for matching serial under policy.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.10 Stationery / Book / Gift Store — Stationery Pack
**Edition:** Retail Standard  
**Typical hardware:** 58mm; scanner; label printer  
**Operational context:** Counter retail + seasonal bundles; Many low-value SKUs

- **VTX-0073 — ISBN and edition** `[Priority: Must | Phase: P1]`  
  Store ISBN, author, publisher, edition and subject.
- **VTX-0074 — School-list bundle** `[Priority: Must | Phase: P1]`  
  Build school/grade product list and convert to one bill.
- **VTX-0075 — Gift wrapping** `[Priority: Must | Phase: P1]`  
  Add wrapping charge, message and package count.
- **VTX-0076 — Seasonal inventory** `[Priority: Should | Phase: P2]`  
  Tag back-to-school, festival and event stock.
- **VTX-0077 — Fast category keys** `[Priority: Should | Phase: P2]`  
  One-touch buttons for common low-value items.
- **VTX-0078 — Set/ream conversion** `[Priority: Should | Phase: P2]`  
  Buy box/ream and sell unit.
- **VTX-0079 — Book pre-order** `[Priority: Could | Phase: P3]`  
  Record unavailable title and notify on receipt.
- **VTX-0080 — Institution quotation** `[Priority: Could | Phase: P3]`  
  Prepare bulk office/school quotation and price list.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.11 Salon / Spa / Beauty — Salon Pack
**Edition:** Vertical Standard  
**Typical hardware:** 58mm printer; tablet  
**Operational context:** Appointments + service billing; Services + consumables + retail

- **VTX-0081 — Appointment calendar** `[Priority: Must | Phase: P1]`  
  Book service, staff, chair/room and duration.
- **VTX-0082 — Service package** `[Priority: Must | Phase: P1]`  
  Sell multi-session package and deduct use.
- **VTX-0083 — Membership** `[Priority: Must | Phase: P1]`  
  Apply member rates, benefits and validity.
- **VTX-0084 — Staff commission** `[Priority: Should | Phase: P2]`  
  Calculate commission by service/product/staff level.
- **VTX-0085 — Consumable deduction** `[Priority: Should | Phase: P2]`  
  Consume configured product quantity per service.
- **VTX-0086 — No-show/cancellation** `[Priority: Should | Phase: P2]`  
  Track appointment status, deposit and cancellation policy.
- **VTX-0087 — Resource scheduling** `[Priority: Could | Phase: P3]`  
  Prevent double-booking of staff, chair or room.
- **VTX-0088 — Rebooking reminder** `[Priority: Could | Phase: P3]`  
  Create consented reminder based on service cycle.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.12 Repair / Service Centre — Service Centre Pack
**Edition:** Vertical Standard  
**Typical hardware:** 58/80mm; label printer  
**Operational context:** Job card + estimate + labour/parts; Spares + customer devices

- **VTX-0089 — Job-card intake** `[Priority: Must | Phase: P1]`  
  Capture device/item, serial, accessories, visible condition and complaint.
- **VTX-0090 — Estimate approval** `[Priority: Must | Phase: P1]`  
  Prepare parts/labour estimate and record customer approval.
- **VTX-0091 — Repair status** `[Priority: Must | Phase: P1]`  
  Received, diagnosis, awaiting approval, repair, test, ready and delivered.
- **VTX-0092 — Technician assignment** `[Priority: Should | Phase: P2]`  
  Assign technician and record work/time.
- **VTX-0093 — Parts consumption** `[Priority: Should | Phase: P2]`  
  Issue spare parts to job and return unused items.
- **VTX-0094 — Device/job label** `[Priority: Should | Phase: P2]`  
  Print QR/barcode tag for device and accessories.
- **VTX-0095 — Repair warranty** `[Priority: Could | Phase: P3]`  
  Set warranty period and link repeat job.
- **VTX-0096 — Unclaimed jobs** `[Priority: Could | Phase: P3]`  
  Age completed but undelivered items and send consented reminders.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.13 Wholesale / Distribution — Wholesale Pack
**Edition:** Business Pro  
**Typical hardware:** 80mm/A4; scanner; mobile printer  
**Operational context:** B2B, route sales, credit; Cases/pieces; warehouse/van

- **VTX-0097 — Customer price levels** `[Priority: Must | Phase: P1]`  
  Dealer, distributor, retail and contract pricing.
- **VTX-0098 — Case-inner-piece hierarchy** `[Priority: Must | Phase: P1]`  
  Buy, sell and report across packaging levels.
- **VTX-0099 — Salesman route** `[Priority: Must | Phase: P1]`  
  Assign customers to route, day and salesperson.
- **VTX-0100 — Offline order booking** `[Priority: Should | Phase: P2]`  
  Capture field orders offline and sync.
- **VTX-0101 — Credit-limit block** `[Priority: Should | Phase: P2]`  
  Control orders and invoices by due/limit.
- **VTX-0102 — Trade schemes** `[Priority: Should | Phase: P2]`  
  Slab, free quantity, target rebate and promotional schemes.
- **VTX-0103 — Loading sheet** `[Priority: Could | Phase: P3]`  
  Generate route/vehicle-wise loading and shortage list.
- **VTX-0104 — Field collection settlement** `[Priority: Could | Phase: P3]`  
  Record salesperson collection and reconcile return to office.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.14 Auto Parts / Garage — Auto Service Pack
**Edition:** Vertical Pro  
**Typical hardware:** 80mm; scanner  
**Operational context:** Part sale + vehicle service; Part compatibility + job parts

- **VTX-0105 — Vehicle master** `[Priority: Must | Phase: P1]`  
  Store registration, make, model, variant, year and owner.
- **VTX-0106 — Part compatibility** `[Priority: Must | Phase: P1]`  
  Map part number to vehicle/engine variants.
- **VTX-0107 — Garage job card** `[Priority: Must | Phase: P1]`  
  Capture complaint, inspection, labour and technician.
- **VTX-0108 — Service estimate** `[Priority: Should | Phase: P2]`  
  Quote parts, labour and approval.
- **VTX-0109 — Labour packages** `[Priority: Should | Phase: P2]`  
  Create standard service labour bundles.
- **VTX-0110 — Service history** `[Priority: Should | Phase: P2]`  
  View previous jobs, parts, odometer and recommendations.
- **VTX-0111 — Warranty claim** `[Priority: Could | Phase: P3]`  
  Track part/service warranty and resolution.
- **VTX-0112 — Next-service reminder** `[Priority: Could | Phase: P3]`  
  Send consented reminder by date/estimated usage.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.15 Optical Store — Optical Pack
**Edition:** Vertical Standard  
**Typical hardware:** 58/80mm; scanner  
**Operational context:** Prescription + frame/lens order; Frames + lens specs

- **VTX-0113 — Prescription capture** `[Priority: Must | Phase: P1]`  
  Sphere, cylinder, axis, add and PD with restricted access.
- **VTX-0114 — Frame/lens order** `[Priority: Must | Phase: P1]`  
  Combine frame, lens spec, coating and fitting service.
- **VTX-0115 — Lab order status** `[Priority: Must | Phase: P1]`  
  Ordered, sent to lab, received, fitting, ready and delivered.
- **VTX-0116 — Advance/balance** `[Priority: Should | Phase: P2]`  
  Collect deposit and final settlement.
- **VTX-0117 — Frame reservation** `[Priority: Should | Phase: P2]`  
  Reserve chosen frame until order completes.
- **VTX-0118 — Warranty/remake** `[Priority: Should | Phase: P2]`  
  Track frame/lens warranty and remake reason.
- **VTX-0119 — Measurement history** `[Priority: Could | Phase: P3]`  
  Retain previous prescription/fitting subject to privacy policy.
- **VTX-0120 — Delivery due list** `[Priority: Could | Phase: P3]`  
  Show due and overdue optical orders.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.16 Agri Input Store — Agri Input Pack
**Edition:** Vertical Pro  
**Typical hardware:** 58/80mm; scanner  
**Operational context:** Seasonal retail + credit; Batch/expiry/crop/pack size

- **VTX-0121 — Batch/expiry control** `[Priority: Must | Phase: P1]`  
  Track seeds, fertiliser and pesticides by batch and expiry.
- **VTX-0122 — Crop/season tags** `[Priority: Must | Phase: P1]`  
  Classify products by crop, season and merchant-configured use.
- **VTX-0123 — Farmer/customer ledger** `[Priority: Must | Phase: P1]`  
  Maintain purchase history, credit and collections.
- **VTX-0124 — Season demand analysis** `[Priority: Should | Phase: P2]`  
  Compare movement across crop seasons.
- **VTX-0125 — Lot traceability** `[Priority: Should | Phase: P2]`  
  Export batch-wise purchase, sale and closing stock.
- **VTX-0126 — Pack conversion** `[Priority: Should | Phase: P2]`  
  Manage bags, bottles, packets and smaller units.
- **VTX-0127 — Licence/mandatory-note fields** `[Priority: Could | Phase: P3]`  
  Merchant-configurable regulated fields after professional review.
- **VTX-0128 — Expiry-sale block** `[Priority: Could | Phase: P3]`  
  Prevent expired batch sale and warn near expiry.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.17 Fresh Produce / Meat / Fish — Fresh Retail Pack
**Edition:** Vertical Standard  
**Typical hardware:** Scale; 58mm; label printer  
**Operational context:** Fast weight-based billing; Perishable lots + wastage

- **VTX-0129 — Scale integration** `[Priority: Must | Phase: P1]`  
  Read stable weight from approved scale.
- **VTX-0130 — PLU buttons** `[Priority: Must | Phase: P1]`  
  Assign numeric PLU and image tile to unbarcoded products.
- **VTX-0131 — Daily price board** `[Priority: Must | Phase: P1]`  
  Bulk-update current selling rates before opening.
- **VTX-0132 — Lot purchase** `[Priority: Should | Phase: P2]`  
  Record vendor, lot, weight, grade and cost.
- **VTX-0133 — Yield processing** `[Priority: Should | Phase: P2]`  
  Convert whole item/crate into cuts or grades.
- **VTX-0134 — Wastage/spoilage** `[Priority: Should | Phase: P2]`  
  Record trim, spoilage and unsold quantity.
- **VTX-0135 — Weight label** `[Priority: Could | Phase: P3]`  
  Print item, weight, rate, packed time and total.
- **VTX-0136 — Tare control** `[Priority: Could | Phase: P3]`  
  Apply container/tare settings under permission.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.18 Laundry / Dry Cleaning — Laundry Pack
**Edition:** Vertical Standard  
**Typical hardware:** 58mm; tag printer  
**Operational context:** Garment intake + status + delivery; Customer garments

- **VTX-0137 — Garment intake** `[Priority: Must | Phase: P1]`  
  Record garment, colour, stains, defects and selected service.
- **VTX-0138 — Garment tag** `[Priority: Must | Phase: P1]`  
  Print unique order and item tags.
- **VTX-0139 — Service price matrix** `[Priority: Must | Phase: P1]`  
  Price by garment and wash/iron/dry-clean/express service.
- **VTX-0140 — Due date/priority** `[Priority: Should | Phase: P2]`  
  Normal or express date with surcharge.
- **VTX-0141 — Processing status** `[Priority: Should | Phase: P2]`  
  Received, sorting, washing, ironing, packed and ready.
- **VTX-0142 — Item-level delivery** `[Priority: Should | Phase: P2]`  
  Verify all tagged garments before closure.
- **VTX-0143 — Damage/loss note** `[Priority: Could | Phase: P3]`  
  Record pre-existing and incident details.
- **VTX-0144 — Pickup/delivery route** `[Priority: Could | Phase: P3]`  
  Schedule address, slot and status.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.19 Gym / Membership Business — Membership Pack
**Edition:** Vertical Standard  
**Typical hardware:** 58mm; QR/biometric optional  
**Operational context:** Membership + recurring fees; Plans + attendance

- **VTX-0145 — Membership plans** `[Priority: Must | Phase: P1]`  
  Duration, fee, access rule and benefits.
- **VTX-0146 — Member registration** `[Priority: Must | Phase: P1]`  
  Contact, plan, consent and optional approved ID reference.
- **VTX-0147 — Instalment schedule** `[Priority: Must | Phase: P1]`  
  Due dates, receipts and outstanding.
- **VTX-0148 — Renewal reminder** `[Priority: Should | Phase: P2]`  
  Consent-based pre/post-expiry notification.
- **VTX-0149 — Attendance/access** `[Priority: Should | Phase: P2]`  
  QR, biometric or manual attendance integration.
- **VTX-0150 — Trainer assignment** `[Priority: Should | Phase: P2]`  
  Trainer, package and commission.
- **VTX-0151 — Session package** `[Priority: Could | Phase: P3]`  
  Sell/deduct PT or class sessions.
- **VTX-0152 — Freeze/extension** `[Priority: Could | Phase: P3]`  
  Pause or extend membership under policy.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.20 Rental Business — Rental Pack
**Edition:** Vertical Pro  
**Typical hardware:** 58/80mm; QR/scanner  
**Operational context:** Booking + deposit + return; Unique rentable assets

- **VTX-0153 — Asset master** `[Priority: Must | Phase: P1]`  
  Unique asset, serial, condition, location and status.
- **VTX-0154 — Availability calendar** `[Priority: Must | Phase: P1]`  
  Booked, available, out and maintenance periods.
- **VTX-0155 — Reservation** `[Priority: Must | Phase: P1]`  
  Customer, period, rate, deposit and terms.
- **VTX-0156 — Checkout checklist** `[Priority: Should | Phase: P2]`  
  Accessories, condition, meter/quantity and acknowledgement.
- **VTX-0157 — Return inspection** `[Priority: Should | Phase: P2]`  
  Time, condition, missing items and usage.
- **VTX-0158 — Late fee** `[Priority: Should | Phase: P2]`  
  Calculate policy-based late charges.
- **VTX-0159 — Damage charge** `[Priority: Could | Phase: P3]`  
  Record assessed cleaning/damage fee with evidence.
- **VTX-0160 — Security deposit** `[Priority: Could | Phase: P3]`  
  Track deposit liability and refund.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.21 Clinic / Diagnostic Centre — Clinic Billing Pack
**Edition:** Vertical Pro  
**Typical hardware:** 80mm/A4; label optional  
**Operational context:** Patient/service/package billing; Consumables + services

- **VTX-0161 — Patient registration** `[Priority: Must | Phase: P1]`  
  Unique patient profile with duplicate prevention.
- **VTX-0162 — Appointment** `[Priority: Must | Phase: P1]`  
  Book doctor/service/room and duration.
- **VTX-0163 — Service/package billing** `[Priority: Must | Phase: P1]`  
  Consultation, test, procedure, consumables and discount.
- **VTX-0164 — Advance/refund** `[Priority: Should | Phase: P2]`  
  Deposits for procedure/test and controlled refund.
- **VTX-0165 — Referral source** `[Priority: Should | Phase: P2]`  
  Track authorised source and configured rule.
- **VTX-0166 — Sample/label reference** `[Priority: Should | Phase: P2]`  
  Generate reference/label without replacing a full laboratory system.
- **VTX-0167 — Sensitive permissions** `[Priority: Could | Phase: P3]`  
  Restrict medical/prescription fields and support access.
- **VTX-0168 — Retention/export policy** `[Priority: Could | Phase: P3]`  
  Configure data retention and export after privacy/legal review.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.22 Small Manufacturing / Assembly — Manufacturing Pack
**Edition:** Business Pro  
**Typical hardware:** A4/80mm; barcode/label  
**Operational context:** Order-to-production-to-invoice; Raw/WIP/finished/BOM

- **VTX-0169 — Bill of materials** `[Priority: Must | Phase: P1]`  
  Raw-material quantities and version per finished item.
- **VTX-0170 — Production order** `[Priority: Must | Phase: P1]`  
  Quantity, date, location and responsible user.
- **VTX-0171 — Material issue** `[Priority: Must | Phase: P1]`  
  Issue raw materials and track shortage/return.
- **VTX-0172 — Finished receipt** `[Priority: Should | Phase: P2]`  
  Receive produced quantity, batch and quality status.
- **VTX-0173 — Yield/scrap** `[Priority: Should | Phase: P2]`  
  Expected versus actual yield, scrap and by-product.
- **VTX-0174 — Job costing** `[Priority: Should | Phase: P2]`  
  Material, labour and overhead estimate by job/batch.
- **VTX-0175 — Subcontract processing** `[Priority: Could | Phase: P3]`  
  Send/receive material with challan/reference.
- **VTX-0176 — Batch traceability** `[Priority: Could | Phase: P3]`  
  Trace finished item back to input batches.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.23 Home Services / Contractor — Field Service Pack
**Edition:** Vertical Standard  
**Typical hardware:** Android + mobile printer  
**Operational context:** Estimate + field job + invoice; Technician stock

- **VTX-0177 — Service request** `[Priority: Must | Phase: P1]`  
  Customer issue, address, slot and attachments.
- **VTX-0178 — Estimate** `[Priority: Must | Phase: P1]`  
  Labour, visit charge, material and validity.
- **VTX-0179 — Technician assignment** `[Priority: Must | Phase: P1]`  
  Skill/location/availability based assignment.
- **VTX-0180 — Field status** `[Priority: Should | Phase: P2]`  
  Assigned, en route, started, paused and completed.
- **VTX-0181 — Technician stock** `[Priority: Should | Phase: P2]`  
  Issue and reconcile materials carried by technician.
- **VTX-0182 — Proof of service** `[Priority: Should | Phase: P2]`  
  OTP/signature/photo under consent.
- **VTX-0183 — On-site invoice** `[Priority: Could | Phase: P3]`  
  Bill and collect from phone online/offline.
- **VTX-0184 — AMC plan** `[Priority: Could | Phase: P3]`  
  Recurring service schedule and entitlement.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

### 11.24 Tuition / Training Institute — Institute Billing Pack
**Edition:** Vertical Standard  
**Typical hardware:** 58mm/A4 printer  
**Operational context:** Course fee + instalments + receipts; Courses, batches, kits

- **VTX-0185 — Student master** `[Priority: Must | Phase: P1]`  
  Student, guardian, contact and batch linkage.
- **VTX-0186 — Course/batch fee plan** `[Priority: Must | Phase: P1]`  
  Total fee, instalments, discount and due dates.
- **VTX-0187 — Fee receipt** `[Priority: Must | Phase: P1]`  
  Numbered receipt for every payment.
- **VTX-0188 — Outstanding/ageing** `[Priority: Should | Phase: P2]`  
  Student-wise due and overdue instalments.
- **VTX-0189 — Scholarship approval** `[Priority: Should | Phase: P2]`  
  Discount/concession reason and approver.
- **VTX-0190 — Course material billing** `[Priority: Should | Phase: P2]`  
  Books, kits, exam or lab fee.
- **VTX-0191 — Batch transfer** `[Priority: Could | Phase: P3]`  
  Transfer student and adjust fee plan.
- **VTX-0192 — Withdrawal/refund** `[Priority: Could | Phase: P3]`  
  Policy-based refund and adjustment document.

**Release condition:** Validate the workflow with at least three representative pilot merchants and document domain/compliance review before general availability.

## 12. Data Model
### Business
- **Purpose:** Merchant identity and settings
- **Key fields:** Legal/trade name, GSTIN, state, address, settings
- **Relationships:** Branch, subscription, invoice
- **Control:** Restricted edits after transactions

### Branch
- **Purpose:** Operating unit
- **Key fields:** Code, address, tax identity, warehouse, price list
- **Relationships:** Business, user, counter
- **Control:** Multi-store scope

### User
- **Purpose:** Named system user
- **Key fields:** Name, role, branch scope, status, sessions
- **Relationships:** Role, audit
- **Control:** No shared admin

### Role
- **Purpose:** Permission template
- **Key fields:** Actions, modules, data scope, limits
- **Relationships:** User
- **Control:** Online and offline enforcement

### Customer
- **Purpose:** Buyer/account holder
- **Key fields:** Name, mobile, GSTIN, address, credit, consent
- **Relationships:** Sale, payment, order, loyalty
- **Control:** Personal data

### Supplier
- **Purpose:** Vendor
- **Key fields:** Name, GSTIN, contact, terms, bank reference
- **Relationships:** Purchase, payment
- **Control:** Role-restricted fields

### Product
- **Purpose:** Stock/service master
- **Key fields:** SKU, name, category, unit, tax, price, flags
- **Relationships:** Barcode, stock, sale, purchase
- **Control:** Effective-dated critical fields

### Product Variant
- **Purpose:** Attribute-specific SKU
- **Key fields:** Size, colour, style, capacity
- **Relationships:** Product, barcode, stock
- **Control:** Vertical-dependent

### Barcode
- **Purpose:** Scan identifier
- **Key fields:** Code, type, product/unit mapping
- **Relationships:** Product, POS
- **Control:** Unique within business

### Price List
- **Purpose:** Segment/branch pricing
- **Key fields:** Effective dates, item price, minimum price
- **Relationships:** Customer segment, branch
- **Control:** Audit changes

### Stock Location
- **Purpose:** Store/warehouse/rack/vehicle
- **Key fields:** Type, branch, status
- **Relationships:** Stock ledger
- **Control:** Access scoped

### Stock Movement
- **Purpose:** Immutable quantity event
- **Key fields:** Item, quantity, source, location, batch/serial, time
- **Relationships:** Sale, purchase, transfer
- **Control:** Basis of stock balance

### Batch/Lot
- **Purpose:** Traceable lot
- **Key fields:** Batch, manufacture, expiry, cost, supplier
- **Relationships:** Stock, sale
- **Control:** Vertical-dependent

### Serial/IMEI
- **Purpose:** Unique unit
- **Key fields:** Serial, model, status, warranty
- **Relationships:** Purchase, sale, service
- **Control:** Unique/state controlled

### Sale
- **Purpose:** Posted customer sale
- **Key fields:** Number, date, customer, tax, totals, status
- **Relationships:** Line, payment, stock
- **Control:** No silent deletion

### Sale Line
- **Purpose:** Invoice item/service
- **Key fields:** Product, quantity, unit, price, discount, tax, traceability
- **Relationships:** Sale, product
- **Control:** Reconciles to totals

### Payment
- **Purpose:** Money received/refunded
- **Key fields:** Mode, amount, reference, status, source
- **Relationships:** Sale, receipt, shift
- **Control:** No sensitive card data

### Purchase Order
- **Purpose:** Procurement commitment
- **Key fields:** Supplier, items, quantity, rate, expected date
- **Relationships:** Receipt, invoice
- **Control:** Approval optional

### Purchase Invoice
- **Purpose:** Supplier bill
- **Key fields:** Reference, tax, charge, due date, totals
- **Relationships:** Stock, payable
- **Control:** Duplicate check

### Ledger Entry
- **Purpose:** Financial event
- **Key fields:** Account, party, amount, source, date
- **Relationships:** Sale, purchase, payment, expense
- **Control:** Period lock

### Expense
- **Purpose:** Operating cost
- **Key fields:** Category, vendor, amount, tax, payment, attachment
- **Relationships:** Ledger, approval
- **Control:** Role/limit control

### Order
- **Purpose:** Pre-invoice demand
- **Key fields:** Source, promised date, status, advance, address
- **Relationships:** Reservation, delivery, sale
- **Control:** Partial fulfilment

### Delivery
- **Purpose:** Fulfilment event
- **Key fields:** Assignee, route, status, proof, COD
- **Relationships:** Order, payment
- **Control:** Consent for proof

### Subscription
- **Purpose:** Merchant plan
- **Key fields:** Plan, term, status, renewal, grace
- **Relationships:** Entitlement
- **Control:** Controls access

### Entitlement
- **Purpose:** Included feature/quota
- **Key fields:** Feature, quota, frequency, location
- **Relationships:** Subscription, support
- **Control:** Machine-enforced

### Support Ticket
- **Purpose:** Merchant issue
- **Key fields:** Category, priority, status, SLA, consent, resolution
- **Relationships:** Device, visit
- **Control:** Access logged

### Catalogue Request
- **Purpose:** Monthly service request
- **Key fields:** Period, item count, source, validation, approval
- **Relationships:** Entitlement, product changes
- **Control:** Quota controlled

### Audit Event
- **Purpose:** Attributable action
- **Key fields:** User, action, entity, before/after, device, time
- **Relationships:** Critical entities
- **Control:** Tamper-resistant

### Consent
- **Purpose:** Permission record
- **Key fields:** Purpose, channel, status, time, evidence
- **Relationships:** Customer, support access
- **Control:** Privacy control

## 13. API and Integration Requirements
- All APIs use tenant-scoped authentication and stable error codes.
- Every POST/PATCH operation affecting financial or stock state accepts an idempotency key.
- External integrations use encrypted server-side credentials and explicit merchant activation.
- Webhooks are signed, retryable and include event ID, tenant ID, entity ID, version and timestamp.
- Printer operations remain local where possible and do not block transaction posting.
- Integration adapters must expose health, last success, retry count and actionable error message.
- OpenAPI specifications and mock servers must be generated before client implementation.

### 13.1 Minimum API resource groups
- Authentication And Devices
- Businesses, Branches And Settings
- Users, Roles And Permissions
- Products, Categories, Units, Barcodes And Prices
- Customers, Suppliers And Consent
- Sales, Returns, Payments And Shifts
- Stock, Batches, Serials, Counts And Transfers
- Purchases, Receipts And Payables
- Orders, Delivery And Advances
- Subscriptions, Entitlements And Support Tickets
- Reports, Exports And Audit Events
- Integrations And Webhooks

## 14. Offline and Sync Specification
- The client writes a complete local transaction before displaying success.
- Each local write receives a globally unique event ID and idempotency key.
- Invoice numbering uses a collision-safe strategy approved for the merchant configuration.
- The outbox preserves order for dependent events and retries with exponential backoff.
- Server acknowledgement records canonical IDs and versions without rewriting printed business content.
- Conflicts are classified: safe merge, server wins, client wins under policy, or manual resolution.
- Serial/IMEI duplication, invoice-number collision and stock conflict must never be silently merged.
- The UI shows last sync, queue count, failures and last successful backup.
- Reinstallation/restore must not replay already acknowledged transactions.

## 15. Printer and Hardware Certification
- Maintain an approved-device registry with model, firmware, connection type and tested app versions.
- Certification test includes text, logo, Unicode/code page, QR, barcode, long receipt, paper-out, reconnect and retry.
- A failed print remains a print job failure, not a failed or duplicated sale.
- Allow reprint only with copy marking and audit.
- Provide an installer health-test screen and exportable diagnostic result.
- The annual plan includes only an approved 58mm model and documented warranty conditions.

## 16. Security, Privacy and Compliance
- Use least privilege, encryption in transit and at rest, secure secret storage and environment separation.
- No production database edits without a controlled repair workflow and before/after audit.
- Support access requires merchant consent, expiry and access log.
- Collect customer information only for necessary billing, credit, warranty, order or consented communication purposes.
- Provide opt-out handling and suppress non-essential communication after withdrawal.
- Statutory rates, thresholds and integration applicability are configurable and must be revalidated before deployment.
- High-risk verticals require additional permissions, retention policies and domain review.
- Maintain backup, restore, incident-response and vulnerability-patch procedures.

## 17. Support and Catalogue Operations
### SUP-01 — Phone & WhatsApp support
- **Inclusion:** Included
- **Availability:** Business hours
- **Included:** App use, printer pairing, common errors
- **Excluded:** Custom development; third-party repair
- **Rule/SLA:** Initial response within business day
- **Metrics:** Response time; resolution time; reopen rate

### SUP-02 — Remote troubleshooting
- **Inclusion:** Included with consent
- **Availability:** Business hours/scheduled
- **Included:** Logs, settings, sync and printer diagnostics
- **Excluded:** Access without merchant approval
- **Rule/SLA:** Attempt before field visit
- **Metrics:** Remote resolution percentage

### SUP-03 — Initial installation
- **Inclusion:** Annual kit included
- **Availability:** Scheduled
- **Included:** Setup, approved printer, test bill, backup and training
- **Excluded:** Electrical/network repair
- **Rule/SLA:** Merchant sign-off checklist
- **Metrics:** First-time installation success

### SUP-04 — On-site support
- **Inclusion:** Limited/chargeable*
- **Availability:** Serviceable areas
- **Included:** Issues not resolved remotely
- **Excluded:** Unlimited visits; unapproved hardware repair
- **Rule/SLA:** Scheduled by capacity
- **Metrics:** Visits and cost per merchant

### SUP-05 — Monthly catalogue request
- **Inclusion:** 1 request/month*
- **Availability:** Valid structured file
- **Included:** Up to 100 additions or updates
- **Excluded:** Unlimited data cleanup/image work
- **Rule/SLA:** 2 business days after valid data
- **Metrics:** Items processed; rework rate

### SUP-06 — Initial catalogue loading
- **Inclusion:** Within agreed annual scope*
- **Availability:** Before go-live
- **Included:** Validated Excel import + approval
- **Excluded:** Unstructured handwritten data unless quoted
- **Rule/SLA:** Scope in order form
- **Metrics:** Onboarding hours; error rate

### SUP-07 — Printer warranty coordination
- **Inclusion:** Assistance included
- **Availability:** Supplier warranty terms
- **Included:** Diagnosis and documentation
- **Excluded:** Physical/water/voltage/misuse damage
- **Rule/SLA:** Subject to approved supplier warranty
- **Metrics:** Failure/replacement by model

### SUP-08 — Customisation request
- **Inclusion:** Quoted separately
- **Availability:** Product review cycle
- **Included:** Approved config, report or integration
- **Excluded:** Unlimited bespoke work under subscription
- **Rule/SLA:** Estimate after requirement review
- **Metrics:** Revenue; delivery time; support impact

## 18. Analytics and Telemetry
- Product analytics: active merchants, billing days, bills/day, average bill, feature adoption and renewal indicators.
- Reliability: crash-free sessions, sync latency, failed queue events, backup success and printer success by model.
- Support economics: tickets, remote minutes, visits, catalogue items, replacements and cost per merchant.
- Risk: unusual discounts, cancellations, returns, cash variance, negative stock and repeated login failures.
- Telemetry must exclude unnecessary invoice/customer content; use identifiers and aggregate metrics where possible.

## 19. Testing Strategy
- Unit tests for tax, discount allocation, rounding, stock movement, valuation, entitlement and state machines.
- Property-based tests for invoice totals, split payments and unit conversions.
- Offline/sync tests with network interruption at every transaction stage.
- Printer certification tests for each approved model and Android device class.
- Migration tests using real-size catalogues and duplicate/error cases.
- Role and permission tests at UI, API, export and offline layers.
- Security tests for authentication, tenant isolation, secrets, rate limits and support access.
- End-to-end vertical tests using representative merchant scenarios.
- Restore drills from backup into isolated environments.
- Regression suite linked to Feature IDs and release gates.

## 20. Release and Acceptance Process
- No feature is Done until acceptance criteria, automated tests, migration impact, analytics and support notes are completed.
- MVP is released only to controlled pilots with approved printers and signed installation checklist.
- Every vertical pack requires at least three pilot merchants.
- Release notes list completed, changed, deprecated and known-risk Feature IDs.
- Rollback and data-recovery plans are mandatory for schema and tax changes.
- Commercial teams may sell only features and hardware marked Generally Available.

## 21. Roadmap
### MVP — Pilot Retail Core (Months 0–3)
- **Goal:** Reliable low-cost billing kit for 30 shops
- **Feature groups:** Setup; catalogue import; POS; GST/non-GST; 58mm print; WhatsApp; payments; offline; basic stock; daily report; entitlement; installation
- **Priority businesses:** Kirana, hardware, stationery, small retail
- **Entry criteria:** Approved printer shortlist; pilot merchants
- **Exit criteria:** Bills retrievable; printer success ≥98%; no duplicate invoices; remote support works
- **Indicative team:** Product; Flutter; backend; QA; implementation/support

### P1 — Commercial Retail Release (Months 3–6)
- **Goal:** Repeatable sales with controlled support cost
- **Feature groups:** Returns; credit; purchase; expense; reports; restore; roles; audit; catalogue quota; tickets; diagnostics; scanner
- **Priority businesses:** Core retail categories
- **Entry criteria:** MVP stability + onboarding playbook
- **Exit criteria:** Support cost tracked; SLA/renewal controls active
- **Indicative team:** Engineering; QA automation; support lead; catalogue ops

### P2 — Retail Pro + Vertical Packs (Months 6–12)
- **Goal:** Higher-value workflows and hardware
- **Feature groups:** Multi-counter; multi-store; promotions; batch/expiry; serial; scale; labels; orders; delivery; advanced inventory; first packs
- **Priority businesses:** Supermarket, pharmacy, restaurant, apparel, electronics, service centre
- **Entry criteria:** 3 design partners per vertical
- **Exit criteria:** No spreadsheet/manual workaround for pilot workflows
- **Indicative team:** Vertical PM; integration engineer; domain consultants

### P3 — Business Platform (Months 12–18)
- **Goal:** Distributors and growing businesses
- **Feature groups:** E-invoice/EWB integration; API; accounting; bank reconciliation; route sales; manufacturing; scheduled reports; channels
- **Priority businesses:** Wholesale, distribution, multi-branch, manufacturing
- **Entry criteria:** Security review; partner/API agreements; compliance validation
- **Exit criteria:** Reliable integration + audit controls accepted
- **Indicative team:** Platform; security; compliance; partner success

## 22. Open Product Decisions
- Final Flutter/backend hosting stack and vendor lock-in limits.
- Exact annual-plan initial catalogue item limit and carry-forward policy.
- Serviceable-area radius, included on-site visit allowance and visit price.
- Approved 58mm printer models, procurement warranty and replacement reserve.
- Whether monthly plan includes cloud backup and how suspension/read-only access behaves.
- Initial business categories for the first 30-shop pilot.
- Which vertical pack launches first after core retail.
- Payment/WhatsApp providers and merchant pass-through pricing.
- Tax-inclusive or exclusive displayed subscription prices.
- Data retention defaults by transaction, support, audit and customer communication category.

## 23. Definition of Done for Claude-Generated Implementation
- Code compiles and passes lint, unit, integration and relevant end-to-end tests.
- Feature IDs are referenced in implementation notes and tests.
- Database migration is reversible or has an explicit recovery procedure.
- API schema and error responses are documented.
- Offline behaviour and sync conflict behaviour are tested.
- Permissions and audit events are implemented.
- Support diagnostics and user-facing error guidance are included.
- No hard-coded merchant, tax, printer or vertical assumptions remain where configuration is required.
- Release documentation identifies known limitations and deferred requirements.

## Appendix A — Document Hierarchy
1. This PRD defines product behaviour, architecture, acceptance gates and implementation rules.
2. The companion Excel workbook provides the complete feature inventory, business matrix, plans, support model, data dictionary, roadmap and sources.
3. Design files define approved visual behaviour but cannot override business or security rules.
4. API contracts and database migrations become technical source-of-truth artefacts after approval.

## Appendix B — Change Control
Every requirement change must record: Feature ID, old requirement, new requirement, reason, owner, impacted modules, migration impact, testing impact, commercial/support impact and target release.
