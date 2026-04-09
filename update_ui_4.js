const fs = require('fs');
const filePath = 'lib/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar_widget.dart';
let text = fs.readFileSync(filePath, 'utf8');

// 1. Add initialization
text = text.replace(
    "_model.tiempoMinimoTextController ??= TextEditingController();",
    "_model.tiempoMinimoTextController ??= TextEditingController();\n    _model.disponibleDesdeTextController ??= TextEditingController();\n    _model.disponibleDesdeFocusNode ??= FocusNode();\n    _model.usoPermitidoTextController ??= TextEditingController();\n    _model.usoPermitidoFocusNode ??= FocusNode();\n    _model.usoNoPermitidoTextController ??= TextEditingController();\n    _model.usoNoPermitidoFocusNode ??= FocusNode();"
);

// 2. Add API payloads
text = text.replace(/othersRent:\s*_model\s*\.rentaOtrosTextController\.text,\s*isCompanyOwned:\s*false,/g,
    "othersRent: _model.rentaOtrosTextController.text,\n                                        allowedUses: _model.usoPermitidoTextController.text,\n                                        prohibitedUses: _model.usoNoPermitidoTextController.text,\n                                        availableFrom: _model.disponibleDesdeTextController.text,\n                                        isCompanyOwned: false,"
);

text = text.replace(/othersRent:\s*_model\s*\.rentaOtrosTextController\.text,\s*isCompanyOwned:\s*_model\s*\.nombreRepresentanteLegalTextController/g,
    "othersRent: _model.rentaOtrosTextController.text,\n                                            allowedUses: _model.usoPermitidoTextController.text,\n                                            prohibitedUses: _model.usoNoPermitidoTextController.text,\n                                            availableFrom: _model.disponibleDesdeTextController.text,\n                                            isCompanyOwned: _model.nombreRepresentanteLegalTextController"
);

text = text.replace(
    "minimumTimeRent: int.tryParse(_model\n                                              .tiempoMinimoTextController.text),\n                                          othersRent: _model\n                                              .rentaOtrosTextController.text,\n                                          isCompanyOwned:",
    "minimumTimeRent: int.tryParse(_model\n                                              .tiempoMinimoTextController.text),\n                                          othersRent: _model\n                                              .rentaOtrosTextController.text,\n                                          allowedUses: _model.usoPermitidoTextController.text,\n                                          prohibitedUses: _model.usoNoPermitidoTextController.text,\n                                          availableFrom: _model.disponibleDesdeTextController.text,\n                                          isCompanyOwned:"
);

const getBlock = (title, controllerName, inputType) => `
                                        Align(
                                          alignment: AlignmentDirectional(-1.0, 0.0),
                                          child: Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                                            child: Text(
                                              '${title}',
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(), letterSpacing: 0.0),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: AlignmentDirectional(-1.0, 0.0),
                                          child: Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                                            child: Container(
                                              width: MediaQuery.sizeOf(context).width * 1.0,
                                              child: TextFormField(
                                                controller: _model.${controllerName}TextController,
                                                focusNode: _model.${controllerName}FocusNode,
                                                autofocus: false,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  filled: true,
                                                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                ),
                                                style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.inter(), letterSpacing: 0.0),
                                                keyboardType: ${inputType},
                                              ),
                                            ),
                                          ),
                                        ),
`;

const lines = text.split('\n');
let newLines = [];
for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes("child: Text(") && lines[i+1] && lines[i+1].includes("'Tiempo mínimo',")) {
        // We go back to find the Align for label
        let j = i;
        while (j > 0 && !lines[j].includes('Align(')) j--;
        // Insert before Align(
        newLines.splice(newLines.length - (i - j), i - j);
        newLines.push(getBlock('Disponible desde', 'disponibleDesde', 'TextInputType.text'));
        for (let k = j; k <= i; k++) newLines.push(lines[k]);
    } else if (lines[i].includes("child: Text(") && lines[i+1] && lines[i+1].includes("'Otros',")) {
        let j = i;
        while (j > 0 && !lines[j].includes('Align(')) j--;
        newLines.splice(newLines.length - (i - j), i - j);
        newLines.push(getBlock('Uso permitido', 'usoPermitido', 'TextInputType.multiline'));
        newLines.push(getBlock('Uso no permitido', 'usoNoPermitido', 'TextInputType.multiline'));
        for (let k = j; k <= i; k++) newLines.push(lines[k]);
    } else {
        newLines.push(lines[i]);
    }
}

fs.writeFileSync(filePath, newLines.join('\n'), 'utf8');
console.log("DONE UI");
