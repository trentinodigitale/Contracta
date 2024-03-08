using Microsoft.Extensions.Configuration;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CommonModule.FileHash;
using System.Text.RegularExpressions;
using eProcurementNext.CommonModule;

namespace eProcurementNext.CommonDB
{
    public class DbEventViewer : IDbEventViewer
    {
        private IConfiguration? _configuration;

        private CommonDbFunctions cdf = new CommonDbFunctions();

        public DbEventViewer(IConfiguration? configuration = null)
        {
            _configuration = configuration;
        }

        public void traceEventInDB(int tipoEvento, string mErrSource, string mErrDescription)
        {
            traceEventInDBConnString(tipoEvento, mErrSource, mErrDescription, "", _configuration);
        }

        public void traceEventInDBConnString(int tipoEvento, string mErrSource, string mErrDescription, string strConnectionString, IConfiguration? configuration = null)
        {
            var sqlParams = new Dictionary<string, object?>();
            string strSql = string.Empty;
            bool bExistNewFields = false;
            int idEventViewer = 0;

            try
            {
                //strSql = "select case when exists (select * from information_schema.columns where table_name = 'CTL_EVENT_VIEWER' AND column_name = 'hashError') then 1 else 0 end as ColExists"
                strSql = "select top 0 * from CTL_EVENT_VIEWER with(nolock)";
                TSRecordSet? rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString);
                if (rs is not null && rs.ColumnExists("hashError"))
                {
                    bExistNewFields = true;
                }
            }
            catch
            {
            }

            //Tronchiamo la descrizione se supera un certo limite di lunghezza stabilito dalla chiave appsetting qui sotto
            int maxLen = Convert.ToInt32(ConfigurationServices.GetKey("EventViewer_Desc_MaxLenght", "8000"));
            mErrDescription = Left(mErrDescription, maxLen);

            string hash = string.Empty;
            if (bExistNewFields)
            {
                hash = GetHashFromString(Algorithm.SHA256, $"{HashWithoutNumbers(mErrSource)}{HashWithoutNumbers(mErrDescription)}");  

                try
                {
                    sqlParams.Add("@hash", hash);
                    strSql = $@"select id from CTL_EVENT_VIEWER with(nolock) where hashError = @hash";
                    TSRecordSet? rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString, sqlParams);
                    if (rs is not null && rs.RecordCount > 0)
                    {
                        idEventViewer = CInt(rs["id"]!);
                    }
                }
                catch
                {
                }
            }

            //Se non ci sono occorrenze dell'hash calcolato (concatenando source+descrizione dell'errore) fa la Insert
            //altrimenti fa l'Update aggiornando solo il contatore errori ed aggiorna la tabella collegata CTL_EVENT_VIEWER_DATES
            if (idEventViewer == 0)
            {
                string strInsertNewFields = string.Empty;
                string strInsertNewValues = string.Empty;
                sqlParams = new Dictionary<string, object?>
                {
                    { "@tipoEvento", tipoEvento },
                    { "@mErrSource", mErrSource },
                    { "@mErrDescription", mErrDescription }
                };
                if (bExistNewFields)
                {
                    sqlParams.Add("@hash", hash);
                    strInsertNewFields = ",[hashError],[errorCount]";
                    strInsertNewValues = $", @hash, 1";
                }
                //se i nuovi campi hashError e errorCount non sono presenti in tabella, nella INSERT omettiamo i campi (strNewFields) e i loro valori (strNewValues)
                strSql = $@"INSERT INTO CTL_EVENT_VIEWER ([data],[tipoEvento],[source],[descrizione]{strInsertNewFields}) VALUES (getdate(), @tipoEvento, @mErrSource, @mErrDescription{strInsertNewValues})";
                cdf.Execute(strSql, strConnectionString, null, parCollection: sqlParams);
            }
            else
            {
                sqlParams.Clear();
                sqlParams.Add("@id", idEventViewer);
                strSql = "UPDATE CTL_EVENT_VIEWER SET errorCount = errorCount + 1 WHERE id = @id";
                cdf.Execute(strSql, strConnectionString, null, parCollection: sqlParams);

                strSql = "INSERT INTO CTL_EVENT_VIEWER_DATES ([idHeader],[dateEvent]) VALUES (@id, getdate())";
                cdf.Execute(strSql, strConnectionString, null, parCollection: sqlParams);
            }
        }

        private string HashWithoutNumbers(string hash)
        {
            Regex regex = new Regex(@"\d+");
            string ret = regex.Replace(CStr(hash), "");   //forziamo il CStr perché soprattutto mErrSource può essere Null
            
            return ret;
        }
    }
}