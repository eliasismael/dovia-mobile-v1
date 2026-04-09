import re

file_path = 'lib/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar_widget.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

# Extract the 'Tiempo mínimo' block to use as a template
# It starts around the Align that has the text 'Tiempo mínimo' and ends after the TextFormField
# Actually it's two Aligns. One for the label, one for the TextFormField.

pattern = r"(Align\(\s+alignment:\s+AlignmentDirectional\(-1.0, 0.0\),\s+child: Padding\(\s+padding:\s+EdgeInsetsDirectional.fromSTEB\(\s+0.0, 10.0, 0.0, 0.0\),\s+child: Text\(\s+'Tiempo mínimo'.*?)(Align\(\s+alignment:\s+AlignmentDirectional\(-1.0, 0.0\),\s+child: Padding\(\s+padding:\s+EdgeInsetsDirectional.fromSTEB\(\s+0.0, 10.0, 0.0, 0.0\),\s+child: Text\(\s+'Otros')"
match = re.search(pattern, text, flags=re.DOTALL)

if match:
    tiempo_minimo_blocks = match.group(1)
    
    # Create Disponible desde based on tiempo_minimo
    disponible_desde_blocks = tiempo_minimo_blocks.replace("'Tiempo mínimo'", "'Disponible desde'").replace('tiempoMinimo', 'disponibleDesde').replace("'2 años'", "'inmediato'")
    # Change keyboardType
    disponible_desde_blocks = disponible_desde_blocks.replace('const TextInputType.numberWithOptions(decimal: true)', 'TextInputType.text')
    
    # Create Uso permitido
    uso_permitido_blocks = tiempo_minimo_blocks.replace("'Tiempo mínimo'", "'Uso permitido en esta propiedad'").replace('tiempoMinimo', 'usoPermitido').replace("'2 años'", "'Residencial, mascotas permitidas...'")
    uso_permitido_blocks = uso_permitido_blocks.replace('const TextInputType.numberWithOptions(decimal: true)', 'TextInputType.multiline')

    # Create Uso no permitido
    uso_no_permitido_blocks = tiempo_minimo_blocks.replace("'Tiempo mínimo'", "'Uso no permitido en esta propiedad'").replace('tiempoMinimo', 'usoNoPermitido').replace("'2 años'", "'Fiestas, drogas...'")
    uso_no_permitido_blocks = uso_no_permitido_blocks.replace('const TextInputType.numberWithOptions(decimal: true)', 'TextInputType.multiline')

    # Update text: Insert Disponible desde before Tiempo minimo
    new_text = text.replace(tiempo_minimo_blocks, disponible_desde_blocks + tiempo_minimo_blocks)
    
    # Insert Uso permitido and Uso no permitido before Otros
    # which is the start of match.group(2)
    otros_block_start = match.group(2)
    new_text = new_text.replace(otros_block_start, uso_permitido_blocks + uso_no_permitido_blocks + otros_block_start)

    # Now update the endpoints
    new_text = new_text.replace(
        "othersRent: _model.rentaOtrosTextController.text,",
        "othersRent: _model.rentaOtrosTextController.text,\n                                        allowedUses: _model.usoPermitidoTextController.text,\n                                        prohibitedUses: _model.usoNoPermitidoTextController.text,\n                                        availableFrom: _model.disponibleDesdeTextController.text,"
    )

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_text)
    print("UI and API properties updated successfully.")
else:
    print("Could not find the target block.")
