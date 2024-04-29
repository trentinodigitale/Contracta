using Chilkat;
using EprocNext.Application;
using EprocNext.CommonDB;
using EprocNext.Email;
using System.Data.SqlClient;
using static EprocNext.CommonModule.Basic;

namespace EprocNext.CtlProcess
{
    public class ProcessRecoverMail
    {

        public void RecoverMail(SqlConnection cnLocal, SqlTransaction transaction, TSRecordSet RsDest, string strDocType, dynamic strDocKey, long lIdPfuMitt)
        {
            string strCause = "";

            // TODO gestione errori  On Error GoTo err

            //' vede se è installato chilkat
            MailMan mailman = null;
            bool bChilkat = false;
            string strLanguage = "";
            int NumRetry = 0;

            string strFileName = "";

            try
            {
                var mailMan = new Chilkat.MailMan();
                bChilkat = true;
            }
            catch (Exception ex)
            {
                bChilkat = false;
            }

            if (!bChilkat)
            {
                throw new Exception("IMPOSSIBILE INVIARE EMAIL");
            }

            TSRecordSet rsMail = null;
            string strSql = "";

            // TODO gestire parametri
            strSql = " select * from CTL_CONFIG_MAIL where alias='" + Replace(Trim(GetValueFromRS(RsDest.Fields["MailFrom"])), "'", "''") + "'";
            // SetRsRead rsMail, cnLocal
            rsMail = rsMail.Open(strSql, ApplicationCommon.Application.ConnectionString);

            // TODO settare connessione sql

            if (bChilkat && GetValueFromRS(RsDest.Fields["MailObj"]) && !(rsMail.EOF && rsMail.BOF))
            {
                Chilkat.Email email = null;
                ICr obj = new Cr();

                string unlockKey = Email.Basic.GetUnlockKey(ApplicationCommon.Configuration);
                bool success = mailman.UnlockComponent(unlockKey);

                if (!success)
                {
                    // TODO return o genero eccezione ?
                }

                rsMail.MoveFirst();

                string strPwd = "";
                strPwd = obj.DeCript(GetValueFromRS(rsMail.Fields["Password"]));

                //' Set the POP3 server's hostname
                mailman.SmtpHost = GetValueFromRS(rsMail.Fields["Server"]);

                //' Set the fields
                if (!IsNull(GetValueFromRS(rsMail.Fields["UserName"])))
                {
                    if (Len(Trim(GetValueFromRS(rsMail.Fields["UserName"]))) > 0)
                    {
                        mailman.SmtpUsername = GetValueFromRS(rsMail.Fields["UserName"]);
                        mailman.SmtpPassword = strPwd;
                    }
                }

                if (!IsNull(GetValueFromRS(rsMail.Fields["ServerPort"])))
                {
                    if (GetValueFromRS(rsMail.Fields["ServerPort"]) > 0)
                    {
                        mailman.SmtpPort = GetValueFromRS(rsMail.Fields["ServerPort"]);
                    }
                }

                if (!IsNull(GetValueFromRS(rsMail.Fields["UseSSL"])))
                {
                    mailman.SmtpSsl = GetValueFromRS(rsMail.Fields["UseSSL"]);
                }

                if (!IsNull(GetValueFromRS(rsMail.Fields["Authenticate"])))
                {
                    mailman.SmtpAuthMethod = GetValueFromRS(rsMail.Fields["Authenticate"]);
                }

                email = new Chilkat.Email();

                //' recupera attach dal db (rappresenta la mail)
                TSRecordSet rsAttach = null;
                string? mailObj = GetValueFromRS(RsDest.Fields["MailObj"]);
                string[] vv = !string.IsNullOrEmpty(mailObj) ? mailObj.Split("*") : new string[] { };

                // TODO settare connessione e usare parametri

                //SetRsRead rsAttach, cnLocal
                rsAttach.Open("select * from ctl_Attach where ATT_Hash ='" + Replace(vv[3], "'", "''") + "'", ApplicationCommon.Application.ConnectionString);

                if (!(rsAttach.EOF && rsAttach.BOF))
                {
                    // TODO sistemare 2 righe sotto

                    //strFileName = app.Path & "\" & strDocKey & ".eml"

                    //strFileName = ReadFromRecordset(rsAttach("ATT_Obj"), rsAttach("ATT_Obj").ActualSize, strFileName)

                }

                if (File.Exists(strFileName))
                {
                    email.LoadEml(strFileName);

                    // TODO sistemare
                    bool bSendMail = Email.Basic.CanSendMail(cnLocal, transaction);



                    string strError = "";

                    if (bSendMail)
                    {

                        strCause = "invio mail";
                        success = mailman.SendEmail(email);

                        if (success)
                        {
                            strError = mailman.LastErrorText;
                        }

                    }

                    if (!IsNull(GetValueFromRS(RsDest.Fields["NumRetry"])))
                    {
                        NumRetry = GetValueFromRS(RsDest.Fields["NumRetry"]);
                    }
                    else
                    {
                        NumRetry = 0;
                    }

                    NumRetry++;

                    // TODO sistemare
                    if (true /*FieldExistsInRS(RsDest, "idAziDest")*/)
                    {
                        //'inserisce nella tabella CTL_Mail_System
                        Email.Basic.Insert_CTL_Mail_System(GetValueFromRS(RsDest.Fields["MailTo"]),
                                                            GetValueFromRS(RsDest.Fields["MailFrom"]),
                                                            IsNull(GetValueFromRS(RsDest.Fields["MailCC"])) ? "" : GetValueFromRS(RsDest.Fields["MailCC"]),
                                                            IsNull(GetValueFromRS(RsDest.Fields["MailCCn"])) ? "" : GetValueFromRS(RsDest.Fields["MailCCn"]),
                                                            GetValueFromRS(RsDest.Fields["MailObject"]),
                                                            GetValueFromRS(RsDest.Fields["MailGuid"]),
                                                            GetValueFromRS(RsDest.Fields["MailBody"]),
                                                            cnLocal,
                                                            transaction,
                                                            string.IsNullOrEmpty(strError) ? (bSendMail ? "Sent" : "NotSent") : "error",
                                                            "OUT",
                                                            IsNull(GetValueFromRS(RsDest.Fields["TypeDoc"])) ? "" : GetValueFromRS(RsDest.Fields["TypeDoc"]),
                                                            IsNull(GetValueFromRS(RsDest.Fields["IdDoc"])) ? -1 : GetValueFromRS(RsDest.Fields["IdDoc"]),
                                                            IsNull(GetValueFromRS(RsDest.Fields["IdPfuMitt"])) ? -1 : GetValueFromRS(RsDest.Fields["IdPfuMitt"]),
                                                            IsNull(GetValueFromRS(RsDest.Fields["IdPfuDest"])) ? -1 : GetValueFromRS(RsDest.Fields["IdPfuDest"]),
                                                            email,
                                                            strError,
                                                            GetValueFromRS(RsDest.Fields["Certified"]) == 1 ? 1 : 0, null, NumRetry, GetValueFromRS(RsDest.Fields["IdPfuDest"]));
                    }
                    else
                    {
                        // TODO sistemare

                        //'inserisce nella tabella CTL_Mail_System
                        //Email.Basic.Insert_CTL_Mail_System(GetValueFromRS(RsDest.Fields["MailTo"]),
                        //                                    GetValueFromRS(RsDest.Fields["MailFrom"]),
                        //                                    IsNull(GetValueFromRS(RsDest.Fields["MailCC"])) ? "" : GetValueFromRS(RsDest.Fields["MailCC"]),
                        //                                    IsNull(GetValueFromRS(RsDest.Fields["MailCCn"])) ? "" : GetValueFromRS(RsDest.Fields["MailCCn"]),
                        //                                    GetValueFromRS(RsDest.Fields["MailObject"]),
                        //                                    GetValueFromRS(RsDest.Fields["MailGuid"]),
                        //                                    GetValueFromRS(RsDest.Fields["MailBody"]),
                        //                                    cnLocal,
                        //                                    string.IsNullOrEmpty(strError) ? (bSendMail ? "Sent" : "NotSent") : "error",
                        //                                    "OUT",
                        //                                    IsNull(GetValueFromRS(RsDest.Fields["TypeDoc"])) ? "" : GetValueFromRS(RsDest.Fields["TypeDoc"]),
                        //                                    IsNull(GetValueFromRS(RsDest.Fields["IdDoc"])) ? -1 : GetValueFromRS(RsDest.Fields["IdDoc"]),
                        //                                    IsNull(GetValueFromRS(RsDest.Fields["IdPfuMitt"])) ? -1 : GetValueFromRS(RsDest.Fields["IdPfuMitt"]),
                        //                                    IsNull(GetValueFromRS(RsDest.Fields["IdPfuDest"])) ? -1 : GetValueFromRS(RsDest.Fields["IdPfuDest"]),
                        //                                    email,
                        //                                    strError,
                        //                                    GetValueFromRS(RsDest.Fields["Certified"]) == 1 ? 1 : 0, null, NumRetry);
                    }

                }

            }

            if (File.Exists(strFileName))
            {
                File.Delete(strFileName);
            }
        }

    }
}
