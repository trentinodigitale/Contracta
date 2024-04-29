using eProcurementNext.CtlProcess.Interfaces;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.CtlProcess
{
    internal abstract class ProcessBase : IProcess
    {
        public abstract ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1);

        public void CloseConnectionIfRequired(SqlConnection cnLocal, dynamic connection)
        {
            if (!(connection is SqlConnection) && cnLocal is not null && cnLocal.State == System.Data.ConnectionState.Open)
            {
                cnLocal.Close();
            }
        }
    }
}
