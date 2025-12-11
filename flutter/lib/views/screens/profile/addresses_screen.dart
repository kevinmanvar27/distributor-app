import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/checkout_controller.dart';
import '../../widgets/widgets.dart';

/// Addresses Screen - Manage shipping/billing addresses
class AddressesScreen extends StatelessWidget {
  final bool isSelectionMode;
  final String? addressType; // 'shipping' or 'billing'

  const AddressesScreen({
    super.key,
    this.isSelectionMode = false,
    this.addressType,
  });

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectionMode
            ? 'Select ${addressType?.capitalize ?? ''} Address'
            : 'My Addresses'),
        actions: [
          if (!isSelectionMode)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddressForm(context),
            ),
        ],
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final addresses = profileController.addresses;

        if (addresses.isEmpty) {
          return EmptyState(
            icon: Icons.location_off,
            title: 'No Addresses',
            message: 'Add your first address to get started',
            actionLabel: 'Add Address',
            onAction: () => _showAddressForm(context),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            final address = addresses[index];
            return _AddressCard(
              address: address,
              isSelectionMode: isSelectionMode,
              onSelect: isSelectionMode
                  ? () {
                      if (addressType == 'shipping') {
                        Get.find<CheckoutController>()
                            .selectShippingAddress(address);
                      } else if (addressType == 'billing') {
                        Get.find<CheckoutController>()
                            .selectBillingAddress(address);
                      }
                      Get.back();
                    }
                  : null,
              onEdit: () => _showAddressForm(context, address: address),
              onDelete: () => _confirmDelete(context, address),
              onSetDefault: () => profileController.setDefaultAddress(
                address['id'],
                addressType ?? 'shipping',
              ),
            );
          },
        );
      }),
      floatingActionButton: isSelectionMode
          ? FloatingActionButton.extended(
              onPressed: () => _showAddressForm(context),
              icon: const Icon(Icons.add),
              label: const Text('New Address'),
            )
          : null,
    );
  }

  void _showAddressForm(BuildContext context, {Map<String, dynamic>? address}) {
    Get.to(() => AddressFormScreen(address: address));
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.find<ProfileController>().deleteAddress(address['id']);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Map<String, dynamic> address;
  final bool isSelectionMode;
  final VoidCallback? onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    this.isSelectionMode = false,
    this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final isDefault = address['is_default'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isSelectionMode ? onSelect : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          address['label'] ?? 'Address',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!isSelectionMode)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit();
                            break;
                          case 'delete':
                            onDelete();
                            break;
                          case 'default':
                            onSetDefault();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        if (!isDefault)
                          const PopupMenuItem(
                            value: 'default',
                            child: Row(
                              children: [
                                Icon(Icons.star, size: 20),
                                SizedBox(width: 8),
                                Text('Set as Default'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                address['name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                address['address_line_1'] ?? '',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (address['address_line_2']?.isNotEmpty == true)
                Text(
                  address['address_line_2'],
                  style: TextStyle(color: Colors.grey[600]),
                ),
              Text(
                '${address['city'] ?? ''}, ${address['state'] ?? ''} ${address['postal_code'] ?? ''}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                address['country'] ?? '',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (address['phone']?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      address['phone'],
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
              if (isSelectionMode) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onSelect,
                    child: const Text('Select This Address'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Address Form Screen - Add/Edit address
class AddressFormScreen extends StatefulWidget {
  final Map<String, dynamic>? address;

  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  bool get isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _labelController.text = widget.address!['label'] ?? '';
      _nameController.text = widget.address!['name'] ?? '';
      _phoneController.text = widget.address!['phone'] ?? '';
      _addressLine1Controller.text = widget.address!['address_line_1'] ?? '';
      _addressLine2Controller.text = widget.address!['address_line_2'] ?? '';
      _cityController.text = widget.address!['city'] ?? '';
      _stateController.text = widget.address!['state'] ?? '';
      _postalCodeController.text = widget.address!['postal_code'] ?? '';
      _countryController.text = widget.address!['country'] ?? '';
      _isDefault = widget.address!['is_default'] == true;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Address' : 'Add Address'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Label
            CustomTextField(
              controller: _labelController,
              label: 'Label',
              hint: 'e.g., Home, Office, Warehouse',
              prefixIcon: Icons.label,
            ),
            const SizedBox(height: 16),

            // Name
            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Recipient name',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone
            PhoneTextField(
              controller: _phoneController,
              label: 'Phone Number',
            ),
            const SizedBox(height: 16),

            // Address Line 1
            CustomTextField(
              controller: _addressLine1Controller,
              label: 'Address Line 1',
              hint: 'Street address',
              prefixIcon: Icons.location_on,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Address Line 2
            CustomTextField(
              controller: _addressLine2Controller,
              label: 'Address Line 2 (Optional)',
              hint: 'Apartment, suite, unit, etc.',
              prefixIcon: Icons.apartment,
            ),
            const SizedBox(height: 16),

            // City and State
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _cityController,
                    label: 'City',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _stateController,
                    label: 'State/Province',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Postal Code and Country
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _postalCodeController,
                    label: 'Postal Code',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _countryController,
                    label: 'Country',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Default checkbox
            CheckboxListTile(
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value ?? false),
              title: const Text('Set as default address'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // Save button
            CustomButton(
              text: isEditing ? 'Update Address' : 'Save Address',
              onPressed: _saveAddress,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final addressData = {
      'label': _labelController.text,
      'name': _nameController.text,
      'phone': _phoneController.text,
      'address_line_1': _addressLine1Controller.text,
      'address_line_2': _addressLine2Controller.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'postal_code': _postalCodeController.text,
      'country': _countryController.text,
      'is_default': _isDefault,
    };

    try {
      final profileController = Get.find<ProfileController>();
      
      if (isEditing) {
        await profileController.updateAddress(
          widget.address!['id'],
          addressData,
        );
      } else {
        await profileController.addAddress(addressData);
      }

      Get.back();
      Get.snackbar(
        'Success',
        isEditing ? 'Address updated' : 'Address added',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
