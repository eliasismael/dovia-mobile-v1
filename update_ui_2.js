const fs = require('fs');
const filePath = 'lib/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar_widget.dart';
let text = fs.readFileSync(filePath, 'utf8');

// 1. Add initialization
text = text.replace(
    "_model.tiempoMinimoTextController ??= TextEditingController();",
    "_model.tiempoMinimoTextController ??= TextEditingController();\n    _model.disponibleDesdeTextController ??= TextEditingController();\n    _model.disponibleDesdeFocusNode ??= FocusNode();\n    _model.usoPermitidoTextController ??= TextEditingController();\n    _model.usoPermitidoFocusNode ??= FocusNode();\n    _model.usoNoPermitidoTextController ??= TextEditingController();\n    _model.usoNoPermitidoFocusNode ??= FocusNode();"
);

// 2. Add API payloads
// Sale and rent CreatePropertyBasicSALEAndRENTCall
text = text.replace(
    "minimumTimeRent: int.tryParse(_model.tiempoMinimoTextController.text),\n                                        othersRent: _model.rentaOtrosTextController.text,\n                                        isCompanyOwned: false,",
    "minimumTimeRent: int.tryParse(_model.tiempoMinimoTextController.text),\n                                        othersRent: _model.rentaOtrosTextController.text,\n                                        allowedUses: _model.usoPermitidoTextController.text,\n                                        prohibitedUses: _model.usoNoPermitidoTextController.text,\n                                        availableFrom: _model.disponibleDesdeTextController.text,\n                                        isCompanyOwned: false,"
);
// Rent CreatePropertyBasicRENTCall
text = text.replace(
    "minimumTimeRent: int.tryParse(_model.tiempoMinimoTextController.text),\n                                            othersRent: _model.rentaOtrosTextController.text,\n                                            isCompanyOwned:",
    "minimumTimeRent: int.tryParse(_model.tiempoMinimoTextController.text),\n                                            othersRent: _model.rentaOtrosTextController.text,\n                                            allowedUses: _model.usoPermitidoTextController.text,\n                                            prohibitedUses: _model.usoNoPermitidoTextController.text,\n                                            availableFrom: _model.disponibleDesdeTextController.text,\n                                            isCompanyOwned:"
);

text = text.replace(
    "minimumTimeRent: int.tryParse(_model\n                                              .tiempoMinimoTextController.text),\n                                          othersRent: _model\n                                              .rentaOtrosTextController.text,\n                                          isCompanyOwned:",
    "minimumTimeRent: int.tryParse(_model\n                                              .tiempoMinimoTextController.text),\n                                          othersRent: _model\n                                              .rentaOtrosTextController.text,\n                                          allowedUses: _model.usoPermitidoTextController.text,\n                                          prohibitedUses: _model.usoNoPermitidoTextController.text,\n                                          availableFrom: _model.disponibleDesdeTextController.text,\n                                          isCompanyOwned:"
);

// We need to carefully exact string match two Aligns that constitute the UI Block:
// For 'Tiempo mínimo':
// Align( ... 'Tiempo mínimo' ... )
// Align( ... TextFormField ... tiempoMinimoTextController ... )

// Since that's hard to read dynamically, we just define the start string for "Tiempo mínimo":
const startTiempo = "Align(\n                                          alignment:\n                                              AlignmentDirectional(-1.0, 0.0),\n                                          child: Padding(\n                                            padding:\n                                                EdgeInsetsDirectional.fromSTEB(\n                                                    0.0, 10.0, 0.0, 0.0),\n                                            child: Text(\n                                              'Tiempo mínimo'";

const endTiempoStr = "validator: _model\n                                                    .tiempoMinimoTextControllerValidator\n                                                    .asValidator(context),\n                                              ),\n                                            ),\n                                          ),\n                                        ),";

const startOtros = "Align(\n                                          alignment:\n                                              AlignmentDirectional(-1.0, 0.0),\n                                          child: Padding(\n                                            padding:\n                                                EdgeInsetsDirectional.fromSTEB(\n                                                    0.0, 10.0, 0.0, 0.0),\n                                            child: Text(\n                                              'Otros'";

let idx1 = text.indexOf(startTiempo);
let idx2 = text.indexOf(endTiempoStr);
let idx3 = text.indexOf(startOtros);

console.log("idxs", idx1, idx2, idx3);

if (idx1 !== -1 && idx2 !== -1 && idx3 !== -1) {
    let block = text.substring(idx1, idx2 + endTiempoStr.length);
    console.log("length of block", block.length); // should be around 2000-3000 chars

    let disponibleBlock = block
        .replace("'Tiempo mínimo'", "'Disponible desde'")
        .replace(/tiempoMinimo/g, 'disponibleDesde')
        .replace("'2 años'", "'En meses o inmediato'")
        .replace("TextInputType.numberWithOptions(decimal: true)", "TextInputType.text");

    let usoPermitidoBlock = block
        .replace("'Tiempo mínimo'", "'Uso permitido en esta propiedad'")
        .replace(/tiempoMinimo/g, 'usoPermitido')
        .replace("'2 años'", "'Residencial, negocio...'")
        .replace("const TextInputType.numberWithOptions(decimal: true)", "TextInputType.multiline");

    let usoNoPermitidoBlock = block
        .replace("'Tiempo mínimo'", "'Uso no permitido en esta propiedad'")
        .replace(/tiempoMinimo/g, 'usoNoPermitido')
        .replace("'2 años'", "'Fiestas, mascotas...'")
        .replace("const TextInputType.numberWithOptions(decimal: true)", "TextInputType.multiline");

    // Insert disponible before tiempo
    text = text.substring(0, idx1) + disponibleBlock + "\n                                        " + text.substring(idx1);
    
    // Remeasure idx3 after insertion
    idx3 = text.indexOf(startOtros);
    // Insert usoPermitido and usoNoPermitido before Otros
    text = text.substring(0, idx3) + usoPermitidoBlock + "\n                                        " + usoNoPermitidoBlock + "\n                                        " + text.substring(idx3);

    fs.writeFileSync(filePath, text, 'utf8');
    console.log("DONE");
} else {
    console.log("Could not find the bounds properly.");
}
