"""Pruebas de integración HTTP sin JavaScript, con ViewState real de IIS Express.
Detectan validaciones omitidas, errores de codificación y botones que guardan por error.
Solo crean datos ficticios con dominio example.test. No eliminan información.
"""
import re, urllib.request, urllib.parse, html, json
from html.parser import HTMLParser
from pathlib import Path

BASE='http://localhost:51842/'
class Form(HTMLParser):
 def __init__(self):
  super().__init__();self.hidden={}
 def handle_starttag(self,tag,attrs):
  a=dict(attrs)
  if tag=='input' and a.get('type')=='hidden':self.hidden[a['name']]=a.get('value','')
def get():
 return urllib.request.urlopen(BASE+'Default.aspx').read().decode('utf-8')
def post(changes=None,valid=False,button='btnRegistrar'):
 f=Form();f.feed(get());data=f.hidden
 if valid:
  data.update(txtNombres='Estudiante Ficticio',txtApellidos='Prueba HTTP',txtCorreo='integracion@example.test',txtTelefono='3001234567',ddlPrograma='1',ddlSemestre='1',rblParticipacion='1',ddlJornada='1',chkAcepta='on',txtComentarios='Prueba automática ficticia')
  data['cblTemas$cblTemas_0']='1';data['cblTemas$cblTemas_1']='2'
 for k,v in (changes or {}).items():
  if v is None:data.pop(k,None)
  else:data[k]=v
 data[button]={'btnRegistrar':'Registrar','btnLimpiar':'Limpiar','btnCancelar':'Cancelar'}[button]
 req=urllib.request.Request(BASE+'Default.aspx',urllib.parse.urlencode(data).encode())
 with urllib.request.urlopen(req) as res:return res.read().decode('utf-8'),res.url
results=[]
def check(name,test):
 try:
  test();results.append({'prueba':name,'resultado':'APROBADA'});print('PASS: '+name)
 except Exception as e:
  results.append({'prueba':name,'resultado':'FALLIDA','detalle':str(e)});print('FAIL: '+name+' '+str(e))
def expect(cond,msg):
 if not cond:raise AssertionError(msg)
def invalid(changes,expected,valid=True):
 s,_=post(changes,valid);s=html.unescape(s)
 expect('No se guardó el registro.' in s,'No se bloqueó el registro')
 expect(expected in s,'No apareció '+expected)

check('Formulario inicial y UTF-8',lambda:expect('Correo electrónico' in get() and 'ENCUENTRO ACADÉMICO' in get(),'Codificación o contenido incorrecto'))
check('Campos vacíos en servidor',lambda:invalid({},'Nombres es obligatorio.',False))
check('Nombres de solo espacios',lambda:invalid({'txtNombres':'   '},'No se guardó'))
check('Apellidos vacíos',lambda:invalid({'txtApellidos':''},'Apellidos es obligatorio.'))
check('Correo inválido',lambda:invalid({'txtCorreo':'correo-invalido'},'formato inválido'))
check('Teléfono inválido',lambda:invalid({'txtTelefono':'300 abc'},'formato inválido'))
check('Programa sin seleccionar',lambda:invalid({'ddlPrograma':''},'Selecciona programa'))
check('Semestre sin seleccionar',lambda:invalid({'ddlSemestre':''},'Selecciona semestre'))
check('Participación sin seleccionar',lambda:invalid({'rblParticipacion':None},'Selecciona el tipo'))
check('Jornada sin seleccionar',lambda:invalid({'ddlJornada':''},'Selecciona jornada'))
check('Sin temas',lambda:invalid({'cblTemas$cblTemas_0':None,'cblTemas$cblTemas_1':None},'Selecciona al menos un tema.'))
check('Sin aceptación',lambda:invalid({'chkAcepta':None},'Debes aceptar'))
check('Comentarios de 501 caracteres',lambda:invalid({'txtComentarios':'x'*501},'longitud de los comentarios'))
check('Nombre mayor de 80 caracteres',lambda:invalid({'txtNombres':'x'*81},'No se guardó'))
def valid_registration():
 s,_=post({'txtNombres':'Prueba & Tildes Á','txtComentarios':'x'*500},True)
 expect('¡Registro realizado correctamente para Prueba & Tildes Á' in html.unescape(s) and '&amp;' in s,'Falta confirmación codificada')
 expect('Tecnología e innovación, Investigación' in html.unescape(s),'No se muestran los dos temas')
 expect(re.search(r'id="txtNombres"[^>]*value=',s) is None,'Formulario no restablecido')
check('Registro completo con dos temas, 500 caracteres, UTF-8 y salida codificada',valid_registration)
check('Comentarios opcionales vacíos',lambda:expect('¡Registro realizado correctamente' in html.unescape(post({'txtComentarios':''},True)[0]),'Se rechazaron comentarios vacíos'))
def clear():
 s,_=post({'txtCorreo':'invalido'},True,'btnLimpiar')
 expect('value="Estudiante Ficticio"' not in s and 'value="invalido"' not in s,'Campos no limpiados')
 expect('checked="checked"' not in s,'Selecciones no limpiadas')
 expect('No se guardó el registro.' not in s and '¡Registro realizado' not in s,'Limpiar validó o registró')
check('Limpiar sin validar ni registrar',clear)
def cancel():
 s,url=post({'txtCorreo':'invalido'},True,'btnCancelar')
 expect(url.endswith('Cancelado.aspx') and 'Registro cancelado' in s and 'Iniciar un nuevo registro' in s,'Cancelar no redirige')
check('Cancelar descarta y muestra nueva pantalla sin validar',cancel)
out=Path(__file__).resolve().parents[1]/'Evidencias'/'pruebas-http.json'
out.write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8')
raise SystemExit(any(x['resultado']=='FALLIDA' for x in results))
