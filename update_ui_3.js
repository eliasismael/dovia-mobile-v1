const fs = require('fs');
const filePath = 'lib/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar_widget.dart';
let text = fs.readFileSync(filePath, 'utf8');

// 1. Add initialization
text = text.replace(
    "_model.tiempoMinimoTextController ??= TextEditingController();",
    "_model.tiempoMinimoTextController ??= TextEditingController();\n    _model.disponibleDesdeTextController ??= TextEditingController();\n    _model.disponibleDesdeFocusNode ??= FocusNode();\n    _model.usoPermitidoTextController ??= TextEditingController();\n    _model.usoPermitidoFocusNode ??= FocusNode();\n    _model.usoNoPermitidoTextController ??= TextEditingController();\n    _model.usoNoPermitidoFocusNode ??= FocusNode();"
);

// 2. Add API payloads
// Wait, regex replace the api payloads since whitespace differs.
text = text.replace(/othersRent:\s*_model\s*\.rentaOtrosTextController\.text,\s*isCompanyOwned:\s*false,/g,
    "othersRent: _model.rentaOtrosTextController.text,\n                                        allowedUses: _model.usoPermitidoTextController.text,\n                                        prohibitedUses: _model.usoNoPermitidoTextController.text,\n                                        availableFrom: _model.disponibleDesdeTextController.text,\n                                        isCompanyOwned: false,"
);

text = text.replace(/othersRent:\s*_model\s*\.rentaOtrosTextController\.text,\s*isCompanyOwned:\s*_model\s*\.nombreRepresentanteLegalTextController/g,
    "othersRent: _model.rentaOtrosTextController.text,\n                                        allowedUses: _model.usoPermitidoTextController.text,\n                                        prohibitedUses: _model.usoNoPermitidoTextController.text,\n                                        availableFrom: _model.disponibleDesdeTextController.text,\n                                        isCompanyOwned: _model.nombreRepresentanteLegalTextController"
);

let idxTLabel = text.indexOf("'Tiempo mínimo'");
let idxOtros = text.indexOf("'Otros'");

if (idxTLabel !== -1 && idxOtros !== -1) {
    let idx1 = text.lastIndexOf("Align(", idxTLabel);
    let idx3 = text.lastIndexOf("Align(", idxOtros);

    let endStr = ".asValidator(context),";
    let endTiempo = text.indexOf(endStr, idxTLabel);
    // Move slightly forward to capture closing parenthesis
    let closingStr = "),\n                                            ),\n                                          ),\n                                        ),";
    let idx2 = text.indexOf(closingStr, endTiempo) + closingStr.length;

    let block = text.substring(idx1, idx2);
    
    let disponibleBlock = block
        .replace("'Tiempo mínimo'", "'Disponible desde'")
        .replace(/tiempoMinimo/g, 'disponibleDesde')
        .replace("'2 años'", "'En meses o inmediato'")
        .replace("TextInputType.numberWithOptions(decimal: true)", "TextInputType.text")
        .replace("const TextInputType.numberWithOptions(decimal: true)", "TextInputType.text");

    let usoPermitidoBlock = block
        .replace("'Tiempo mínimo'", "'Uso permitido en esta propiedad'")
        .replace(/tiempoMinimo/g, 'usoPermitido')
        .replace("'2 años'", "'Residencial, negocio...'")
        .replace("const TextInputType.numberWithOptions(decimal: true)", "TextInputType.multiline")
        .replace("TextInputType.numberWithOptions(decimal: true)", "TextInputType.multiline");

    let usoNoPermitidoBlock = block
        .replace("'Tiempo mínimo'", "'Uso no permitido en esta propiedad'")
        .replace(/tiempoMinimo/g, 'usoNoPermitido')
        .replace("'2 años'", "'Fiestas, mascotas...'")
        .replace("const TextInputType.numberWithOptions(decimal: true)", "TextInputType.multiline")
        .replace("TextInputType.numberWithOptions(decimal: true)", "TextInputType.multiline");

    text = text.substring(0, idx1) + disponibleBlock + "\n                                        " + text.substring(idx1);
    
    // Recalculate idx3 for otros
    idx3 = text.indexOf("'Otros'");
    let realIdx3 = text.lastIndexOf("Align(", idx3);

    text = text.substring(0, realIdx3) + usoPermitidoBlock + "\n                                        " + usoNoPermitidoBlock + "\n                                        " + text.substring(realIdx3);

    fs.writeFileSync(filePath, text, 'utf8');
    console.log("DONE");
} else {
    console.log("Could not find");
}
