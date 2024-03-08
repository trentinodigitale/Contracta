using Microsoft.Extensions.Configuration;

namespace eProcurementNext.CommonDB
{
    public interface IDbEventViewer
    {
        void traceEventInDB(int tipoEvento, string mErrSource, string mErrDescription);
        void traceEventInDBConnString(int tipoEvento, string mErrSource, string mErrDescription, string strConnectionString, IConfiguration configuration);
    }
}
