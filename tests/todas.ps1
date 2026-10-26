$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Data
$cn=New-Object System.Data.SqlClient.SqlConnection('Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=EncuentroAcademicoDB;Integrated Security=True;Encrypt=False')
function CountRecords {
 $cn.Open()
 try { $cmd=$cn.CreateCommand();$cmd.CommandText='SELECT COUNT(*) FROM dbo.Registro'; return $cmd.ExecuteScalar() }
 finally {$cn.Close()}
}
$antes=CountRecords
$bundledPython=Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (Test-Path -LiteralPath $bundledPython) { $pythonPath=$bundledPython }
else { $pythonPath=(Get-Command python -ErrorAction Stop).Source }
$env:PYTHONIOENCODING='utf-8'
& $pythonPath (Join-Path $PSScriptRoot 'servidor.py')
if ($LASTEXITCODE -ne 0) {throw 'Fallaron pruebas HTTP'}
$despues=CountRecords
if (($despues-$antes) -ne 2) {throw 'Cambió el número de registros fuera de las dos inscripciones válidas esperadas'}
Write-Output ('PASS: solo los dos casos válidos guardaron registros SQL; antes='+$antes+', después='+$despues)
& (Join-Path $PSScriptRoot 'sql-test.ps1')
$cn.Dispose()
