"""Genera lib/notifications/notification_catalog.dart desde el catálogo de
notificaciones del backend (backend/docs/contexts/notification/catalog/*.md).

Uso, desde la raíz de la app:
    python tools/gen_notification_catalog.py <ruta del repo del backend>

El repo del backend puede ser un sparse checkout: se lee de HEAD con git.
"""
import subprocess
import sys

CATALOG = 'backend/docs/contexts/notification/catalog'
OUT = 'lib/notifications/notification_catalog.dart'


def git(repo, *args):
    return subprocess.run(['git', '-C', repo, *args], check=True,
                          capture_output=True, encoding='utf-8').stdout


def dart_str(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def main(repo):
    files = [f for f in git(repo, 'ls-tree', '--name-only', f'HEAD:{CATALOG}').split()
             if f.endswith('.md') and f != 'index.md']
    rows = []
    for f in files:
        for line in git(repo, 'show', f'HEAD:{CATALOG}/{f}').splitlines():
            if not line.startswith('| 0'):
                continue
            c = [x.strip() for x in line.split('|')[1:-1]]
            recipient, role = [x.strip() for x in c[5].split('/')]
            data = [x.strip() for x in c[10].split(',') if x.strip() not in ('', 'None')]
            rows.append((c[0], c[1], c[2], c[3], recipient, role, c[6], c[9], data))
    rows.sort()

    out = [
        '// GENERADO por tools/gen_notification_catalog.py desde el catálogo del',
        '// backend (backend/docs/contexts/notification/catalog). No editar a mano.',
        '',
        "import 'notification_catalog_entry.dart';",
        '',
        'const kNotificationCatalog = <NotificationCatalogEntry>[',
    ]
    for id_, code, title, body, recipient, role, delivery, path, data in rows:
        out += [
            '  NotificationCatalogEntry(',
            f'    id: {dart_str(id_)},',
            f'    code: {dart_str(code)},',
            f'    title: {dart_str(title)},',
            f'    body: {dart_str(body)},',
            f'    recipient: {dart_str(recipient)},',
            f'    role: {dart_str(role)},',
            f'    delivery: {dart_str(delivery)},',
            f'    actionPath: {dart_str(path)},',
            f'    data: [{", ".join(dart_str(d) for d in data)}],',
            '  ),',
        ]
    out += ['];', '']
    with open(OUT, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(out))
    subprocess.run(['dart', 'format', OUT], check=True, capture_output=True, shell=True)
    print(f'{len(rows)} notificaciones -> {OUT}')


if __name__ == '__main__':
    main(sys.argv[1])
