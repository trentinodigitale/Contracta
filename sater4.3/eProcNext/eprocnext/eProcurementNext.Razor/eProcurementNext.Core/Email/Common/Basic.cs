using Chilkat;
using eProcurementNext.Application;
using eProcurementNext.BizDB;
using eProcurementNext.CommonDB;
using eProcurementNext.CommonModule;
using eProcurementNext.Core.Storage;
using Microsoft.Extensions.Configuration;
using System.Data;
using System.Data.SqlClient;
using static eProcurementNext.CommonModule.Basic;
using static eProcurementNext.CtlProcess.Basic;

namespace eProcurementNext.Email
{
    /// <summary>
    /// Funzioni base per invio email
    /// 
    /// Diagramma chiamate
    /// 
    /// SendMailCentralizzata_New
    ///     -> SendMailCdo_New 
    ///         ->  SendMailCdo_crdll: System.Net.Mail ha sostituito CDO
    ///             SendMailCdo_Chilkat_950: usa libreria Chilkat
    /// 
    /// </summary>
    public static class Basic
    {
        //static string CdoBodyFormatText = ""; //  TODO recuperare  valore CdoBodyFormatText

        public static string GetUnlockKey(IConfiguration configuration)
        {
            return configuration.GetSection("Chilkat:UNLOCK_KEY").Value;
        }

        public static void SendMailCentralizzata_New(
                                string strMailTo,
                                string strMailFrom,
                                string strAlias,
                                string strMailCC,
                                string strMailCCN,
                                string strSubject,
                                dynamic vText,
                                string strLanguage,
                                SqlConnection cnLocal,
                                SqlTransaction? transaction,
                                dynamic? collBodyMail,
                                IList<string>? collAttach,
                                dynamic? BodyFormat,
                                IList<string>? AttachName,
                                dynamic? typeDoc,
                                dynamic? idDoc,
                                dynamic? IdPfuMitt,
                                dynamic? IdPfuDest,
                                dynamic? myGuid,
                                dynamic? idAziDest)
        {
            string strCause = string.Empty;
            string strSql = string.Empty;

            CommonDbFunctions cdf = new();
            DebugTrace dt = new();

            //'--CONTROLLO SE DEVO FARE INVIO TRAMITE CDOSYS PARTICOLARE (PER FARE N INVII DIVERSI)
            strCause = "CONTROLLO SE DEVO FARE INVIO TRAMITE CDOSYS PARTICOLARE (PER FARE N INVII DIVERSI)";
            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@MailFrom", Trim(strMailFrom));
            strSql = "select * from CTL_CONFIG_MAIL with (nolock) where alias=@MailFrom";
            TSRecordSet rsMail = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, parCollection: sqlParams);

            dt.Write("SendMailCentralizzata_New riga 81 - @MailFrom=" + Trim(strMailFrom) + " - sql: " + strSql);
            if (!(rsMail.EOF && rsMail.BOF))
            {
                SendMailCdo_New(strMailTo, strMailFrom, strMailCC, strMailCCN, strSubject, vText, strLanguage, cnLocal, transaction, collBodyMail, collAttach, BodyFormat, AttachName, typeDoc, idDoc, IdPfuMitt, IdPfuDest, myGuid, idAziDest);
            }
            else
            {
                dt.Write("CtlProcess.Basic.SendMailCentralizzata_New riga 89 - Impossibile trovare la configurazione email per l'alias " + Trim(strMailFrom));
                throw new Exception($"Impossibile trovare la configurazione email per l'alias {Trim(strMailFrom)} - strCause:{strCause}");
            }
        }

