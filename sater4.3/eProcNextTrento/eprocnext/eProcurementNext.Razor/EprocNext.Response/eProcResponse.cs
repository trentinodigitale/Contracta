using System.Text;
using Microsoft.AspNetCore.Http;

namespace eProcurementNext.CommonModule
{
    public class EprocResponse : IEprocResponse
    {
        private readonly StringBuilder response;
        private int mp_xmlAttachType; //'-- 1 = Base64, 2 = FormaTecnica, 3 = hash SHA del file
        public EprocResponse(string? XML_ATTACH_TYPE = "1", int capacity = 0)
        {
            //Federico: nota : passare la capacità dello string builder ne
            //  aumenta le performance, anche del doppio, chiaramente un utilizzo sovradimensionato
            //  porta ad uno spreco di memoria

            if ( capacity == 0)
            { 
                response = new StringBuilder();
            }
            else
            { 
                response = new StringBuilder(capacity);
            }

            if (!string.IsNullOrEmpty(XML_ATTACH_TYPE))
                mp_xmlAttachType = Convert.ToInt32(XML_ATTACH_TYPE);
            else
                mp_xmlAttachType = 1;
            
        }

        public void Write(string str)
        {
            response.Append(str);
        }

		public void Write(char str)
		{
            //Federico: l'append di un char rispetto all'append di una string di 1 carattere è molto più performante
			response.Append(str);
		}

		public void BinaryWrite(HttpContext _context, byte[] bytes){
            _context.Response.Body.Write(bytes, 0, bytes.Length);
        }

        public string Out()
        {
            return response.ToString();
        }

        public void Clear()
        {
           //response = new StringBuilder()
           response.Clear();
        }

        public int getXmlAttachType()
        {
            return mp_xmlAttachType;
        }
    }
}