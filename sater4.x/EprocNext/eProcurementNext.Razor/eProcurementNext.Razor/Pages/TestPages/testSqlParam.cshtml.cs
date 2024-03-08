using System.Data;
using eProcurementNext.Application;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data.SqlClient;
using System.Diagnostics;

namespace eProcurementNext.Razor.TestPages
{
    public class testSqlParam : PageModel
    {
        public void OnGet()
        {
        }

        public long testQuery(string modid, string operation)
        {

            var affected = -1;

            if (string.IsNullOrEmpty(operation) || string.IsNullOrEmpty(modid))
                return affected;


            SqlDataAdapter da;
            using SqlConnection conn = new SqlConnection(ApplicationCommon.Application.ConnectionString);
            using SqlCommand cmd = new SqlCommand();
            cmd.Connection = conn;

            //default 
            var strSql = "select * from CTL_modelattributeproperties with(nolock) where MAP_MA_MOD_ID = @modid";

            //I migliori sono 2,4 e 5 che di fatto vanno a lavorare sul DB con la variabile varchar, cioè coerente con la colonna.
            //i loro tempi di performance ( almeno su aflink_pa_dev ) praticamente si equivalgono e sono nettamente migliori degli altri operation.
            //se non vogliamo cambiare il codice del core, per prevedere la collection di parametri sql tipizzati, suggerisco l'operation 5. 
            //attenzione però alla dimensione che si indica nel cast. farla coerente con la dimensione della colonna o superiore
            switch (operation)
            {
                case "1":

                    cmd.Parameters.AddWithValue("@modid", modid);

                    break;

                case "2":

                    cmd.Parameters.Add("@modid", SqlDbType.VarChar).Value = modid;

                    break;

                case "3":

                    cmd.Parameters.Add("@modid", SqlDbType.NVarChar).Value = modid;

                    break;

                case "4":

                    strSql = $"select * from CTL_modelattributeproperties with(nolock) where MAP_MA_MOD_ID = '{modid.Replace("'", "''")}'";
                    break;

                case "5":

                    strSql = "select * from CTL_modelattributeproperties with(nolock) where MAP_MA_MOD_ID = CAST (  @modid AS VARCHAR(1000) ) ";
                    cmd.Parameters.AddWithValue("@modid", modid);

                    break;

                case "6":

                    strSql = "select * from CTL_modelattributeproperties with(nolock) where MAP_MA_MOD_ID = CAST (  @modid AS NVARCHAR(2000) ) ";
                    cmd.Parameters.AddWithValue("@modid", modid);

                    break;

                default:
                    return affected;
            }

            cmd.CommandType = CommandType.Text;
            cmd.CommandText = strSql;
            
            conn.Open();

            Stopwatch benchmark = new Stopwatch();

            // Avvio del cronometro
            benchmark.Start();

            //Eseguo la query nella modalità richiesta dal chiamante
            affected = cmd.ExecuteNonQuery();

            // Arresto del cronometro
            benchmark.Stop();

            // Calcolo del tempo trascorso in millisecondi
            long elapsedMilliseconds = benchmark.ElapsedMilliseconds;

            conn.Close();
            
            return elapsedMilliseconds;

        }
    }
}
