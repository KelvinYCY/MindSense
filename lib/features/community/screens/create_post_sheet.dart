import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../services/post_service.dart';
import '../models/post_model.dart';

class CreatePostSheet extends StatefulWidget {
 const CreatePostSheet({Key? key}) : super(key: key);

 @override
 State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
 final TextEditingController _contentController = TextEditingController();
 final PostService _postService = PostService();
 final FirebaseAuth _auth = FirebaseAuth.instance;
 final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 final ImagePicker _imagePicker = ImagePicker();
 
 bool _isLoading = false;
 File? _selectedImage;
 int? _meditationMinutes;

 @override
 void dispose() {
   _contentController.dispose();
   super.dispose();
 }

 Future<void> _pickImage() async {
   try {
     final XFile? image = await _imagePicker.pickImage(
       source: ImageSource.gallery,
       maxWidth: 1080,
       maxHeight: 1080,
       imageQuality: 85,
     );

     if (image != null) {
       setState(() {
         _selectedImage = File(image.path);
       });
     }
   } catch (e) {
     _showErrorSnackBar('Error picking image: $e');
   }
 }

 Future<String?> _uploadImage(String userId) async {
   if (_selectedImage == null) return null;

   try {
     final String fileName = path.basename(_selectedImage!.path);
     final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
     final String uniqueFileName = '${timestamp}_$fileName';
     
     final Reference storageRef = FirebaseStorage.instance
         .ref()
         .child('post_images')
         .child(userId)
         .child(uniqueFileName);

     final UploadTask uploadTask = storageRef.putFile(_selectedImage!);
     final TaskSnapshot snapshot = await uploadTask;
     
     return await snapshot.ref.getDownloadURL();
   } catch (e) {
     debugPrint('Error uploading image: $e');
     return null;
   }
 }

