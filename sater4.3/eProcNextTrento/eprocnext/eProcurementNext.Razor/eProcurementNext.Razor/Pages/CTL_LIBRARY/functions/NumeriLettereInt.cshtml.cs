using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class NumeriLettereIntModel : PageModel
    {
        public void OnGet()
        {
        }
        public string[] strNumeri;
        public string[] strDecine;
        public string[] centinatia;
        public string strVocali = "";

        public string strMille = "";
        public string strMila = "";
        public string strMilas = "";
        public string strMilione = "";
        public string strMilioni = "";
        public string strMilionis = "";
        public string strMiliardo = "";
        public string strMiliardi = "";
        public string strMiliardis = "";
        public string Sep = "/";
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



            centinatia[1] = "cento";
            centinatia[2] = "duecento";
            centinatia[3] = "trecento";
            centinatia[4] = "quattrocento";
            centinatia[5] = "cinquecento";
            centinatia[6] = "seicento";
            centinatia[7] = "settecento";
            centinatia[8] = "ottocento";
            centinatia[9] = "novecento";


            strVocali = "aeiou";


            strMille = "mille";
            strMila = "mila";
            strMilas = "mila";
            strMilione = "un milione";
            strMilioni = "milioni";
            strMilionis = "milioni";
            strMiliardo = "un miliardo";
            strMiliardi = "miliardi";
            strMiliardis = "miliardi";


        }
        private void initPolacco()
        {
            //'     * TABELLA DEI NUMERI 1/2/3/4/5/6/7/8/9/0
            //'       01  TAB-1.
            //'           05  FILLER          PIC  X(10)   VALUE  'JEDEN - 6'.
            //'           05  FILLER          PIC  X(10)   VALUE  'DWA - 4'.
            //'           05  FILLER          PIC  X(10)   VALUE  'TRZY - 5'.
            //'           05  FILLER          PIC  X(10)   VALUE  'CZTERY - 7'.
            //'           05  FILLER          PIC  X(10)   VALUE  'PIEC - 5'.
            //'           05  FILLER          PIC  X(10)   VALUE  'SZESC - 6'.
            //'           05  FILLER          PIC  X(10)   VALUE  'SIEDEM - 7'.
            //'           05  FILLER          PIC  X(10)   VALUE  'OSIEM - 6'.
            //'           05  FILLER          PIC  X(10)   VALUE  'DZIEWIEC - 9'.
            //'           05  FILLER          PIC  X(10)   VALUE  '         0'.
            //'
            //'      * TABELLA DEI NUMERI 11/12/13/14/15/16/17/18/19/10
            //'       01  TAB-2.
            //'           05  FILLER      PIC X(17)   VALUE  'JEDENASCIE - 11'.
            //'           05  FILLER      PIC X(17)   VALUE  'DWANASCIE - 10'.
            //'           05  FILLER      PIC X(17)   VALUE  'TRZYNASCIE - 11'.
            //'           05  FILLER      PIC X(17)   VALUE  'CZTERNASCIE - 12'.
            //'           05  FILLER      PIC X(17)   VALUE  'PIETNASCIE - 11'.
            //'           05  FILLER      PIC X(17)   VALUE  'SZESNASCIE - 11'.
            //'           05  FILLER      PIC X(17)   VALUE  'SIEDEMNASCIE - 13'.
            //'           05  FILLER      PIC X(17)   VALUE  'OSIEMNASCIE - 12'.
            //'           05  FILLER      PIC X(17)   VALUE  'DZIEWIETNASCIE - 15'.
            //'           05  FILLER      PIC X(17)   VALUE  'DZIESIEC - 09'.




            strNumeri[0] = "";
            strNumeri[1] = "JEDEN-";
            strNumeri[2] = "DWA-";
            strNumeri[3] = "TRZY-";
            strNumeri[4] = "CZTERY-";
            strNumeri[5] = "PIEC-";
            strNumeri[6] = "SZESC-";
            strNumeri[7] = "SIEDEM-";
            strNumeri[8] = "OSIEM-";
            strNumeri[9] = "DZIEWIEC-";
            strNumeri[10] = "DZIESIEC-";
            strNumeri[11] = "JEDENASCIE-";
            strNumeri[12] = "DWANASCIE-";
            strNumeri[13] = "TRZYNASCIE-";
            strNumeri[14] = "CZTERNASCIE-";
            strNumeri[15] = "PIETNASCIE-";
            strNumeri[16] = "SZESNASCIE-";
            strNumeri[17] = "SIEDEMNASCIE-";
            strNumeri[18] = "OSIEMNASCIE-";
            strNumeri[19] = "DZIEWIETNASCIE-";
            strNumeri[20] = "DWADZIESCIA-";


            //'      01  TAB-3.
            //'           05  FILLER     PIC X(19)    VALUE  '                 00'.
            //'           05  FILLER     PIC X(19)    VALUE  'DWADZIESCIA - 12'.
            //'           05  FILLER     PIC X(19)    VALUE  'TRZYDZIESCI - 12'.
            //'           05  FILLER     PIC X(19)    VALUE  'CZTERDZIESCI - 13'.
            //'           05  FILLER     PIC X(19)    VALUE  'PIECDZIESIAT - 13'.
            //'           05  FILLER     PIC X(19)    VALUE  'SZESCDZIESIAT - 14'.
            //'           05  FILLER     PIC X(19)    VALUE  'SIEDEMDZIESIAT - 15'.
            //'           05  FILLER     PIC X(19)    VALUE  'OSIEMDZIESIAT - 14'.
            //'           05  FILLER     PIC X(19)    VALUE  'DZIEWIECDZIESIAT - 17'.
            //'           05  FILLER     PIC X(19)    VALUE  '                 00'.
            //'
            strDecine[2] = "DWADZIESCIA-";
            strDecine[3] = "TRZYDZIESCI-";
            strDecine[4] = "CZTERDZIESCI-";
            strDecine[5] = "PIECDZIESIAT-";
            strDecine[6] = "SZESCDZIESIAT-";
            strDecine[7] = "SIEDEMDZIESIAT-";
            strDecine[8] = "OSIEMDZIESIAT-";
            strDecine[9] = "DZIEWIECDZIESIAT-";
            strDecine[10] = "STO-";
            //'     * TABELLA DEI NUMERI 100/200/300/400/500/600/700/800/900
            //'       01  TAB-4.
            //'           05  FILLER     PIC X(14)    VALUE  'STO - 04'.
            //'           05  FILLER     PIC X(14)    VALUE  'DWIESCIE - 09'.
            //'           05  FILLER     PIC X(14)    VALUE  'TRZYSTA - 08'.
            //'           05  FILLER     PIC X(14)    VALUE  'CZTERYSTA - 10'.
            //'           05  FILLER     PIC X(14)    VALUE  'PIECSET - 08'.
            //'           05  FILLER     PIC X(14)    VALUE  'SZESCSET - 09'.
            //'           05  FILLER     PIC X(14)    VALUE  'SIEDEMSET - 10'.
            //'           05  FILLER     PIC X(14)    VALUE  'OSIEMSET - 09'.
            //'           05  FILLER     PIC X(14)    VALUE  'DZIEWIECSET - 12'.
            //'           05  FILLER     PIC X(14)    VALUE  '             0'.
            //'       
            centinatia[1] = "STO-";
            centinatia[2] = "DWIESCIE-";
            centinatia[3] = "TRZYSTA-";
            centinatia[4] = "CZTERYSTA-";
            centinatia[5] = "PIECSET-";
            centinatia[6] = "SZESCSET-";
            centinatia[7] = "SIEDEMSET-";
            centinatia[8] = "OSIEMSET-";
            centinatia[9] = "DZIEWIECSET-";


            strVocali = "aeiou";
            //'
            //'1              REC -COST - 1#
            //'           05   MILIARDI       PIC  X(9)    VALUE 'MILIARD  '.
            //'           05   CONT-1         PIC   9      VALUE  9.
            //'1              REC -COST - 2#
            //'           05  MILIARDO        PIC  X(13)   VALUE 'ONE MILLIARD '.
            //'           05  CONT-2           PIC  99      VALUE 13.
            //'1              REC -COST - 3#
            //'           05  MILIONI         PIC  X(9)    VALUE 'MILIONY - '.
            //'           05  CONT-3          PIC  9       VALUE  8.
            //'       01      REC-COST-3A.
            //'           05  MILIONIS        PIC  X(9)    VALUE 'MILION�W - '.
            //'           05  CONT-3A         PIC  9       VALUE  9.
            //'1              REC -COST - 4#
            //'           05  MILIONE         PIC  X(7)   VALUE 'MILION - '.
            //'           05  CONT-4          PIC  9      VALUE 7.
            //'1              REC -COST - 5#
            //'           05  MILA            PIC  X(9)   VALUE  'TYSIACE - '.
            //'           05  CONT-5          PIC  9      VALUE  8.
            //'       01      REC-COST-5B.
            //'060309***  05  MILAS           PIC  X(9)   VALUE  'TYSIECY - '.
            //'060309     05  MILAS           PIC  X(6)   VALUE  'TYS.- '.
            //'           05  CONT-5B         PIC  9      VALUE  5.
            //'1              REC -COST - 6#
            //'           05  MILLE           PIC X(9)    VALUE  'TYSIAC - '.
            //'           05  CONT-6          PIC  9      VALUE   7.
            //'1              REC -COST - 7#
            //'           05  MENO            PIC X(8)    VALUE  ' - '.
            //'           05  CONT-7          PIC  9      VALUE  1.
            //'
            strMille = "TYSIAC-";
            strMilas = "TYS.-";
            strMila = "TYSIACE-";


            strMilione = "MILION-";
            strMilioni = "MILIONY-";
            strMilionis = "MILION�W-";
            strMiliardo = "ONE MILLIARD-";
            strMiliardi = "MILIARD-";
            strMiliardis = "MILIARD-";


        }
        public string NumeroInLettere(int num)
        {
            int l = 0;
            string strNum = "";
            string strApp;
            string sottonumero = "";
            int sn = 0;
            strNum = CStr(num);
            //'strNum = Right(strNum, Len(strNum) - 1)
            //'strNum = "0000" & strNum
            l = strNum.Length;
            strApp = "";
            double nv;
            double temp = l / 3;
            nv = Math.Truncate(temp);
            if (l > 9)
            {
                sottonumero = Strings.Right(strNum, 12);
                sottonumero = Strings.Mid(sottonumero, 1, sottonumero.Length - 9);
                sn = CInt(sottonumero);
                if (sn == 0)
                {

                }

                else if (sn == 1)//  If l = 4 And Left(strNum, 1) = "1" Then
                {
                    strApp = strApp + strMiliardo + "mille";
                }
                else if (sn == 2 || sn == 3 || sn == 4) //'ElseIf l = 4 And (Left(strNum, 1) = "2" Or Left(strNum, 1) = "3" Or Left(strNum, 1) = "4") Then
                {
                    strApp = strApp + TreCifre(CLng(sottonumero)) + strMiliardi; //''"mila";
                }
                else
                {
                    strApp = strApp + TreCifre(CLng(sottonumero)) + strMiliardis; //''"mila";
                }



            }
            if (l > 6)
            {
                sottonumero = Strings.Right(strNum, 9);
                sottonumero = Strings.Mid(sottonumero, 1, Len(sottonumero) - 6);
                sn = CInt(sottonumero);
                if (sn == 0)
                {
                }
                else if (sn == 1)//If l = 4 And Left(strNum, 1) = "1" Then
                {
                    strApp = strApp + strMilione + "mille";
                }
                else if (sn == 2 || sn == 3 || sn == 4)//'ElseIf l = 4 And (Left(strNum, 1) = "2" Or Left(strNum, 1) = "3" Or Left(strNum, 1) = "4") Then
                {
                    strApp = strApp + TreCifre(CLng(sottonumero)) + strMilioni; //'"mila"
                }
                else
                {
                    strApp = strApp + TreCifre(CLng(sottonumero)) + strMilionis; //'"mila";
                }

            }
            if (l > 3)
            {

                sottonumero = Strings.Right(strNum, 6);
                sottonumero = Strings.Mid(sottonumero, 1, Len(sottonumero) - 3);
                sn = CInt(sottonumero);
                if (sn == 0)
                {

                }
                else if (sn == 1)//'            If l = 4 And Left(strNum, 1) = "1" Then
                {
                    strApp = strApp + strMille + "mille";
                }
                else if (sn == 2 || sn == 3 || sn == 4)//'ElseIf l = 4 And (Left(strNum, 1) = "2" Or Left(strNum, 1) = "3" Or Left(strNum, 1) = "4") Then
                {
                    strApp = strApp + TreCifre(CLng(sottonumero)) + strMila; //'"mila"
                }
                else
                {
                    strApp = strApp + TreCifre(CLng(sottonumero)) + strMilas; //'"mila
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
                if (String.Equals(Strings.Left(strNum, 1), "1"))
                {
                    strApp = centinatia[1]; //'"cento"
                }
                else
                {
                    strApp = centinatia[CLng(Strings.Left(strNum, 1))]; //'strNumeri(CLng(Left(strNum, 1))) & "cento"
                }
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
                    //InStr(1, strVocali, Left(strNumeri(CLng(Right(strNum, 1))), 1))
                    if (strVocali.Contains(Strings.Left(strNumeri[CLng(Strings.Right(strNum, 1))], 1), StringComparison.Ordinal))
                    {
                        strApp = Strings.Left(strApp, strApp.Length - 1);
                    }
                    strApp = strApp + strNumeri[CLng(Strings.Right(strNum, 1))];
                }
            }
            return strApp;
        }
        public void puliscinumero(int Valore, int importo, int decimali)
        {
            string str = "";
            int p;
            str = Math.Round(CDbl(Valore), 2).ToString();


            p = Strings.InStr(1, str, ",");
            p = p + Strings.InStr(1, str, ".");

            if (p > 0)
            {
                importo = CInt(Strings.Left(str, p - 1));
                decimali = CInt(Strings.Mid(str + "00", p + 1, 2));
            }
            else
            {
                importo = CInt(str);
                decimali = 0;
            }
        }
        public string ImportoInLettere(int vale)
        {
            int importo = 0, decimali = 0;
            string _ImportoInLettere = "";
            //'Call init

            puliscinumero(vale, importo, decimali);

            _ImportoInLettere = NumeroInLettere(importo) + Sep + Strings.Left(decimali + "00", 2);
            return _ImportoInLettere;
        }
        private void initInglese()
        {
            strNumeri[0] = "";
            strNumeri[1] = "ONE ";
            strNumeri[2] = "TWO ";
            strNumeri[3] = "THREE ";
            strNumeri[4] = "FOUR ";
            strNumeri[5] = "FIVE ";
            strNumeri[6] = "SIX ";
            strNumeri[7] = "SEVEN ";
            strNumeri[8] = "EIGHT ";
            strNumeri[9] = "NINE ";
            strNumeri[10] = "TEN ";
            strNumeri[11] = "ELEVEN ";
            strNumeri[12] = "TWELVE ";
            strNumeri[13] = "THIRTEEN ";
            strNumeri[14] = "FOURTEEN ";
            strNumeri[15] = "FIFTEEN ";
            strNumeri[16] = "SIXTEEN ";
            strNumeri[17] = "SEVENTEEN ";
            strNumeri[18] = "EIGHTEEN ";
            strNumeri[19] = "NINETEEN ";
            strNumeri[20] = "TWENTY ";


            strDecine[2] = "TWENTY ";
            strDecine[3] = "THIRTY ";
            strDecine[4] = "FORTY ";
            strDecine[5] = "FIFTY ";
            strDecine[6] = "SIXTY ";
            strDecine[7] = "SEVENTY ";
            strDecine[8] = "EIGHTY ";
            strDecine[9] = "NINETY ";
            strDecine[10] = "HUNDRED ";



            centinatia[1] = "HUNDRED ";
            centinatia[2] = "TWO HUNDRED ";
            centinatia[3] = "THREE HUNDRED ";
            centinatia[4] = "FOUR HUNDRED ";
            centinatia[5] = "FIVE HUNDRED ";
            centinatia[6] = "SIX HUNDRED ";
            centinatia[7] = "SEVEN HUNDRED ";
            centinatia[8] = "EIGHT HUNDRED ";
            centinatia[9] = "NINE HUNDRED ";


            strVocali = "aeiou";


            strMille = "THOUSAND ";
            strMila = "THOUSAND ";
            strMilas = "THOUSAND ";
            strMilione = "ONE MILLION ";
            strMilioni = "MILLIONS ";
            strMilionis = "MILLIONS ";
            strMiliardo = "ONE MILLIARD ";
            strMiliardi = "MILLIARD ";
            strMiliardis = "MILLIARD ";
        }

    }

}
