using eProcurementNext.Application;
using eProcurementNext.CommonModule;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Core.Pages.CTL_LIBRARY.functions
{
    public class net_utilsModel : PageModel
    {

        private static string str_Drive = string.Empty;
        private static string str_UserName = string.Empty;
        private static string str_Pwd =string.Empty;


        public void OnGet()
        {
        }

        public static string getIpClient(HttpRequest Request)
        {

            string userIp = CStr(Request.HttpContext.Connection.RemoteIpAddress);

            string userIP_reverseProxy = CStr(Request.HttpContext.GetServerVariable("HTTP_X_FORWARDED_FOR"));

            if (userIP_reverseProxy != "")
            {
                userIp = userIP_reverseProxy;
            }

            if (userIp != "")
            {

                //'-- contiamo quanti ":" ci sono nell'ip
                int totOccurs = Strings.Len(userIp) - Strings.Len(Strings.Replace(userIp, ":", ""));

                //'-- Se nell'indirizzo IP c'� un solo ":" lo ripuliamo scartando dal due punti in avanti. ( caso server AZURE dove ci arriva anche la porta nell'ip chiamante )
                //'--		( lasciamo inalterato il caso IPV4 privo di : o il caso IPV6 con : multipli )
                if (totOccurs == 1)
                {

                    int pos = Strings.InStr(1, userIp, ":");
                    userIp = Strings.Left(userIp, pos - 1);

                }

                if (userIp.Contains(",", StringComparison.Ordinal))
                {
                    int pos = userIp.IndexOf(",", StringComparison.Ordinal);
                    userIp = userIp.Substring(0, pos);
                }

            }

            return userIp;
        }

        /// <summary>
        /// Mapping di una unità di rete
        /// </summary>
        /// <param name="str_Drive">Unità da utilizzare</param>
        /// <param name="PercorsoDiRete">Path del file da gestire</param>
        /// <param name="persistent">Variabile non usate, passare a false</param>
        /// <param name="str_UserName">UserName dell'utente autorizzato (dato recuperato da variabili SYS)</param>
        /// <param name="str_Pwd">Password dell'utente autorizzato (dato recuperato da variabili SYS)</param>
        /// <param name="delete">Booleano opzionale da utilizzare quando è richiesta la cancellazione dell'associazione dell'unità di rete</param>
        /// <exception cref="NotSupportedException"></exception>
        public static void MapNetWorkDrive(string str_Drive, string PercorsoDiRete, bool persistent, string str_UserName, string str_Pwd, bool delete = false)
        {

            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            {
                using var p = new Process();

                if (!delete)
                {
                    p.StartInfo.FileName = "net.exe";
                    p.StartInfo.Arguments = " use " + str_Drive + @": """ + PercorsoDiRete + @""" " + str_Pwd + " /USER:" + str_UserName;
                    p.StartInfo.CreateNoWindow = true;
                    p.Start();
                    p.WaitForExit();
                    //p.Close();
                }
                else
                {

                    p.StartInfo.FileName = "net.exe";
                    p.StartInfo.Arguments = " use " + str_Drive + ": /DELETE";
                    p.StartInfo.CreateNoWindow = true;
                    p.Start();
                    p.WaitForExit();
                    //p.Close();
                }

                //Empiricamente abbiamo notato che la share creata non era subito disponibile, l'accesso al drive creato andava in errore ma riprovando immediatamente dopo invece funzionava
                //  per provare ad ovviare a questo introduciamo una sleep
                Thread.Sleep(500);
            }
            else
            {
                // TODO: predisporre per un eventuale utilizzo multipiattaforma
                throw new NotSupportedException("Funzione MapNetworkDrive non utilizzabile con un sistema operativo diverso da Windows");
            }

        }

        public static string MAP_SHARE_WITH_DRIVE(string PercorsoDiRete, bool delete = false)
        {
            DebugTrace dt = new DebugTrace();

            string MAP_SHARE_WITH_DRIVE_ret = PercorsoDiRete;


            dt.Write($"MAP_SHARE_WITH_DRIVE - {MAP_SHARE_WITH_DRIVE_ret}", filter: "download");

            if (!delete)
            {

                //'--CONTROLLO SE IL PERCORSO NON INIZA CON UNA LETTERA
                string str_Head = PercorsoDiRete.Substring(0, 1);

                Regex myRegExp = new Regex("[^a-zA-Z]");
                bool FoundMatch = myRegExp.Match(str_Head).Success;

                dt.Write($"MAP_SHARE_WITH_DRIVE/str_Head : {str_Head} - FoundMatch : {FoundMatch}", filter: "download");

                //'--se si tratta di una SHARED perchè non inizia con una lettera dell'alfabeto
                //'--allora provo a fare il MAP se ho le SYS per fare l'operazione
                if (FoundMatch)
                {

                    //'--se il percorso finisce con un carattere "\" lo tolgo perchè altrimenti non funzionerebbe il mapping
                    if (PercorsoDiRete.EndsWith(@"\", StringComparison.Ordinal))
                    {
                        PercorsoDiRete = PercorsoDiRete.Substring(0, PercorsoDiRete.Length - 1);
                    }

                    dt.Write($"MAP_SHARE_WITH_DRIVE/PercorsoDiRete : {PercorsoDiRete}", filter: "download");

                    //'--se esistono le SYS per il MAP effettuo il map
                    eProcurementNext.Application.IEprocNextApplication application = ApplicationCommon.Application;

                    if (!string.IsNullOrEmpty(application["MAP_SHARE_ACCESS_FILE_DRIVE"]) && !string.IsNullOrEmpty(application["MAP_SHARE_ACCESS_FILE_USERNAME"]) && !string.IsNullOrEmpty(application["MAP_SHARE_ACCESS_FILE_PWD"]))
                    {

                        str_Drive = application["MAP_SHARE_ACCESS_FILE_DRIVE"];
                        str_UserName = application["MAP_SHARE_ACCESS_FILE_USERNAME"];
                        str_Pwd = application["MAP_SHARE_ACCESS_FILE_PWD"];

                        dt.Write($"MAP_SHARE_WITH_DRIVE/str_Drive : {str_Drive} - str_UserName : {str_UserName} - str_Pwd : {str_Pwd}");

                        try
                        {
							MapNetWorkDrive(str_Drive, PercorsoDiRete, false, str_UserName, str_Pwd, true);
							MapNetWorkDrive(str_Drive, PercorsoDiRete, false, str_UserName, str_Pwd);
                        }
                        catch (Exception ex)
                        {
                            dt.Write($"MAP_SHARE_WITH_DRIVE/errore MapNetWorkDrive : {ex}", filter: "download");
                            eProcurementNext.CommonDB.Basic.TraceErr(ex, ApplicationCommon.Application.ConnectionString);
                        }

                        MAP_SHARE_WITH_DRIVE_ret = str_Drive + @":\";

                    }
                }

                dt.Write($"MAP_SHARE_WITH_DRIVE/MAP_SHARE_WITH_DRIVE_ret : {MAP_SHARE_WITH_DRIVE_ret}", filter: "download");
            }
            else
            {
                MapNetWorkDrive(str_Drive, PercorsoDiRete, false, str_UserName, str_Pwd, true);
            }
            return MAP_SHARE_WITH_DRIVE_ret;

        }

    }
}

