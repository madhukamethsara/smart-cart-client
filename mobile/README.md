# NovaMart Smart Cart — Customer App

Flutter app for customers to scan smart cart QR codes and view their shopping cart in real time.

## Theme
Black & White editorial design matching the NovaMart web platform.
- **Syne** — UI headings and buttons
- **Instrument Serif** — display headings and totals
- **IBM Plex Mono** — data labels, codes, metadata

---

## Features

| Screen | Description |
|--------|-------------|
| **Home** | Landing page with how-it-works guide, status indicator |
| **Scanner** | Full-screen QR scanner with corner frame overlay, torch toggle, manual entry fallback |
| **Cart View** | 3-tab view: Items (grouped by category), Summary (totals + category breakdown bar chart), Details (session info + store info) |
| **Bill/Receipt** | Receipt display with payment confirmation, itemised list, and total |
| **Settings** | Backend URL config with live connection tester, about info |

### Demo Mode
When the backend is unreachable, the app automatically loads demo cart data so all screens are fully functional for preview/testing.

---

## Setup

### 1. Install Flutter
```bash
flutter --version  # requires Flutter 3.x+
```

### 2. Install dependencies
```bash
cd novamart_smart_cart
flutter pub get
```

### 3. Run
```bash
# Android
flutter run

# iOS
flutter run -d "iPhone"

# With a specific device
flutter run -d <device-id>
```

---

## Backend Integration

The app reads the backend base URL from compile-time variable `API_BASE_URL`.

Default (when not provided): `http://10.0.2.2:8787`

To change the backend URL at build/run time:
- Android emulator/local backend:
  - `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8787`
- iOS simulator/local backend:
  - `flutter run --dart-define=API_BASE_URL=http://localhost:8787`
- Production/staging:
  - `flutter run --dart-define=API_BASE_URL=https://api.example.com`
  - `flutter build apk --dart-define=API_BASE_URL=https://api.example.com`

You can still override and save the URL in **Settings** inside the app.

### API Endpoints Used

| Endpoint | Purpose |
|----------|---------|
| `GET /api/health` | Backend health check |
| `GET /api/carts/:code` | Load cart by QR code |
| `GET /api/carts/:id/items` | Load items for a cart |
| `GET /api/checkout/bills?cart_id=X` | Fetch bill for a cart |

### QR Code Format
The scanner accepts any of:
- Plain cart ID: `42`
- Prefixed: `CART-42` or `NM-42`
- Deep link: `novamart://cart/42`

---

## Project Structure

```
lib/
├── main.dart               # Entry point
├── theme/
│   └── app_theme.dart      # Colors, typography, ThemeData
├── models/
│   └── models.dart         # Cart, CartItem, Product, Bill, DemoData
├── services/
│   └── api_service.dart    # HTTP client for NovaMart backend
├── widgets/
│   └── widgets.dart        # NovaBadge, NovaButton, StatBox, SectionHeader…
└── screens/
    ├── home_screen.dart     # Landing / home
    ├── scanner_screen.dart  # QR camera scanner
    ├── cart_screen.dart     # Cart detail (Items / Summary / Details)
    ├── bill_screen.dart     # Receipt view
    └── settings_screen.dart # Backend URL + app info
```

---

## Dependencies

```yaml
mobile_scanner: ^5.2.3    # QR / barcode scanning
http: ^1.2.1              # API calls
shared_preferences: ^2.2.3 # Persist backend URL
google_fonts: ^6.2.1      # Syne, Instrument Serif, IBM Plex Mono
flutter_animate: ^4.5.0   # Smooth entrance animations
qr_flutter: ^4.1.0        # QR code display
```

---

## Android Notes
- `android:usesCleartextTraffic="true"` is set for local HTTP (localhost).  
  Remove this for production with HTTPS.
- Camera permission is declared in `AndroidManifest.xml`.

## iOS Notes
- `NSCameraUsageDescription` is set in `Info.plist`.
- iOS 12+ required.
