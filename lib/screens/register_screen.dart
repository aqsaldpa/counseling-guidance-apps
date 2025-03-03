import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/constant/color.dart';
import 'package:myapp/constant/img_const.dart';
import 'package:myapp/model/user_model.dart';
import 'package:myapp/routes/routes_name.dart';
import 'package:myapp/service/sheet_service.dart';
import 'package:myapp/widgets/custom_scaffold.dart';
import 'package:myapp/widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kelasController = TextEditingController();
  final _tempatLahirController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = false;
  String _selectedGender = 'Laki-laki'; // Default value
  int _age = 0;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the SheetService when the screen loads
    _initSheetService();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  Future<void> _initSheetService() async {
    // Make sure the sheet service is initialized before we try to use it
    await SheetService.init();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kelasController.dispose();
    _tempatLahirController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: greenBorders,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _calculateAge(picked);
      });
    }
  }

  void _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;

    // Adjust age if birthday hasn't occurred yet this year
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    setState(() {
      _age = age;
    });
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih tanggal lahir'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);

        // Use the new ID generation method that combines name and birthdate
        final userId = SheetService.generateUserIdFromNameAndBirthdate(
            _namaController.text, formattedDate);

        final userData = UserModel(
          id: userId,
          nama: _namaController.text,
          kelas: _kelasController.text,
          jenisKelamin: _selectedGender,
          tempatLahir: _tempatLahirController.text,
          tglLahir: formattedDate,
        );

        // Debug logging
        debugPrint("Attempting to save user: ${userData.toJson()}");
        debugPrint("User age: ${userData.umur}");

        // Make sure the sheet service is initialized
        if (SheetService.userSheet == null) {
          await SheetService.init();
          if (SheetService.userSheet == null) {
            throw Exception("Failed to initialize Google Sheets");
          }
        }

        final success = await SheetService.saveUser(userData);

        debugPrint("Save result: $success");

        if (!mounted) return;

        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi berhasil! Silakan login.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Navigate to login screen
          Navigator.of(context).pushReplacementNamed(RoutesName.loginScreen);
        } else {
          // Show error message with retry option
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Gagal menyimpan data ke Google Sheets. Silakan coba lagi.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: _registerUser,
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint("Error registering user: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;
    final horizontalPadding = isLargeScreen ? screenSize.width * 0.1 : 16.0;

    return CustomScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: greenBorders,
        title: const Text(
          'Pendaftaran',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      child: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: greenBorders),
                  SizedBox(height: 16),
                  Text(
                    'Memproses pendaftaran...',
                    style: TextStyle(
                      color: greenBorders,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeInAnimation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                      Colors.grey.shade100,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header with image
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                ImageConstants.instance.registerImg,
                                height: 150,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: greenBorders.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: greenBorders,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Silakan mengisi data diri Anda untuk melanjutkan',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: greenBorders,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Form Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section title
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: greenBorders,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.person_add_rounded,
                                      color: greenBorders,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Data Pribadi',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: greenBorders,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Nama field
                              CustomTextField(
                                hintText: 'Nama Lengkap',
                                prefixIcon: Icons.person,
                                controller: _namaController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nama kosong';
                                  }
                                  return null;
                                },
                              ),

                              // Layout for smaller fields (Kelas & Jenis Kelamin) in a row
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Kelas field
                                  Expanded(
                                    flex: isLargeScreen ? 1 : 2,
                                    child: CustomTextField(
                                      hintText: 'Kelas',
                                      prefixIcon: Icons.class_,
                                      controller: _kelasController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Kelas Kosong';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Jenis Kelamin dropdown
                                  Expanded(
                                    flex: isLargeScreen ? 1 : 3,
                                    child: Container(
                                      height: 56,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: greenBorders, width: 2),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.person_outline,
                                              color: Colors.black54,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value: _selectedGender,
                                                  dropdownColor: Colors.white,
                                                  isExpanded: true,
                                                  icon: const Icon(
                                                      Icons.arrow_drop_down),
                                                  items: <String>[
                                                    'Laki-laki',
                                                    'Perempuan'
                                                  ].map((String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  onChanged:
                                                      (String? newValue) {
                                                    setState(() {
                                                      _selectedGender =
                                                          newValue!;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Layout for Tempat Lahir & Tanggal Lahir in a row
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Tempat Lahir field
                                  Expanded(
                                    child: CustomTextField(
                                      hintText: 'Tempat Lahir',
                                      prefixIcon: Icons.location_city,
                                      controller: _tempatLahirController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Tempat lahir kosong';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Tanggal Lahir picker
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selectDate(context),
                                      child: Container(
                                        height: 56,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: greenBorders, width: 2),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_today,
                                                color: Colors.black54,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _selectedDate == null
                                                      ? 'Tanggal Lahir'
                                                      : DateFormat('dd/MM/yyyy')
                                                          .format(
                                                              _selectedDate!),
                                                  style: TextStyle(
                                                    color: _selectedDate == null
                                                        ? Colors.black54
                                                        : Colors.black,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Display calculated age if date is selected
                              if (_selectedDate != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 16),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.teal.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.cake,
                                        color: Colors.teal.shade700,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Umur: $_age tahun',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.teal.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Submit Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: greenBorders.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenBorders,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Login link
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, RoutesName.loginScreen);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: greenBorders,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontSize: 15,
                                  color: greenBorders,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sudah memiliki akun? ',
                                  ),
                                  TextSpan(
                                    text: 'Masuk sekarang',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
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
