using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Const;

namespace eProcurementNext.CtlProcess
{
    internal class ClsSetValueXml : ProcessBase
    {
        public override ELAB_RET_CODE Elaborate(string strDocType, dynamic strDocKey, long lIdPfu, string strParam, ref string strDescrRetCode, dynamic? vIdMp = null, dynamic? connection = null, SqlTransaction? transaction = null, int timeout = -1)
        {
            //la classe ClsSetValueXml non è più utile ma viene ancora richiamata nei workflow presenti nel metabase, la rendiamo quindi passante, è sempre un OK
            return ELAB_RET_CODE.RET_CODE_OK;
        }
    }
}