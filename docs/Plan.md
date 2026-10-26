# Plan y decisiones — 23 de octubre de 2026

Objetivo: cumplir la guía de Web Forms con una aplicación independiente y una ampliación SQL basada en las dos fotografías. Se crea desde cero porque la búsqueda limitada en Documentos no encontró RegistroEncuentro.

Arquitectura: Web Application C#, .NET Framework 4.7.2, IIS Express, System.Data.SqlClient y LocalDB. Default.aspx contiene controles y validadores; Default.aspx.cs maneja eventos; DatosEncuentro.cs carga catálogos y guarda dentro de una transacción. No se requieren paquetes NuGet.

- [x] Crear prueba HTTP del formulario inicial; fallo por conexión rechazada antes de la implementación. Ampliar comprobaciones con casos inválidos, registro, limpieza y cancelación.
- [x] Crear solución, formulario y estilos según mockup de página 2. Comentarios opcionales (tabla de requisitos prevalece sobre asterisco del mockup), máximo 500 caracteres; teléfono de 10 dígitos sin espacios.
- [x] Crear siete tablas originales más RegistroTema. Idtema representa el tema principal (menor ID seleccionado); dos triggers garantizan que también pertenezca al puente. Decisión final: evitar referencias cíclicas, pues SQL Server no admite FK diferibles.
- [x] Ejecutar scripts no destructivos; compilar con MSBuild instalado; probar HTTP y navegador con IIS Express, SQL, transacción y relaciones.
- [x] Crear capturas reales, explicación, trazabilidad, reporte y ZIP sin bin/obj/.vs.

Restricciones: no modificar entrada ni LoginDB; no sobrescribir proyectos o bases. Catálogos de demostración sin atribución institucional. Validación de servidor independiente de JavaScript; mensajes codificados y errores SQL genéricos.

Revisión independiente final: no se encontraron defectos críticos ni importantes. Se corrigió la descripción inicial del mecanismo de consistencia para reflejar los triggers implementados.

Revisión: espacios en nombres, comentarios largos, catálogos manipulados, selección múltiple y rollback ante fallo. Ejecución autónoma autorizada expresamente por el usuario. La carpeta nueva es el aislamiento solicitado; no se crea un worktree ajeno a esa ruta.