        //'--EP: invia una mail utilizzando un server di posta a cui bisogna loggarsi
        //'--collBodyMail collezione che contiene il path del file da aggiungere come body
        //'--collAttach collezione che contiene i path dei file da aggiungere come attach
        //'--BodyFormat serve ad impostare il tipo di mail HTML o TEXT:se valorizzato allora se <> -1 allora HTML altrimenti testo
        public static void SendMailCdo_New(string strMailTo, string strMailFrom, string strMailCC, string strMailCCN, string strSubject, dynamic vText, string strLanguage, SqlConnection cnLocal, SqlTransaction transaction, dynamic? collBodyMail, IList<string> collAttach, dynamic? BodyFormat, IList<string> AttachName, dynamic? typeDoc, dynamic? idDoc, dynamic? IdPfuMitt, dynamic? IdPfuDest, dynamic? myGuid, dynamic? idAziDest)
        {
            try
            {
                var mailMan = new Chilkat.MailMan();

                SendMailCdo_Chilkat_950(strMailTo, strMailFrom, strMailCC, strMailCCN, strSubject, vText, strLanguage, cnLocal, transaction, collBodyMail, collAttach, BodyFormat, AttachName, typeDoc, idDoc, IdPfuMitt, IdPfuDest, myGuid, idAziDest);
            }
            catch (Exception ex)
            {
                DebugTrace dt = new();
                dt.Write("CtlProcess.Basic.SendMailCentralizzata_New riga 109 - " + ex.ToString());
                throw new Exception("Errore nella funzione SendMailCdo_New", ex);
            }
        }

