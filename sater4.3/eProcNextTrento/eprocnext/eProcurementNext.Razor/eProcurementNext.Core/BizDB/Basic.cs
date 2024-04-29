using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using System.Data.SqlClient;
using System.Globalization;

namespace eProcurementNext.BizDB
{
    public class Basic
    {


        public static string GetValueSys(SqlConnection cnLocal, string NameSys, SqlTransaction? transaction = null)
        {
            string ret = "";

            Dictionary<string, object?> pars = new Dictionary<string, object?>();
            pars.Add("@dzt_name", NameSys);

            CommonDbFunctions cdf = new CommonDbFunctions();
            var rs = cdf.GetRSReadFromQueryWithTransaction("select DZT_ValueDef from lib_dictionary with(nolock) where dzt_name = @dzt_name", cnLocal.ConnectionString, cnLocal, transaction, parCollection: pars);

            if (rs != null && !(rs.EOF && rs.BOF))
            {

                rs.MoveFirst();

                if (rs["DZT_ValueDef"] != null)
                {
                    ret = (string)rs["DZT_ValueDef"];
                }
            }

            return ret;
        }

        public string GetCTLParam(string Contesto, string Oggetto, string Proprieta)
        {
            string ret = "";

			var sqlParams = new Dictionary<string, object?>();
			sqlParams.Add("@Contesto", Contesto);
            sqlParams.Add("@Oggetto", Oggetto);
            sqlParams.Add("@Proprieta", Proprieta);

            string strSql = "select valore from ctl_parametri with(nolock) where Contesto = @Contesto and Oggetto = @Oggetto and Proprieta = @Proprieta and Deleted=0";

            CommonDbFunctions cdf = new();
            var rs = cdf.GetRSReadFromQuery_(strSql, ApplicationCommon.Application.ConnectionString, parCollection: sqlParams);

            if (rs is not null && !(rs.EOF && rs.BOF))
            {
                rs.MoveFirst();

                if (rs["valore"] is not null)
                {
                    ret = (string)rs["valore"];
                }
            }

            return ret;
        }

        public string GetSepDecimal()
        {
            return CultureInfo.CurrentCulture.NumberFormat.NumberDecimalSeparator;
        }

        public string GetSepDate()
        {
            return CultureInfo.CurrentCulture.DateTimeFormat.DateSeparator;
        }

        public string GetSepTime()
        {
            return CultureInfo.CurrentCulture.DateTimeFormat.TimeSeparator;
        }
        public bool IsEnabled(string Permission, int indP)
        {
            if (indP > 0 && indP < Permission.Length && Permission[indP] == '1')
            {
                return true;
            }
            return false;
        }

        public TSRecordSet User_GetInfoAttrib(long lIdPfu, string Attrib, string strConnectionString)
        {
            TSRecordSet? rs = null;

			var sqlParams = new Dictionary<string, object?>();
			sqlParams.Add("@IdPfu", lIdPfu);
            sqlParams.Add("@Attrib", Attrib);

            string strSql = "select dztNome, attValue from ProfiliutenteAttrib with(nolock) where IdPfu=@IdPfu and dztNome = @Attrib order by IdUsAttr";

            try
            {
                CommonDbFunctions cdf = new();
                rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString, parCollection: sqlParams);
            }
            catch (Exception ex)
            {
                throw new Exception("User_GetInfoAttrib ( " + strSql + " )", ex);
            }

            return rs;
        }


        public TSRecordSet User_GetInfo(long lIdPfu, string strConnectionString)
        {
            TSRecordSet? rs = null;

			var sqlParams = new Dictionary<string, object?>();
			sqlParams.Add("@IdPfu", lIdPfu);

            string strSql = "select dztNome, attValue from ProfiliutenteAttrib with(nolock) where IdPfu=@lIdPfu";

            try
            {
                CommonDbFunctions cdf = new();
                rs = cdf.GetRSReadFromQuery_(strSql, strConnectionString, null, parCollection: sqlParams);
            }
            catch (Exception ex)
            {
                throw new Exception("User_GetInfo ( " + strSql + " )", ex);
            }

            return rs;
        }
    }
}
