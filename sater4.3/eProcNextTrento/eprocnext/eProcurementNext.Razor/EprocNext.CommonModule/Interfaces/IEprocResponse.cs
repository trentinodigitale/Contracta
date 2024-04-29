using Microsoft.AspNetCore.Http;

namespace eProcurementNext.CommonModule
{
    public interface IEprocResponse
    {
        void Write(string str);
        string Out();
        void Clear();

        void BinaryWrite(HttpContext _context, byte[] bytes);

        int getXmlAttachType();
    }
}
