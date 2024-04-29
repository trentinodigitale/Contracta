using System.Data.SqlClient;


namespace eProcurementNext.BizDB
{
    public interface ITabManage
    {
        //Dictionary<string, dynamic> GetRsReadFromQuery(string strSql);
        void ExecSql(string strSql, string? parConnection, SqlConnection? conn = null, Dictionary<string, object> parCollection = null);


    }
}
