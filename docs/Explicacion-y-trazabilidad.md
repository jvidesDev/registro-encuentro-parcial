# Controles, eventos y relación con la guía

## Explicación para la sustentación

`Default.aspx` define la interfaz y controles de servidor con `runat="server"`. El atributo `ID` permite acceder al mismo control desde C#. `Default.aspx.designer.cs` declara esos controles y se vincula a la clase parcial del code-behind; no contiene lógica de negocio.

Se usan siete tipos principales de controles: TextBox, DropDownList, RadioButtonList, CheckBoxList, CheckBox, Label y Button, además de los validadores. Existen once campos de entrada: cuatro datos personales, dos listas académicas, participación, jornada, temas, comentarios y aceptación. Cada control de entrada tiene etiqueta o leyenda de grupo.

`Page_Load` carga los cinco catálogos SQL solo cuando `!IsPostBack`, para no perder las selecciones al enviar el formulario. Web Forms conserva controles y selecciones mediante ViewState, con validación de eventos habilitada por defecto.

`btnRegistrar_Click` llama a `Page.Validate("Registro")`, verifica `Page.IsValid`, lee los valores y llama a `DatosEncuentro.Guardar`. RequiredFieldValidator cubre los campos y listas obligatorios. RegularExpressionValidator verifica correo y teléfono. CustomValidator comprueba temas, aceptación, longitudes, espacios y selecciones en el servidor. ValidationSummary reúne los errores. La configuración `UnobtrusiveValidationMode=None` permite los validadores tradicionales sin depender de jQuery. El servidor valida aunque el navegador no ejecute JavaScript.

La persistencia comienza una transacción SQL. Se inserta el estudiante, se recupera su ID con SCOPE_IDENTITY, se inserta Registro y se guardan los temas adicionales. Commit confirma todas las operaciones; cualquier excepción produce Rollback. Las consultas usan parámetros con tipo y tamaño explícitos. El navegador recibe un mensaje comprensible, sin detalles internos de excepciones SQL.

`btnLimpiar_Click` llama a `Restablecer`: vacía todos los textos y selecciones, desmarca aceptación y oculta validaciones y mensajes. `btnCancelar_Click` redirige a `Cancelado.aspx`, donde se puede iniciar otra inscripción. Ambos tienen `CausesValidation=false`; ninguno llama a SQL para guardar. `lblMensaje` muestra la confirmación personalizada codificada con HtmlEncode.

## Trazabilidad de requisitos del PDF

| Requisito de la sección 9 | Implementación / evidencia |
|---|---|
| 1. Web Application .NET Framework y Web Forms | Solución y csproj clásico, C#, net472, referencia System.Web, MSBuild de VS |
| 2. Default.aspx y Default.aspx.cs | Formulario principal y sus eventos en la raíz |
| 3. Mínimo seis tipos | Siete tipos principales más validadores |
| 4. Ocho entradas | Once campos/grupos de entrada |
| 5. Tres botones diferentes | Registrar guarda, Limpiar restablece, Cancelar abre otra pantalla |
| 6. IDs únicos | IDs pedidos en la guía, declaraciones designer y validadores identificados |
| 7. Validaciones obligatorias | RequiredFieldValidator, Regex, CustomValidator, Page.IsValid y comprobación servidor |
| 8. Evento Click C# | Tres manejadores Click en Default.aspx.cs |
| 9. Resultado dinámico | Nombre completo, código, programa, semestre, participación, jornada y temas |
| 10. Pruebas válidas e inválidas | 18 pruebas HTTP y pruebas SQL; capturas reales |
| 11. Funcionamiento IIS Express/F5 | Ejecución real en IIS Express en puerto 51842; proyecto configurado para F5 |

La rúbrica de estructura (10), interfaz (15), variedad (15), nomenclatura (10), validaciones (15), C# (15), retroalimentación (5), pruebas (5) y presentación (10) se respalda con esos mismos archivos y esta explicación. No se adjudica una calificación: corresponde al docente.

## Siete entregables del PDF

| Entregable | Archivo o ubicación |
|---|---|
| Proyecto completo Visual Studio | RegistroEncuentroParcial.sln y archivos de esta carpeta |
| Captura del formulario terminado | Evidencias/01-formulario.png |
| Captura de validación | Evidencias/02-validacion.png |
| Captura de éxito | Evidencias/03-registro-exitoso.png |
| Default.aspx | Default.aspx |
| Default.aspx.cs | Default.aspx.cs |
| Explicación oral o escrita | Este documento, apartado de controles y eventos |

Los scripts, modelo, README y pruebas SQL son materiales complementarios. La guía plantea preparación futura para persistencia; no exige guardar en SQL. La conexión actual se agregó por solicitud del usuario y por las fotografías del modelo.

## Modelo de datos y decisiones

Se revisaron las dos fotografías localizadas en `entrada/docs`: imagen del 19 de octubre (esquema manuscrito) e imagen del 21 de octubre (diagrama relacional). Coinciden en siete entidades fundamentales. Se conserva la denominación de la petición: `Estudiantes`, `Programas`, `Semestre`, `TipoParticipacion`, `Tema`, `Jornada` y `Registro`.

| Tabla | Clave primaria | Relación |
|---|---|---|
| Estudiantes | Idestudiante | Un estudiante puede tener varios registros |
| Programas | Idprograma | Un programa participa en muchos registros |
| Semestre | Idsemestres | Un semestre aparece en muchos registros |
| TipoParticipacion | Idparticipacion | Un tipo aparece en muchos registros |
| Tema | Idtema | Catálogo para tema principal y tabla puente |
| Jornada | Idjornada | Una jornada aparece en muchos registros |
| Registro | numero | Seis FK a estudiante, programa, semestre, participación, tema principal y jornada |
| RegistroTema (ampliación) | (numero, Idtema) | Dos FK, a Registro y Tema; relación muchos a muchos sin duplicados |

Todas las columnas del diagrama se conservaron. Los IDs son enteros; los textos utilizan NVARCHAR salvo el teléfono VARCHAR(10). Comentarios permite NULL y tiene límite de 500. Los datos del estudiante se crean por inscripción; no se impone unicidad al correo porque la guía no prohíbe inscribirse varias veces.

`Registro.Idtema` guarda el menor ID entre los temas elegidos y representa el tema principal para mantener el campo del diagrama original. `RegistroTema` contiene TODOS los temas seleccionados, incluido el principal. Un trigger de Registro agrega automáticamente el principal al puente al insertar o cambiarlo; otro trigger impide quitarlo del puente mientras sea principal. La aplicación agrega los otros temas dentro de la misma transacción. Si se cambia el principal directamente en SQL, el anterior sigue como tema adicional, una asociación válida. La prueba SQL demuestra que ningún registro queda con el principal ausente del puente y que el trigger bloquea su eliminación.

Se eligieron triggers en lugar de una FK cíclica porque SQL Server comprueba las FK inmediatamente: dos referencias obligatorias recíprocas impedirían insertar la primera fila. La restricción compuesta del puente impide temas duplicados y sus FK impiden referencias inexistentes.

La guía permite mejorar colores y distribución. Se mantiene el orden de campos y una cuadrícula de dos columnas, con secciones y estilos responsive. El asterisco de comentarios en el mockup contradice la tabla que lo define opcional: se sigue la regla escrita, también pedida por el usuario. Los catálogos son ejemplos educativos porque no se encontró el formulario anterior ni una lista institucional autorizada.

No se agregó login, CRUD de Personas, MVC, Core ni funciones ajenas al registro.
