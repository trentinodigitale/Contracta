using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class captcha_accessModel : PageModel
    {
        public void OnGet()
        {

        }

        //'-- *********************************************************************
        //'-- * Versione=1&data=2015-06-19&Attvita=76718&Nominativo=FedericoLeone *
        //'-- *********************************************************************


        //'--- Restituisce un numero casuale nel range da MIN a MAX
        public static int getNumeroCasuale(int min, int max)
        {

            //'ad es: 
            //'min=1
            //'max=9
            Random random = new Random();
            return random.Next(min, max + 1);

        }

        //'--- Restituisce un operatore casuale tra "-" e "+"
        public static string getOperatoreCasuale()
        {


            string operatore = "+";

            //'-- mi faccio ritornare un numero casuale tra 1 e 2
            int sceltaCasuale = getNumeroCasuale(1, 2);

            switch (sceltaCasuale)
            {
                case 1: //'-- addizione
                    operatore = "+";
                    break;
                case 2: //'-- sottrazione
                    operatore = "-";
                    break;


            }

            return operatore;

        }

        //'--- Restituisce la conversione di un numero ad una cifra nel corrispettivo numero romano
        public static string getNumeroRomano(int num)
        {


            string romano = "";

            switch (num)
            {
                //'-- 0 non esiste in numeri romani
                case 1:
                    romano = "I";
                    break;
                case 2:
                    romano = "II";
                    break;
                case 3:
                    romano = "III";
                    break;
                case 4:
                    romano = "IV";
                    break;
                case 5:
                    romano = "V";
                    break;
                case 6:
                    romano = "VI";
                    break;
                case 7:
                    romano = "VII";
                    break;
                case 8:
                    romano = "VIII";
                    break;
                case 9:
                    romano = "IX";
                    break;
            }


            return "(numero romano) " + romano;

        }

        //'--- Restituisce la conversione di un numero ad una cifra nel corrispettivo numero in lettere
        public static string getNumeroInLettere(int num)
        {

            string lettere = "";

            switch (num)
            {
                case 1:
                    lettere = "uno";
                    break;
                case 2:
                    lettere = "due";
                    break;
                case 3:
                    lettere = "tre";
                    break;
                case 4:
                    lettere = "quattro";
                    break;
                case 5:
                    lettere = "cinque";
                    break;
                case 6:
                    lettere = "sei";
                    break;
                case 7:
                    lettere = "sette";
                    break;
                case 8:
                    lettere = "otto";
                    break;
                case 9:
                    lettere = "nove";
                    break;
                case 10:
                    lettere = "dieci";
                    break;
                case 11:
                    lettere = "undici";
                    break;
                case 12:
                    lettere = "dodici";
                    break;
                case 13:
                    lettere = "tredici";
                    break;
                case 14:
                    lettere = "quattordici";
                    break;
                case 15:
                    lettere = "quindici";
                    break;
                case 16:
                    lettere = "sedici";
                    break;
                case 17:
                    lettere = "diciassette";
                    break;
                case 18:
                    lettere = "diciotto";
                    break;
                case 19:
                    lettere = "diciannove";
                    break;
                case 20:
                    lettere = "venti";
                    break;
                case 21:
                    lettere = "ventuno";
                    break;
                case 22:
                    lettere = "ventidue";
                    break;
                case 23:
                    lettere = "ventitre";
                    break;
                case 24:
                    lettere = "ventiquattro";
                    break;
                case 25:
                    lettere = "venticinque";
                    break;
                case 26:
                    lettere = "ventisei";
                    break;
                case 27:
                    lettere = "ventisette";
                    break;


            }

            return lettere;

        }

        public static string getNumeroOffuscato(int num)
        {


            int sceltaCasuale = getNumeroCasuale(1, 3);
            string _out = "";


            switch (sceltaCasuale)
            {
                case 1:
                    _out = num.ToString();
                    break;
                case 2:
                    _out = getNumeroInLettere(num);
                    break;

                case 3:
                    _out = getNumeroRomano(num);
                    break;

            }


            return _out;

        }

        //'--- Restituisce la conversione dell'operatore "+" nel corrispettivo esteso
        public static string getOperatoreAddizione()
        {

            int sceltaCasuale = getNumeroCasuale(1, 6);

            string _out = "";

            switch (sceltaCasuale)
            {
                case 1:
                    _out = "aggiungi";
                    break;
                case 2:
                    _out = "somma";
                    break;
                case 3:
                    _out = "addiziona";
                    break;
                case 4:
                    _out = "aggiungere";
                    break;
                case 5:
                    _out = "aggiunga";
                    break;
                case 6:
                    _out = "sommi";
                    break;

                    //'Case 1
                    //'	out = "pi&ugrave;"
                    //'Case 2
                    //'	out = "sommato"
                    //'Case 3
                    //'	out = "addizionato"

            }

            return _out;

        }


        public static string getOperatoreSottrazione()
        {


            int sceltaCasuale = getNumeroCasuale(1, 8);
            string _out = "";

            switch (sceltaCasuale)
            {
                //'Case 1
                //'	out = "meno"
                case 1:
                    _out = "detrai";
                    break;
                case 2:
                    _out = "sottrarre";
                    break;
                case 3:
                    _out = "detrarre";
                    break;
                case 4:
                    _out = "dedurre";
                    break;
                case 5:
                    _out = "detragga";
                    break;
                case 6:
                    _out = "sottragga";
                    break;
                case 7:
                    _out = "tolga";
                    break;
                case 8:
                    _out = "togli";
                    break;
            }


            return _out;

        }

        public static string getOperatoreOffuscato(string op)
        {

            string _out = "";

            switch (op)
            {
                case "+":
                    _out = getOperatoreAddizione();
                    break;
                case "-":
                    _out = getOperatoreSottrazione();
                    break;
            }


            return _out;


        }

        public static string getTotaleOffuscato(int num, int formato)
        {

            string _out = "";
            //'sceltaCasuale = getNumeroCasuale(1, 2)

            switch (formato)
            {
                case 1:
                    _out = num.ToString();
                    break;
                case 2:
                    _out = getNumeroInLettere(num);
                    break;
            }


            return _out;

        }

        //'-- Restituisce una lettera in maniera casuale
        public static string getLetteraCasuale()
        {

            //'-- range delle lettere maiuscole
            int minNumber = 65;
            int maxNumber = 90;

            return Strings.Chr(CInt(getNumeroCasuale(65, 90) + minNumber)).ToString();


        }

        //'-- per rendere pi� sicuro il field nel quale si deve immettere il captcha, genero il nome del field in maniera casuale con una stringa a lunghezza variabile con contenuto a sua volta random
        public static string getSicurityCaptchaFieldName()
        {

            string _out = "";

            //'-- genero un numero di caratteri casuali tra 10 e 20 e li popolo con lettere casuali
            int sceltaCasuale = getNumeroCasuale(10, 20);
            do
            {
                _out = _out + getLetteraCasuale();

            } while (_out.Length < sceltaCasuale);

            return _out;

        }


        public static string generaCaptchaAccessibile(string sessionKeyTotale, string sessionKeyFieldName, string sessionKeyFormatoTotaleOut, eProcurementNext.Session.ISession session)
        {

            int numeroUno = 0;
            int numeroDue = 0;
            int numeroTre = 0;
            string operatore1 = "";
            string operatore2 = "";
            string _out = "";
            int totale;
            do
            {

                bool hasToContinue = true;
                do
                {

                    numeroUno = getNumeroCasuale(1, 9);
                    numeroDue = getNumeroCasuale(1, 9);
                    operatore1 = getOperatoreCasuale();

                    if (operatore1 == "-")
                    {
                        if (numeroUno - numeroDue < 0)
                        {

                            hasToContinue = true;
                        }
                        else
                        {
                            hasToContinue = false;
                        }
                    }
                    else
                    {
                        hasToContinue = false;
                    }

                    //'-- faccio in modo che l'operazione tra i primi due numeri non dia un numero negativo
                } while (hasToContinue);

                numeroTre = getNumeroCasuale(1, 9);
                operatore2 = getOperatoreCasuale();

                if (operatore1 == "+" && operatore2 == "+")
                {
                    totale = numeroUno + numeroDue + numeroTre;
                }
                else if (operatore1 == "-" && operatore2 == "+")
                {
                    totale = numeroUno - numeroDue + numeroTre;
                }
                else if (operatore1 == "+" && operatore2 == "-")
                {
                    totale = numeroUno + numeroDue - numeroTre;
                }
                else if (operatore1 == "-" && operatore2 == "-")
                {
                    totale = numeroUno - numeroDue - numeroTre;
                }
                else
                {
                    totale = 0;
                }

            } while (totale < 0);  //'-- itero fintanto che non raggiungo un totale maggiore di 0

            _out = "A " + getNumeroOffuscato(numeroUno) + " " + getOperatoreOffuscato(operatore1) + " " + getNumeroOffuscato(numeroDue) + " e " + getOperatoreOffuscato(operatore2) + " " + getNumeroOffuscato(numeroTre);

            session[sessionKeyFieldName] = getSicurityCaptchaFieldName();

            _out = offuscaOutput(_out);

            int sceltaFormatoTotale = getNumeroCasuale(1, 2);

            session[sessionKeyFormatoTotaleOut] = sceltaFormatoTotale; //'-- 1 numero, 2 lettere
            session[sessionKeyTotale] = getTotaleOffuscato(totale, sceltaFormatoTotale);

            return _out;

        }

        public static string offuscaOutput(string inputstr)
        {

            string outputstr = "";

            for (int i = 1; i <= inputstr.Length; i++)
            {


                string x = Strings.Mid(inputstr, i, 1);

                //'-- in modo casuale decido se mettere o no una stringa di offuscamento
                if (getNumeroCasuale(1, 2) == 1)
                {

                    //'-- in modo casuale decido se mettere un commento una span invisibile
                    if (getNumeroCasuale(1, 2) == 1)
                    {
                        outputstr = outputstr + @"<span style=""display:none"">" + getSicurityCaptchaFieldName() + @"</span>";
                    }
                    else
                    {
                        outputstr = outputstr + @"<!--" + getSicurityCaptchaFieldName() + @"-->";
                    }

                }

                outputstr = outputstr + x;

            }


            return outputstr;

        }

        public static bool TestCaptcha(string valSession, string valCaptcha, eProcurementNext.Session.ISession session)
        {
            string tmpSession;
            valSession = valSession.Trim();
            valCaptcha = valCaptcha.Trim();
            if (string.IsNullOrEmpty(valSession) || string.IsNullOrEmpty(valCaptcha))
            {
                return false;
            }
            else
            {
                tmpSession = valSession;
                valSession = session[valSession].Trim();
                session[tmpSession] = "";
                if (string.IsNullOrEmpty(valSession))
                {
                    return false;
                }
                else
                {
                    valCaptcha = Replace(valCaptcha, "i", "I");
                    if (Strings.StrComp(valSession, valCaptcha, CompareMethod.Text) == 0)
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
            }
        }




    }
}
