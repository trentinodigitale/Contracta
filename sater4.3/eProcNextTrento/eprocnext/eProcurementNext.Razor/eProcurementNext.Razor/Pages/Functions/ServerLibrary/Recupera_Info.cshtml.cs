namespace eProcurementNext.Razor.Pages.Functions
{
    public class Recupera_Info
    {
        //'@bfunc Private | GetInfoDomAttrWeb | string | eventuale stringa d'errore
        //'@bparm strDztName | string | dztnome dell'attributo del quale si vuole il dominio dei valori
        //'@bparm strSuffix | string | suffisso lingua dell'utente in riferimento al quale esprimere la decrizione del dominio valori
        //'@bparm vInfo | Array | (output) Array di ritorno contenente le info relativo al dominio valori dell'attributo:
        //'					    vInfo(riga, 0)-->descrizione
        //'					    vInfo(riga, 1)-->codice del valore
        //'@bparm strTdrCod | string | tdr codice. Se vogliono tutti i valori, di un dominio, settare questo aprametro a ""
        //'@comm Restituisce il dominio dei valori relativo all'attributo specificato mediante dztnome.
        //'@comm Nel casoin cui non vengono trovate le info, l'array viene settato ad empty.
        public string GetInfoDomAttrWeb(string strDztName, string strSuffix, ref dynamic[,] vInfo, string strTdrCod)
        {

            throw new Exception("Raggiunto codice obsoleto");

        }



    }
}