# Resultados reales de verificación

Fecha de trabajo: 23 de octubre de 2026, hora de Colombia. Todas las pruebas usan datos ficticios del dominio reservado `example.test`. Los registros de demostración se conservaron para poder recuperar evidencia, sin eliminar datos reales.

## Compilación

MSBuild de Visual Studio Community 2026, ruta `C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe`, ejecutó Rebuild de la solución, configuración Debug, .NET Framework 4.7.2. Resultado final: salida 0, **0 errores y 0 advertencias**. Log completo: `Evidencias/msbuild.log`.

Durante la preparación se corrigieron caracteres de escape del archivo csproj y la configuración de lectura UTF-8 del ASPX. La compilación y las capturas entregadas corresponden a los archivos corregidos.

## Ejecución y capturas

IIS Express instalado en `C:\Program Files\IIS Express\iisexpress.exe` ejecutó la aplicación real en `http://localhost:51842/Default.aspx`. Se recibió HTTP 200, se cargaron catálogos desde LocalDB y se interactuó con el formulario en el navegador.

- `01-formulario.png`: formulario completo inicial, sin edición ni simulación.
- `02-validacion.png`: pulsación real de Registrar con campos vacíos; validaciones visibles.
- `03-registro-exitoso.png`: confirmación real de Ana Sofía Prueba Académica, código EA-00001, con Tecnología e innovación e Investigación.

Se verificaron visualmente la distribución de escritorio, controles, tildes y mensajes. La interfaz incluye media query para una columna en pantallas de hasta 640 px.

## Pruebas HTTP contra IIS Express

**18 de 18 aprobadas**, ejecutando solicitudes reales con ViewState y EventValidation, sin JavaScript. Detalle automatizado: `Evidencias/pruebas-http.json`.

| Caso | Resultado |
|---|---|
| Formulario inicial y UTF-8 | Aprobado |
| Campos obligatorios vacíos | Rechazados en servidor |
| Nombres con solo espacios / apellidos vacíos | Rechazados |
| Correo inválido / teléfono inválido | Rechazados |
| Programa / semestre sin seleccionar | Rechazados |
| Participación / jornada sin seleccionar | Rechazados |
| Ningún tema seleccionado | Rechazado |
| Tratamiento de datos sin aceptar | Rechazado |
| Comentarios de 501 caracteres | Rechazados |
| Nombre mayor de 80 caracteres | Rechazado |
| Datos completos, dos temas, comentarios de 500 caracteres | Guardados, confirmación personalizada y campos restablecidos |
| Comentarios opcionales vacíos | Aceptados |
| Datos con ampersand y tildes | Salida HTML codificada, sin perder caracteres |
| Limpiar con correo inválido | Limpia sin validar ni registrar |
| Cancelar con correo inválido | Redirige a cancelación sin validar ni registrar |

Las primeras pruebas HTTP de éxito detectaron nombres incorrectos de CheckBoxList en la herramienta de prueba: se corrigieron para utilizar los nombres reales renderizados por Web Forms. No era una pérdida de temas del formulario; la prueba del navegador ya guardaba ambos. Los resultados finales corresponden a las pruebas corregidas.

## Base de datos

Antes de crear la base se consultó master: existían las bases del sistema y LoginDB; EncuentroAcademicoDB no existía. Se creó exclusivamente EncuentroAcademicoDB. Se crearon las siete tablas del modelo y RegistroTema, con ocho FK habilitadas y confiables.

Comprobaciones aprobadas:

- Recuperación mediante JOIN del registro real del navegador, catálogos y dos temas.
- Ausencia de registros con tema principal fuera del puente.
- Trigger impide retirar el tema principal del puente; operación de prueba revertida, sin borrar datos persistidos.
- La misma clase `DatosEncuentro.Guardar` falló intencionalmente al insertar un segundo tema inexistente; los conteos de estudiantes, registros y asociaciones quedaron iguales a los iniciales. Rollback completo confirmado.
- Segunda ejecución de los scripts sobre la base existente: correcta, sin eliminar ni sobrescribir tablas; los catálogos no se duplican.
- La ejecución conjunta de pruebas compara conteos SQL antes y después: únicamente las dos solicitudes válidas agregan inscripciones; las solicitudes inválidas, Limpiar y Cancelar no guardan.

Evidencias: `pruebas-sql.txt`, `pruebas-completas.txt`, `repeticion-scripts.txt` y `almacenamiento-sql.csv`. El CSV permite verificar los campos recuperados de SQL, incluidos ambos temas de cada inscripción ficticia.

## Revisión y pendientes

Se hizo una revisión independiente de código, SQL, configuración, límites y flujo; no encontró defectos importantes ni críticos. Se actualizó el plan para describir correctamente los triggers utilizados.

**No se ejecutó F5 dentro de la interfaz de Visual Studio**: se probó el mismo proyecto con MSBuild de Visual Studio e IIS Express directamente. La solución está configurada para abrirse y ejecutarse con F5, pero esa pulsación concreta queda como comprobación manual. Tampoco se realizó una prueba visual en un dispositivo móvil físico. No se marcan esas comprobaciones como aprobadas.

Todas las funcionalidades obligatorias del formulario están implementadas y los tres estados exigidos tienen capturas reales. Los pendientes anteriores son comprobaciones de entorno adicionales, no funciones omitidas.
