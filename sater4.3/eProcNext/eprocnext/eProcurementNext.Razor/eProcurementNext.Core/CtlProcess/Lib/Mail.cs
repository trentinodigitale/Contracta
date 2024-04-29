using System.Data.SqlClient;

namespace eProcurementNext.CtlProcess
{
    internal class Mail
    {
        public void SendWithCDOSYS_New(string strMailTo, string strMailFrom, string strMailCC, string strMailCCN, string strSubject, dynamic vBody, IList<string> AttachPath, IList<string> AttachName, string strSuffix, dynamic BodyFormat, ref SqlConnection? cnLocal, ref SqlTransaction transaction, dynamic? TypeDoc, dynamic? idDoc, dynamic? IdPfuMitt, dynamic? IdPfuDest, dynamic? idAziDest)
        {
            //'--costruisco collection degli allegati della mail
            string sFile = "";
            int i = 0;
            List<string> collAttach = new List<string>();

            if (AttachPath != null)
            {
                for (i = 0; i < AttachPath.Count; i++)
                {
                    sFile = AttachPath[i];
                    collAttach.Add(sFile);
                }
            }

            eProcurementNext.Email.Basic.SendMailCentralizzata_New(strMailTo, strMailFrom, "", strMailCC, strMailCCN, strSubject,
                                vBody, strSuffix, cnLocal, transaction, null, collAttach, BodyFormat, AttachName, TypeDoc, idDoc, IdPfuMitt, IdPfuDest, null, idAziDest);
        }
    }
}
