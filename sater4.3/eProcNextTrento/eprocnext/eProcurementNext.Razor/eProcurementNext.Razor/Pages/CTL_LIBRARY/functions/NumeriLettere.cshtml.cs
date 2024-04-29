using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class NumeriLettereModel : PageModel
    {
        public void OnGet()
        {
        }
        public string[] strNumeri;
        public string[] strDecine;
        public static string strVocali;

        private void init()
        {
            strNumeri[0] = "";
            strNumeri[1] = "uno";
            strNumeri[2] = "due";
            strNumeri[3] = "tre";
            strNumeri[4] = "quattro";
            strNumeri[5] = "cinque";
            strNumeri[6] = "sei";
            strNumeri[7] = "sette";
            strNumeri[8] = "otto";
            strNumeri[9] = "nove";
            strNumeri[10] = "dieci";
            strNumeri[11] = "undici";
            strNumeri[12] = "dodici";
            strNumeri[13] = "tredici";
            strNumeri[14] = "quattordici";
            strNumeri[15] = "quindici";
            strNumeri[16] = "sedici";
            strNumeri[17] = "diciasette";
            strNumeri[18] = "diciotto";
            strNumeri[19] = "diciannove";
            strNumeri[20] = "venti";


            strDecine[2] = "venti";
            strDecine[3] = "trenta";
            strDecine[4] = "quaranta";
            strDecine[5] = "cinquanta";
            strDecine[6] = "sessanta";
            strDecine[7] = "settanta";
            strDecine[8] = "ottanta";
            strDecine[9] = "novanta";
            strDecine[10] = "cento";

            strVocali = "aeiou";

        }
        public string NumeroInLettere(int num)
        {
            int l = 0;
            string strNum = "";
            string strApp = "";
            strNum = CStr(num);
            //'strNum = Right(strNum, Len(strNum) - 1)
            l = strNum.Length;
            strApp = "";
            if (l > 3)
            {
                if (l == 4 && Strings.Left(strNum, 1) == "1")
                {
                    strApp = "mille";

                }
                else
                {
                    strApp = TreCifre(CLng(Strings.Left(strNum, l - 3))) + "mila";

                }
            }
            strApp = strApp + TreCifre(CLng(Strings.Right(strNum, 3)));
            return strApp;

        }
        public string TreCifre(long num)
        {
            int l = 0;
            string strNum = "";
            string strApp = "";
            strNum = CStr(num);
            //'strNum = Right(strNum, Len(strNum) - 1)
            l = strNum.Length;
            strApp = "";
            if (l == 3)
            {
                if (Strings.Left(strNum, 1) == "1")
                {
                    strApp = "cento";

                }
                else
                {
                    strApp = strNumeri[CLng(Strings.Left(strNum, 1))] + "cento";

                }
                strNum = Strings.Right(strNum, 2);

            }
            if (CLng(strNum) < 21)
            {
                strApp = strApp + strNumeri[CLng(strNum)];

            }
            else
            {
                strApp = strApp + strDecine[CLng(Strings.Left(strNum, 1))];
                if (!String.Equals(Strings.Right(strNum, 1), "0"))
                {
                    if (strVocali.Contains(Strings.Left(strNumeri[CLng(Strings.Right(strNum, 1))], 1), StringComparison.Ordinal))
                    {
                        strApp = Strings.Left(strApp, Len(strApp) - 1);

                    }
                    strApp = strApp + strNumeri[CLng(Strings.Right(strNum, 1))];

                }

            }
            return strApp;
        }
        public void puliscinumero(int Valore, int importo, int decimali)
        {
            string str = "";
            int p = 0;


            str = Math.Round(CDbl(Valore), 2).ToString();


            p = Strings.InStr(1, str, ",");
            p = p + Strings.InStr(1, str, ".");



            if (p > 0)
            {
                importo = CInt(Strings.Left(str, p - 1));
                decimali = CInt(Strings.Mid((str + "00"), (p + 1), 2));
            }
            else
            {
                importo = CInt(str);
                decimali = 0;

            }
        }
        public string ImportoInLettere(int vale)
        {
            int importo = 0;
            int decimali = 0;
            string _ImportoInLettere = "";

            init();

            puliscinumero(vale, importo, decimali);

            _ImportoInLettere = NumeroInLettere((int)CLng(importo)) + "/" + Strings.Left(decimali + "00", 2);
            return _ImportoInLettere;

        }




    }
}
