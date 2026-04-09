import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'terminos_condiciones_model.dart';
export 'terminos_condiciones_model.dart';

class TerminosCondicionesWidget extends StatefulWidget {
  const TerminosCondicionesWidget({super.key});

  @override
  State<TerminosCondicionesWidget> createState() =>
      _TerminosCondicionesWidgetState();
}

class _TerminosCondicionesWidgetState extends State<TerminosCondicionesWidget> {
  late TerminosCondicionesModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TerminosCondicionesModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 348.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x33000000),
            offset: Offset(
              0.0,
              2.0,
            ),
          )
        ],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(30.0, 40.0, 30.0, 30.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'Términos y condiciones',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.publicSans(
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      fontSize: 20.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                child: Text(
                  '1. ¿QUÉ ES DOVIA?\n• DOVIA es una plataforma digital que permite: publicar propiedades, coordinar visitas,\n• recibir y gestionar ofertas, facilitar procesos de venta y renta de inmuebles.\n• DOVIA no es propietaria de los inmuebles, no es agente inmobiliario tradicional, DOVIA\nno representa legalmente a ninguna de las partes, DOVIA actúa únicamente como\nplataforma de facilitación tecnológica.\n\n2. RESPONSABILIDAD DEL USUARIO\n• Cada usuario es responsable de la información que publica, las decisiones que toma,\nlos acuerdos que celebra.\n• DOVIA no garantiza, cierres de venta o renta, precios, comportamiento de otros\nusuarios, resultados de negociaciones.\n\n3. PUBLICACIÓN DE PROPIEDADES\n• Al publicar una propiedad en DOVIA, el propietario declara que, es el legítimo\npropietario o cuenta con autorización expresa, la información proporcionada es veraz y\nactualizada.\n• DOVIA no se hace responsable por información falsa, incompleta o engañosa\nproporcionada por los usuarios.\n\n4. ACUERDOS FUERA DE DOVIA (CLÁUSULA CRÍTICA)\n• Si un propietario, comprador, arrendatario o interesado negocia, agenda visitas,\nintercambia datos, realiza pagos, firma contratos, utiliza abogados o notarios, FUERA\nDE LA APLICACIÓN DOVIA, acepta expresamente que:\no DOVIA no se hace responsable de ningún problema, estafa, incumplimiento,\ndaño, pérdida económica o conflicto legal derivado de dichos acuerdos.\no Esto incluye contratos privados, escrituras, pagos en efectivo o transferencias\nexternas, acuerdos verbales.\n\n5. VISITAS, CITAS Y SEGURIDAD\n• DOVIA realiza verificaciones básicas de usuarios, sin garantizar identidad real,\nconducta, intenciones.\n• Si un usuario decide reunirse, permitir visitas, coordinar citas, fuera de la app, lo hace\nbajo su propio riesgo, y acepta que DOVIA no es responsable de robos, estafas, daños\nfísicos o amenazas.\n\n6. COMISIONES Y OBLIGACIONES DEL PROPIETARIO\n• DOVIA obtiene sus ingresos mediante comisiones cobradas al propietario cuando una\noperación de venta o renta se origina, gestiona o facilita a través de la app.\n• Al publicar una propiedad, el propietario acepta que todo contacto, visita u oferta\ngenerada a partir de DOVIA se considera originada por la Plataforma.\n• La comisión de DOVIA es exigible si la operación se concreta, aunque el cierre final se\nrealice fuera de la app.\n\nEvasión de comisiones\n• Si el propietario retira la propiedad, negocia directamente con un interesado, utiliza\nabogados, notarios o intermediarios externos, firma contratos fuera de DOVIA, con el\nobjetivo de evitar el pago de la comisión, acepta que DOVIA podrá reclamar el pago\ntotal de la comisión correspondiente, así como los gastos asociados a la gestión y\ncomercialización.\n• Esto aplica incluso si el cierre ocurre después de retirar la propiedad y el trato se\nconcreta con un usuario conocido a través de DOVIA.\n\n7. ASOCIADOS Y SHOWINGS\n• Los asociados que muestran propiedades no son empleados de DOVIA, actúan como\ncontratistas independientes. DOVIA no se hace responsable por actos u omisiones de\nasociados fuera del marco de la app.\n\n8. SUSPENSIÓN Y CANCELACIÓN DE CUENTAS\n• DOVIA podrá suspender o cancelar cuentas en caso de fraude, evasión de comisiones,\nuso indebido de la plataforma, incumplimiento de estos términos.\n\n9. LIMITACIÓN DE RESPONSABILIDAD\n• DOVIA no será responsable por daños indirectos, pérdidas económicas, conflictos\nentre usuarios, decisiones tomadas fuera de la app.\n• Cualquier responsabilidad se limita al monto efectivamente pagado a DOVIA, si\nexistiera.\n\n10. LEY APLICABLE\n• Estos términos se rigen por las leyes de la República de Guatemala.\nCualquier disputa será resuelta por los tribunales competentes del país.\n\n11. ACEPTACIÓN\n• Al usar DOVIA confirmas que leíste, entendiste y aceptas estos términos en su\ntotalidad.Términos y condiciones DOVIA\n\n1. ¿QUÉ ES DOVIA HOME?\n• DOVIA Home es un servicio de la app DOVIA que permite coordinar técnicos, programar\ntrabajos, solicitar servicios para propiedades.\n• DOVIA no presta directamente los servicios técnicos. Los técnicos son terceros\nindependientes.\n\n2. NATURALEZA DEL SERVICIO\n• DOVIA Home actúa como plataforma de coordinación y pago, no como proveedor del\nservicio.\n• DOVIA no garantiza resultados específicos, tiempos exactos, ausencia total de fallas.\n\n3. GARANTÍA DOVIA HOME\n• La garantía SOLO aplica si: el servicio se solicita desde la app, el técnico es asignado\npor DOVIA, el pago se realiza completamente dentro de la app.\n\n4. EXCLUSIÓN DE GARANTÍA\n• DOVIA no se hace responsable si el usuario contrata al técnico fuera de la app, paga en\nefectivo o por transferencia externa, acuerda trabajos adicionales fuera de la\nplataforma, continúa la relación sin DOVIA, aunque haya conocido al técnico a través\nde DOVIA.\n\n5. TÉCNICOS Y PROVEEDORES\n• Los técnicos no son empleados de DOVIA, actúan bajo su propia responsabilidad.\n• DOVIA no responde por daños indirectos, pérdidas económicas, trabajos fuera del\nalcance contratado en la app.\n\n6. EMERGENCIAS\n• Los tiempos de atención son estimados, no garantizados.\nFactores externos pueden afectar la respuesta.\n\n7. PAGOS Y DISPUTAS\n• Los pagos deben realizarse dentro de la app.\n• Cualquier disputa deberá reportarse por los canales oficiales.\n\n8. LIMITACIÓN DE RESPONSABILIDAD\n• DOVIA Home no será responsable por daños consecuenciales, fallas fuera del alcance\ncontratado, acuerdos realizados fuera de la app.• La responsabilidad máxima se limita al monto pagado dentro de DOVIA Home, si existiera.\n\n9. SUSPENSIÓN DE CUENTAS\n• DOVIA podrá suspender o cancelar cuentas por fraude, uso indebido, incumplimiento\nde estos términos.\n\n10. LEY APLICABLE\n• Estos términos se rigen por las leyes de la República de Guatemala.\n\n11. ACEPTACIÓN\n• Al usar DOVIA Home aceptas estos términos en su totalidad.',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.publicSans(
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
