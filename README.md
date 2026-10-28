# DOVIA

A new Flutter project.

## Getting Started

FlutterFlow projects are built to run on the Flutter _stable_ release.

## Firma del release de Android

Sin `android/key.properties` el release se firma con la clave de debug: sirve
para las APK de prueba (`tools/build_apks.ps1`), no para Play Store.

Para publicar, generar una vez la clave de upload y guardarla fuera del repo
(si se pierde, hay que pedirle a Google que la reemplace):

```bash
keytool -genkey -v -keystore C:/claves/dovia-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

y crear `android/key.properties` (no se versiona, igual que los `.jks`):

```properties
storeFile=C:/claves/dovia-upload.jks
storePassword=...
keyAlias=upload
keyPassword=...
```
