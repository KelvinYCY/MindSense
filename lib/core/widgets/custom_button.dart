// lib/core/widgets/custom_button.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
 final String text;
 final VoidCallback onPressed;
 final bool isLoading;
 final Color? backgroundColor;
 final Color? textColor;
 final double? width;
 final double height;
 final bool outlined;
 final IconData? icon;
 final double borderRadius;

 const CustomButton({
   super.key,
   required this.text,
   required this.onPressed,
   this.isLoading = false,
   this.backgroundColor,
   this.textColor,
   this.width,
   this.height = 48,
   this.outlined = false,
   this.icon,
   this.borderRadius = 24,
 });

 @override
 Widget build(BuildContext context) {
   final defaultBgColor = outlined ? Colors.transparent : AppColors.primary;
   final defaultTextColor = outlined ? AppColors.primary : Colors.white;

   return SizedBox(
     width: width,
     height: height,
     child: ElevatedButton(
       onPressed: isLoading ? null : onPressed,
       style: ElevatedButton.styleFrom(
         backgroundColor: backgroundColor ?? defaultBgColor,
         foregroundColor: textColor ?? defaultTextColor,
         elevation: outlined ? 0 : 2,
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(borderRadius),
           side: outlined 
               ? BorderSide(color: backgroundColor ?? AppColors.primary)
               : BorderSide.none,
         ),
         padding: const EdgeInsets.symmetric(horizontal: 24),
       ),
       child: isLoading
           ? const SizedBox(
               height: 20,
               width: 20,
               child: CircularProgressIndicator(
                 strokeWidth: 2,
                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
               ),
             )
           : Row(
               mainAxisSize: MainAxisSize.min,
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 if (icon != null) ...[
                   Icon(icon, size: 20),
                   const SizedBox(width: 8),
                 ],
                 Text(
                   text,
                   style: AppTextStyles.button.copyWith(
                     color: textColor ?? defaultTextColor,
                   ),
                 ),
               ],
             ),
     ),
   );
 }
}