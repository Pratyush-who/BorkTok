import 'package:flutter/material.dart';

class Bookavetpage extends StatefulWidget {
  const Bookavetpage({super.key});

  @override
  State<Bookavetpage> createState() => _BookavetpageState();
}

class _BookavetpageState extends State<Bookavetpage> {
  // Form key to validate the form
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _petNameController = TextEditingController();
  final _petBreedController = TextEditingController();
  final _reasonController = TextEditingController();
  
  // Variables for selected values
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedPetType = 'Dog';
  
  bool _isSubmitted = false;
  bool _isLoading = false;

  // Pet type options with image paths
  final List<Map<String, dynamic>> _petTypes = [
    {'name': 'Dog', 'imagePath': 'assets/images/dog.png'},
    {'name': 'Cat', 'imagePath': 'assets/images/cat.png'},
    {'name': 'Bird', 'imagePath': 'assets/images/bird.png'},
    {'name': 'Rabbit', 'imagePath': 'assets/images/rabbit.png'},
    {'name': 'Hamster', 'imagePath': 'assets/images/hamster.png'},
    {'name': 'Other', 'imagePath': 'assets/images/other_pet.png'},
  ];

  // Define colors
  final Color _primaryGreen = const Color(0xFF5C8D89);
  final Color _lightBeige = const Color(0xFFF5F5DC);
  final Color _darkBeige = const Color(0xFFE6E6C9);
  final Color _accentColor = const Color(0xFF93B5B3);
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _petNameController.dispose();
    _petBreedController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  // Function to pick date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryGreen,
              onPrimary: Colors.white,
              surface: _lightBeige,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Function to pick time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryGreen,
              onPrimary: Colors.white,
              surface: _lightBeige,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Function to handle form submission
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call or processing delay
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
          _isSubmitted = true;
        });
      });
    }
  }

  // Function to reset form
  void _resetForm() {
    setState(() {
      _isSubmitted = false;
      _nameController.clear();
      _phoneController.clear();
      _petNameController.clear();
      _reasonController.clear();
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _selectedTime = TimeOfDay.now();
      _selectedPetType = 'Dog';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Book a Vet Appointment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isSubmitted 
        ? _buildConfirmationScreen() 
        : _buildAppointmentForm(),
    );
  }

  Widget _buildAppointmentForm() {
    return SingleChildScrollView(
      child: Stack(
        children: [
          // Background design elements
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _primaryGreen,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          
          // Form content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with image
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 30),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/head.png',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Schedule Your Pet\'s Care',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete the form below to book a visit with our experienced veterinarians',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Owner Information Section
                  _buildSectionTitle('Owner Information', Icons.person_outline),
                  
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      } else if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Pet Information Section
                  _buildSectionTitle('Pet Information', Icons.pets),
                  
                  _buildTextField(
                    controller: _petNameController,
                    label: 'Pet Name',
                    icon: Icons.pets,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your pet\'s name';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildTextField(
                    controller: _petBreedController,
                    label: 'Breed of your pet',
                    icon: Icons.pets,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your pet\'s name';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Appointment Details Section
                  _buildSectionTitle('Appointment Details', Icons.calendar_today),
                  
                  Row(
                    children: [
                      // Date Picker
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _accentColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: _primaryGreen,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Time Picker
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _accentColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: _primaryGreen,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _selectedTime.format(context),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Reason for Visit
                  _buildTextField(
                    controller: _reasonController,
                    label: 'Reason for Visit',
                    icon: Icons.medical_services_outlined,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a reason for your visit';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Service types
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _accentColor.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Services',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildServiceTile('Check-up & Vaccination', 'From \$45'),
                        _buildServiceTile('Surgery', 'From \$150'),
                        _buildServiceTile('Dental Care', 'From \$80'),
                        _buildServiceTile('Grooming', 'From \$35'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  _isLoading 
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryGreen.withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                          child: const Text(
                            'Book Appointment',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationScreen() {
    // Confirmation screen code remains unchanged
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              _lightBeige.withOpacity(0.5),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success animation or image
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primaryGreen.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Confirmation details
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Appointment Confirmed!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _primaryGreen,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'We\'re excited to see you and your pet soon',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Appointment date and time
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at ${_selectedTime.format(context)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Please arrive 10 minutes early',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Appointment details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildConfirmationDetail(
                            'Person',
                            _nameController.text,
                            Icons.person,
                          ),
                          Divider(color: Colors.grey.shade200),
                          _buildConfirmationDetail(
                            'Phone',
                            _phoneController.text,
                            Icons.phone,
                          ),
                          Divider(color: Colors.grey.shade200),
                          _buildConfirmationDetail(
                            'Pet',
                            '${_petNameController.text} (${_selectedPetType})',
                            Icons.pets,
                          ),
                          Divider(color: Colors.grey.shade200),
                          _buildConfirmationDetail(
                            'Reason',
                            _reasonController.text,
                            Icons.medical_services_outlined,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: _primaryGreen,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'We\'ll send you a reminder 24 hours before your appointment.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetForm,
                    icon: Icon(Icons.add),
                    label: const Text('Book Another'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryGreen,
                      side: BorderSide(color: _primaryGreen),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to home or dashboard
                      Navigator.pushNamed(context, '/home');
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Go Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for section titles
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for form text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(icon, color: _primaryGreen),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // Helper widget for confirmation details
  Widget _buildConfirmationDetail(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for service tile
  Widget _buildServiceTile(String service, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: _primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            service,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            price,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}