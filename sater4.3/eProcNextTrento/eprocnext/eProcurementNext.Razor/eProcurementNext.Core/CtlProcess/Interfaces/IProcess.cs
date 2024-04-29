using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.CtlProcess.Interfaces
{
    public interface IProcess
    {
        ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1);
    }
}