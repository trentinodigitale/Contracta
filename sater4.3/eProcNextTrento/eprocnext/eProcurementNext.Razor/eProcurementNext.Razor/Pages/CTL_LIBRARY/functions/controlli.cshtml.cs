using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;
using System.Text.RegularExpressions;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class controlliModel : PageModel
    {
        public void OnGet()
        {

        }
        public static string checkPivaExt(string stato, string piva)
        {

            string checkPivaExt;
            string strCause = "";


            //'V1
            //'set
            //rs = GetRS("select * from ctl_controllopiva where stato = '" + stato.Replace("'", "''") + "' and not pattern is null");
            //'V2

            //'set
            //rs = GetRS("select a.* from CTL_ControlloPiva a with(nolock) left join  CTL_Transcodifica b with(nolock) on dztNome = 'CountryName' and Sistema = 'PREFISSI_STATI_EU' and ValOut = a.stato where isnull(b.ValIn, a.stato) = '" + stato.Replace("'", "''") + "' and not pattern is null");

            //'V3

            string strSQL = "select * from ( ";
            strSQL = strSQL + " 	select valout from CTL_Transcodifica b with(nolock) where dztNome = 'CountryName' and Sistema = 'PREFISSI_STATI_EU' and ValIn = '" + stato.Replace("'", "''") + "' ";
            strSQL = strSQL + " 		union ";
            strSQL = strSQL + "		select '" + stato.Replace("'", "''") + "' as ValOut where not exists ( select valout from CTL_Transcodifica b with(nolock) where dztNome = 'CountryName' and Sistema = 'PREFISSI_STATI_EU' and ValIn = '" + stato.Replace("'", "''") + "'  ) ";
            strSQL = strSQL + "	) b ";
            strSQL = strSQL + "	inner join CTL_ControlloPiva a with(nolock)  on a.stato = b.ValOut and a.pattern is not null ";

            TSRecordSet? rs = null;
            try
            {
                rs = GetRS(strSQL);
            }
            catch (Exception ex)
            {

                checkPivaExt = "2#" + ApplicationCommon.CNV("Errore server:") + ex.Message;
                return checkPivaExt;
            }


            if (rs != null && rs.RecordCount > 0)
            {



                rs.MoveFirst();

                //'-- l'assunto di base è che la partita iva non è valida
                bool bCheck = false;
                try
                {
                    // '-- itero su tutti i pattern trovati per lo stato passato come parametro	
                    do
                    {




                        string pattern = CStr(rs.Fields["pattern"]);

                        int minlen = CInt(rs.Fields["minlen"]);

                        int maxlen = CInt(rs.Fields["maxlen"]);



                        strCause = checkPiva(piva, pattern, CInt(minlen), CInt(maxlen));

                        if (string.IsNullOrEmpty(CStr(strCause)))
                        {
                            bCheck = true; //'--la piva è valida

                            break;
                        }

                        rs.MoveNext();



                    } while (!(rs.EOF));

                }
                catch (Exception ex)
                {
                    checkPivaExt = "2#" + ApplicationCommon.CNV("Errore server:") + ex.Message;
                    return checkPivaExt;
                }

                rs = null;

                //if (err.number != 0)
                //{
                //checkPivaExt = "2#" + ApplicationCommon.CNV("Errore server") + err.Description;
                //err.Clear();
                //return checkPivaExt; ;

                // }
                if (bCheck == true)
                {
                    checkPivaExt = "0#" + ApplicationCommon.CNV("Partita iva valida");
                }
                else
                {
                    checkPivaExt = "1#" + ApplicationCommon.CNV(strCause);
                }
                return checkPivaExt;

            }
            else
            {

                rs = null;

                checkPivaExt = "1#" + ApplicationCommon.CNV("Stato non gestito");

                return checkPivaExt;



            }
        }

        //'-- ritorna un rs passata la query
        public static TSRecordSet GetRS(string strSql)
        {


            //var obj = server.CreateObject("ctldb.clsTabManage");
            CommonDbFunctions cdf = new CommonDbFunctions();
            TSRecordSet rs = cdf.GetRSReadFromQuery_(strSql, ApplicationCommon.Application["ConnectionString"]);

            return rs;
        }

        public static string checkPiva(string piva, string pattern, int minlen, int maxlen)
        {



            // ' 9 = carattere numerico 
            // ' A = carattere alfabetico 
            // ' X = carattere alfanumerico 
            //' Altri caratteri indicano che in quella posizione deve essere presente proprio quel carattere

            int i;
            int totChar;
            string Char = "";
            string checkChar = "";

            //htmlToReturn.Write(piva);

            bool bExit = false;
            string checkPiva = "";
            totChar = piva.Length;




            //'-- Se la partita iva non rientra nel range di caratteri ammesso

            if (totChar > maxlen || totChar < minlen)
            {
                checkPiva = "Numero di cifre per la partita iva non corretto";
                return checkPiva;
            }

            pattern = pattern.ToUpper();
            piva = piva.ToUpper();

            for (i = 1; i <= totChar; i++)
            {
                Char = Strings.Mid(piva, i, 1);

                checkChar = Strings.Mid(pattern, i, 1);

                switch (checkChar)
                {
                    case "9":

                        if (!(IsNumeric(Char)))
                        {
                            bExit = true;
                        }

                        break;

                    case "A":


                        if (!(isChar(Char)))
                        {

                            bExit = true;
                        }

                        break;

                    case "X":

                        if (!(isChar(Char)) && !(IsNumeric(Char)))
                        {
                            bExit = true;
                        }
                        break;

                    default:
                        if (!(String.Equals(Char, checkChar)))
                        {
                            bExit = true;
                        }
                        break;
                }

                if (bExit)
                {
                    checkPiva = "La partita iva non ha rispettato la validazione formale";
                    return checkPiva;
                }


            }

            checkPiva = "";
            return checkPiva;
            //'-- tutto ok

        }
        public static bool isChar(string car)
        {
            string caratteri = "qwertyuiopasdfghjklzxcvbnm";
            bool isChar = false;

            if ((Strings.InStr(1, caratteri, car.ToLower())) > 0)
            {
                isChar = true;
                return isChar;
            }
            else
            {

                isChar = false;
                return isChar;
            }
        }

        public static bool isConsonante(string car)
        {
            string caratteri = "qwrtypsdfghjklzxcvbnm";
            bool isConsonante = false;

            if (Strings.InStr(1, caratteri, car.ToLower()) > 0)
            {
                isConsonante = true;
                return isConsonante;
            }
            else
            {

                isConsonante = false;
                return isConsonante;
            }


        }
        public static bool isVocale(string car)
        {
            string caratteri = "aeiou";
            bool isVocale = false;

            if ((Strings.InStr(1, caratteri, car.ToLower())) > 0)
            {
                isVocale = true;
                return isVocale;

            }
            else
            {

                isVocale = false;
                return isVocale;
            }

        }

        public static string ControllaPIVA(string pi)
        {
            string ControllaPIVA = "";

            if (String.Equals(pi, "00000000000"))
            {
                ControllaPIVA = "Partita Iva non valida";

            }
            else
            {

                if (string.IsNullOrEmpty(pi))
                {
                    ControllaPIVA = "";
                }
                else
                {

                    if (pi.Length != 11)
                    {
                        ControllaPIVA = "La lunghezza della partita IVA non &egrave corretta: la partita IVA dovrebbe essere lunga esattamente 11 caratteri.";
                    }
                    else
                    {

                        //' istanzia l'oggetto REGULAR EXPRESSION

                        var objER = new Regex("^[0-9]+$");
                        //' cerca il pattern in tutta la stringa di input
                        //objER.Global = true;
                        //' nessuna differenza fra maiuscole/minuscole
                        //objER.IgnoreCase = true;

                        //'''''''''''''''''''''''''''''''''''''''''''''''''
                        // objER.Pattern = "^[0-9]+$";

                        //'''''''''''''''''''''''''''''''''''''''''''''''''
                        // ' verifica la corrispondenza con il pattern
                        //var result = objER.Test(pi);
                        bool result = objER.IsMatch(pi);

                        if (result != true)
                        {
                            ControllaPIVA = "Dato non valido.Contiene dei caratteri non ammessi: Deve contenere solo cifre.";

                            objER = null;
                        }
                        else
                        {

                            int s, c;
                            int s2 = 0;
                            int s1 = 0;
                            string Char = "";



                            for (int i = 0; i <= 9; i++)
                            {
                                i = i + 1;
                                Char = Strings.Mid(pi, i, 1);


                                s1 = s1 + Strings.Asc(Char) - Strings.Asc("0");

                            }

                            for (int i = 1; i <= 9; i++)
                            {
                                i = i + 1;
                                Char = Strings.Mid(pi, i, 1);
                                c = 2 * (Strings.Asc(Char) - Strings.Asc("0"));

                                if (c > 9)
                                {
                                    c = c - 9;
                                    s2 = s2 + c;
                                }
                                else
                                {

                                    s2 = s2 + c;
                                }
                            }

                            s = s1 + s2;

                            if (((10 - s % 10) % 10) != (Strings.Asc(Strings.Mid(pi, 11, 1)) - Strings.Asc("0")))
                            {
                                ControllaPIVA = "Dato non valido: il codice di controllo non corrisponde.";


                            }
                            else
                            {


                                ControllaPIVA = "";

                            }


                        }

                    }
                }
            }



            return ControllaPIVA;




        }

        public static bool compareStrings(string string1, string string2)
        {
            int res = String.Compare(string1, string2);
            if (res == 0 || res == -1)
                return true;
            else
                return false;
        }

        public static string ControllaCF(string cf, bool isPersonaFisica)
        {
            string controllaCF;
            if (string.IsNullOrEmpty(cf))
            {
                controllaCF = "";
            }
            else
            {

                //'-- se il codice fiscale è una partita iva  

                if (isPersonaFisica == false && cf.Length == 11)
                {
                    controllaCF = ControllaPIVA(cf);
                    return controllaCF;
                }
                else if (cf.Length != 16)
                {
                    controllaCF = "La lunghezza del codice fiscale non &egrave; corretta: il codice fiscale deve essere lungo o 11 o 16 caratteri.";
                }
                else
                {
                    string cfToCheck = cf.ToUpper();


                    //'----------------------------------------------
                    //'--GESTIONE OMOCODIA DEL CF.attività 189838 --
                    //'----------------------------------------------
                    //'on error resume next 

                    //' Trasformo il CF nella sua versione 'valida' in caso di omocodia


                    // var rsCF = GetRS("select dbo.fn_Handle_Omocodia('" + cf.Replace("'","''")+ "') as CF");

                    //rsCF.MoveFirst();

                    // if (err.number == 0)
                    //{
                    //cfToCheck = rsCF.Find("CF");
                    //}

                    //rsCF = null;

                    //on error goto 0




                    //' istanzia l'oggetto REGULAR EXPRESSION
                    //var objER = New RegExp;
                    //' cerca il pattern in tutta la stringa di input

                    var objER = new Regex("^[\\w]+$");
                    //objER.Global = true;
                    //' nessuna differenza fra maiuscole/minuscole
                    //objER.IgnoreCase = true;

                    //'''''''''''''''''''''''''''''''''''''''''''''''''
                    // objER.Pattern = "^[\\w]+$";

                    //'''''''''''''''''''''''''''''''''''''''''''''''''

                    //' verifica la corrispondenza con il pattern
                    //objER.Test(cfToCheck);
                    bool result = objER.IsMatch(cfToCheck);


                    if (result != true)
                    {
                        controllaCF = "Il codice fiscale contiene dei caratteri non validi: i soli caratteri validi sono le lettere e le cifre.";

                        objER = null;
                    }
                    else
                    {


                        int s, s1, s2, i;
                        string c;
                        s1 = 0;
                        i = 0;

                        for (i = 2; i <= 14; i = i + 2)
                        {// to 14 step 2
                            c = Strings.Mid(cfToCheck, i, 1);

                            if (compareStrings("0", c) && compareStrings(c, "9"))
                            {

                                s1 = s1 + Strings.Asc(c) - Strings.Asc("0");
                            }
                            else
                            {
                                s1 = s1 + Strings.Asc(c) - Strings.Asc("A");
                            }
                        }

                        s2 = 0;

                        for (i = 1; i <= 15; i = i + 2)
                        { // to 15 step 2) { 
                            c = Strings.Mid(cfToCheck, i, 1);

                            switch (c)
                            {
                                case "0":
                                    s2 = s2 + 1;
                                    break;

                                case "1":
                                    s2 = s2 + 0;
                                    break;

                                case "2":
                                    s2 = s2 + 5;
                                    break;

                                case "3":
                                    s2 = s2 + 7;
                                    break;

                                case "4":
                                    s2 = s2 + 9;
                                    break;

                                case "5":
                                    s2 = s2 + 13;
                                    break;

                                case "6":
                                    s2 = s2 + 15;
                                    break;

                                case "7":
                                    s2 = s2 + 17;
                                    break;

                                case "8":
                                    s2 = s2 + 19;
                                    break;

                                case "9":
                                    s2 = s2 + 21;
                                    break;

                                case "A":
                                    s2 = s2 + 1;
                                    break;

                                case "B":
                                    s2 = s2 + 0;
                                    break;

                                case "C":
                                    s2 = s2 + 5;
                                    break;

                                case "D":
                                    s2 = s2 + 7;
                                    break;

                                case "E":
                                    s2 = s2 + 9;
                                    break;

                                case "F":
                                    s2 = s2 + 13;
                                    break;

                                case "G":
                                    s2 = s2 + 15;
                                    break;

                                case "H":
                                    s2 = s2 + 17;
                                    break;

                                case "I":
                                    s2 = s2 + 19;
                                    break;

                                case "J":

                                    s2 = s2 + 21;
                                    break;

                                case "K":

                                    s2 = s2 + 2;
                                    break;

                                case "L":

                                    s2 = s2 + 4;
                                    break;
                                case "M":

                                    s2 = s2 + 18;
                                    break;

                                case "N":

                                    s2 = s2 + 20;
                                    break;

                                case "O":

                                    s2 = s2 + 11;
                                    break;

                                case "P":

                                    s2 = s2 + 3;
                                    break;

                                case "Q":

                                    s2 = s2 + 6;
                                    break;

                                case "R":

                                    s2 = s2 + 8;
                                    break;

                                case "S":

                                    s2 = s2 + 12;
                                    break;

                                case "T":

                                    s2 = s2 + 14;
                                    break;

                                case "U":

                                    s2 = s2 + 16;
                                    break;

                                case "V":

                                    s2 = s2 + 10;
                                    break;

                                case "W":

                                    s2 = s2 + 22;
                                    break;

                                case "X":

                                    s2 = s2 + 25;
                                    break;

                                case "Y":

                                    s2 = s2 + 24;
                                    break;

                                case "Z":

                                    s2 = s2 + 23;
                                    break;
                                default:
                                    break;

                            }
                        }


                        s = s1 + s2;

                        if (Strings.Chr((s % 26) + Strings.Asc("A")).ToString() != Strings.Mid(cfToCheck, 16, 1))
                        {
                            controllaCF = "Il codice fiscale non &egrave; corretto: il codice di controllo non corrisponde.";

                        }
                        else
                        {
                            controllaCF = "";

                        }
                    }
                }

            }

            return controllaCF;
        }


        public static bool isEmailValid(string email)
        {


            string strEmail = email.Replace("-@", "@");

            string pattern = "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w{2,}$";
            var regEx = new Regex(pattern);
            return regEx.IsMatch(strEmail.Trim());



        }

        public static bool isValidString(string targetString, string patternRegExp)
        {


            var re = new Regex(patternRegExp);
            return re.IsMatch(targetString);


            /*With re
              .Pattern = patternRegExp
              .Global = False
              .IgnoreCase = true
            End With
            */
            // string isValidString = re.Test(targetString);
            // re = null;

        }
        public static bool isMyCF(string nome, string cognome, string cf)
        {
            bool isMyCF;
            //' es: ADA SMITH				---> SMTDAA
            //' es: FEDERICO LEONE		---> LNEFRC
            //' es. ROSA MARIA D'ANGELO	---> DNGRMR

            //' - SPIEGAZIONE 1.  :
            //'Nome: Sono necessari 3 caratteri e sono la 1a, la 3a e la 4a consonante, 
            //'		se il numero di consonanti è inferiore a 3 si aggiungo le vocali.
            //'		se il totale di queste 2 cose non arriva a 3 si aggiungono delle X a destra fino ad arrivare a 3
            //'Cognome: Sono necessari 3 caratteri per rappresentare il cognome e sono la 1a, 
            //'		la 2a e la 3a consonante, se le consonanti sono meno di tre si aggiungono le vocali nell'ordine in cui compaiono nel cognome.
            //'		se il totale di queste 2 cose non arriva a 3 si aggiungono delle X a destra fino ad arrivare a 3

            //' - SPIEGAZIONE 2 : 
            //' Cognome e nome
            //' Il cognome e il nome della persona sono convertiti in lettere maiuscole dell'alfabeto inglese (26 caratteri) 
            //' eliminando gli eventuali spazi, trattini e apostrofi. È conteggiato il numero delle vocali e delle consonanti
            //' contenute nel cognome e nel nome. La vocale è una delle cinque lettere A, E, I, O, U, le consonanti sono le rimanenti 21 lettere dell'alfabeto.

            //' Il campo del cognome è formato da tutte le consonanti copiate nello stesso ordine in cui si riscontrano nel cognome,
            //' seguite dalle vocali. Se il risultato contiene un numero di lettere inferiore a 3, viene riempito da X a destra.
            //' Le prime tre lettere del risultato vengono copiate nel codice fiscale, nelle posizioni da 1 a 3.

            //' La formazione del campo del nome dipende dal numero delle consonanti: se supera 3, si prendono la prima, la terza e 
            //' la quarta consonante del nome. Altrimenti si procede come nella formazione del cognome. Le prime tre lettere del risultato 
            //' vengono copiate nel codice fiscale, nelle posizioni da 4 a 6. Questo metodo è stato adottato, si pensa, a causa dei tanti 
            //' nomi composti in uso in Italia, come ad esempio Maria Teresa.

            //' - SPIEGAZIONE 3 : 
            //'  Caratteri indicativi del cognome.
            //'	I cognomi che risultano composti da più parti o comunque separati od interrotti, vengono considerati
            //'   come se fossero scritti secondo un'unica ed ininterrotta successione di caratteri. 
            //' 	Per i soggetti di sesso femminile coniugati si prende in considerazione soltanto il cognome da nubile. 
            //'	Se il cognome contiene tre o più consonanti, i tre caratteri da rilevare sono, nell'ordine, la prima, 
            //'	la seconda e la terza consonante. Se il cognome contiene due consonanti, i tre caratteri da rilevare sono, nell'ordine, 
            //'	la prima e la seconda consonante e la prima vocale. Se il cognome contiene una consonante e due vocali, si rilevano, 
            //'	nell'ordine, quella consonante e quindi la prima e la seconda vocale. Se il cognome contiene una consonante e una vocale, 
            //'	si rilevano la consonante e la vocale, nell'ordine, e si assume come terzo carattere la lettera x (ics).
            //'	Se il cognome è costituito da due sole vocali, esse si rilevano, nell'ordine, e si assume come terzo carattere la lettera x (ics).

            //'	Caratteri indicativi del nome.
            //'	 I nomi doppi, multipli o comunque composti, vengono considerati come scritti per esteso in ogni loro parte
            //'	 e secondo un'unica ed ininterrotta successione di caratteri. Se il nome contiene quattro o più consonanti, 
            //'	 i tre caratteri da rilevare sono, nell'ordine, la prima, la terza e la quarta consonante. Se il nome contiene tre consonanti, 
            //'	 i tre caratteri da rilevare sono, nell'ordine, la prima, la seconda e la terza consonante. Se il nome contiene due consonanti, 
            //'	 i tre caratteri da rilevare sono, nell'ordine, la prima e la seconda consonante e la prima vocale. Se il nome contiene una consonante
            //'	 e due vocali, i tre caratteri da rilevare sono, nell'ordine, quella consonante e quindi la prima e la seconda vocale.
            //'	 Se il nome contiene una consonante e una vocale, si rilevano la consonante e la vocale, nell'ordine, e si assume come terzo carattere 
            //'	 la lettera x (ics). Se il nome è costituito da due sole vocali, esse si rilevano nell'ordine, e si assume come terzo carattere la lettera x (ics).

            // da verificare se sono metodi
            string tmpCognome = getCognomeCF(cognome);
            string tmpNome = getNomeCF(nome);

            string tmpStr = Strings.Mid(cf, 1, 6);





            if (Strings.UCase(Strings.Trim(CStr(tmpStr))) == (Strings.UCase(tmpCognome) + Strings.UCase(tmpNome)))
            {
                isMyCF = true;
            }
            else
            {
                isMyCF = false;
            }
            return isMyCF;
        }

        public static string getCognomeCF(string cognome)
        {
            string stringToReturn = "";
            int totChar = cognome.Length;
            string getCognomeCF = "";

            //'-- prendo le consonanti del nome
            string strConsonanti = getConsonanti(cognome);

            //'-- prendo le prime 3 consonanti. se non ce ne sono 3 le prendo tutte
            if (strConsonanti.Length >= 3)
            {
                getCognomeCF = Strings.Mid(strConsonanti, 1, 3);
            }
            else
            {
                getCognomeCF = strConsonanti;
                var strVocali = getVocali(cognome);
                getCognomeCF = getCognomeCF + Strings.Mid(strVocali, 1, 3 - strConsonanti.Length);

                if (getCognomeCF.Length < 3)
                {
                    getCognomeCF = addChr(cognome, "X", 3);
                }
            }
            return getCognomeCF;

        }

        public static string getNomeCF(string nome)
        {
            int totChar = nome.Length;
            string getNomeCF = "";

            //'-- prendo le consonanti
            string strConsonanti = getConsonanti(nome);
            //Se ci sono sufficienti consonanti per prendere la 1a LA 3a e LA 4a

            if (strConsonanti.Length >= 4)
            {
                getNomeCF = Strings.Mid(strConsonanti, 1, 1);
                getNomeCF = getNomeCF + Strings.Mid(strConsonanti, 3, 1);
                getNomeCF = getNomeCF + Strings.Mid(strConsonanti, 4, 1);
            }
            else
            {

                //'-- se non sono sufficienti le prendo tutte
                getNomeCF = strConsonanti;
            }

            //'-- Se non ce ne sono 3 ci aggiungo le vocali
            if (getNomeCF.Length < 3)
            {
                string strVocali = getVocali(nome);

                getNomeCF = getNomeCF + Strings.Mid(strVocali, 1, 3 - getNomeCF.Length);

                if (getNomeCF.Length < 3)
                {
                    getNomeCF = addChr(nome, "X", 3);
                }
            }
            return getNomeCF;
        }

        public static string getConsonanti(string str)
        {
            int totChar = str.Length;
            string getConsonanti = "";
            string car = "";

            //'-- prendo le consonanti
            for (int i = 1; i <= totChar; i++)
            {
                car = Strings.Mid(str, i, 1);

                if (isConsonante(car))
                {
                    getConsonanti = getConsonanti + car;
                }
            }



            return getConsonanti;

        }

        public static string getVocali(string str)
        {
            int totChar = str.Length;
            string getVocali = "";
            string car = "";
            //'-- prendo le consonanti

            for (int i = 1; i <= totChar; i++)
            {
                car = Strings.Mid(str, i, 1);

                if (isVocale(car))
                {
                    getVocali = getVocali + car;
                }
            }
            return getVocali;

        }
        public static string addChr(string str, string toAdd, int totChar)
        {
            string addChr = "";

            while (str.Length < totChar)
            {
                str = str + toAdd;

            }

            addChr = str;
            return addChr;
        }



    }

}