        public static void Insert_CTL_Mail_System(string strMailTo,
                                    string strMailFrom,
                                    string strMailCC,
                                    string strMailCCN,
                                    string strSubject,
                                    string vGuid,
                                    dynamic vText,
                                    SqlConnection cnLocal,
                                    SqlTransaction transaction,
                                    string status,
                                    string InOut,
                                    dynamic? typeDoc,
                                    dynamic? idDoc,
                                    dynamic? IdPfuMitt,
                                    dynamic? IdPfuDest,
                                    dynamic? objectMail,
                                    dynamic? strError,
                                    dynamic? IsFromPec,
                                    dynamic? IsToPec,
                                    dynamic? NumRetry,
                                    dynamic? idAziDest)
        {

            TSRecordSet rs;
            string strID = string.Empty;
            string strHashName = string.Empty;
            double dSize = 0;
            LibDbAttach obj;
            string? sPath = string.Empty;
            string strName = string.Empty;
            CommonDbFunctions cdf = new();
            DebugTrace dt = new();

            try
            {
                //' cancella logicamente le mail già presenti con quel guid solo per quelle inviate
                if (InOut.ToUpper() == "OUT")
                {
                    Dictionary<string, object?> sqlParams = new Dictionary<string, object?>();
                    sqlParams.Add("@MailGuid", vGuid);
                    cdf.ExecuteWithTransaction("update CTL_Mail_System set deleted=1,DataUpdate=getdate() where InOut = 'OUT' and MailGuid = @MailGuid", cnLocal.ConnectionString, cnLocal, transaction, parCollection: sqlParams);
                }

                strID = string.Empty;

                //' genera l'oggetto mail come allegato nella tabella
                if (objectMail != null)
                {
                    obj = new LibDbAttach();

                    strHashName = "";

                    if (vGuid.Length > 0)
                    {
                        strName = Replace(Replace(vGuid, "{", ""), "}", "") + ".eml";
                    }
                    else
                    {
                        strName = $"{objectMail.Uidl()}.eml";

                        if (strName == ".eml")
                        {
                            strName = DateTime.Now.ToString("yyyyMMddHHmmss") + ".eml";
                        }
                    }

                    sPath = ConfigurationServices.GetKey("ApplicationContext:PathFolderAllegati", "")!;
                    if (string.IsNullOrEmpty(sPath))
                    {
                        /* ''-- accede alla SYS_PathFolderAllegati per prendere il path temporaneo dove scrivere i file */
                        TSRecordSet rs1 = cdf.GetRSReadFromQueryWithTransaction("select DZT_ValueDef from lib_dictionary with(nolock) where dzt_name ='SYS_PathFolderAllegati'", cnLocal.ConnectionString, cnLocal, transaction);

                        if (!(rs1.EOF && rs1.BOF))
                        {
                            rs1.MoveFirst();

                            if (!string.IsNullOrEmpty(CStr(rs1["DZT_ValueDef"])))
                            {
                                sPath = CStr(rs1["DZT_ValueDef"]);
                            }
                        }
                    }

                    if (string.IsNullOrEmpty(sPath))
                    {
                        throw new Exception("Insert_ctl_mail_system, SYS_PathFolderAllegati non trovato");
                    }

                    if (!Directory.Exists(sPath))
                    {
                        throw new Exception("Directory configurata in SYS_PathFolderAllegati non presente. crearla!");
                    }

                    sPath = Path.Combine(sPath, strName);

                    //' salva la mail in un file
                    if (objectMail is not null)
                    {
                        objectMail.SaveEml(sPath);
                    }

                    var f = new FileInfo(sPath);
                    dSize = f.Length;
                    f = null;

                    if (File.Exists(sPath))
                    {
                        dt.Write("Basic.Insert_CTL_Mail_System riga 220 - prima di InsertCTL_Attachment");
                        obj.InsertCTL_Attachment(sPath, dSize.ToString(), strName, "EML", cnLocal.ConnectionString, ref strID, ref strHashName);
                        dt.Write("Basic.Insert_CTL_Mail_System riga 220 - dopo InsertCTL_Attachment - strID= " + strID);

                        CommonStorage.DeleteFile(sPath);
                    }
                }

                // SetRsWrite rs, cnLocal serve ?

                rs = new TSRecordSet();
                rs.Open("select top 0 * from CTL_Mail_System with(nolock)", cnLocal.ConnectionString);
                dt.Write("Basic.Insert_CTL_Mail_System riga 240");
                DataRow dr = rs.AddNew();

                if (typeDoc is not null)
                {
                    dr["TypeDoc"] = typeDoc;
                }

                if (idDoc is not null)
                {
                    dr["IdDoc"] = idDoc;
                }

                dr["MailGuid"] = vGuid;
                dr["MailFrom"] = strMailFrom;
                dr["MailTo"] = strMailTo;
                dr["MailObject"] = strSubject;
                dr["MailBody"] = vText;
                dr["MailCC"] = strMailCC;
                dr["MailCCn"] = strMailCCN;
                dr["MailData"] = DateTime.Now;

                if (IdPfuMitt is not null)
                {
                    dr["IdPfuMitt"] = IdPfuMitt;
                }

                if (IsFromPec is not null)
                {
                    dr["IsFromPec"] = IsFromPec;
                }

                if (IsToPec is not null)
                {
                    dr["IsToPec"] = IsToPec;
                }

                if (IdPfuDest is not null)
                {
                    dr["IdPfuDest"] = IdPfuDest;
                }

                if (strError is not null)
                {
                    dr["DescrError"] = strError;
                }

                if (NumRetry is not null)
                {
                    dr["NumRetry"] = NumRetry;
                }

                if (objectMail is not null)
                {
                    dr["MailObj"] = strID;
                }


                try
                {
                    if (idAziDest is not null && !string.IsNullOrEmpty(CStr(idAziDest)) && CStr(idAziDest).Length > 0 && cdf.FieldExistsInRS(rs, "idAziDest"))
                    {
                        dr["idAziDest"] = idAziDest;
                    }
                }
                catch (Exception ex)
                {
                    dt.Write("CtlProcess.Basic.SendMailCentralizzata_New riga 320 - " + ex.ToString());
                    throw new Exception($"Eccezione nella gestione di idAziDest, err:{ex.Message}", ex);
                }

                dr["Status"] = status;
                dr["InOut"] = InOut;
                dr["deleted"] = 0;

                dt.Write("Basic.Insert_CTL_Mail_System riga 329 prima di Update CTL_Mail_System");
                EsitoTSRecordSet esito = rs.Update(dr, "ID", "CTL_Mail_System");
                dt.Write("Basic.Insert_CTL_Mail_System riga 331 dopo Update CTL_Mail_System - id=" + esito.id.ToString());
            }
            catch (Exception ex)
            {
                if (!string.IsNullOrEmpty(sPath))
                {
                    CommonStorage.CheckExistsAndDelete(sPath, true, false);
                }
                throw new Exception($"Eccezione in Insert_CTL_Mail_System, err:{ex.Message}", ex);
            }
        }

