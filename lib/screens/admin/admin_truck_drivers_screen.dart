import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/truck_driver.dart';
import '../../services/truck_driver_service.dart';
import '../../widgets/feature/truck_driver_form.dart';
import '../../widgets/feature/truck_driver_tile.dart';
import '../../widgets/ui/delete_confirm_dialog.dart';
import '../../widgets/ui/password_reset_dialog.dart';

class AdminTruckDriversScreen extends StatefulWidget {
  const AdminTruckDriversScreen({super.key});

  @override
  State<AdminTruckDriversScreen> createState() =>
      _AdminTruckDriversScreenState();
}

class _AdminTruckDriversScreenState extends State<AdminTruckDriversScreen> {
  final _truckDriverService = TruckDriverService();
  
  bool _isLoadingDrivers = false;
  bool _isProcessing = false;
  bool _showCreateForm = false;
  List<TruckDriver> _drivers = [];

  @override
  void initState() {
    super.initState();
    _loadTruckDrivers();
  }

  Future<void> _loadTruckDrivers() async {
    setState(() => _isLoadingDrivers = true);

    try {
      final result = await _truckDriverService.getAllTruckDrivers();
      if (result.success) {
        final List<dynamic> driversList = result.data as List<dynamic>;
        setState(() {
          _drivers = driversList
              .map((driver) => TruckDriver.fromJson(driver as Map<String, dynamic>))
              .toList();
        });
      } else {
        if (mounted) {
          _showSnackBar(result.error ?? 'Failed to load truck drivers', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error loading drivers: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingDrivers = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(8, (index) => chars[(random + index) % chars.length]).join();
  }

  Future<void> _handleCreateDriver(
    String phone,
    String barangay,
    String? password,
  ) async {
    setState(() => _isProcessing = true);

    try {
      final result = await _truckDriverService.createTruckDriver(
        phone: phone,
        password: password ?? _generatePassword(),
        barangay: barangay,
      );

      if (mounted) {
        if (result.success) {
          _showSuccessDialog(phone, barangay, password ?? _generatePassword());
          await _loadTruckDrivers();
        } else {
          _showSnackBar(result.error ?? 'Failed to create driver account', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('An error occurred: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSuccessDialog(String phone, String barangay, String password) {
    final driverName = 'Truck Driver for $barangay';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryGreen,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Driver Account Created',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Account for $driverName has been successfully created.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Details:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Name: $driverName'),
                      Text('Phone: $phone'),
                      Text('Password: $password'),
                      Text('Barangay: $barangay'),
                      const Text('Role: Truck Driver'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() => _showCreateForm = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleUpdateDriver(TruckDriver driver, String phone, String barangay, String? _) async {
    setState(() => _isProcessing = true);

    try {
      final result = await _truckDriverService.updateTruckDriver(
        driverId: driver.id,
        phone: phone,
        barangay: barangay,
      );

      if (mounted) {
        if (result.success) {
          _showSnackBar('Driver updated successfully');
          await _loadTruckDrivers();
        } else {
          _showSnackBar(result.error ?? 'Failed to update driver', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showEditDialog(TruckDriver driver) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: TruckDriverForm(
              driver: driver,
              onSubmit: (phone, barangay, password) {
                Navigator.of(context).pop();
                _handleUpdateDriver(driver, phone, barangay, password);
              },
              isLoading: _isProcessing,
            ),
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog(TruckDriver driver) {
    showDialog(
      context: context,
      builder: (context) => PasswordResetDialog(
        driverName: driver.fullName,
        onGeneratePassword: _generatePassword,
        onConfirm: (password) => _resetPassword(driver.id, password),
      ),
    );
  }

  Future<void> _resetPassword(String driverId, String newPassword) async {
    try {
      final result = await _truckDriverService.resetTruckDriverPassword(
        driverId: driverId,
        newPassword: newPassword,
      );

      if (mounted) {
        if (result.success) {
          showDialog(
            context: context,
            builder: (context) => PasswordResetSuccessDialog(password: newPassword),
          );
        } else {
          _showSnackBar(result.error ?? 'Failed to reset password', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    }
  }

  void _showDeleteDialog(TruckDriver driver) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        title: 'Delete Driver Account',
        message: 'Are you sure you want to delete ${driver.fullName}\'s account? This action cannot be undone.',
        onConfirm: () => _deleteDriver(driver.id),
      ),
    );
  }

  Future<void> _deleteDriver(String driverId) async {
    try {
      final result = await _truckDriverService.deleteTruckDriver(driverId);

      if (mounted) {
        if (result.success) {
          _showSnackBar('Driver deleted successfully');
          await _loadTruckDrivers();
        } else {
          _showSnackBar(result.error ?? 'Failed to delete driver', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Truck Driver Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage driver accounts and assignments',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showCreateForm = !_showCreateForm),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _showCreateForm ? Icons.close : Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Registered Drivers: ${_drivers.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_isLoadingDrivers) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateDriverForm() {
    if (!_showCreateForm) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TruckDriverForm(
        onSubmit: _handleCreateDriver,
        isLoading: _isProcessing,
      ),
    );
  }

  Widget _buildDriversList() {
    if (_isLoadingDrivers) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
        ),
      );
    }

    if (_drivers.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark.withValues(alpha: 0.1),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No Truck Drivers Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create your first truck driver account to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Registered Truck Drivers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _drivers.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: AppColors.surfaceWhite,
            ),
            itemBuilder: (context, index) {
              final driver = _drivers[index];
              return TruckDriverTile(
                driver: driver,
                onEdit: () => _showEditDialog(driver),
                onResetPassword: () => _showResetPasswordDialog(driver),
                onDelete: () => _showDeleteDialog(driver),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildCreateDriverForm(),
              _buildDriversList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

