using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;

namespace RegistroEncuentroParcial
{
    // Una clase pequeña para separar SQL de los eventos del formulario.
    public static class DatosEncuentro
    {
        private static SqlConnection Conexion()
        {
            return new SqlConnection(ConfigurationManager.ConnectionStrings["EncuentroAcademico"].ConnectionString);
        }

        public static DataTable Catalogo(string nombre)
        {
            // Lista cerrada: el nombre de una tabla nunca proviene de un parámetro HTTP.
            var consultas = new Dictionary<string, string> {
                { "Programas", "SELECT Idprograma AS Id, nombre AS Texto FROM dbo.Programas ORDER BY Idprograma" },
                { "Semestre", "SELECT Idsemestres AS Id, descripcion AS Texto FROM dbo.Semestre ORDER BY Idsemestres" },
                { "TipoParticipacion", "SELECT Idparticipacion AS Id, descripcion AS Texto FROM dbo.TipoParticipacion ORDER BY Idparticipacion" },
                { "Jornada", "SELECT Idjornada AS Id, descripcion AS Texto FROM dbo.Jornada ORDER BY Idjornada" },
                { "Tema", "SELECT Idtema AS Id, descripcion AS Texto FROM dbo.Tema ORDER BY Idtema" }
            };
            using (var cn = Conexion())
            using (var da = new SqlDataAdapter(consultas[nombre], cn))
            {
                var tabla = new DataTable();
                da.Fill(tabla);
                return tabla;
            }
        }

        public static int Guardar(string nombres, string apellidos, string correo, string telefono,
            int programa, int semestre, int participacion, int jornada, int[] temas, string comentarios)
        {
            if (temas == null || temas.Length == 0) throw new ArgumentException("Se requiere un tema.");
            var seleccion = temas.Distinct().OrderBy(x => x).ToArray();
            using (var cn = Conexion())
            {
                cn.Open();
                using (var tx = cn.BeginTransaction())
                {
                    try
                    {
                        int estudiante;
                        using (var cmd = new SqlCommand(@"INSERT dbo.Estudiantes(nombres,apellidos,email,telefono)
                            VALUES(@n,@a,@e,@t); SELECT CAST(SCOPE_IDENTITY() AS int);", cn, tx))
                        {
                            cmd.Parameters.Add("@n", SqlDbType.NVarChar, 80).Value = nombres;
                            cmd.Parameters.Add("@a", SqlDbType.NVarChar, 80).Value = apellidos;
                            cmd.Parameters.Add("@e", SqlDbType.NVarChar, 160).Value = correo;
                            cmd.Parameters.Add("@t", SqlDbType.VarChar, 10).Value = telefono;
                            estudiante = (int)cmd.ExecuteScalar();
                        }
                        int numero;
                        using (var cmd = new SqlCommand(@"INSERT dbo.Registro(Idestudiante,Idprograma,Idsemestres,Idparticipacion,Idtema,Idjornada,comentarios)
                            VALUES(@e,@p,@s,@pa,@t,@j,@c); SELECT CAST(SCOPE_IDENTITY() AS int);", cn, tx))
                        {
                            cmd.Parameters.Add("@e", SqlDbType.Int).Value = estudiante;
                            cmd.Parameters.Add("@p", SqlDbType.Int).Value = programa;
                            cmd.Parameters.Add("@s", SqlDbType.Int).Value = semestre;
                            cmd.Parameters.Add("@pa", SqlDbType.Int).Value = participacion;
                            cmd.Parameters.Add("@t", SqlDbType.Int).Value = seleccion[0];
                            cmd.Parameters.Add("@j", SqlDbType.Int).Value = jornada;
                            cmd.Parameters.Add("@c", SqlDbType.NVarChar, 500).Value = string.IsNullOrWhiteSpace(comentarios) ? (object)DBNull.Value : comentarios;
                            numero = (int)cmd.ExecuteScalar();
                        }
                        // El trigger ya insertó el principal; los demás se guardan aquí.
                        foreach (int tema in seleccion.Skip(1))
                        using (var cmd = new SqlCommand("INSERT dbo.RegistroTema(numero,Idtema) VALUES(@n,@t)", cn, tx))
                        {
                            cmd.Parameters.Add("@n", SqlDbType.Int).Value = numero;
                            cmd.Parameters.Add("@t", SqlDbType.Int).Value = tema;
                            cmd.ExecuteNonQuery();
                        }
                        tx.Commit();
                        return numero;
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }
    }
}
