// lib/features/auth/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
 const ForgotPasswordScreen({super.key});

 @override
 State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
 final _formKey = GlobalKey<FormState>();
 final _emailController = TextEditingController();
 bool _isLoading = false;
 bool _emailSent = false;

 @override
 void dispose() {
   _emailController.dispose();
   super.dispose();
 }

 Future<void> _handleResetPassword() async {
   if (!_formKey.currentState!.validate()) return;

   setState(() => _isLoading = true);

   try {
     await FirebaseAuth.instance.sendPasswordResetEmail(
       email: _emailController.text.trim(),
     );

     if (!mounted) return;
     
     setState(() => _emailSent = true);

     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
         content: Text('Password reset email sent. Please check your inbox.'),
         backgroundColor: AppColors.success,
         behavior: SnackBarBehavior.floating,
       ),
     );

   } on FirebaseAuthException catch (e) {
     String message;
     switch (e.code) {
       case 'user-not-found':
         message = 'No user found with this email.';
         break;
       case 'invalid-email':
         message = 'The email address is not valid.';
         break;
       default:
         message = 'An error occurred. Please try again.';
     }
     
     if (!mounted) return;
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text(message),
         backgroundColor: AppColors.error,
         behavior: SnackBarBehavior.floating,
       ),
     );
   } catch (e) {
     if (!mounted) return;
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
         content: Text('An error occurred. Please try again.'),
         backgroundColor: AppColors.error,
         behavior: SnackBarBehavior.floating,
       ),
     );
   } finally {
     if (mounted) {
       setState(() => _isLoading = false);
     }
   }
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: AppColors.background,
     appBar: AppBar(
       backgroundColor: Colors.transparent,
       elevation: 0,
       leading: IconButton(
         icon: const Icon(Icons.arrow_back_ios),
         color: AppColors.textPrimary,
         onPressed: () => Navigator.pop(context),
       ),
     ),
     body: SafeArea(
       child: Center(
         child: SingleChildScrollView(
           padding: const EdgeInsets.all(24.0),
           child: Form(
             key: _formKey,
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 // Icon
                 Icon(
                   _emailSent ? Icons.check_circle : Icons.lock_reset,
                   size: 80,
                   color: _emailSent ? AppColors.success : AppColors.primary,
                 ),
                 const SizedBox(height: 24),

                 // Title
                 Text(
                   _emailSent ? 'Email Sent!' : 'Reset Password',
                   style: AppTextStyles.heading2,
                   textAlign: TextAlign.center,
                 ),
                 const SizedBox(height: 8),

                 // Description
                 Text(
                   _emailSent
                       ? 'Please check your email for instructions to reset your password.'
                       : 'Enter your email address and we\'ll send you instructions to reset your password.',
                   style: AppTextStyles.body2,
                   textAlign: TextAlign.center,
                 ),
                 const SizedBox(height: 32),

                 if (!_emailSent) ...[
                   // Email Field
                   CustomTextField(
                     controller: _emailController,
                     label: 'Email',
                     hint: 'Enter your email',
                     keyboardType: TextInputType.emailAddress,
                     prefix: const Icon(Icons.email_outlined),
                     validator: Validators.validateEmail,
                     textInputAction: TextInputAction.done,
                     onSubmitted: (_) => _handleResetPassword(),
                   ),
                   const SizedBox(height: 24),

                   // Reset Button
                   CustomButton(
                     text: 'Send Reset Link',
                     onPressed: _handleResetPassword,
                     isLoading: _isLoading,
                   ),
                 ] else ...[
                   // Return to Login Button
                   CustomButton(
                     text: 'Return to Login',
                     onPressed: () {
                       Navigator.pop(context);
                     },
                   ),
                 ],

                 const SizedBox(height: 24),

                 // Additional Help Text
                 if (!_emailSent)
                   Center(
                     child: TextButton(
                       onPressed: () {
                         // You could add customer support here
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(
                             content: Text('Contact support@mindsense.com for help'),
                             behavior: SnackBarBehavior.floating,
                           ),
                         );
                       },
                       child: Text(
                         'Need help?',
                         style: AppTextStyles.body2.copyWith(
                           color: AppColors.primary,
                         ),
                       ),
                     ),
                   ),
               ],
             ),
           ),
         ),
       ),
     ),
   );
 }
}