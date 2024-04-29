using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;

namespace INIPEC.Service.FLES
{
    public class FLESI1Service
    {
        SqlCommand sqlCmd;
        SqlConnection sqlConnection;
        SqlDataAdapter sqlDataAdapter;
        CultureInfo culture;

        public FLESI1Service()
        {
            sqlConnection = new SqlConnection(ConfigurationManager.AppSettings["db.conn"]);
            sqlCmd = new SqlCommand
            {
                Connection = sqlConnection
            };
            culture = new CultureInfo("it-IT");
        }

        public AnacFormI1 recuperaAnacFormI1(int idDoc)
        {
            AnacFormI1 anacFormI1 = new AnacFormI1();

            sqlCmd.Parameters.Clear();
            sqlCmd.CommandText = "SELECT * FROM FLES_TABLE_SCHEDA_I1 WITH(NOLOCK) WHERE IDDOC = @idDoc AND STATO_BOZZA = 'Bozza'";
            sqlCmd.CommandType = CommandType.Text;
            sqlCmd.Parameters.AddWithValue("@idDoc", idDoc);

            sqlDataAdapter = new SqlDataAdapter();
            sqlDataAdapter.SelectCommand = sqlCmd;
            DataTable dataTable = new DataTable();
            sqlDataAdapter.Fill(dataTable);

            DatiI1 datiI1 = new DatiI1();
            datiI1.consegnaSottoRiserva = Convert.ToInt16(dataTable.Rows[0]["CONSEGNA_SOTTO_RISERVA"]) == 1 ? true : false;
            datiI1.dataEffettivoInizio = Convert.ToDateTime(dataTable.Rows[0]["DATA_EFFETTIVO_INIZIO"], culture).ToString("yyyy-MM-ddTHH:mm:ssZ");
            datiI1.dataFinePrevista = Convert.ToDateTime(dataTable.Rows[0]["DATA_FINE_PREVISTA"], culture).ToString("yyyy-MM-ddTHH:mm:ssZ");

            anacFormI1.datiInizio = datiI1;

            anacFormI1.idContratto = Convert.ToString(dataTable.Rows[0]["ID_CONTRATTO"]);

            return anacFormI1;
        }

        public void updateStato(int idRowScheda, string statoFunzionale, string statoBozza)
        {
            string updateI1 = $"UPDATE [dbo].[FLES_TABLE_SCHEDA_I1] SET [DATA_ULTIMA_MODIFICA] = GETDATE(), " +
                $"[STATO_FUNZIONALE] = '{statoFunzionale}', [STATO_BOZZA] = '{statoBozza}' WHERE [IDROW_PCP_SCHEDE] = {idRowScheda};";
            sqlCmd.Parameters.Clear();
            sqlCmd.CommandType = CommandType.Text;
            sqlCmd.CommandText = updateI1;
            sqlConnection.Open();
            sqlCmd.ExecuteNonQuery();
            sqlConnection.Close();
        }

        public void updateStatoContratto(int idDoc)
        {
            string updateContratto = $"UPDATE CTL_DOC SET StatoFunzionale = 'In Esecuzione' WHERE ID = {idDoc};";
            sqlCmd.Parameters.Clear();
            sqlCmd.CommandType = CommandType.Text;
            sqlCmd.CommandText = updateContratto;
            sqlConnection.Open();
            sqlCmd.ExecuteNonQuery();
            sqlConnection.Close();
        }

    }

    /* INIZIO DTO per la scheda I1 */
    public class BodyI1
    {
        public AnacFormI1 anacForm { get; set; }
    }

    public class AnacFormI1
    {
        public string idContratto { get; set; }
        public DatiI1 datiInizio { get; set; }
    }

    public class DatiI1
    {
        public Boolean consegnaSottoRiserva { get; set; }
        public string dataEffettivoInizio { get; set; }
        public string dataFinePrevista { get; set; }
    }
    /* FINE DTO per scheda I1 */

}