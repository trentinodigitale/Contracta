namespace eProcurementNext.Email
{
    public class Cr : ICr
    {
        private const char OFFSETDISPARI = 'e';
        private const char OFFSETPARI = 'h';

        public string Cript(string strValue)
        {
            string strCript = "";

            if (strValue != "")
            {
                char strTemp = (char)0;

                int nAsc = 0;

                int nLen = 0;

                nLen = strValue.Length;

                int i = 0;

                for (i = 0; i < nLen; i++)
                {
                    strTemp = strValue[i];

                    if (i % 2 == 0)
                    {
                        nAsc = strTemp + (i + OFFSETDISPARI);
                    }
                    else
                    {
                        nAsc = strTemp + (i + OFFSETPARI);
                    }

                    if (nAsc > 255)
                    {
                        nAsc = nAsc - 255;
                    }

                    strTemp = (char)nAsc;

                    strCript = strCript + strTemp;
                }
            }

            return strCript;
        }

        public string DeCript(string strCript)
        {

            string strValue = "";

            if (strCript != "")
            {

                int nAsc = 0;

                char strTemp = (char)0;

                int nLen = 0;

                nLen = strCript.Length;

                for (int i = 0; i < strCript.Length; i++)
                {
                    strTemp = strCript[i];

                    if (i % 2 == 0)
                    {
                        nAsc = strTemp - (i + OFFSETDISPARI);
                    }
                    else
                    {
                        nAsc = strTemp - (i + OFFSETPARI);
                    }

                    if (nAsc <= 0)
                    {
                        nAsc = nAsc + 255;
                    }

                    strTemp = (char)nAsc;

                    strValue = strValue + strTemp;
                }
            }

            return strValue;
        }
    }
}
