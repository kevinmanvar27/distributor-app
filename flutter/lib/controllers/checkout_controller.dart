import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/data.dart';
import 'cart_controller.dart';

/// Checkout Controller
/// Manages checkout flow, address selection, payment, and order placement
class CheckoutController extends GetxController {
  final InvoiceRepository _invoiceRepository;
  final CartController _cartController;

  CheckoutController({
    InvoiceRepository? invoiceRepository,
    CartController? cartController,
  })  : _invoiceRepository = invoiceRepository ?? InvoiceRepository(Get.find()),
        _cartController = cartController ?? Get.find<CartController>();

  // Checkout steps
  final RxInt currentStep = 0.obs;
  final RxList<String> steps = <String>[
    'Review',
    'Shipping',
    'Payment',
    'Confirm',
  ].obs;

  // Shipping address
  final Rx<Map<String, dynamic>?> selectedAddress = Rx<Map<String, dynamic>?>(null);
  final RxList<Map<String, dynamic>> savedAddresses = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingAddresses = false.obs;
  
  // New address form
  final addressFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();
  final countryController = TextEditingController();
  final RxBool isDefaultAddress = false.obs;

  // Payment method
  final RxString selectedPaymentMethod = 'credit_terms'.obs;
  final RxList<Map<String, dynamic>> paymentMethods = <Map<String, dynamic>>[
    {
      'id': 'credit_terms',
      'name': 'Credit Terms',
      'description': 'Pay within your credit terms',
      'icon': Icons.account_balance,
    },
    {
      'id': 'bank_transfer',
      'name': 'Bank Transfer',
      'description': 'Pay via bank transfer',
      'icon': Icons.account_balance_wallet,
    },
    {
      'id': 'cash_on_delivery',
      'name': 'Cash on Delivery',
      'description': 'Pay when you receive the order',
      'icon': Icons.money,
    },
  ].obs;

  // Order notes
  final notesController = TextEditingController();
  final RxString purchaseOrderNumber = ''.obs;
  final poNumberController = TextEditingController();

  // Delivery options
  final RxString selectedDeliveryOption = 'standard'.obs;
  final RxList<Map<String, dynamic>> deliveryOptions = <Map<String, dynamic>>[
    {
      'id': 'standard',
      'name': 'Standard Delivery',
      'description': '5-7 business days',
      'price': 0.0,
    },
    {
      'id': 'express',
      'name': 'Express Delivery',
      'description': '2-3 business days',
      'price': 25.0,
    },
    {
      'id': 'next_day',
      'name': 'Next Day Delivery',
      'description': 'Next business day',
      'price': 50.0,
    },
  ].obs;

  // Order summary
  final RxDouble subtotal = 0.0.obs;
  final RxDouble discount = 0.0.obs;
  final RxDouble shipping = 0.0.obs;
  final RxDouble tax = 0.0.obs;
  final RxDouble total = 0.0.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isPlacingOrder = false.obs;
  final RxBool isSavingAddress = false.obs;

  // Validation
  final RxBool canProceed = false.obs;
  final RxString errorMessage = ''.obs;

  // Created order
  final Rx<ProformaInvoiceModel?> createdOrder = Rx<ProformaInvoiceModel?>(null);

  // Getters
  bool get isFirstStep => currentStep.value == 0;
  bool get isLastStep => currentStep.value == steps.length - 1;
  bool get hasSelectedAddress => selectedAddress.value != null;
  bool get hasSelectedPayment => selectedPaymentMethod.value.isNotEmpty;
  
  double get deliveryPrice {
    final option = deliveryOptions.firstWhereOrNull(
      (o) => o['id'] == selectedDeliveryOption.value,
    );
    return option?['price'] ?? 0.0;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeCheckout();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    notesController.dispose();
    poNumberController.dispose();
    super.onClose();
  }

  /// Initialize checkout
  void _initializeCheckout() {
    _calculateTotals();
    loadSavedAddresses();
    _validateStep();
  }

