import 'package:flutter/material.dart';
import 'checkout_screen.dart';

class FormPesananScreen extends StatefulWidget {
  const FormPesananScreen({super.key});

  @override
  State<FormPesananScreen> createState() => _FormPesananScreenState();
}

class _FormPesananScreenState extends State<FormPesananScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController waController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController hariController = TextEditingController(text: "1");

  DateTime tglMulai = DateTime.now();

  DateTime get tglKembali {
    int hari = int.tryParse(hariController.text) ?? 1;
    return tglMulai.add(Duration(days: hari));
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tglMulai,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFD700),
              onPrimary: Color(0xFF003B46),
              surface: Color(0xFF004466),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        tglMulai = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Pemesan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF004466),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF004466), Color(0xFF006688)],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildTextField("Nama Lengkap", namaController, TextInputType.name),
              const SizedBox(height: 16),
              _buildTextField("Nomor WhatsApp", waController, TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField("Email", emailController, TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField("Lama Sewa (Hari)", hariController, TextInputType.number, onChanged: (v) => setState(() {})),
              const SizedBox(height: 24),
              const Text("Tanggal Sewa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pilihTanggal(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFFD700))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Mulai", style: TextStyle(color: Colors.white54, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text("${tglMulai.day}/${tglMulai.month}/${tglMulai.year}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white30)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Kembali (Otomatis)", style: TextStyle(color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text("${tglKembali.day}/${tglKembali.month}/${tglKembali.year}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: const Color(0xFF003B46),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                          nama: namaController.text,
                          whatsapp: waController.text,
                          email: emailController.text,
                          hari: int.parse(hariController.text),
                          tglMulai: tglMulai,
                          tglKembali: tglKembali,
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Lanjut ke Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type, {Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white30), borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFFFFD700)), borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
      validator: (value) => value!.isEmpty ? "Harap isi $label" : null,
    );
  }
}