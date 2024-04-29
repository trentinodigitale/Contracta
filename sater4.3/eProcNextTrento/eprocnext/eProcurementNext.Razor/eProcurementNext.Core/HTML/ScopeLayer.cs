using Microsoft.AspNetCore.Http;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.HTML
{
    public class ScopeLayer
    {
        private object? mp_input = null; //'es. request
        private object? mp_output = null; //'es. response,file (path + nome file), stringa
        private dynamic mp_ObjSession;
        private int outType; //'1 = response, 2 = file, 3 = stringa
        private object Request_QueryString;
        private bool bPrintBlob; //'-- sostituita da mp_xmlAttachType
        private string mp_outputString;
        private int mp_xmlAttachType; //'-- 1 = Base64, 2 = FormaTecnica, 3 = hash SHA del file

        HttpContext _context = null;

        public ScopeLayer(HttpContext context)
        {
            _context = context;
        }

        public void InitNew(dynamic inputObj, dynamic outputObj, dynamic mp_session, int outputType)
        {
            // On Error GoTo err

            mp_input = inputObj;

            if (outputType != 3)
            {
                mp_output = outputObj;
            }
            else
            { //'per le stringhe
                mp_outputString = outputObj;
            }

            outType = outputType;

            //'If (Not mp_session Is Empty) Then
            mp_ObjSession = mp_session;
            //'End If

            //'If Not mp_session Is Nothing Then
            //    Set Request_QueryString = mp_session(0)
            //'End If
            //
            //'If Request_QueryString("XMLBLOB") <> "" Then
            //'    bPrintBlob = False
            //'Else
            //'    bPrintBlob = True
            //'End If
            //
            //'If Not mp_session Is Nothing Then

            int mp_xmlAttachType = 0;
            if (GetParamURL(_context.Request.QueryString, "XML_ATTACH_TYPE") != "")
            {
                mp_xmlAttachType = CInt(GetParamURL(_context.Request.QueryString, "XML_ATTACH_TYPE"));
            }
            else
            {
                mp_xmlAttachType = 1;
            }

            //'Else

            //'    mp_xmlAttachType = 2

            //'End If

        }




        public void scrivi(string str)
        {
            switch (outType)
            {

                case 1: //'response
                    //mp_output.Write(str);     // TODO sistemare
                    break;
                case 2:
                    //Open mp_output For Output As #1   // TODO completare
                    //Print #1, str
                    //Close #1 'quando richiameremo la "scrivi" sarà in append il file ?
                    break;
                case 3:
                    mp_outputString = mp_outputString + str;
                    break;
            }

        }

        public object getOutput()
        {
            return mp_output;
        }

        public object getInput()
        {
            return mp_input;
        }

        public dynamic getSession()
        {
            return mp_ObjSession;
        }

        public object getOut()
        {
            object getOut = null;

            if (outType != 3)
            {
                getOut = mp_output;
            }
            else
            { //'per le stringhe
                getOut = mp_outputString;
            }

            return getOut;
        }

        public void flush()
        {

            //'-- se l'output è la response
            if (outType == 1)
            {
                //mp_output.flush();    // TODO completare
            }
        }

        public int getXmlAttachType()
        {
            return mp_xmlAttachType;
        }

        public void setXmlAttachType(int tipo)
        {
            mp_xmlAttachType = tipo;
        }
    }
}
