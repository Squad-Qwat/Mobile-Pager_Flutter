import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pager_flutter/core/constants/app_routes.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/features/authentication/domain/auth_notifier.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(color: AppColor.grey600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoggingOut = true);

    try {
      await ref.read(authNotifierProvider.notifier).signOut();
      
      if (!mounted) return;
      
      // Navigate to login/welcome page - adjust route name as needed
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.authentication,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoggingOut = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal logout: ${e.toString()}'),
          backgroundColor: AppColor.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'merchant':
        return 'Merchant';
      case 'customer':
        return 'Customer';
      case 'guest':
        return 'Guest';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColor.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColor.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar with initial
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColor.primaryLight,
                              width: 3,
                            ),
                          ),
                          child: user.photoURL != null
                              ? ClipOval(
                                  child: Image.network(
                                    user.photoURL!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(
                                        _getInitials(user.displayName),
                                        style: const TextStyle(
                                          color: AppColor.textWhite,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    _getInitials(user.displayName),
                                    style: const TextStyle(
                                      color: AppColor.textWhite,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Display name
                        Text(
                          user.displayName ?? 'Pengguna',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        
                        // Email
                        if (user.email != null)
                          Text(
                            user.email!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColor.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 8),
                        
                        // Role badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: user.isMerchant 
                                ? AppColor.primary.withOpacity(0.1)
                                : AppColor.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: user.isMerchant 
                                  ? AppColor.primary 
                                  : AppColor.info,
                            ),
                          ),
                          child: Text(
                            _getRoleText(user.role),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: user.isMerchant 
                                  ? AppColor.primary 
                                  : AppColor.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Account Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Akun',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildInfoRow(
                          'User ID',
                          user.uid.substring(0, 8) + '...',
                          Icons.badge_outlined,
                        ),
                        
                        if (user.isGuestUser) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Guest ID',
                            user.guestId ?? '-',
                            Icons.person_outline,
                          ),
                        ],
                        
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Auth Provider',
                          user.authProvider == 'google' ? 'Google' : 'Guest',
                          Icons.verified_user_outlined,
                        ),
                        
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Bergabung Sejak',
                          _formatDate(user.createdAt),
                          Icons.calendar_today_outlined,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Logout Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isLoggingOut ? null : _handleLogout,
                      icon: _isLoggingOut
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColor.textWhite,
                                ),
                              ),
                            )
                          : const Icon(Icons.logout),
                      label: Text(
                        _isLoggingOut ? 'Logging out...' : 'Logout',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.error,
                        foregroundColor: AppColor.textWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Version info (optional)
                  Center(
                    child: Text(
                      'Cammo v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColor.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColor.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColor.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}