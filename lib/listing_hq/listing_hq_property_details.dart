import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/domain/property_ownership_view.dart';
import '/domain/property_types.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/listing_hq/l_i_s_t_i_n_g_h_q_visor_pdf/l_i_s_t_i_n_g_h_q_visor_pdf_widget.dart';
import '/listing_hq/listing_hq_ui.dart';

/// Ficha de lo que cargó el propietario al publicar, para Listing HQ: datos de
/// la propiedad, datos registrales y, según a nombre de quién está, los datos
/// del titular, de quien registra o de la sociedad y su representante.
///
/// [property] es la propiedad del detalle de la visita; [ownerProfile], la
/// cuenta que publicó; [ownership], el `ownership` completo del backoffice
/// (el del detalle de la visita solo trae el tipo).
class ListingHqPropertyDetails extends StatelessWidget {
  const ListingHqPropertyDetails({
    super.key,
    required this.property,
    this.ownerProfile,
    this.ownership,
  });

  final Map? property;
  final Map? ownerProfile;
  final dynamic ownership;

  @override
  Widget build(BuildContext context) {
    final p = property;
    final legal = _map(p?['legalInfo']);
    final sale = _map(p?['saleInfo']);
    final rent = _map(p?['rentInfo']);
    final address = _map(_map(p?['location'])['address']);
    final description = _map(p?['description']);
    final phone = _map(ownerProfile?['phone']);
    final accountName = _str(ownerProfile?['fullName']);
    final view = ownershipView(ownership, accountName: accountName);

    final String operation;
    switch (_str(p?['listingType']).toUpperCase()) {
      case 'SALE':
        operation = 'Venta';
      case 'RENT':
        operation = 'Renta';
      case '':
        operation = '';
      default:
        operation = 'Venta y renta';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _sectionTitle(context, 'Datos de la propiedad'),
        _card(context, [
          _InfoRow('Dirección', _str(address['fullAddress'])),
          _InfoRow('Referencia', _str(address['extra'])),
          _InfoRow(
              'Tipo',
              propertyTypeLabel(p?['propertyType']) ??
                  _str(p?['propertyType'])),
          _InfoRow('Operación', operation),
          _InfoRow('Precio de venta', _money(sale['salePrice'])),
          _InfoRow('Renta mensual', _money(rent['monthlyRent'])),
          _InfoRow('Mantenimiento', _money(sale['maintenanceFee'])),
          _InfoRow('IUSI', _money(sale['singlePropertyTax'])),
          _InfoRow('Propietario', view.ownerName),
          _InfoRow('Teléfono',
              '${_str(phone['countryCode'])} ${_str(phone['number'])}'.trim()),
          _InfoRow('Email', _str(ownerProfile?['email'])),
          _InfoRow('A nombre de', view.typeLabel),
          _InfoRow('Descripción', _str(description['raw'])),
          _RegistryBox(legal),
        ]),
        for (final section
            in ownershipSections(ownership, accountName: accountName))
          if (section.rows.any((r) => r.$2.isNotEmpty)) ...[
            _sectionTitle(context, section.title),
            _card(context, [
              for (final r in section.rows) _InfoRow(r.$1, r.$2),
            ]),
          ],
      ],
    );
  }

  static Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
        child: Text(text, style: ListingHqUi.sectionTitle(context)),
      );

  static Widget _card(BuildContext context, List<Widget> children) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: ListingHqUi.cardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );

  static String _money(dynamic v) {
    final n = v is num ? v : num.tryParse(_str(v));
    if (n == null) return '';
    return 'Q ${NumberFormat('#,##0', 'en_US').format(n)}';
  }
}

/// Documento que se abre solo para ver. Sin archivo muestra [missingText]; si
/// el documento es obligatorio ([required]), en rojo.
class ListingHqDocTile extends StatelessWidget {
  const ListingHqDocTile({
    super.key,
    required this.name,
    required this.url,
    this.missingText = 'No lo subió',
    this.required = false,
  });

  final String name;
  final String url;
  final String missingText;
  final bool required;

  static const Color _missingRequired = Color(0xFFBC0000);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final has = url.isNotEmpty;
    final idle = required ? _missingRequired : theme.secondaryText;
    return InkWell(
      onTap: !has
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LISTINGHQVisorPdfWidget(
                    documentName: name,
                    documentUrl: url,
                    isPdf: url.toLowerCase().contains('.pdf'),
                  ),
                ),
              ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              has ? Icons.description_outlined : Icons.remove_circle_outline,
              color: has ? theme.primary : idle,
              size: 22.0,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                name,
                style: theme.bodyMedium.override(
                  font: GoogleFonts.publicSans(),
                  fontSize: 14.0,
                  letterSpacing: 0.0,
                ),
              ),
            ),
            Text(
              has ? 'Ver' : missingText,
              style: theme.bodyMedium.override(
                font: GoogleFonts.publicSans(
                    fontWeight:
                        has || required ? FontWeight.w600 : FontWeight.w400),
                color: has ? theme.primary : idle,
                fontSize: 13.0,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.0,
            child: Text(
              label,
              style: theme.bodyMedium.override(
                font: GoogleFonts.publicSans(),
                color: theme.secondaryText,
                fontSize: 13.0,
                letterSpacing: 0.0,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.bodyMedium.override(
                font: GoogleFonts.publicSans(fontWeight: FontWeight.w500),
                fontSize: 13.0,
                letterSpacing: 0.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Finca, folio y libro destacados: con ellos el Lister HQ saca la
/// certificación del registro.
class _RegistryBox extends StatelessWidget {
  const _RegistryBox(this.legal);

  final Map legal;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    Widget cell(String label, String value) => Expanded(
          child: Column(
            children: [
              Text(
                label,
                style: theme.bodyMedium.override(
                  font: GoogleFonts.publicSans(),
                  color: theme.secondaryText,
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                ),
              ),
              const SizedBox(height: 4.0),
              SelectableText(
                value.isEmpty ? '—' : value,
                style: theme.bodyMedium.override(
                  font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
        );
    // Sin fondo de color: una línea fina lo separa de los datos de arriba.
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.only(top: 14.0),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE9EFF2))),
      ),
      child: Column(
        children: [
          Text(
            'Datos registrales',
            style: theme.bodyMedium.override(
              font: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
              color: ListingHqUi.textDark,
              fontSize: 13.0,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              cell('Finca', _str(legal['finca'])),
              cell('Folio', _str(legal['folio'])),
              cell('Libro', _str(legal['libro'])),
            ],
          ),
        ],
      ),
    );
  }
}

String _str(dynamic v) => v == null ? '' : v.toString().trim();
Map _map(dynamic v) => v is Map ? v : const {};
