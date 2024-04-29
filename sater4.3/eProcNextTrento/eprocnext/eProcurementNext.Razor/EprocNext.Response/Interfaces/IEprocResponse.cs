using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
