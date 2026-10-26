$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Data
$cn=New-Object System.Data.SqlClient.SqlConnection('Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=EncuentroAcademicoDB;Integrated Security=True;Encrypt=False')
$cn.Open()
function Scalar($sql) { $cmd=$cn.CreateCommand(); $cmd.CommandText=$sql; return $cmd.ExecuteScalar() }
function Check($condition,$name) { if (-not $condition) {throw ('FAIL: '+$name)}; Write-Output ('PASS: '+$name) }
try {
 Check ((Scalar 'SELECT COUNT(*) FROM sys.tables') -eq 8) 'Ocho tablas creadas'
 Check ((Scalar 'SELECT COUNT(*) FROM sys.foreign_keys WHERE is_disabled=1 OR is_not_trusted=1') -eq 0) 'Claves foráneas habilitadas y confiables'
 Check ((Scalar 'SELECT COUNT(*) FROM sys.foreign_keys') -eq 8) 'Ocho relaciones de clave foránea'
 Check ((Scalar 'SELECT COUNT(*) FROM dbo.Registro r LEFT JOIN dbo.RegistroTema rt ON rt.numero=r.numero AND rt.Idtema=r.Idtema WHERE rt.numero IS NULL') -eq 0) 'Todo tema principal pertenece al puente'
 Check ((Scalar "SELECT COUNT(*) FROM dbo.Registro r JOIN dbo.Estudiantes e ON e.Idestudiante=r.Idestudiante WHERE e.email='ana.prueba@example.test' AND (SELECT COUNT(*) FROM dbo.RegistroTema rt WHERE rt.numero=r.numero)=2") -ge 1) 'Registro real del navegador con dos temas recuperado'
 $cmd=$cn.CreateCommand()
 $cmd.CommandText=@'
SELECT r.numero,e.nombres,e.apellidos,e.email,p.nombre AS programa,s.descripcion AS semestre,
 tp.descripcion AS participacion,j.descripcion AS jornada,t.descripcion AS tema,r.Idtema AS temaPrincipal
FROM dbo.Registro r JOIN dbo.Estudiantes e ON e.Idestudiante=r.Idestudiante
JOIN dbo.Programas p ON p.Idprograma=r.Idprograma JOIN dbo.Semestre s ON s.Idsemestres=r.Idsemestres
JOIN dbo.TipoParticipacion tp ON tp.Idparticipacion=r.Idparticipacion JOIN dbo.Jornada j ON j.Idjornada=r.Idjornada
JOIN dbo.RegistroTema rt ON rt.numero=r.numero JOIN dbo.Tema t ON t.Idtema=rt.Idtema
WHERE e.email LIKE '%@example.test' ORDER BY r.numero,t.Idtema;
'@
 $da=New-Object System.Data.SqlClient.SqlDataAdapter($cmd);$dt=New-Object System.Data.DataTable;[void]$da.Fill($dt)
 $dt | Select-Object numero,nombres,apellidos,email,programa,semestre,participacion,jornada,tema,temaPrincipal | Export-Csv (Join-Path $PSScriptRoot '..\Evidencias\almacenamiento-sql.csv') -NoTypeInformation -Encoding utf8
 # Se invoca la misma clase usada por el formulario, forzando un tema inexistente después del principal.
 $exe=Join-Path $PSScriptRoot '..\bin\Rollback.exe'
 $reference='/r:'+(Join-Path $PSScriptRoot '..\bin\RegistroEncuentroParcial.dll')
 & "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe" /nologo /r:System.Configuration.dll $reference "/out:$exe" (Join-Path $PSScriptRoot 'Rollback.cs')
 if ($LASTEXITCODE -ne 0) {throw 'No compiló la prueba de rollback'}
 $xml=[xml](Get-Content (Join-Path $PSScriptRoot '..\Web.config') -Raw)
 ('<configuration>'+ $xml.configuration.connectionStrings.OuterXml +'</configuration>') | Set-Content ($exe+'.config') -Encoding utf8
 & $exe
 Check ($LASTEXITCODE -eq 0) 'Rollback completo de la clase de persistencia'
 # No modifica registros existentes: intenta borrar el principal dentro de una transacción que se revierte.
 $blocked=$false
 try { [void](Scalar 'SET XACT_ABORT ON; BEGIN TRANSACTION; DELETE TOP(1) rt FROM dbo.RegistroTema rt JOIN dbo.Registro r ON r.numero=rt.numero AND r.Idtema=rt.Idtema; ROLLBACK; SELECT 1;') } catch { $blocked=$true }
 Check $blocked 'Trigger impide quitar tema principal del puente'
 Write-Output ('Inscripciones ficticias almacenadas: '+(Scalar 'SELECT COUNT(*) FROM dbo.Registro'))
} finally { $cn.Dispose() }
