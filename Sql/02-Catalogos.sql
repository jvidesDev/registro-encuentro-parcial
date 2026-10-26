USE EncuentroAcademicoDB;
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
-- Opciones ficticias de demostración, sin atribución a una institución.
INSERT dbo.Programas(nombre) SELECT v FROM (VALUES(N'Ingeniería de Sistemas'),(N'Administración de Empresas'),(N'Contaduría Pública')) x(v) WHERE NOT EXISTS(SELECT 1 FROM dbo.Programas p WHERE p.nombre=x.v);
INSERT dbo.Semestre(descripcion) SELECT v FROM (VALUES(N'1'),(N'2'),(N'3'),(N'4'),(N'5'),(N'6'),(N'7'),(N'8'),(N'9'),(N'10')) x(v) WHERE NOT EXISTS(SELECT 1 FROM dbo.Semestre s WHERE s.descripcion=x.v);
INSERT dbo.TipoParticipacion(descripcion) SELECT v FROM (VALUES(N'Asistente'),(N'Ponente'),(N'Organizador')) x(v) WHERE NOT EXISTS(SELECT 1 FROM dbo.TipoParticipacion t WHERE t.descripcion=x.v);
INSERT dbo.Tema(descripcion) SELECT v FROM (VALUES(N'Tecnología e innovación'),(N'Investigación'),(N'Emprendimiento'),(N'Sostenibilidad')) x(v) WHERE NOT EXISTS(SELECT 1 FROM dbo.Tema t WHERE t.descripcion=x.v);
INSERT dbo.Jornada(descripcion) SELECT v FROM (VALUES(N'Mañana'),(N'Tarde'),(N'Noche')) x(v) WHERE NOT EXISTS(SELECT 1 FROM dbo.Jornada j WHERE j.descripcion=x.v);
COMMIT;
GO
