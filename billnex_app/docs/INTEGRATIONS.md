# Integrations (P6) — runbook

Implemented as pure-Dart builders in `lib/services/integrations.dart` (unit-tested).
The *building* needs no accounts; *transmitting* needs the accounts noted below.

## 1. Dynamic UPI (BNX-0119) — ready
`UpiService.buildIntent(...)` returns a `upi://pay?...` deep link for a specific
amount. To use:
- **Launch** the payer's UPI app: add `url_launcher` and
  `launchUrl(Uri.parse(intent))`.
- **QR** on receipt: encode the same string (the `printing`/`pdf` `BarcodeWidget`
  already draws QR — pass the intent string instead of the static payload).
- **Accounts:** none for the intent. For *auto-confirmation* of payment status
  you need a PSP/aggregator (Razorpay/PhonePe/Cashfree) — that's a separate SDK.

## 2. WhatsApp invoice (BNX-0072) — ready (link) / account (API)
- **Now:** `WhatsAppService.invoiceLink(phone, message)` → `https://wa.me/...`;
  open with `url_launcher`. Also `Printing.sharePdf` already shares the PDF via
  the OS share sheet (WhatsApp included).
- **Business API** (templates, delivery receipts, BNX-0329): needs a Meta
  WhatsApp Business account + a BSP (Gupshup/Twilio/360dialog). Send the
  template via their REST API from your backend, not the client.

## 3. GST e-invoice / IRN (BNX-0111) — payload ready / GSP account to submit
`EInvoiceService.buildPayload(...)` produces the IRP `Version 1.1` JSON.
- **To submit:** register on the IRP via a GSP (ClearTax/Masters India/etc.),
  authenticate, POST the payload, receive `Irn` + `SignedQRCode`, then render
  that QR on the A4 invoice.
- Do the GSP call **server-side** (credentials never on device). Store the
  returned IRN/QR against the sale.
- E-way bill (BNX-0115) follows the same GSP pattern.

## 4. ESC/POS thermal (PRD §15) — interface ready
The app prints via `printing` (PDF → any printer, incl. thermal) today. For a
**direct** ESC/POS byte stream (cutter, drawer kick, code pages) on certified
models, implement `EscPosPrinter` with:
- `esc_pos_utils` (command bytes) + `print_bluetooth_thermal` or
  `flutter_thermal_printer` (Bluetooth/USB transport).
- Keep it behind the `EscPosPrinter` interface so the PDF path stays the
  cross-platform default and only certified models use raw commands.
- **Certify** each model per §15 (text, logo, QR, barcode, long receipt,
  paper-out, reconnect) before marking it supported.

## Security
- All provider credentials (GSP, WhatsApp BSP, PSP) live on the **backend**, never
  in the app. The client only ever holds the merchant VPA (public) and a JWT.
