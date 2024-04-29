using Microsoft.AspNetCore.Http;
using System.Text;

namespace eProcurementNext.CommonModule
{
    public class EprocResponse : IEprocResponse
    {
        private readonly StringBuilder _response;
        private readonly int _mpXmlAttachType; //'-- 1 = Base64, 2 = FormaTecnica, 3 = hash SHA del file
        public EprocResponse(string? XML_ATTACH_TYPE = "1", int capacity = 0)
        {
	        //Federico: nota : passare la capacità dello string builder ne
            //  aumenta le performance, anche del doppio, chiaramente un utilizzo sovradimensionato
            //  porta ad uno spreco di memoria

            _response = capacity == 0 ? new StringBuilder() : new StringBuilder(capacity);

            _mpXmlAttachType = !string.IsNullOrEmpty(XML_ATTACH_TYPE) ? Convert.ToInt32(XML_ATTACH_TYPE) : 1;
        }

        public void Write(string str)
        {
            _response.Append(str);
        }

        public void Write(char str)
        {
            //Federico: l'append di un char rispetto all'append di una string di 1 carattere è molto più performante
            _response.Append(str);
        }

        public void BinaryWrite(HttpContext context, byte[] bytes)
        {
            context.Response.Body.Write(bytes, 0, bytes.Length);
        }

        public string Out()
        {
            return _response.ToString();
        }

        public void Clear()
        {
            //response = new StringBuilder()
            _response.Clear();
        }

        public int getXmlAttachType()
        {
            return _mpXmlAttachType;
        }
    }
}