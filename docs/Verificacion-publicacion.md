# Verificación para GitHub

Fecha: 25 de octubre de 2026, America/Bogota.

Repositorio independiente: `registro-encuentro-parcial`, propietario previsto `jvidesDev`, visibilidad privada y rama `main`.

## Compilación de esta copia

MSBuild instalado con Visual Studio Community 2026 ejecutó **Rebuild Debug** sobre la solución: salida 0, **0 errores y 0 advertencias**. Framework conservado: .NET Framework 4.7.2. Se comprobaron los archivos Compile/Content/None y todas las referencias HintPath del csproj: presentes. No requiere paquetes NuGet.

No se ejecutaron formularios ni scripts SQL de escritura durante la preparación para GitHub. Los informes funcionales previos se mantienen identificados como históricos; no equivalen a pruebas nuevas. La ejecución F5 y funcional en otro equipo sigue requiriendo preparar su LocalDB propia.

## Integridad y seguridad

Se compararon hashes SHA-256: los archivos originales no se modificaron y las fuentes funcionales de la copia son idénticas. Solo se agregó o ajustó documentación, .gitignore y, en Login, scripts adicionales de reconstrucción y demostración. Las cadenas SQL existentes usan autenticación integrada; no contienen contraseñas SQL. Se revisaron patrones de tokens, claves privadas y secretos, sin hallazgos reales.

Se excluyeron .vs, bin, obj, archivos de usuario, packages restaurables, bases físicas y respaldos, ZIP duplicados, certificados privados, variables .env, cachés y logs de compilación con rutas locales. Las guías PDF y fotografías de clase no se publicaron: no son dependencias del proyecto. Se retiraron de los documentos las rutas personales del equipo. No se incluyó AGENTS.md con instrucciones locales ajenas al código entregado.

Las tres capturas y CSV de evidencia contienen exclusivamente estudiantes ficticios y correos example.test. No se exportó una base real.
