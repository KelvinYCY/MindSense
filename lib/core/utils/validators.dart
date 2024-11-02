class Validators {
 static String? validateEmail(String? value) {
   if (value == null || value.isEmpty) {
     return 'Email is required';
   }
   
   final emailPattern = RegExp(
     r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
   );
   
   if (!emailPattern.hasMatch(value)) {
     return 'Please enter a valid email';
   }
   
   return null;
 }

 static String? validatePassword(String? value) {
   if (value == null || value.isEmpty) {
     return 'Password is required';
   }
   
   if (value.length < 6) {
     return 'Password must be at least 6 characters';
   }
   
   return null;
 }

 static String? validateName(String? value) {
   if (value == null || value.isEmpty) {
     return 'Name is required';
   }
   
   if (value.length < 2) {
     return 'Name must be at least 2 characters';
   }
   
   return null;
 }

 static String? validateRequired(String? value, String fieldName) {
   if (value == null || value.trim().isEmpty) {
     return '$fieldName is required';
   }
   return null;
 }

 static String? validatePhone(String? value) {
   if (value == null || value.isEmpty) {
     return null;  // Phone is optional
   }
   
   final phonePattern = RegExp(r'^\+?[\d\s-]{10,}$');
   if (!phonePattern.hasMatch(value)) {
     return 'Please enter a valid phone number';
   }
   
   return null;
 }

 static String? validateUrl(String? value) {
   if (value == null || value.isEmpty) {
     return null;  // URL is optional
   }
   
   final urlPattern = RegExp(
     r'^(http|https)://[a-zA-Z0-9-_.]+\.[a-zA-Z]{2,}[a-zA-Z0-9-_%&\?/.=]*$',
   );
   
   if (!urlPattern.hasMatch(value)) {
     return 'Please enter a valid URL';
   }
   
   return null;
 }

 static String? validateConfirmPassword(String? value, String? password) {
   if (value == null || value.isEmpty) {
     return 'Please confirm your password';
   }
   
   if (value != password) {
     return 'Passwords do not match';
   }
   
   return null;
 }

 static String? validateMinLength(String? value, int minLength, String fieldName) {
   if (value == null || value.isEmpty) {
     return '$fieldName is required';
   }
   
   if (value.length < minLength) {
     return '$fieldName must be at least $minLength characters';
   }
   
   return null;
 }

 static String? validateMaxLength(String? value, int maxLength, String fieldName) {
   if (value == null || value.isEmpty) {
     return null;  // Optional field
   }
   
   if (value.length > maxLength) {
     return '$fieldName cannot exceed $maxLength characters';
   }
   
   return null;
 }
}