using eProcurementNext.Application;
using eProcurementNext.RegistroImprese;
using Microsoft.AspNetCore.Mvc.RazorPages;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class Azienda_info_extModel : PageModel
    {
        public static string Get_Dati_Azienda_Ext(string cf, eProcurementNext.Session.ISession session, eProcurementNext.CommonModule.EprocResponse htmlToReturn, string PartitaIVA = "")
        {
            string strToReturn;
            string progIdCompleto = CStr(ApplicationCommon.Application["CONNETTORE_AZIENDE_EXT_PROGID"]);
            string progIdMin = CStr(ApplicationCommon.Application["CONNETTORE_AZIENDE_EXT"]);
            string strTmpPiva = string.Empty;

            //emilia romagna : 
            //    CONNETTORE_AZIENDE_EXT_PROGID: VUOTO 
            //    CONNETTORE_AZIENDE_EXT : "ClasseAdrierClient" 
            
            //valle d'aosta : 
            //    CONNETTORE_AZIENDE_EXT_PROGID : "CERVED.CervedClient" 
            //    CONNETTORE_AZIENDE_EXT : vuoto  
                
            //regione lazio : 
            //    CONNETTORE_AZIENDE_EXT_PROGID : VUOTO  
            //    CONNETTORE_AZIENDE_EXT : "ClasseParixClient" 
                
            //    SE pure dovessimo trovare le 2 variabili di ambiente valorizzate, quindi una situazione abbastanza sporca, deve vincere CONNETTORE_AZIENDE_EXT_PROGID 





            string nome_libreria = "";

            if(!string.IsNullOrEmpty(progIdCompleto) && !string.IsNullOrEmpty(progIdMin))
            {
                nome_libreria = progIdCompleto;
            }


            if (!string.IsNullOrEmpty(progIdMin))
            {
				//nome_libreria = "ParixClient." + progIdMin;
				nome_libreria = progIdMin;
			}


            if (!string.IsNullOrEmpty(progIdCompleto))
            {
                nome_libreria = progIdCompleto;
            }

//#if DEBUG
//            //nome_libreria = "";
//            //if (string.IsNullOrEmpty(nome_libreria))
//            //{
//            nome_libreria = "ClasseAdrierClient";
//            //}
//#endif

            //on error resume next

            strToReturn = "Recupero Dati Azienda Esterni non attivo";


            if (!string.IsNullOrEmpty(nome_libreria))
            {

                strToReturn = "";

                try
                {
                    IParixClient obj = eProcurementNext.RegistroImprese.Factory.getClient(nome_libreria);
                    try
                    {
                        

                        strToReturn = obj.getParixInfo(cf, CStr(session["SESSION_WORK_KEY"]), ApplicationCommon.Application["connectionstring"]);

                        //if (!string.IsNullOrEmpty(PartitaIVA))
                        //{
                        //    //'-- se il registro delle imprese non ha trovato l'azienda con il CF proviamo con la PIVA
                        //    if(nome_libreria.ToUpper().StartsWith("ADRIER")  || nome_libreria.ToUpper().Contains("ADRIER") && strToReturn == "IMP_OCCORRENZA_0")
                        //    {
                        //        strTmpPiva = PartitaIVA.ToUpper().Replace("IT", "");
                        //        strToReturn = obj.getParixInfo(strTmpPiva, CStr(session["SESSION_WORK_KEY"]), ApplicationCommon.Application["connectionstring"]);
                        //    }
                        //}
                        
                        if(strToReturn == "IMP_OCCORRENZA_0" && !string.IsNullOrEmpty(PartitaIVA))
                        {
                           
                            if (nome_libreria.ToUpper().StartsWith("ADRIER") || nome_libreria.ToUpper().Contains("ADRIER"))
                            {
                                session["tipoRicerca"] = "PIVA";
                                strTmpPiva = PartitaIVA.ToUpper().Replace("IT", "");
                                strToReturn = obj.getParixInfo(strTmpPiva, CStr(session["SESSION_WORK_KEY"]), ApplicationCommon.Application["connectionstring"]);
                            }
                        }
                        else
                        {
                            session["tipoRicerca"] = "CF";
                        }
                    }
                    catch (Exception ex)
                    {
                        strToReturn = "Errore invocazione" + nome_libreria + " , " + ex.Message;
                        //err.clear
                    }


                }
                catch
                {
                    strToReturn = "<strong>ERRORE SERVER. Manca la componente " + nome_libreria + "</strong>";
                    htmlToReturn.Write(strToReturn);
                    //response.end
                    //err.clear
                }

                //Set obj = nothing

            }

            //on error goto 0

            return strToReturn;

        }

        public static string GetDatiAziCessateEnon(string cf, string PartitaIVA, eProcurementNext.Session.ISession session, eProcurementNext.CommonModule.EprocResponse htmlToReturn)
        {

            string strToReturn;
            string progIdCompleto = CStr(ApplicationCommon.Application["CONNETTORE_AZIENDE_EXT_PROGID"]);
            string progIdMin = CStr(ApplicationCommon.Application["CONNETTORE_AZIENDE_EXT"]);
            string strTmpPiva = string.Empty;

            string nome_libreria = "";

            if (!string.IsNullOrEmpty(progIdMin))
            {
                //nome_libreria = "ParixClient." + progIdMin;
                nome_libreria = progIdMin;
            }

            if (!string.IsNullOrEmpty(progIdCompleto))
            {
                nome_libreria = progIdCompleto;
            }

            //on error resume next

            strToReturn = "Recupero Dati Azienda Esterni non attivo";

            if (!string.IsNullOrEmpty(nome_libreria))
            {

                strToReturn = "";

                try
                {
                    IParixClient obj = eProcurementNext.RegistroImprese.Factory.getClient(nome_libreria);
                    try
                    {

                        strToReturn = obj.getParixInfo(CStr(cf), CStr(session["SESSION_WORK_KEY"]), ApplicationCommon.Application.ConnectionString, CStr("1"));

                        if (strToReturn == "IMP_OCCORRENZA_0" && !string.IsNullOrEmpty(PartitaIVA))
                        {
                            if (nome_libreria.ToUpper().StartsWith("ADRIER") || nome_libreria.ToUpper().Contains("ADRIER"))
                            {
                                strTmpPiva = PartitaIVA.ToUpper().Replace("IT", "");
                                strToReturn = obj.getParixInfo(strTmpPiva, CStr(session["SESSION_WORK_KEY"]), ApplicationCommon.Application["connectionstring"], "1");
                            }
                        }


                    }
                    catch (Exception ex)
                    {
                        strToReturn = "Errore invocazione" + nome_libreria + " , " + ex.Message;
                        //err.clear
                    }
                }
                catch
                {
                    strToReturn = "<strong>ERRORE SERVER. Manca la componente " + nome_libreria + "</strong>";
                    htmlToReturn.Write(strToReturn);
                    //response.end
                    //err.clear
                }









                //Set obj = nothing


            }

            //on error goto 0
            return strToReturn;
        }


    }
}
