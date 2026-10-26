using System;
using System.Configuration;
using System.Data.SqlClient;
using RegistroEncuentroParcial;
class RollbackTest
{
 static int Count(SqlConnection cn,string table)
 { using(var cmd=new SqlCommand("SELECT COUNT(*) FROM dbo."+table,cn)) return (int)cmd.ExecuteScalar(); }
 static int Main()
 {
  using(var cn=new SqlConnection(ConfigurationManager.ConnectionStrings["EncuentroAcademico"].ConnectionString))
  {
   cn.Open(); int estudiantes=Count(cn,"Estudiantes"),registros=Count(cn,"Registro"),temas=Count(cn,"RegistroTema");
   bool fallo=false;
   try { DatosEncuentro.Guardar("Rollback","Ficticio","rollback@example.test","3001234567",1,1,1,1,new int[]{1,2147483647},"Prueba de rollback"); }
   catch(SqlException) { fallo=true; }
   if(!fallo || estudiantes!=Count(cn,"Estudiantes") || registros!=Count(cn,"Registro") || temas!=Count(cn,"RegistroTema"))
   { Console.WriteLine("FAIL: rollback de la transacción"); return 1; }
   Console.WriteLine("PASS: fallo en segundo tema revierte estudiante, registro y puente usando DatosEncuentro.Guardar");
   return 0;
  }
 }
}