        public static void SendMailCdo_Chilkat_950(string strMailTo,
                         string strMailFrom,
                         string strMailCC,
                         string strMailCCN,
                         string strSubject,
                         dynamic vText,
                         string strLanguage,
                         SqlConnection cnLocal,
                         SqlTransaction transaction,
                         dynamic collBodyMail,
                         IList<string>? collAttach,
                         dynamic BodyFormat,
                         IList<string>? AttachName,
                         dynamic typeDoc,
                         dynamic idDoc,
                         dynamic IdPfuMitt,
                         dynamic IdPfuDest,
                         string myGuid,
                         dynamic idAziDest)
        {

            string strCause = string.Empty;
            TSRecordSet? rsMail = null;
            string strPwd = string.Empty;
            string strSql = string.Empty;
            DebugTrace dt = new DebugTrace();

            try
            {

                MailMan mailman;
                Chilkat.Email email;

                mailman = new MailMan();

                dt.Write("SendMailCdo_Chilkat_950 riga 383 - prima di UnlockComponent");
                string unlockKey = GetUnlockKey(ApplicationCommon.Configuration);
                bool success = mailman.UnlockComponent(unlockKey);
                dt.Write("SendMailCdo_Chilkat_950 riga 386 - dopo UnlockComponent - success=" + success.ToString());

                CommonDbFunctions cdf = new CommonDbFunctions();

                if (!success)
                {
                    dt.Write("CtlProcess.Basic.SendMailCdo_Chilkat_950 riga 392 - Impossibile fare l'Unlock della componente Chilkat - FUNZIONE : SendMailCdo_Chilkat_950");
                    throw new Exception("Impossibile fare l'Unlock della componente Chilkat - FUNZIONE : SendMailCdo_Chilkat_950");
                }

                string ReplyTo = string.Empty;

                bool bCounter = false;
                int lID = 0;

                //'--recupero parametri per invio mail
                strCause = $"recupero parametri invio mail per alias={strMailFrom}";
                dt.Write("SendMailCdo_Chilkat_950 riga 403");
                try
                {
                    var sqlParams = new Dictionary<string, object?>();
                    sqlParams.Add("@MailFrom", strMailFrom);
                    strSql = " select top 1 *, dbo.DecryptPwd(password) as pwdDecrypt from CTL_CONFIG_MAIL with (nolock) where alias=@MailFrom order by counter asc";

                    rsMail = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, parCollection: sqlParams);
                    bCounter = true;
                }
                catch
                {
                    dt.Write("SendMailCdo_Chilkat_950 riga 414 - catch vuoto");
                }

                if (!bCounter)
                {
                    var sqlParams = new Dictionary<string, object?>();
                    sqlParams.Add("@MailFrom", Trim(strMailFrom));
                    strSql = " select top 1 *, dbo.DecryptPwd(password) as pwdDecrypt from CTL_CONFIG_MAIL with (nolock) where alias=@MailFrom";
                    dt.Write("SendMailCdo_Chilkat_950 riga 422, strSql: " + strSql);
                    rsMail = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, parCollection: sqlParams);
                }

