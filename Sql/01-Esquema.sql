-- Ejecutar en (localdb)\MSSQLLocalDB. No elimina ni reemplaza objetos existentes.
USE master;
GO
IF DB_ID(N'EncuentroAcademicoDB') IS NULL
    EXEC(N'CREATE DATABASE EncuentroAcademicoDB');
GO
USE EncuentroAcademicoDB;
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF OBJECT_ID(N'dbo.Estudiantes', N'U') IS NULL
 CREATE TABLE dbo.Estudiantes(Idestudiante int IDENTITY PRIMARY KEY, nombres nvarchar(80) NOT NULL, apellidos nvarchar(80) NOT NULL, email nvarchar(160) NOT NULL, telefono varchar(10) NOT NULL);
IF OBJECT_ID(N'dbo.Programas', N'U') IS NULL
 CREATE TABLE dbo.Programas(Idprograma int IDENTITY PRIMARY KEY, nombre nvarchar(100) NOT NULL UNIQUE);
IF OBJECT_ID(N'dbo.Semestre', N'U') IS NULL
 CREATE TABLE dbo.Semestre(Idsemestres int IDENTITY PRIMARY KEY, descripcion nvarchar(50) NOT NULL UNIQUE);
IF OBJECT_ID(N'dbo.TipoParticipacion', N'U') IS NULL
 CREATE TABLE dbo.TipoParticipacion(Idparticipacion int IDENTITY PRIMARY KEY, descripcion nvarchar(100) NOT NULL UNIQUE);
IF OBJECT_ID(N'dbo.Tema', N'U') IS NULL
 CREATE TABLE dbo.Tema(Idtema int IDENTITY PRIMARY KEY, descripcion nvarchar(100) NOT NULL UNIQUE);
IF OBJECT_ID(N'dbo.Jornada', N'U') IS NULL
 CREATE TABLE dbo.Jornada(Idjornada int IDENTITY PRIMARY KEY, descripcion nvarchar(50) NOT NULL UNIQUE);
IF OBJECT_ID(N'dbo.Registro', N'U') IS NULL
 CREATE TABLE dbo.Registro(numero int IDENTITY PRIMARY KEY,
 Idestudiante int NOT NULL REFERENCES dbo.Estudiantes(Idestudiante),
 Idprograma int NOT NULL REFERENCES dbo.Programas(Idprograma),
 Idsemestres int NOT NULL REFERENCES dbo.Semestre(Idsemestres),
 Idparticipacion int NOT NULL REFERENCES dbo.TipoParticipacion(Idparticipacion),
 Idtema int NOT NULL REFERENCES dbo.Tema(Idtema),
 Idjornada int NOT NULL REFERENCES dbo.Jornada(Idjornada),
 comentarios nvarchar(500) NULL);
IF OBJECT_ID(N'dbo.RegistroTema', N'U') IS NULL
 CREATE TABLE dbo.RegistroTema(numero int NOT NULL REFERENCES dbo.Registro(numero), Idtema int NOT NULL REFERENCES dbo.Tema(Idtema), CONSTRAINT PK_RegistroTema PRIMARY KEY(numero,Idtema));
COMMIT;
GO
-- El tema principal siempre forma parte del puente, incluso ante inserciones SQL directas.
IF OBJECT_ID(N'dbo.TR_Registro_TemaPrincipal', N'TR') IS NULL
 EXEC(N'CREATE TRIGGER dbo.TR_Registro_TemaPrincipal ON dbo.Registro AFTER INSERT, UPDATE AS
 BEGIN
 SET NOCOUNT ON;
 INSERT dbo.RegistroTema(numero,Idtema)
 SELECT i.numero,i.Idtema FROM inserted i
 WHERE NOT EXISTS(SELECT 1 FROM dbo.RegistroTema rt WHERE rt.numero=i.numero AND rt.Idtema=i.Idtema);
 END');
GO
IF OBJECT_ID(N'dbo.TR_RegistroTema_ProtegerPrincipal', N'TR') IS NULL
 EXEC(N'CREATE TRIGGER dbo.TR_RegistroTema_ProtegerPrincipal ON dbo.RegistroTema AFTER DELETE, UPDATE AS
 BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM dbo.Registro r JOIN deleted d ON r.numero=d.numero AND r.Idtema=d.Idtema
 WHERE NOT EXISTS(SELECT 1 FROM dbo.RegistroTema rt WHERE rt.numero=r.numero AND rt.Idtema=r.Idtema))
 THROW 51001, ''El tema principal debe estar asociado al registro.'', 1;
 END');
GO
