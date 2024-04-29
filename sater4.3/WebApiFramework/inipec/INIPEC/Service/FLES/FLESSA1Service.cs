using INIPEC.Library;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;

namespace INIPEC.Service.FLES
{
    public class FLESSA1Service
    {
        SqlCommand sqlCmd;
        SqlConnection sqlConnection;
        SqlDataAdapter sqlDataAdapter;
        CultureInfo culture;

        public FLESSA1Service()
        {
            sqlConnection = new SqlConnection(ConfigurationManager.AppSettings["db.conn"]);
            sqlCmd = new SqlCommand
            {
                Connection = sqlConnection
            };
            culture = new CultureInfo("it-IT");
        }

        public AnacFormSA1 recuperaAnacFormSA1(int idDoc)
        {
            AnacFormSA1 anacFormSA1 = new AnacFormSA1();

            sqlCmd.Parameters.Clear();
            sqlCmd.CommandText = "SELECT * FROM FLES_TABLE_SCHEDA_SA1 WITH(NOLOCK) WHERE IDDOC = @idDoc AND STATO_BOZZA = 'Bozza'";
            sqlCmd.CommandType = CommandType.Text;
            sqlCmd.Parameters.AddWithValue("@idDoc", idDoc);

            sqlDataAdapter = new SqlDataAdapter();
            sqlDataAdapter.SelectCommand = sqlCmd;
            DataTable dataTable = new DataTable();
            sqlDataAdapter.Fill(dataTable);

            DatiSA1 datiSA1 = new DatiSA1();
            datiSA1.denominazioneAvanzamento = Convert.ToString(dataTable.Rows[0]["DENOMINAZIONE_AVANZAMENTO"]);
            datiSA1.modalitaPagamento = new Codice() {idTipologica = "modalitaPagamento", codice = Convert.ToString(dataTable.Rows[0]["MODALITA_PAGAMENTO"])};
            datiSA1.dataAvanzamento = Convert.ToDateTime(dataTable.Rows[0]["DATA_AVANZAMENTO"], culture).ToString("yyyy-MM-ddTHH:mm:ssZ");
            datiSA1.impSal = Convert.ToDouble(dataTable.Rows[0]["IMPORTO_CUMULATO"]);
            datiSA1.avanzamento = new Codice() {idTipologica = "avanzamento", codice = Convert.ToString(dataTable.Rows[0]["AVANZAMENTO"])};

            anacFormSA1.avanzamento = datiSA1;

            anacFormSA1.idContratto = Convert.ToString(dataTable.Rows[0]["ID_CONTRATTO"]);

            return anacFormSA1;
        }

        public void updateStato(int idRowScheda, string statoFunzionale, string statoBozza)
        {
            string updateSA1 = $"UPDATE [dbo].[FLES_TABLE_SCHEDA_SA1] SET [DATA_ULTIMA_MODIFICA] = GETDATE(), " +
                $"[STATO_FUNZIONALE] = '{statoFunzionale}', [STATO_BOZZA] = '{statoBozza}' WHERE [IDROW_PCP_SCHEDE] = {idRowScheda};";
            sqlCmd.Parameters.Clear();
            sqlCmd.CommandType = CommandType.Text;
            sqlCmd.CommandText = updateSA1;
            sqlConnection.Open();
            sqlCmd.ExecuteNonQuery();
            sqlConnection.Close();
        }

    }

    /* INIZIO DTO per la scheda SA1 */
    public class BodySA1
    {
        public AnacFormSA1 anacForm { get; set; }
    }

    public class AnacFormSA1
    {
        public string idContratto { get; set; }
        public DatiSA1 avanzamento { get; set; }
    }

    public class DatiSA1
    {
        public string denominazioneAvanzamento { get; set; }
        public Codice modalitaPagamento { get; set; }
        public string dataAvanzamento { get; set; }
        public double impSal { get; set; }
        public Codice avanzamento { get; set; }
    }
    /* FINE DTO per scheda SA1 */

}