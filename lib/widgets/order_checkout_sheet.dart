import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../state/basket_controller.dart';
import '../theme/bakery_theme.dart';

/// Form data delivered to the backend callback by CartScreen.
class CheckoutDetails {
  const CheckoutDetails({
    required this.name,
    required this.phone,
    required this.address,
    required this.notes,
  });

  final String name;
  final String phone;
  final String address;
  final String notes;
}

/// Bottom-sheet checkout that reuses the SAME artwork as the approved Cart:
/// cream parchment, terracotta bricks, pink bow, stitched cocoa frame,
/// and the little bakery scene at the bottom.
///
/// To open it, call showModalBottomSheet(..., builder: (_) =>
///   OrderCheckoutSheet(basket: basket, onSubmit: ...)).
class OrderCheckoutSheet extends StatefulWidget {
  const OrderCheckoutSheet({
    super.key,
    required this.basket,
    required this.onSubmit,
    this.submitLabel = 'Konfirmasi Pesanan',
  });

  final BasketController basket;

  /// Return the Order ID from OrderService.createOrder().
  final Future<String> Function(CheckoutDetails details) onSubmit;
  final String submitLabel;

  @override
  State<OrderCheckoutSheet> createState() => _OrderCheckoutSheetState();
}

class _OrderCheckoutSheetState extends State<OrderCheckoutSheet> {

  final ScrollController _formScrollController = ScrollController();
  bool _hasReachedBottom = false;

