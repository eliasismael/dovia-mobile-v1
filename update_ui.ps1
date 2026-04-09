$filePath = 'lib/dovia_client/app/mis_propiedades/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar/d_o_v_i_a_c_l_i_e_n_t_mis_propiedades_vender_rentar_widget.dart'
$text = Get-Content -Path $filePath -Raw

$pattern = "(?s)(Align\(\s+alignment:\s+AlignmentDirectional\(-1.0, 0.0\),\s+child: Padding\(\s+padding:\s+EdgeInsetsDirectional.fromSTEB\(\s+0.0, 10.0, 0.0, 0.0\),\s+child: Text\(\s+'Tiempo mnimo'.*?)(Align\(\s+alignment:\s+AlignmentDirectional\(-1.0, 0.0\),\s+child: Padding\(\s+padding:\s+EdgeInsetsDirectional.fromSTEB\(\s+0.0, 10.0, 0.0, 0.0\),\s+child: Text\(\s+'Otros')"

# Sometimes "mínimo" is read as "mnimo" or just "mínimo" in powershell if not using utf8
$patternUnicode = "(?s)(Align\(\s+alignment:\s+AlignmentDirectional\(-1.0, 0.0\),\s+child: Padding\(\s+padding:\s+EdgeInsetsDirectional.fromSTEB\(\s+0.0, 10.0, 0.0, 0.0\),\s+child: Text\(\s+'Tiempo m.nimo'.*?)(Align\(\s+alignment:\s+AlignmentDirectional\(-1.0, 0.0\),\s+child: Padding\(\s+padding:\s+EdgeInsetsDirectional.fromSTEB\(\s+0.0, 10.0, 0.0, 0.0\),\s+child: Text\(\s+'Otros')"

if ($text -match $patternUnicode) {
    Write-Host "Match found!"
    $tiempo_minimo_blocks = $matches[1]

    $disponible_desde_blocks = $tiempo_minimo_blocks.Replace("'Tiempo mínimo'", "'Disponible desde'").Replace("'Tiempo mnimo'", "'Disponible desde'").Replace('tiempoMinimo', 'disponibleDesde').Replace("'2 años'", "'inmediato'")
    $disponible_desde_blocks = $disponible_desde_blocks.Replace('const TextInputType.numberWithOptions(decimal: true)', 'TextInputType.text')

    $uso_permitido_blocks = $tiempo_minimo_blocks.Replace("'Tiempo mínimo'", "'Uso permitido en esta propiedad'").Replace("'Tiempo mnimo'", "'Uso permitido en esta propiedad'").Replace('tiempoMinimo', 'usoPermitido').Replace("'2 años'", "'Residencial, mascotas permitidas...'")
    $uso_permitido_blocks = $uso_permitido_blocks.Replace('const TextInputType.numberWithOptions(decimal: true)', 'TextInputType.multiline')

    $uso_no_permitido_blocks = $tiempo_minimo_blocks.Replace("'Tiempo mínimo'", "'Uso no permitido en esta propiedad'").Replace("'Tiempo mnimo'", "'Uso no permitido en esta propiedad'").Replace('tiempoMinimo', 'usoNoPermitido').Replace("'2 años'", "'Fiestas, drogas...'")
    $uso_no_permitido_blocks = $uso_no_permitido_blocks.Replace('const TextInputType.numberWithOptions(decimal: true)', 'TextInputType.multiline')

    $new_text = $text.Replace($tiempo_minimo_blocks, $disponible_desde_blocks + $tiempo_minimo_blocks)
    
    $otros_block_start = $matches[2]
    $new_text = $new_text.Replace($otros_block_start, $uso_permitido_blocks + $uso_no_permitido_blocks + $otros_block_start)

    $new_text = $new_text.Replace(
        "othersRent: _model.rentaOtrosTextController.text,",
        "othersRent: _model.rentaOtrosTextController.text,`n                                        allowedUses: _model.usoPermitidoTextController.text,`n                                        prohibitedUses: _model.usoNoPermitidoTextController.text,`n                                        availableFrom: _model.disponibleDesdeTextController.text,"
    )

    $new_text = $new_text.Replace(
        "othersRent: _model.rentaOtrosTextController.text,",
        "othersRent: _model.rentaOtrosTextController.text,`n                                            allowedUses: _model.usoPermitidoTextController.text,`n                                            prohibitedUses: _model.usoNoPermitidoTextController.text,`n                                            availableFrom: _model.disponibleDesdeTextController.text,"
    )

    [IO.File]::WriteAllText($filePath, $new_text, [System.Text.Encoding]::UTF8)
    Write-Host "UI and API properties updated successfully."
} else {
    Write-Host "Could not find the target block."
}
