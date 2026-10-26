$ErrorActionPreference = 'Stop'
$base = 'http://localhost:51842/'
$r = Invoke-WebRequest ($base + 'Default.aspx') -UseBasicParsing
if ($r.StatusCode -ne 200 -or $r.Content -notmatch 'txtNombres' -or $r.Content -notmatch 'cblTemas') { throw 'Formulario inicial incorrecto' }
Write-Output 'PASS: formulario inicial servido por IIS Express'
