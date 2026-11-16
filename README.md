# Crumb & Oven — Flutter Web Microsite

Two-page bakery **store**, not a game. This is the UI slicing of the approved pixel-art mockup using its exact interior image plus seven new bread sprites supplied by the user.

## Run

Requires the Flutter SDK (stable) and Chrome or Edge. From this directory:

```bash
flutter create . --platforms web --project-name crumb_oven_store
flutter pub get
flutter run -d chrome
```

If Chrome is not detected, run `flutter run -d web-server`, then open the served URL in your browser.

**Note:** The Flutter SDK was not available in the environment where this package was created, so this version has not yet been compiled or browser-tested. `flutter create` fills in Flutter-generated platform/build files.

## Scope

- Menu page: approved hero, seven horizontally stacked bakery items, live quantity +/- controls.
- Floating basket: unit count and subtotal (excluding shipping), opens cart.
- Cart: selected items, quantity +/- controls, summary, shipping rule.
- `itemCount` means **total units** (sum of quantities), not distinct products.
- 1–5 units → estimated shipping IDR 12,000. 6+ → free shipping. Zero items → zero shipping.
- Checkout button is a **demo action**: copies the order message to the clipboard, no charge/payment or backend actions.

## Customize

- Products and prices: `lib/data/products.dart`
- Shipping threshold and amount: `lib/main.dart`, BasketController constructor.
- Color tokens: `lib/theme/bakery_theme.dart`
- Product images: `assets/products/`
- Master interior artwork: `assets/hero/bakery_interior.png`
- Other reference frames and decoration: `assets/ui/`, `assets/decor/`

## Visual fidelity

The interior and header are **pixel-exact crops** from the approved design. Seven bread sprites are from the subsequent bread reference photos and their previously generated pixel-art sheet. Frames and controls are PNGs from the earlier asset pack. Dynamic text, item names/prices, quantities, shipping info and summaries are rendered by Flutter so they work; these cannot be pixel-identical to a static AI mockup in every viewport.

Images use `FilterQuality.none` to preserve blocky pixel texture. The layout is mobile-first, centered and width-constrained on desktop. We deliberately avoided extra pages, game mechanics and category filters.

## Before production

Connect a real checkout destination/number, persist the basket if needed, decide pickup vs delivery, validate shipping by destination, confirm inventory, and add stock handling. Current shipping is a single illustrative flat rate, not a courier API quote.
