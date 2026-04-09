const fs = require('fs');
const filePath = 'lib/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar_widget.dart';
let text = fs.readFileSync(filePath, 'utf8');

const regex = /Align\([^]*?child: Text\(\s+'Tiempo mínimo'[^]*?_model\s*\.tiempoMinimoTextControllerValidator\s*\.asValidator\(context\),\s*\),\s*\),\s*\),\s*\)/m;
const match = text.match(regex);

if (match) {
    console.log("Matched tiempo minimo length:", match[0].length);
    let tiempoBlock = match[0];

    let disponibleBlock = tiempoBlock
        .replace("'Tiempo mínimo'", "'Disponible desde'")
        .replace(/tiempoMinimo/g, 'disponibleDesde')
        .replace("'2 años'", "'En meses o inmediato'")
        .replace("TextInputType.numberWithOptions(decimal: true)", "TextInputType.text");

    let usoPermitidoBlock = tiempoBlock
        .replace("'Tiempo mínimo'", "'Uso permitido en esta propiedad'")
        .replace(/tiempoMinimo/g, 'usoPermitido')
        .replace("'2 años'", "'Residencial, negocio...'")
        .replace("const TextInputType.numberWithOptions(decimal: true)", "TextInputType.multiline");

    let usoNoPermitidoBlock = tiempoBlock
        .replace("'Tiempo mínimo'", "'Uso no permitido en esta propiedad'")
        .replace(/tiempoMinimo/g, 'usoNoPermitido')
        .replace("'2 años'", "'Fiestas, mascotas...'")
        .replace("const TextInputType.numberWithOptions(decimal: true)", "TextInputType.multiline");

    text = text.replace(tiempoBlock, disponibleBlock + '\n' + tiempoBlock);

    const regexOtros = /Align\([^]*?child: Text\(\s+'Otros'[^]*?_model\s*\.rentaOtrosTextControllerValidator\s*\.asValidator\(context\),\s*\),\s*\),\s*\),\s*\)/m;
    const matchOtros = text.match(regexOtros);
    if (matchOtros) {
        console.log("Matched otros length:", matchOtros[0].length);
        let otrosBlock = matchOtros[0];
        text = text.replace(otrosBlock, usoPermitidoBlock + '\n' + usoNoPermitidoBlock + '\n' + otrosBlock);
        
        fs.writeFileSync(filePath, text, 'utf8');
        console.log("Done updating UI blocks.");
    } else {
        console.log("Could not find otros block.");
    }
} else {
    console.log("Could not find tiempo minimo block.");
}
