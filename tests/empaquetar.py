"""Crea la entrega sin salidas de compilación ni carpetas temporales."""
from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
root=Path(__file__).resolve().parents[1]
target=root.parent/'RegistroEncuentroParcial-Entrega.zip'
excluded={'.vs','bin','obj','.git','__pycache__'}
with ZipFile(target,'w',ZIP_DEFLATED,compresslevel=9) as z:
 for p in sorted(root.rglob('*')):
  relative=p.relative_to(root)
  if p.is_file() and not excluded.intersection(relative.parts) and p.suffix not in {'.user','.suo','.pyc'}:
   z.write(p,Path(root.name)/relative)
with ZipFile(target) as z:
 assert z.testzip() is None,'ZIP dañado'
 files=set(z.namelist())
 for name in ['RegistroEncuentroParcial.sln','RegistroEncuentroParcial.csproj','Default.aspx','Default.aspx.cs','Default.aspx.designer.cs','Web.config','Evidencias/01-formulario.png','Evidencias/02-validacion.png','Evidencias/03-registro-exitoso.png','docs/Explicacion-y-trazabilidad.md','Sql/01-Esquema.sql','Sql/02-Catalogos.sql']:
  assert root.name+'/'+name in files,'Falta '+name
 assert all(not excluded.intersection(Path(x).parts) for x in files)
print('ZIP verificado:',target)
print('Archivos:',len(files))
print('Bytes:',target.stat().st_size)
assert target.stat().st_size<4_000_000,'Supera 4 MB'
