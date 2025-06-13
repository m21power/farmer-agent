import 'package:flutter/material.dart';
import '../../domain/entities/disease.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddEditDiseasePage extends StatefulWidget {
  final Disease? disease; // null means Add
  final void Function(Disease disease) onSave;

  const AddEditDiseasePage({super.key, this.disease, required this.onSave});

  @override
  State<AddEditDiseasePage> createState() => _AddEditDiseasePageState();
}

class _AddEditDiseasePageState extends State<AddEditDiseasePage> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final signsCtrl = TextEditingController();
  final treatCtrl = TextEditingController();
  final prevCtrl = TextEditingController();

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    final d = widget.disease;
    if (d != null) {
      nameCtrl.text = d.name;
      descCtrl.text = d.description;
      signsCtrl.text = d.signs;
      treatCtrl.text = d.treatments;
      prevCtrl.text = d.prevention;
    }
    nameCtrl.addListener(_checkState);
    descCtrl.addListener(_checkState);
    signsCtrl.addListener(_checkState);
    treatCtrl.addListener(_checkState);
    prevCtrl.addListener(_checkState);
  }

  void _checkState() {
    final isEdit = widget.disease != null;

    final current = Disease(
      id: widget.disease?.id ?? '',
      name: nameCtrl.text.trim(),
      description: descCtrl.text.trim(),
      signs: signsCtrl.text.trim(),
      treatments: treatCtrl.text.trim(),
      prevention: prevCtrl.text.trim(),
      createdAt: widget.disease?.createdAt ?? DateTime.now(),
    );

    final isAllFilled = current.name.isNotEmpty &&
        current.description.isNotEmpty &&
        current.signs.isNotEmpty &&
        current.treatments.isNotEmpty &&
        current.prevention.isNotEmpty;

    if (!isAllFilled) {
      setState(() => isButtonEnabled = false);
      return;
    }

    if (isEdit) {
      final original = widget.disease!;
      final changed = current.name != original.name ||
          current.description != original.description ||
          current.signs != original.signs ||
          current.treatments != original.treatments ||
          current.prevention != original.prevention;
      setState(() => isButtonEnabled = changed);
    } else {
      setState(() => isButtonEnabled = true);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    signsCtrl.dispose();
    treatCtrl.dispose();
    prevCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.disease != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit
              ? AppLocalizations.of(context)!.edit_disease
              : AppLocalizations.of(context)!.add_disease,
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 23, 165, 28),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(nameCtrl, 'Name'),
            _buildMultilineField(descCtrl, 'Description'),
            _buildMultilineField(signsCtrl, 'Signs'),
            _buildMultilineField(treatCtrl, 'Treatments'),
            _buildMultilineField(prevCtrl, 'Prevention'),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 23, 165, 28),
              ),
              onPressed: isButtonEnabled
                  ? () {
                      final newDisease = Disease(
                        id: widget.disease?.id ?? '',
                        name: nameCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        signs: signsCtrl.text.trim(),
                        treatments: treatCtrl.text.trim(),
                        prevention: prevCtrl.text.trim(),
                        createdAt: widget.disease?.createdAt ?? DateTime.now(),
                      );
                      widget.onSave(newDisease);
                      Navigator.pop(context);
                    }
                  : null,
              child: Text(isEdit
                  ? AppLocalizations.of(context)!.update_disease
                  : AppLocalizations.of(context)!.add_disease),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _buildMultilineField(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        minLines: 3,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
