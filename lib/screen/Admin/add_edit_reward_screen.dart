// screens/Admin/add_edit_reward_screen.dart
import 'package:flutter/material.dart';
import '../../Model/reward_item.dart';

class AddEditRewardScreen extends StatefulWidget {
  final RewardItem? itemToEdit;
  const AddEditRewardScreen({super.key, this.itemToEdit});

  @override
  State<AddEditRewardScreen> createState() => _AddEditRewardScreenState();
}

class _AddEditRewardScreenState extends State<AddEditRewardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _costController;
  // ADDED: Controller for the image URL
  late TextEditingController _imageUrlController;

  bool get _isEditing => widget.itemToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.itemToEdit?.itemName);
    _descriptionController = TextEditingController(text: widget.itemToEdit?.description);
    _costController = TextEditingController(text: widget.itemToEdit?.cost.toString());
    // ADDED: Initialize the new controller
    _imageUrlController = TextEditingController(text: widget.itemToEdit?.imageUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _imageUrlController.dispose(); // ADDED: Dispose the new controller
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newItem = RewardItem(
        id: widget.itemToEdit?.id ?? '',
        itemName: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        cost: int.parse(_costController.text.trim()),
        // ADDED: Get the URL from the controller
        imageUrl: _imageUrlController.text.trim(),
      );
      Navigator.of(context).pop(newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Reward' : 'Add Reward'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name*'),
                validator: (v) => v!.isEmpty ? 'Name is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description*'),
                validator: (v) => v!.isEmpty ? 'Description is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Cost (Points)*'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Cost is required.';
                  if (int.tryParse(v) == null) return 'Please enter a valid number.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // ADDED: New TextFormField for the image URL
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                  hintText: 'https://example.com/image.png'
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text(_isEditing ? 'UPDATE ITEM' : 'ADD ITEM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}