  /// Calculate order totals
  void _calculateTotals() {
    subtotal.value = _cartController.subtotal;
    discount.value = _cartController.discount;
    tax.value = _cartController.tax;
    shipping.value = deliveryPrice;
    total.value = subtotal.value - discount.value + tax.value + shipping.value;
  }

  /// Load saved addresses
  Future<void> loadSavedAddresses() async {
    isLoadingAddresses.value = true;
    
    try {
      // In a real app, this would fetch from API
      // For now, using mock data
      savedAddresses.value = [
        {
          'id': 1,
          'name': 'Main Office',
          'phone': '+1 234 567 8900',
          'address_line_1': '123 Business Street',
          'address_line_2': 'Suite 100',
          'city': 'New York',
          'state': 'NY',
          'postal_code': '10001',
          'country': 'United States',
          'is_default': true,
        },
        {
          'id': 2,
          'name': 'Warehouse',
          'phone': '+1 234 567 8901',
          'address_line_1': '456 Industrial Ave',
          'address_line_2': '',
          'city': 'New Jersey',
          'state': 'NJ',
          'postal_code': '07001',
          'country': 'United States',
          'is_default': false,
        },
      ];

      // Select default address
      final defaultAddress = savedAddresses.firstWhereOrNull(
        (a) => a['is_default'] == true,
      );
      if (defaultAddress != null) {
        selectedAddress.value = defaultAddress;
      }
    } catch (e) {
      // Silently fail
    } finally {
      isLoadingAddresses.value = false;
    }
  }

  /// Select address
  void selectAddress(Map<String, dynamic> address) {
    selectedAddress.value = address;
    _validateStep();
  }

