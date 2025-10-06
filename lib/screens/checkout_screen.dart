import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/services/cart_manager.dart';
import '/services/location_service.dart';
import 'package:local_auth/local_auth.dart';

class CheckoutPage extends StatefulWidget {
  final CartManager cartManager;

  const CheckoutPage({Key? key, required this.cartManager}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late CartManager _cartManager;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final LocalAuthentication _auth = LocalAuthentication();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _cartManager = widget.cartManager;
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();

      print('=== BIOMETRIC STATUS ===');
      print('Device supported: $isDeviceSupported');
      print('Can check biometrics: $canCheckBiometrics');
      print('Available biometrics: $availableBiometrics');
      print('=======================');
    } catch (e) {
      print('Error checking biometric status: $e');
    }
  }

  @override
  void dispose() {
    for (var controller in [
      _nameController,
      _emailController,
      _addressController,
      _cardNumberController,
      _expiryController,
      _cvvController,
      _cardHolderController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildOrderSummary(theme),
            _buildPaymentMethod(theme),
            _buildDeliveryDetails(theme),
            _buildPlaceOrderButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_cartManager.items.length, (index) {
            final item = _cartManager.items[index];
            final product = item.product!;
            final price = product.discountPrice ?? product.price;

            return Padding(
              padding: EdgeInsets.only(bottom: index < _cartManager.items.length - 1 ? 12 : 0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: product.image != null && product.fullImageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.fullImageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.image_not_supported,
                                color: theme.brightness == Brightness.dark ? Colors.grey[600] : Colors.grey[400],
                                size: 20,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.image_not_supported,
                            color: theme.brightness == Brightness.dark ? Colors.grey[600] : Colors.grey[400],
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'x${item.quantity}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LKR ${(price * item.quantity).toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total (${_cartManager.itemCount} items)',
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'LKR ${_cartManager.totalAmount.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardHolderController,
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.person),
            ),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter cardholder name';
              if (value.trim().length < 2) return 'Name must be at least 2 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              labelText: 'Card Number',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.credit_card),
              hintText: '1234567890123456',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter card number';
              if (value.length != 16) return 'Card number must be 16 digits';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: InputDecoration(
                    labelText: 'MM/YY',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.calendar_today),
                    hintText: '12/25',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4), _ExpiryDateFormatter()],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (value.length != 5 || !value.contains('/')) return 'Format: MM/YY';
                    final parts = value.split('/');
                    final month = int.tryParse(parts[0]);
                    final year = int.tryParse(parts[1]);
                    if (month == null || month < 1 || month > 12) return 'Invalid month';
                    if (year == null) return 'Invalid year';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.lock),
                    hintText: '123',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (value.length != 3) return 'Must be 3 digits';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetails(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), prefixIcon: const Icon(Icons.person)),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your full name';
              if (value.trim().length < 2) return 'Name must be at least 2 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), prefixIcon: const Icon(Icons.email)),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your email';
              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value.trim())) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              setState(() => _isProcessing = true);
              String address = await LocationService().getCurrentAddress();
              _addressController.text = address;
              setState(() => _isProcessing = false);
            },
            icon: const Icon(Icons.my_location),
            label: const Text('Use Current Location'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
              foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(labelText: 'Delivery Address', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), prefixIcon: const Icon(Icons.home)),
            maxLines: 2,
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter your delivery address' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
            disabledBackgroundColor: theme.brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isProcessing
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: theme.brightness == Brightness.dark ? Colors.black : Colors.white)),
                    const SizedBox(width: 12),
                    Text('Processing...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.brightness == Brightness.dark ? Colors.black : Colors.white)),
                  ],
                )
              : Text(
                  'Place Order • LKR ${_cartManager.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.brightness == Brightness.dark ? Colors.black : Colors.white),
                ),
        ),
      ),
    );
  }

  void _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);

      try {
        print('Starting authentication...');
        
        final bool canCheckBiometrics = await _auth.canCheckBiometrics;
        final bool isDeviceSupported = await _auth.isDeviceSupported();
        final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();

        print('Can check: $canCheckBiometrics, Supported: $isDeviceSupported');
        print('Available: $availableBiometrics');

        if (!canCheckBiometrics || !isDeviceSupported || availableBiometrics.isEmpty) {
          print('No biometric available - proceeding without auth');
          final proceed = await _showNoBiometricDialog();
          if (!proceed) {
            setState(() => _isProcessing = false);
            return;
          }
        } else {
          print('Attempting biometric authentication...');
          bool didAuthenticate = false;
          
          try {
            didAuthenticate = await _auth.authenticate(
              localizedReason: 'Scan your fingerprint to confirm your order',
              options: const AuthenticationOptions(
                stickyAuth: true,
                biometricOnly: false,
              ),
            );
            print('Authentication result: $didAuthenticate');
          } on PlatformException catch (e) {
            print('PlatformException during auth: ${e.code} - ${e.message}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Authentication error: ${e.message ?? e.code}')),
              );
            }
            setState(() => _isProcessing = false);
            return;
          }

          if (!didAuthenticate) {
            print('User cancelled authentication');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Authentication cancelled')),
              );
            }
            setState(() => _isProcessing = false);
            return;
          }
        }

        // Proceed with order
        print('Authentication successful - placing order');
        await Future.delayed(const Duration(seconds: 2));
        await _cartManager.clearCart();

        if (mounted) {
          setState(() => _isProcessing = false);
          _showSuccessDialog();
        }
      } catch (e) {
        print('Unexpected error: $e');
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<bool> _showNoBiometricDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Biometric Available'),
        content: const Text('Fingerprint authentication is not available. Proceed without it?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Proceed'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccessDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 80, height: 80, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 40)),
              const SizedBox(height: 24),
              Text('Order Placed Successfully!', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('Thank you for your purchase. You will receive your delivery details soon.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600]), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Continue Shopping', style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.black : Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length >= 2) {
      final month = text.substring(0, 2);
      final year = text.length > 2 ? text.substring(2) : '';
      final formattedText = year.isEmpty ? '$month/' : '$month/$year';
      return TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
    return newValue;
  }
}