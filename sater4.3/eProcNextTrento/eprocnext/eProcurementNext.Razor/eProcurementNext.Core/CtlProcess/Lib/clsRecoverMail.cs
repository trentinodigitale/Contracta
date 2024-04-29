using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.CtlProcess
{
    internal class ClsRecoverMail : ProcessBase
    {
        const string MODULE_NAME = "CtlProcess.ClsRecoverMail";
        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            throw new NotImplementedException();
        }

    }
}