  /// Add new address
  Future<void> addNewAddress() async {
    if (!addressFormKey.currentState!.validate()) return;

    isSavingAddress.value = true;

    try {
      final newAddress = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': nameController.text,
        'phone': phoneController.text,
        'address_line_1': addressLine1Controller.text,
        'address_line_2': addressLine2Controller.text,
        'city': cityController.text,
        'state': stateController.text,
        'postal_code': postalCodeController.text,
        'country': countryController.text,
        'is_default': isDefaultAddress.value,
      };

      // If set as default, update other addresses
      if (isDefaultAddress.value) {
        for (var address in savedAddresses) {
          address['is_default'] = false;
        }
      }

      savedAddresses.add(newAddress);
      selectedAddress.value = newAddress;
      
      _clearAddressForm();
      Get.back();
      _showSuccess('Address added successfully');
    } catch (e) {
      _showError('Failed to add address');
    } finally {
      isSavingAddress.value = false;
    }
  }

  /// Clear address form
  void _clearAddressForm() {
    nameController.clear();
    phoneController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    cityController.clear();
    stateController.clear();
    postalCodeController.clear();
    countryController.clear();
    isDefaultAddress.value = false;
  }

  /// Select payment method
  void selectPaymentMethod(String methodId) {
    selectedPaymentMethod.value = methodId;
    _validateStep();
  }

  /// Select delivery option
  void selectDeliveryOption(String optionId) {
    selectedDeliveryOption.value = optionId;
    _calculateTotals();
  }

  /// Update purchase order number
  void updatePONumber(String value) {
    purchaseOrderNumber.value = value;
  }

  /// Go to next step
  void nextStep() {
    if (!_validateCurrentStep()) return;
    
    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
      _validateStep();
    }
  }

  /// Go to previous step
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      _validateStep();
    }
  }

  /// Go to specific step
  void goToStep(int step) {
    if (step >= 0 && step < steps.length) {
      currentStep.value = step;
      _validateStep();
    }
  }

  /// Validate current step
  bool _validateCurrentStep() {
    switch (currentStep.value) {
      case 0: // Review
        if (_cartController.items.isEmpty) {
          _showError('Your cart is empty');
          return false;
        }
        return true;
        
      case 1: // Shipping
        if (selectedAddress.value == null) {
          _showError('Please select a shipping address');
          return false;
        }
        return true;
        
      case 2: // Payment
        if (selectedPaymentMethod.value.isEmpty) {
          _showError('Please select a payment method');
          return false;
        }
        return true;
        
      case 3: // Confirm
        return true;
        
      default:
        return true;
    }
  }

  /// Validate step for UI
  void _validateStep() {
    switch (currentStep.value) {
      case 0:
        canProceed.value = _cartController.items.isNotEmpty;
        break;
      case 1:
        canProceed.value = selectedAddress.value != null;
        break;
      case 2:
        canProceed.value = selectedPaymentMethod.value.isNotEmpty;
        break;
      case 3:
        canProceed.value = true;
        break;
    }
  }

  /// Place order
  Future<void> placeOrder() async {
    if (!_validateCurrentStep()) return;

    isPlacingOrder.value = true;
    errorMessage.value = '';

    try {
      // Prepare order data
      final orderData = {
        'items': _cartController.items.map((item) => {
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.price,
          'notes': item.notes,
        }).toList(),
        'shipping_address': selectedAddress.value,
        'payment_method': selectedPaymentMethod.value,
        'delivery_option': selectedDeliveryOption.value,
        'notes': notesController.text,
        'purchase_order_number': purchaseOrderNumber.value,
        'subtotal': subtotal.value,
        'discount': discount.value,
        'shipping': shipping.value,
        'tax': tax.value,
        'total': total.value,
        'coupon_code': _cartController.appliedCoupon.value,
      };

      // Create proforma invoice
      final order = await _invoiceRepository.createInvoice(orderData);
      createdOrder.value = order;

      // Clear cart
      await _cartController.clearCart();

      // Navigate to success
      Get.offNamed('/order-success', arguments: order);
      
      _showSuccess('Order placed successfully!');
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      _showError(e.message);
    } catch (e) {
      errorMessage.value = 'Failed to place order';
      _showError('Failed to place order');
    } finally {
      isPlacingOrder.value = false;
    }
  }

  /// Get cart items from cart controller
  List<CartItemModel> get cartItems => _cartController.items;

  /// Get applied coupon
  String? get appliedCoupon => _cartController.appliedCoupon.value;

  /// Format address for display
  String formatAddress(Map<String, dynamic> address) {
    final parts = <String>[];
    
    if (address['address_line_1']?.isNotEmpty == true) {
      parts.add(address['address_line_1']);
    }
    if (address['address_line_2']?.isNotEmpty == true) {
      parts.add(address['address_line_2']);
    }
    if (address['city']?.isNotEmpty == true) {
      parts.add(address['city']);
    }
    if (address['state']?.isNotEmpty == true) {
      parts.add(address['state']);
    }
    if (address['postal_code']?.isNotEmpty == true) {
      parts.add(address['postal_code']);
    }
    if (address['country']?.isNotEmpty == true) {
      parts.add(address['country']);
    }
    
    return parts.join(', ');
  }

  /// Show new address dialog
  void showNewAddressDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Add New Address'),
        content: SingleChildScrollView(
          child: Form(
            key: addressFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Address Name'),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                TextFormField(
                  controller: addressLine1Controller,
                  decoration: const InputDecoration(labelText: 'Address Line 1'),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                TextFormField(
                  controller: addressLine2Controller,
                  decoration: const InputDecoration(labelText: 'Address Line 2'),
                ),
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                TextFormField(
                  controller: stateController,
                  decoration: const InputDecoration(labelText: 'State'),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                TextFormField(
                  controller: postalCodeController,
                  decoration: const InputDecoration(labelText: 'Postal Code'),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                TextFormField(
                  controller: countryController,
                  decoration: const InputDecoration(labelText: 'Country'),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                Obx(() => CheckboxListTile(
                  title: const Text('Set as default'),
                  value: isDefaultAddress.value,
                  onChanged: (v) => isDefaultAddress.value = v ?? false,
                )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: isSavingAddress.value ? null : addNewAddress,
            child: isSavingAddress.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          )),
        ],
      ),
    );
  }

  /// Show success snackbar
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show error snackbar
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 3),
    );
  }
}
