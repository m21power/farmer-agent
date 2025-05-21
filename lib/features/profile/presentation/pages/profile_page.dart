import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maize_guard/features/profile/presentation/bloc/profile_bloc.dart';
import '../../../auth/domain/entities/entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  final User? user; // ✅ make it nullable

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  bool isSaving = false;
  bool hasChanged = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    final user = widget.user;

    firstNameController = TextEditingController(text: user?.firstName ?? "");
    lastNameController = TextEditingController(text: user?.lastName ?? "");
    emailController = TextEditingController(text: user?.email ?? "");
    phoneController = TextEditingController(text: user?.phone ?? "");

    firstNameController.addListener(_checkForChanges);
    lastNameController.addListener(_checkForChanges);
    emailController.addListener(_checkForChanges);
    phoneController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final user = widget.user;
    if (user == null) return;

    final changed = firstNameController.text.trim() != user.firstName ||
        lastNameController.text.trim() != user.lastName ||
        emailController.text.trim() != user.email ||
        phoneController.text.trim() != user.phone;

    if (hasChanged != changed) {
      setState(() {
        hasChanged = changed;
      });
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void saveProfile() {
    final user = widget.user;
    if (user == null) return;

    final updatedUser = user.copyWith(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
    );

    context.read<ProfileBloc>().add(UpdateProfileEvent(user: updatedUser));
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is AuthLogoutSuccessState) {
            context.read<AuthBloc>().add(AuthCheckEvent());
          }

          if (state is UpdateLoadingState || state is ProfileInitial) {
            setState(() => isSaving = true);
          } else {
            setState(() => isSaving = false);
          }

          if (state is UpdateSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profile updated"),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              hasChanged = false;
            });
          } else if (state is UpdateFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue.shade100,
                child: ClipOval(
                  child: Image.asset(
                    "assets/${user.role}.png",
                    fit: BoxFit.cover,
                    width: 90,
                    height: 90,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              buildField("First Name", firstNameController, user),
              const SizedBox(height: 15),
              buildField("Last Name", lastNameController, user),
              const SizedBox(height: 15),
              buildField("Email (optional)", emailController, user),
              const SizedBox(height: 15),
              buildField("Phone", phoneController, user),
              const SizedBox(height: 30),
              user.role != "expert"
                  ? ElevatedButton(
                      onPressed: (isSaving || !hasChanged)
                          ? null
                          : () => saveProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 23, 165, 28),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Save Changes",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(String label, TextEditingController controller, User user) {
    return TextFormField(
      controller: controller,
      readOnly: user.role == "expert",
      enabled: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
