$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Data
$cn = New-Object System.Data.SqlClient.SqlConnection('Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=master;Integrated Security=True;Encrypt=False')
try {
 $cn.Open()
 $cmd = $cn.CreateCommand()
 $cmd.CommandText = "SELECT COUNT(*) FROM sys.databases WHERE name=N'EncuentroAcademicoDB'"
 Write-Output ('Base existente antes del script: ' + $cmd.ExecuteScalar())
 foreach ($file in @('01-Esquema.sql','02-Catalogos.sql')) {
  $sql = Get-Content -LiteralPath (Join-Path $PSScriptRoot $file) -Raw -Encoding UTF8
  foreach ($batch in [regex]::Split($sql, '(?im)^GO\s*$')) {
   if ($batch.Trim()) { $cmd.CommandText=$batch; $cmd.CommandTimeout=60; [void]$cmd.ExecuteNonQuery() }
  }
  Write-Output ('Ejecutado: ' + $file)
 }
 $cmd.CommandText='SELECT COUNT(*) FROM EncuentroAcademicoDB.sys.tables'
 Write-Output ('Tablas: ' + $cmd.ExecuteScalar())
} finally { $cn.Dispose() }
