using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.Functions
{
    public class ConvertiData
    {
        //Non viene mai usato nei Sorgenti
        public static dynamic ConvertiData_(dynamic strData)
        {
            return strData;
        }

        ///Non viene mai usato nei Sorgenti
        public static dynamic ConvertiDataSenzaSeparatori(dynamic strData)
        {
            return strData;
        }


        public static dynamic ConvertiDataSRidotta(dynamic strData)
        {
            dynamic Giorno;
            dynamic Mese;
            dynamic Anno;

            strData = NewToOld(strData);
            Giorno = Strings.Right(strData, 2);
            Mese = Strings.Mid(strData, 6, 2);
            Anno = Strings.Left(strData, 4);

            return $"{Giorno}/{Mese}/{Anno}";

        }


        ///Non viene mai usato nei Sorgenti
        public static dynamic ConvertiDataTime(dynamic strData)
        {

            return ConvertiDataTimeNew(strData);

        }

        public static dynamic ConvertiDataTimeNew(dynamic strData)
        {
            dynamic Giorno;
            dynamic Mese;
            dynamic Anno;
            if (strData != "")
            {

                dynamic nPos = Strings.InStr(1, strData, "T", CompareMethod.Text);
                dynamic dataOld;
                dynamic timeOld;
                if (nPos != 0)
                {
                    //' Abbiamo incontrato una data nel fomato nuovo. Estrapoliamo 
                    //'la data aaaa-mm-gg e lo convertiamo in aaaa,mm,gg
                    dataOld = Strings.Replace(Strings.Left(strData, nPos - 1), "-", ",");
                    timeOld = Strings.Right(strData, Strings.Len(strData) - nPos);


                }
                else
                {
                    //' Abbiamo incontrato una data nel fomato vecchio. Lo restituiamo cos� come �
                    dataOld = Strings.Replace(strData, "-", ",");
                    timeOld = "";

                }
                Giorno = Strings.Right(dataOld, 2);
                Mese = Strings.Mid(dataOld, 6, 2);
                Anno = Strings.Left(dataOld, 4);


                strData = $"{Giorno}/{Mese}/{Anno} {timeOld}";
            }

            return strData;

        }

        public static dynamic Converti(dynamic strData)
        {

            dynamic Giorno;
            dynamic Mese;
            dynamic Anno;
            strData = NewToOld(strData);
            Giorno = Strings.Right(strData, 2);
            Mese = Strings.Mid(strData, 6, 2);
            Anno = Strings.Left(strData, 4);
            strData = $"{Giorno}/{Mese}/{Anno}";
            return strData;

        }

        ///Non viene mai usato nei Sorgenti

        public static dynamic VisualSubData(dynamic strData)
        {
            return strData;
        }

        ///Non viene mai usato nei Sorgenti
        public static dynamic NormalizzaData(dynamic dataIn)
        {
            return dataIn;
        }

        //'questa funzione accetta la data nel formato aaaa-mm-ggT00:00:00 e ritorna una data nel formato aaaa,mm,gg

        public static dynamic NewToOld(dynamic dataNew)
        {

            dynamic nPos = Strings.InStr(1, dataNew, "T", CompareMethod.Text);
            dynamic dataOld;
            dynamic timeOld;
            if (nPos != 0)
            {  //' Abbiamo incontrato una data nel fomato nuovo. Estrapoliamo 
               //'la data aaaa-mm-gg e lo convertiamo in aaaa,mm,gg
                dataOld = Strings.Replace(Strings.Left(dataNew, nPos - 1), "-", ",");
                timeOld = Strings.Right(dataNew, Strings.Len(dataNew) - nPos);
            }
            else
            {
                //' Abbiamo incontrato una data nel fomato vecchio. Lo restituiamo cos� come �
                dataOld = Strings.Replace(dataNew, "-", ",");

            }
            return dataOld;

        }

        public static dynamic OldToNew(dynamic dataOld)
        {
            return $"{Strings.Replace(dataOld, ",", "-")}T00:00:00";
        }

        ///Non viene mai usato nei Sorgenti
        public static dynamic DataCompare(dynamic data1, dynamic data2)
        {
            return data1;
        }


        ///Non viene mai usato nei Sorgenti
        public static dynamic cmpData(dynamic strDataInput)
        {
            return strDataInput;
        }

        public static string addZero(dynamic str)
        {
            if (str != "")
            {
                if (CInt(str) <= 9)
                {
                    return $@"0{str}";
                }
                else
                {
                    return str;
                }
            }
            else
            {
                return str;
            }
        }


        ///Non viene mai usato nei Sorgenti
        public static void NowToStr()
        {

        }


    }
}