import 'package:flutter/material.dart';

/// Diálogos para eliminar la cuenta, los mismos en los ajustes de todos los
/// roles. Primero la confirmación: pregunta y dos botones, Cancelar y
/// Eliminar cuenta.
class DeleteAccountConfirmDialog extends StatelessWidget {
  const DeleteAccountConfirmDialog({super.key, required this.onConfirm});

  /// Pasa al paso siguiente (el motivo). Quien llama cierra este diálogo.
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Estás seguro de que quieres eliminar tu cuenta?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00444B),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                            color: Color(0xFF007376), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Cancelar',
                          style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF007376))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      // En un renglón: si no entra, se achica en vez de
                      // partirse en dos.
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Eliminar cuenta',
                            maxLines: 1,
                            style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
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
}

/// Segundo paso de eliminar la cuenta: el motivo (opcional) y Enviar.
class DeleteAccountReasonDialog extends StatelessWidget {
  const DeleteAccountReasonDialog(
      {super.key, required this.controller, required this.onConfirm});

  final TextEditingController controller;

  /// Elimina la cuenta. Quien llama cierra este diálogo.
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cuéntanos por qué deseas eliminar tu cuenta',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00444B),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller,
                maxLines: 4,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: Color(0xFF00444B),
                ),
                decoration: const InputDecoration(
                  hintText: 'Escribe aquí....',
                  hintStyle: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    color: Color(0xFF888888),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007376),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text('Enviar',
                    style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