  @override
  void initState() {
    super.initState();

    _formScrollController.addListener(_checkScrollBottom);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollBottom();
    });
  }

  void _checkScrollBottom() {
    if (!mounted ||
        _hasReachedBottom ||
        _orderId != null ||
        !_formScrollController.hasClients) {
      return;
    }

    if (_formScrollController.position.extentAfter <= 24) {
      setState(() {
        _hasReachedBottom = true;
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();

  bool _submitting = false;
  String? _submitError;
  String? _orderId;
  int? _confirmedTotal;

 @override
void dispose() {
  _formScrollController.removeListener(_checkScrollBottom);
  _formScrollController.dispose();

  _name.dispose();
  _phone.dispose();
  _address.dispose();
  _notes.dispose();

  super.dispose();
}

  Future<void> _submit() async {
    if (_submitting || _orderId != null || widget.basket.itemCount == 0) return;
    if (_formKey.currentState?.validate() != true) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _submitError = null;
    });

   
try {
      // Simpan total sebelum keranjang dikosongkan.
      final confirmedTotal = widget.basket.total;

      final id = await widget.onSubmit(
        CheckoutDetails(
          name: _name.text.trim(),
          phone: _phone.text.trim().replaceAll(
                RegExp(r'[\s-]'),
                '',
              ),
          address: _address.text.trim(),
          notes: _notes.text.trim(),
        ),
      );

      // API sudah berhasil menyimpan pesanan.
      // Tampilkan success state dengan nominal sebelumnya.
      if (mounted) {
        setState(() {
          _orderId = id;
          _confirmedTotal = confirmedTotal;
          _submitting = false;
        });
      }

      // Tetap kosongkan keranjang meskipun modal sudah tertutup.
      await widget.basket.clear();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
        _submitError = error.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final heightAvailable = media.size.height - media.viewInsets.bottom - 8;
    final sheetHeight = math.min(790.0, math.max(1.0, heightAvailable));

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SizedBox(
            width: double.infinity,
            height: sheetHeight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: const BoxDecoration(
                  color: BakeryColors.darkCocoa,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x603F1E15),
                      blurRadius: 22,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(3, 3, 3, 0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(19),
                  ),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFEDCE), Color(0xFFF7DAB8)],
                      ),
                    ),
                    child: Column(
                      children: [
                        _CheckoutHeader(
                          subtitle: _orderId == null
                              ? '${widget.basket.itemCount} item dipilih'
                              : 'pesananmu berhasil dicatat!',
                          title: _orderId == null ? 'Data Pemesan' : 'Hore, Berhasil!',
                          onClose: _submitting
                              ? null
                              : () => Navigator.of(context).pop(_orderId),
                        ),
                        Expanded(
                          child: _orderId != null
                              ? _successContent()
                              : AnimatedBuilder(
                                  animation: widget.basket,
                                  builder: (context, _) => _checkoutForm(),
                                ),
                        ),
                        _bottomAction(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _checkoutForm() {
    return SingleChildScrollView(
        controller: _formScrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(17, 7, 17, 21),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BakeryPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const _PixelFlower(),
                      const SizedBox(width: 9),
                      Text('Data Pengiriman', style: BakeryText.heading(19)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Isi datamu dulu, biar rotinya sampai dengan aman ♡',
                    style: BakeryText.label(11, weight: FontWeight.w500),
                  ),
                  const SizedBox(height: 18),
                  _CheckoutInput(
                    label: 'Nama lengkap *',
                    hint: 'Nama penerima',
                    controller: _name,
                    icon: Icons.person_outline,
                    action: TextInputAction.next,
                    validator: (v) {
                      final text = v?.trim() ?? '';
                      return text.length >= 2 && text.length <= 80
                          ? null : 'Masukkan nama 2–80 karakter';
                    },
                  ),
                  _CheckoutInput(
                    label: 'Nomor WhatsApp *',
                    hint: '08xxxxxxxxxx',
                    controller: _phone,
                    icon: Icons.chat_bubble_outline,
                    inputType: TextInputType.phone,
                    action: TextInputAction.next,
                    validator: (v) {
                      final value = (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
                      return RegExp(r'^(?:0|62|\+62)8\d{7,12}$').hasMatch(value)
                          ? null : 'Nomor WhatsApp belum valid';
                    },
                  ),
                  _CheckoutInput(
                    label: 'Alamat lengkap *',
                    hint: 'Jalan, nomor rumah, RT/RW, kecamatan, patokan...',
                    controller: _address,
                    // icon: Icons.location_on_outlined,
                    inputType: TextInputType.streetAddress,
                    action: TextInputAction.newline,
                    maxLines: 3,
                    
validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Alamat wajib diisi';
                      }
                      return null;
                    },
                  ),
                  _CheckoutInput(
                    label: 'Catatan (opsional)',
                    hint: 'Contoh: patokan rumah, jadwal penerimaan...',
                    controller: _notes,
                    // icon: Icons.edit_note_outlined,
                    inputType: TextInputType.multiline,
                    action: TextInputAction.newline,
                    maxLines: 2,
                    validator: (v) => (v?.trim().length ?? 0) <= 300
                        ? null : 'Catatan maksimal 300 karakter',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _BakeryPanel(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite, color: BakeryColors.button, size: 14),
                      const SizedBox(width: 7),
                      Text('Ringkasan Pesanan', style: BakeryText.heading(17)),
                      const SizedBox(width: 7),
                      const Icon(Icons.favorite, color: BakeryColors.button, size: 14),
                    ],
                  ),
                  const SizedBox(height: 14),
                  for (final product in widget.basket.selectedProducts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        children: [
                          Container(
                            width: 43,
                            height: 43,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE7C8),
                              border: Border.all(color: BakeryColors.border, width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              product.asset,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.none,
                              errorBuilder: (context, error, stack) =>
                                  const Icon(Icons.bakery_dining_outlined,
                                      color: BakeryColors.cocoa),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, style: BakeryText.label(12)),
                                const SizedBox(height: 2),
                                Text(
                                  '×${widget.basket.quantityOf(product.id)}',
                                  style: BakeryText.label(10, weight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            rupiah(product.price * widget.basket.quantityOf(product.id)),
                            style: BakeryText.label(12),
                          ),
                        ],
                      ),
                    ),
                  const _DashDivider(),
                  const SizedBox(height: 5),
                  _CostLine(
                    label: 'Subtotal (${widget.basket.itemCount} item)',
                    value: rupiah(widget.basket.subtotal),
                  ),
                  _CostLine(label: 'Ongkir', value: rupiah(widget.basket.shipping)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, thickness: 1, color: Color(0xFFD6A27F)),
                  ),
                  _CostLine(
                    label: 'Total Pembayaran',
                    value: rupiah(widget.basket.total),
                    prominent: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE7BE),
                border: Border.all(color: BakeryColors.caramel, width: 1.5),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined,
                      color: BakeryColors.cocoa, size: 23),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ongkir flat Rp10.000 per pesanan. '
                      'Pembayaran menunggu konfirmasi batch PO mingguan.',
                      style: BakeryText.label(11, weight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _successContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(17, 10, 17, 20),
      child: _BakeryPanel(
        child: Column(
          children: [
            const SizedBox(height: 5),
            const _PixelFlower(size: 39),
            const SizedBox(height: 13),
            Text('Rotimu sudah tercatat! ♡',
                textAlign: TextAlign.center, style: BakeryText.heading(22)),
            const SizedBox(height: 8),
            Text(
              'Pesanan sedang menunggu konfirmasi batch mingguan. '
              'Simpan Order ID ini, ya!',
              textAlign: TextAlign.center,
              style: BakeryText.label(12, weight: FontWeight.w500),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE0B2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: BakeryColors.border, width: 1.7),
              ),
              child: Column(
                children: [
                  Text('ORDER ID', style: BakeryText.label(10)),
                  const SizedBox(height: 5),
                  SelectableText(
                    _orderId!,
                    textAlign: TextAlign.center,
                    style: BakeryText.label(15, weight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _orderId!));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order ID disalin!')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Salin Order ID'),
                    style: TextButton.styleFrom(foregroundColor: BakeryColors.cocoa),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            _CostLine(
              label: 'Total pesanan',
              value: rupiah(_confirmedTotal ?? widget.basket.total),
              prominent: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Status: Menunggu konfirmasi batch',
              textAlign: TextAlign.center,
              style: BakeryText.label(11),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  
Widget _bottomAction() {
  final showButton = _hasReachedBottom || _orderId != null;

  return SafeArea(
    top: false,
    child: SizedBox(
      height: 124,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/checkout/checkout_footer.png',
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),

          Positioned(
            top: 6,
            left: 20,
            right: 20,
            child: !showButton
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBD2),
                      border: Border.all(
                        color: BakeryColors.border,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.keyboard_double_arrow_down_rounded,
                          color: BakeryColors.button,
                          size: 24,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Scroll sampai bawah untuk '
                            'konfirmasi pesanan ♡',
                            style: BakeryText.label(
                              11,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      if (_submitError != null &&
                          _orderId == null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBD2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            _submitError!,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: BakeryText.label(10).copyWith(
                              color: BakeryColors.button,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                      ],
                      _TerracottaButton(
                        label: _orderId != null
                            ? 'Kembali ke Menu ♡'
                            : widget.submitLabel,
                        busy: _submitting,
                        enabled: _orderId != null ||
                            widget.basket.itemCount > 0,
                        icon: _orderId != null
                            ? Icons.favorite_rounded
                            : Icons.shopping_bag_outlined,
                        onTap: _orderId != null
                            ? () => Navigator.of(context).pop(_orderId)
                            : _submit,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    ),
  );
}
}


class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({
    required this.title,
    required this.subtitle,
    this.onClose,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        final w = size.maxWidth;
        final h = w * 183 / 579;
        return SizedBox(
          height: h,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/checkout/checkout_header.png',
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                ),
              ),
              Positioned(
                left: w * 0.052,
                top: h * 0.30,
                width: w * 0.108,
                height: h * 0.34,
                child: Semantics(
                  button: true,
                  label: 'Tutup data pemesan',
                  child: InkWell(onTap: onClose),
                ),
              ),
              Positioned(
                top: h * 0.41,
                left: w * .20,
                right: w * .20,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: BakeryText.heading(w < 370 ? 22 : 27),
                ),
              ),
              Positioned(
                top: h * 0.74,
                left: w * .24,
                right: w * .24,
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: BakeryText.label(w < 370 ? 10 : 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BakeryPanel extends StatelessWidget {
  const _BakeryPanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/checkout/checkout_panel.png',
            centerSlice: const Rect.fromLTRB(36, 32, 540, 262),
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),
        ),
        CustomPaint(
          foregroundPainter: const _StitchPainter(inset: 13),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 23, 24, 22),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _CheckoutInput extends StatelessWidget {
  const _CheckoutInput({
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    this.icon,
    this.action = TextInputAction.next,
    this.inputType = TextInputType.text,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final IconData? icon;
  final TextInputAction action;
  final TextInputType inputType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: BakeryText.label(12, weight: FontWeight.w800)),
          const SizedBox(height: 7),
          TextFormField(
            controller: controller,
            keyboardType: inputType,
            textInputAction: action,
            maxLines: maxLines,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: BakeryText.label(12, weight: FontWeight.w600),
            cursorColor: BakeryColors.button,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: BakeryText.label(11, weight: FontWeight.w400)
                  .copyWith(color: const Color(0xFF98715E)),         
prefixIcon: icon == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.only(
                        bottom: maxLines > 1 ? 30 : 0,
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: BakeryColors.caramel,
                      ),
                    ),
              prefixIconConstraints:
                  icon == null ? null : const BoxConstraints(minWidth: 42),

              filled: true,
              fillColor: const Color(0xFFFFFAEA),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13, vertical: 15,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: BakeryColors.border, width: 1.8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: BakeryColors.darkCocoa, width: 2.3),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: BakeryColors.button, width: 1.8),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: BakeryColors.button, width: 2.3),
              ),
              errorStyle: const TextStyle(fontSize: 10, color: BakeryColors.button),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostLine extends StatelessWidget {
  const _CostLine({required this.label, required this.value, this.prominent = false});
  final String label;
  final String value;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: BakeryText.label(
                prominent ? 12 : 11,
                weight: prominent ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: BakeryText.label(
              prominent ? 16 : 11,
              weight: FontWeight.w900,
            ).copyWith(color: prominent ? BakeryColors.button : BakeryColors.cocoa),
          ),
        ],
      ),
    );
  }
}

class _TerracottaButton extends StatelessWidget {
  const _TerracottaButton({
    required this.label,
    required this.onTap,
    required this.icon,
    required this.busy,
    required this.enabled,
  });
  final String label;
  final VoidCallback onTap;
  final IconData icon;
  final bool busy;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (!enabled || busy) ? null : onTap,
          borderRadius: BorderRadius.circular(11),
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: BakeryColors.button,
              border: Border.all(color: BakeryColors.darkCocoa, width: 2.2),
              borderRadius: BorderRadius.circular(11),
              boxShadow: const [
                BoxShadow(color: BakeryColors.darkCocoa, offset: Offset(0, 3)),
              ],
            ),
            child: CustomPaint(
              foregroundPainter: const _StitchPainter(
                color: Color(0xFFF8D9BA),
                inset: 6,
                cornerRadius: 5,
              ),
              child: Center(
                child: busy
                    ? const SizedBox.square(
                        dimension: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFFFFFAE9),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: const Color(0xFFFFFAE9), size: 19),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: const TextStyle(
                              color: Color(0xFFFFFAE9),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PixelFlower extends StatelessWidget {
  const _PixelFlower({this.size = 23});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: const CustomPaint(painter: _PixelFlowerPainter()),
      );
}

class _PixelFlowerPainter extends CustomPainter {
  const _PixelFlowerPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 23, size.height / 23);
    final dark = Paint()..color = BakeryColors.darkCocoa;
    final petal = Paint()..color = const Color(0xFFD87C88);
    final center = Paint()..color = const Color(0xFFFFCE65);
    for (final rect in [
      const Rect.fromLTWH(8, 0, 7, 7),
      const Rect.fromLTWH(0, 8, 7, 7),
      const Rect.fromLTWH(16, 8, 7, 7),
      const Rect.fromLTWH(8, 16, 7, 7),
    ]) {
      canvas.drawRect(rect, dark);
      canvas.drawRect(rect.deflate(1), petal);
    }
    canvas.drawRect(const Rect.fromLTWH(8, 8, 7, 7), dark);
    canvas.drawRect(const Rect.fromLTWH(9, 9, 5, 5), center);
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _PixelFlowerPainter oldDelegate) => false;
}

class _DashDivider extends StatelessWidget {
  const _DashDivider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: SizedBox(
          height: 2,
          width: double.infinity,
          child: CustomPaint(painter: _DashLinePainter()),
        ),
      );
}

class _DashLinePainter extends CustomPainter {
  const _DashLinePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = BakeryColors.border;
    for (double x = 0; x < size.width; x += 10) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 5, 2), paint);
    }
  }
  @override
  bool shouldRepaint(covariant _DashLinePainter oldDelegate) => false;
}

class _StitchPainter extends CustomPainter {
  const _StitchPainter({
    this.color = const Color(0xFFD9AC86),
    this.inset = 4,
    this.cornerRadius = 6,
  });
  final Color color;
  final double inset;
  final double cornerRadius;
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    if (bounds.width <= 0 || bounds.height <= 0) return;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        bounds, Radius.circular(cornerRadius),
      ));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in path.computeMetrics()) {
      for (double offset = 0; offset < metric.length; offset += 9) {
        canvas.drawPath(
          metric.extractPath(offset, math.min(offset + 4, metric.length)),
          paint,
        );
      }
    }
  }
  @override
  bool shouldRepaint(covariant _StitchPainter old) =>
      old.color != color || old.inset != inset || old.cornerRadius != cornerRadius;
}