 void _showMeditationTimePicker() {
   showDialog(
     context: context,
     builder: (context) => AlertDialog(
       title: const Text('Add Meditation Time'),
       content: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           const Text('How long did you meditate?'),
           const SizedBox(height: 16),
           Wrap(
             spacing: 8,
             alignment: WrapAlignment.center,
             children: [5, 10, 15, 20, 30].map((minutes) {
               return ElevatedButton(
                 onPressed: () {
                   setState(() => _meditationMinutes = minutes);
                   Navigator.pop(context);
                 },
                 child: Text('$minutes min'),
                 style: ElevatedButton.styleFrom(
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(20),
                   ),
                 ),
               );
             }).toList(),
           ),
         ],
       ),
     ),
   );
 }

 Future<void> _createPost() async {
   if (_contentController.text.trim().isEmpty) {
     _showErrorSnackBar('Please enter some content');
     return;
   }

   setState(() => _isLoading = true);

   try {
     final user = _auth.currentUser;
     if (user == null) {
       _showErrorSnackBar('Please sign in to post');
       return;
     }

     final userDoc = await _firestore.collection('users').doc(user.uid).get();
     if (!userDoc.exists) {
       _showErrorSnackBar('User profile not found');
       return;
     }

     final userData = userDoc.data() as Map<String, dynamic>;

     String? imageUrl;
     if (_selectedImage != null) {
       imageUrl = await _uploadImage(user.uid);
     }

     final post = PostModel.create(
       uid: user.uid,
       name: userData['name'] ?? 'Anonymous',
       userAvatar: userData['profilePicture'] ?? 'https://via.placeholder.com/150',
       content: _contentController.text.trim(),
       imageUrl: imageUrl,
       meditationMinutes: _meditationMinutes,
     );

     await _postService.createPost(post);

     if (mounted) {
       Navigator.pop(context);
     }
   } catch (e) {
     _showErrorSnackBar('Error creating post: $e');
   } finally {
     if (mounted) {
       setState(() => _isLoading = false);
     }
   }
 }

 void _showErrorSnackBar(String message) {
   if (!mounted) return;
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
       content: Text(message),
       backgroundColor: Colors.red,
     ),
   );
 }

 Widget _buildHeader() {
   return Container(
     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
     decoration: BoxDecoration(
       color: Colors.white,
       borderRadius: const BorderRadius.only(
         topLeft: Radius.circular(20),
         topRight: Radius.circular(20),
       ),
       boxShadow: [
         BoxShadow(
           color: Colors.grey.withOpacity(0.1),
           spreadRadius: 1,
           blurRadius: 1,
         ),
       ],
     ),
     child: Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
         const Text(
           'Create Post',
           style: TextStyle(
             fontSize: 20,
             fontWeight: FontWeight.bold,
           ),
         ),
         IconButton(
           icon: const Icon(Icons.close),
           onPressed: () => Navigator.pop(context),
         ),
       ],
     ),
   );
 }

 Widget _buildContent() {
   return Padding(
     padding: const EdgeInsets.all(16),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.stretch,
       children: [
         TextField(
           controller: _contentController,
           maxLines: 5,
           maxLength: 500,
           decoration: InputDecoration(
             hintText: 'Share your meditation experience...',
             hintStyle: TextStyle(color: Colors.grey[400]),
             border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(12),
               borderSide: BorderSide(color: Colors.grey[300]!),
             ),
             focusedBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(12),
               borderSide: BorderSide(color: Theme.of(context).primaryColor),
             ),
             contentPadding: const EdgeInsets.all(16),
           ),
         ),
         const SizedBox(height: 16),
         _buildImagePreview(),
         const SizedBox(height: 16),
         _buildActionButtons(),
       ],
     ),
   );
 }

 Widget _buildImagePreview() {
   if (_selectedImage == null) return const SizedBox.shrink();

   return Stack(
     children: [
       ClipRRect(
         borderRadius: BorderRadius.circular(12),
         child: Image.file(
           _selectedImage!,
           height: 200,
           width: double.infinity,
           fit: BoxFit.cover,
         ),
       ),
       Positioned(
         top: 8,
         right: 8,
         child: GestureDetector(
           onTap: () => setState(() => _selectedImage = null),
           child: Container(
             padding: const EdgeInsets.all(4),
             decoration: const BoxDecoration(
               color: Colors.black54,
               shape: BoxShape.circle,
             ),
             child: const Icon(
               Icons.close,
               color: Colors.white,
               size: 20,
             ),
           ),
         ),
       ),
     ],
   );
 }

 Widget _buildActionButtons() {
   return Row(
     children: [
       IconButton(
         icon: const Icon(Icons.image_outlined),
         onPressed: _pickImage,
         color: Theme.of(context).primaryColor,
         tooltip: 'Add Image',
       ),
       IconButton(
         icon: const Icon(Icons.timer_outlined),
         onPressed: _showMeditationTimePicker,
         color: Theme.of(context).primaryColor,
         tooltip: 'Add Meditation Time',
       ),
       if (_meditationMinutes != null)
         Chip(
           label: Text('$_meditationMinutes min'),
           onDeleted: () => setState(() => _meditationMinutes = null),
         ),
       const Spacer(),
       ElevatedButton(
         onPressed: _isLoading ? null : _createPost,
         style: ElevatedButton.styleFrom(
           padding: const EdgeInsets.symmetric(
             horizontal: 24,
             vertical: 12,
           ),
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(20),
           ),
         ),
         child: _isLoading
             ? const SizedBox(
                 width: 20,
                 height: 20,
                 child: CircularProgressIndicator(
                   strokeWidth: 2,
                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                 ),
               )
             : const Text('Post'),
       ),
     ],
   );
 }

 @override
 Widget build(BuildContext context) {
   return Container(
     padding: EdgeInsets.only(
       bottom: MediaQuery.of(context).viewInsets.bottom,
     ),
     decoration: const BoxDecoration(
       color: Colors.white,
       borderRadius: BorderRadius.only(
         topLeft: Radius.circular(20),
         topRight: Radius.circular(20),
       ),
     ),
     child: Column(
       mainAxisSize: MainAxisSize.min,
       children: [
         _buildHeader(),
         _buildContent(),
       ],
     ),
   );
 }
}