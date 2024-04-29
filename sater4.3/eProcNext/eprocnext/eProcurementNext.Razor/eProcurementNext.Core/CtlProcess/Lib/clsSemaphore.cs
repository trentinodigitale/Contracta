using eProcurementNext.CommonDB;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.CtlProcess
{
    public class ClsSemaphore : IDisposable
    {
        string lOwnerGuid = string.Empty;
        string lConnectionString = string.Empty;
        string lName = string.Empty;

        private readonly CommonDbFunctions cdf = new CommonDbFunctions();

        private const string MODULE_NAME = "CtlProcess.ClsSemaphore";

        ~ClsSemaphore()
        {
            //-- cancello il record legato al guid corrente se esiste
            if (Len(Trim(lOwnerGuid)) > 0 && Len(Trim(lName)) > 0 && Len(Trim(lConnectionString)) > 0)
                Drop_Semaphore(lName, lOwnerGuid, lConnectionString);
        }

        //-- Name = nome del semaforo
        //-- nMaxSeconds = massimo numero di secondi per tentare di inserire il semaforo
        //-- ritorna il guid inserito sul semaforo
        public string Init_Semaphore(string name, string strConnectionString, long nMaxSeconds = 30)
        {
            string strReturn = string.Empty;
            string strGuid = string.Empty;
            string strCause = string.Empty;
            SqlConnection cnLocal = null!;
            bool bInsert = false;
            DateTime dStartTime = DateTime.MinValue;

            try
            {
                strCause = "recupero GUID di sistema";
                strGuid = GetNewGuid();

                //--apro la connessione
                strCause = "apro la connessione";
                cnLocal = cdf.SetConnection(strConnectionString);
                cnLocal.Open();

                //--conservo quando inizio a provare
                dStartTime = DateTime.Now;

                try
                {
                    //    On Error Resume Next
                    while (!bInsert && (DateDiff("s", dStartTime, DateTime.Now) < nMaxSeconds))
                    {
                        if (InsertSemaphore(ref name, ref cnLocal, strGuid))
                        {
                            lName = name;
                            lOwnerGuid = strGuid;
                            lConnectionString = strConnectionString;
                            bInsert = true;
                        }
                        //--sleep di 1 millisecondo per non fare un loop stretto
                        Thread.Sleep(1);
                    }
                }
                catch { }
                finally
                {
                    //    '--chiudo la connessione
                    CloseConnection(cnLocal);
                }

                if (bInsert)
                    strReturn = strGuid;
                else
                    //        err.Raise "20000", "Init_Semaphore()", "Semaforo " & name & " Rosso"
                    throw new Exception("20000" + " - FUNZIONE : clsSemaphore.Init_Semaphore - " + name + " Rosso");

                return strReturn;
            }
            catch (Exception ex)
            {
                //--chiudo la connessione
                CloseConnection(cnLocal);

                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + "Init_Semaphore", ex);
            }
        }

        private bool InsertSemaphore(ref string name, ref SqlConnection conn, string strGuid)
        {
            try
            {
                //-- provo ad inserire il record nella tabella CTL_SEPAPHORE
                string strCause = $"Inserimento del record  nella CTL_SEMAPHORE per Name = {name} - OwnerGuid = {strGuid}";
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@name", name);
                sqlParams.Add("@strGuid", strGuid);
                string strSQL = "INSERT INTO CTL_SEMAPHORE (Name, OwnerGuid) values (@name, @strGuid)";
                cdf.Execute(strSQL, conn.ConnectionString, conn, parCollection: sqlParams);
                return true;
            }
            catch { return false; }
        }

        //--rimuove un semaforo
        //--Name = nome del semaforo
        //--restituisce 0 tutto ok, -1 errore

        public int Drop_Semaphore(string name, string OwnerGuid, string strConnectionString)
        {
            int iReturn = -1;
            SqlConnection cnLocal = null!;
            try
            {
                //--apro la connessione
                string strCause = "apro la connessione";
                cnLocal = cdf.SetConnection(strConnectionString);
                cnLocal.Open();

                //-- provo ad inserire il record nella tabella CTL_SEPAPHORE
                strCause = $"cancellazione del record  nella CTL_SEMAPHORE per Name = {name} - OwnerGuid = {OwnerGuid}";
                var sqlParams = new Dictionary<string, object?>();
                sqlParams.Add("@name", name);
                sqlParams.Add("@OwnerGuid", OwnerGuid);
                string strSQL = "delete CTL_SEMAPHORE where Name = @name and OwnerGuid = @OwnerGuid";
                cdf.Execute(strSQL, cnLocal.ConnectionString, cnLocal, parCollection: sqlParams);

                //--pulisco le prop per la terminate
                lName = string.Empty;
                lOwnerGuid = string.Empty;
                lConnectionString = string.Empty;

                iReturn = 0;

                //--chiudo la connessione
                CloseConnection(cnLocal);

                return iReturn;
            }
            catch (Exception ex)
            {
                //--chiudo la connessione
                CloseConnection(cnLocal);

                throw new Exception(ex.Message + " - FUNZIONE : " + MODULE_NAME + "Init_Semaphore", ex);
            }
        }

        public void Dispose()
        {
            //-- cancello il record legato al guid corrente se esiste
            if (Len(Trim(lOwnerGuid)) > 0 && Len(Trim(lName)) > 0 && Len(Trim(lConnectionString)) > 0)
                Drop_Semaphore(lName, lOwnerGuid, lConnectionString);
        }
    }
}