                dt.Write("SendMailCdo_Chilkat_950 riga 426");
                if (rsMail is not null && !(rsMail.EOF && rsMail.BOF))
                {
                    rsMail.MoveFirst();

                    while (!rsMail.EOF)
                    {
                        lID = CInt(rsMail["id"]!);

                        strPwd = string.Empty;
                        strPwd = CStr(rsMail["pwdDecrypt"]);
                        dt.Write("SendMailCdo_Chilkat_950 riga 438");
                        //' gestione del replyto (la colonna può non esserci sulla tabella)
                        ReplyTo = string.Empty;
                        if (cdf.FieldExistsInRS(rsMail, "ReplyTo") && !string.IsNullOrEmpty(CStr(rsMail["ReplyTo"])))
                        {
                            ReplyTo = Trim(CStr(rsMail["ReplyTo"]));
                        }
                        dt.Write("SendMailCdo_Chilkat_950 riga 449");
                        //' Set the POP3 server's hostname
                        mailman.SmtpHost = CStr(rsMail["Server"]);

                        //' Set the fields
                        if (!string.IsNullOrEmpty(CStr(rsMail["UserName"])) && Len(Trim(CStr(rsMail["UserName"]))) > 0)
                        {
                            mailman.SmtpUsername = CStr(rsMail["UserName"]);
                            mailman.SmtpPassword = strPwd;
                        }
                        dt.Write("SendMailCdo_Chilkat_950 riga 462");
                        if (!IsNull(CInt(rsMail["ServerPort"]!)) && CInt(rsMail["ServerPort"]!) > 0)
                        {
                            mailman.SmtpPort = CInt(rsMail["ServerPort"]!);
                        }

                        if (!IsNull(CBool(rsMail["UseSSL"])))
                        {
                            mailman.SmtpSsl = CBool(rsMail["UseSSL"]);
                        }
                        dt.Write("SendMailCdo_Chilkat_950 riga 475");
                        if (!IsNull(CInt(rsMail["Authenticate"]!)))
                        {
                            //Authenticate può assumere valoti 0 e 1, nal caso di 1 corrisponde a LOGIN, 0 a NONE
                            if (CInt(rsMail["Authenticate"]!) == 1)
                                mailman.SmtpAuthMethod = "LOGIN";
                            else
                                mailman.SmtpAuthMethod = "NONE";
                        }
                        dt.Write("SendMailCdo_Chilkat_950 riga 484");
                        if (cdf.FieldExistsInRS(rsMail, "StartTLS") && !IsNull(CInt(rsMail["StartTLS"]!)))
                        {
                            //-- questo campo dovrebbe essere sempre a 1 quando UseSSL è a 1
                            //-- ma la sua assenza non causa problemi sulla maggioranza
                            //-- dei server. in caso di errore metterlo a 1. lasciarlo a null
                            //-- se UseSSL è  0
                            //-- valori ammessi : 0 o 1
                            //-- se la colonna è null non setto niente sul campo in mailMan
                            mailman.StartTLS = CBool(CInt(rsMail["StartTLS"]!));
                        }

                        dt.Write("SendMailCdo_Chilkat_950 riga 553");

                        email = new Chilkat.Email();

                        strCause = "imposto To,Ogggetto,From dell mail";

                        email.ClearTo();
                        email.ClearCC();
                        email.ClearBcc();

                        string[] vv = strMailTo.Split(";");

                        for (int j = 0; j < vv.Length; j++)
                        {
                            email.AddTo(vv[j], vv[j]);
                        }

                        dt.Write("SendMailCdo_Chilkat_950 riga 570");

                        string strGuid = string.Empty;

                        if (string.IsNullOrEmpty(myGuid))
                            strGuid = CommonModule.Basic.GetNewGuid();
                        else
                            strGuid = myGuid;

                        //' concatena guid all'oggetto della mail
                        strSubject = ManageGuidMail(strSubject, strGuid);

                        dt.Write("SendMailCdo_Chilkat_950 riga 583");

                        email.Subject = strSubject;
                        email.FromAddress = CStr(rsMail["MailFrom"]);
                        email.FromName = CStr(rsMail["AliasFrom"]);

                        //--se nn si tratta di un form di posta certificata imposto cc e ccn
                        if (CInt(rsMail["Certified"]!) == 0)
                        {
                            email.AddCC(strMailCC, strMailCC);
                            email.AddBcc(strMailCCN, strMailCCN);
                        }

                        //--imposto il formato della mail HTML o TEXT
                        if (!IsNull(BodyFormat))
                        {
                            if (BodyFormat != MAIL_BODY_FORMAT.TEXT)
                            {
                                email.SetHtmlBody(CStr(vText));
                            }
                            else
                            {
                                email.Body = vText;
                            }
                        }
                        else
                        {
                            //'--controllo il formato text oppure HTML
                            if (CStr(rsMail["BodyFormat"]) != "HTML")
                            {
                                email.Body = vText;
                            }
                            else
                            {
                                email.SetHtmlBody(CStr(vText));
                            }
                        }

                        //'--aggiunge come allegato un file contenente il Body della mail
                        //' nella lingua indicata
                        strCause = "aggiunge come allegato un file contenente il Body della mail";

                        dt.Write("SendMailCdo_Chilkat_950 riga 626");

                        if (collBodyMail != null && !IsEmpty(collBodyMail) && collBodyMail.count > 0)
                        {
                            try
                            {
                                email.AddFileAttachment(collBodyMail[strLanguage]);
                                email.SetAttachmentFilename(0, GetNameAttach(CStr(collBodyMail[strLanguage])));
                            }
                            catch (Exception ex)
                            {
                                dt.Write("CtlProcess.Basic.SendMailCentralizzata_New riga 648 - " + ex.ToString());
                                throw new Exception(ex.Message + " - FUNZIONE : SendMailCdo_Chilkat_950");
                            }
                        }

                        //--se ci sono allegati li aggiunge alla mail
                        strCause = "se ci sono allegati li aggiunge alla mail";
                        string strAttachName = string.Empty;

                        if (collAttach is not null && !IsEmpty(collAttach) && collAttach.Count > 0)
                        {
                            for (int i = 0; i < collAttach.Count; i++)
                            {
                                strCause = "aggiunge allegato:" + collAttach[i];

                                email.AddFileAttachment(collAttach[i]);

                                strAttachName = GetNameAttach(CStr(collAttach[i]));
                                if (AttachName != null)
                                {
                                    strAttachName = AttachName[i];
                                }

                                email.SetAttachmentFilename(i, strAttachName);
                            }
                        }

                        //--controllo se sono da impostare le notifiche e ricevute
                        strCause = "controllo se sono da impostare le notifiche e ricevute";

                        if (!string.IsNullOrEmpty(CStr(rsMail["NotificationTo"])))
                        {
                            //'.Fields("urn:schemas:mailheader:disposition-notification-to") = rsMail("NotificationTo").Value

                            email.AddHeaderField("Disposition-Notification-To", $"<{CStr(rsMail["NotificationTo"])}>");
                            //''Call email.AddHeaderField("Disposition-Notification-To", rsMail("NotificationTo").Value)
                            email.ReturnReceipt = true;
                        }

                        if (!string.IsNullOrEmpty(CStr(rsMail["ReceiptTo"])))
                        {
                            //'.Fields("urn:schemas:mailheader:return-receipt-to") = rsMail("ReceiptTo").Value
                            email.AddHeaderField("Return-Receipt-To", $"<{CStr(rsMail["ReceiptTo"])}>");
                            //''Call email.AddHeaderField("Return-Receipt-To", rsMail("ReceiptTo").Value)

                            email.ReturnReceipt = true;
                        }

                        dt.Write("SendMailCdo_Chilkat_950 riga 698");

                        //' gestione del replyto
                        if (ReplyTo != "")
                        {
                            email.ReplyTo = ReplyTo;
                        }

                        //'--invio mail
                        bool bSendMail = false;

                        bSendMail = CanSendMail(cnLocal, transaction);

                        string strError = "";

                        if (bSendMail)
                        {
                            dt.Write("SendMailCdo_Chilkat_950 riga 715");

                            strCause = "invio mail";
                            success = mailman.SendEmail(email);

                            if (!success)
                            {
                                strError = mailman.LastErrorText;
                                dt.Write("SendMailCdo_Chilkat_950 riga 723 - Errore: " + strError);
                            }
                        }

                        dt.Write("SendMailCdo_Chilkat_950 riga 730 - prima di Insert_CTL_Mail_System");
                        //'inserisce nella tabella CTL_Mail_System
                        Insert_CTL_Mail_System(strMailTo,
                                                    CStr(rsMail["MailFrom"]),
                                                    strMailCC,
                                                    strMailCCN,
                                                    strSubject,
                                                    strGuid,
                                                    vText,
                                                    cnLocal,
                                                    transaction,
                                                    strError == "" ? (bSendMail ? "Sent" : "NotSent") : "error",
                                                    "OUT",
                                                    typeDoc,
                                                    idDoc,
                                                    IdPfuMitt,
                                                    IdPfuDest,
                                                    email,
                                                    strError,
                                                    (CInt(rsMail["Certified"]!) == 1 ? 1 : 0),
                                                    null, null, idAziDest);

                        dt.Write("SendMailCdo_Chilkat_950 riga 752 - dopo Insert_CTL_Mail_System");

                        //''-- incrementa il counter
                        if (bCounter)
                        {
                            cdf.ExecuteWithTransaction("update CTL_CONFIG_MAIL set counter = counter + 1 where id=" + lID, cnLocal.ConnectionString, cnLocal, transaction);
                        }

                        rsMail.MoveNext();

                    }


                }
            }
            catch (Exception ex)
            {
                dt.Write("CtlProcess.Basic.SendMailCdo_Chilkat_950 riga 784 - Errore: " + ex.ToString());
                throw new Exception(ex.Message + " - FUNZIONE: SendMailCdo_Chilkat_950", ex);
            }
        }

        public static bool CanSendMail(SqlConnection conn, SqlTransaction? trans = null)
        {
            var ret = true;
            CommonDbFunctions cdf = new CommonDbFunctions();
            TSRecordSet rs = cdf.GetRSReadFromQueryWithTransaction("select DZT_ValueDef from lib_dictionary where dzt_name ='SYS_SEND_MAIL'", conn.ConnectionString, conn, trans);

            if (!(rs.EOF && rs.BOF))
            {
                string? valueDef = CStr(rs["DZT_ValueDef"]);
                if (!string.IsNullOrEmpty(valueDef) && valueDef.ToUpper() == "NO")
                {
                    ret = false;
                }
            }

            return ret;
        }

        public static string ManageGuidMail(string str, string sGuid)
        {
            string strApp = str;

            //' vede se la stringa contiene la sintassi che dice di non mettere il guid
            if (strApp.Contains("#GUID.NO#", StringComparison.Ordinal))
            {
                strApp = Replace(strApp, "#GUID.NO#", "");
            }
            //' vede se la stringa contiene la sintassi che dice di posizionare il guid in un dato punto
            else if (strApp.Contains("#GUID.VALUE#", StringComparison.Ordinal))
            {
                strApp = Replace(strApp, "#GUID.VALUE#", "GUID=[" + sGuid + "]");
            }
            else
            {
                //' caso di default (mette il guid alla fine)
                strApp = strApp + "   GUID=[" + sGuid + "]";
            }

            return strApp;
        }




        public static string GetCTLParam(SqlConnection cnLocal, SqlTransaction? transaction, string Contesto, string Oggetto, string Proprieta)

        {
            string ret = string.Empty;

            //On Error GoTo err

            TSRecordSet rs;

            var sqlParams = new Dictionary<string, object?>();
            sqlParams.Add("@Contesto", Contesto);
            sqlParams.Add("@Oggetto", Oggetto);
            sqlParams.Add("@Proprieta", Proprieta);

            string strSql = "select valore from ctl_parametri where Contesto = @Contesto and Oggetto = @Oggetto and Proprieta = @Proprieta and Deleted=0";

            var cdf = new CommonDbFunctions();
            rs = cdf.GetRSReadFromQueryWithTransaction(strSql, cnLocal.ConnectionString, cnLocal, transaction, parCollection: sqlParams);

            if (!(rs.EOF && rs.BOF))
            {
                rs.MoveFirst();

                if (CStr(rs["valore"]) is not null)
                {
                    ret = CStr(rs["valore"]);
                }
            }

            return ret;
        }

    }
}
