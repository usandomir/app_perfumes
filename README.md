# App Perfumes

Aplicación Flutter para gestionar una colección personal de perfumes.

## Funcionalidad principal

- Registro e inicio de sesión de usuarios locales.
- Catálogo de perfumes por usuario.
- Alta, edición y eliminación de perfumes.
- Vista en grilla, lista y modo compacto.
- Detalle con descripción, especificaciones y opiniones asociadas al perfume.
- Selección de imagen desde cámara o galería.
- Preferencias de tema y moneda.

## Stack técnico

- Flutter y Dart.
- Riverpod para estado.
- GoRouter para navegación.
- Sqflite para persistencia local.
- Shared Preferences para datos simples de sesión y preferencias.

## Cómo levantar el proyecto

```powershell
flutter pub get
flutter run
```

Para revisar el análisis estático:

```powershell
flutter analyze
```

## Notas de desarrollo

La persistencia está separada en repositorios para facilitar una futura migración a Firebase. Por ahora la app trabaja con SQLite local, pero las pantallas quedan desacopladas de la implementación concreta de datos.
