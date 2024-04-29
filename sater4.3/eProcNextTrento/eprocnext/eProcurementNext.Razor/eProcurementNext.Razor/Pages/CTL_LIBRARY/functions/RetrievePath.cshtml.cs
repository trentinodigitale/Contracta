using eProcurementNext.Application;
using eProcurementNext.CommonDB;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.VisualBasic;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.Razor.Pages.CTL_LIBRARY.functions
{
    public class RetrievePathModel : PageModel
    {
        public void OnGet()
        {
        }
        public static string RetrievePathOld(string TipoDoc)
        {
			CommonDbFunctions cdf = new();
			string ainfo = string.Empty;
            string RetrievePath = string.Empty;
			var sqlParams = new Dictionary<string, object?>();
			sqlParams.Add("@TipoDoc", TipoDoc);
			string strQuerySource = "select REL_ValueOutput from CTL_Relations where REL_Type='DOC_2_PATH' and REL_ValueInput=@TipoDoc";
            try
            {
                TSRecordSet rs = cdf.GetRSReadFromQuery_(strQuerySource, ApplicationCommon.Application.ConnectionString, sqlParams);
                if (rs.RecordCount == 0)
                {
                    int pos = Strings.InStrRev(TipoDoc, ";");
                    TipoDoc = Left(TipoDoc, pos - 1);
                    strQuerySource = "select REL_ValueOutput from CTL_Relations where REL_Type='DOC_2_PATH' and REL_ValueInput=@TipoDoc";
                    TSRecordSet rs1 = cdf.GetRSReadFromQuery_(strQuerySource, ApplicationCommon.Application.ConnectionString, sqlParams);
                    if (rs1.RecordCount == 0)
                    {
                        pos = Strings.InStrRev(TipoDoc, ";");
                        if (pos > 0)
                        {
                            TipoDoc = Strings.Left(TipoDoc, pos - 1);
                            strQuerySource = "select REL_ValueOutput from CTL_Relations where REL_Type='DOC_2_PATH' and REL_ValueInput=@TipoDoc";
                            TSRecordSet rs2 = cdf.GetRSReadFromQuery_(strQuerySource, ApplicationCommon.Application.ConnectionString, sqlParams);
                            if (rs2.RecordCount == 0)
                            {
                                pos = Strings.InStrRev(TipoDoc, ";");
                                if (pos > 0)
                                {
                                    TipoDoc = Strings.Left(TipoDoc, pos - 1);
                                    strQuerySource = "select REL_ValueOutput from CTL_Relations where REL_Type='DOC_2_PATH' and REL_ValueInput=@TipoDoc";
                                    TSRecordSet rs3 = cdf.GetRSReadFromQuery_(strQuerySource, ApplicationCommon.Application.ConnectionString, sqlParams);
                                    if (rs3.RecordCount > 0)
                                    {
                                        rs.MoveFirst();
                                        RetrievePath = CStr(rs3["REL_ValueOutput"]);
                                    }
                                }
                            }
                            else
                            {
                                rs2.MoveFirst();
                                RetrievePath = CStr(rs2["REL_ValueOutput"]);
                            }
                        }
                    }
                    else
                    {
                        rs1.MoveFirst();
                        RetrievePath = GetValueFromRS(rs1.Fields["REL_ValueOutput"]);
                    }
                }
                else
                {
                    rs.MoveFirst();
                    RetrievePath = CStr(rs["REL_ValueOutput"]);
                }
            }
            catch
            {
                //err.Clear
            }
            //'ainfo=split(RetrievePath,"#")

            //'RetrievePath = ainfo(0) & "#" & CNV(ainfo(0)) & "#" & CNV(ainfo(1))
            return RetrievePath;
        }
        //'--dato un pattern della forma ITYPE;ISUBTYPE;TIPOAPPALTO;TIPOBANDO;STATO;ADVANCEDSTATO (per il doc generico)
        //'--oppure diverso basta che ci sia il carattere ";" come separatore
        //'--restituisce le info per costruire il path corretto nella versione bandocentrico
        public static string RetrievePath(string TipoDoc)
        {
			CommonDbFunctions cdf = new();
            string[] ainfo = null;
            int NumElem = 0;
            int i = 0;
            string _RetrievePath = string.Empty;
			var sqlParams = new Dictionary<string, object?>();
			sqlParams.Add("@TipoDoc", TipoDoc);
			string strQuerySource = "select REL_ValueOutput from CTL_Relations where REL_Type='DOC_2_PATH' and REL_ValueInput=@TipoDoc";
            try
            {
                TSRecordSet rs = cdf.GetRSReadFromQuery_(strQuerySource, ApplicationCommon.Application.ConnectionString, sqlParams);
                if (rs.RecordCount == 0)
                {
                    ainfo = TipoDoc.Split(";");
                    NumElem = ainfo.Length;
                    if (NumElem > 0)
                    {
                        for (i = 1; i < NumElem; i++)
                        {
                            int pos = Strings.InStrRev(TipoDoc, ";");
                            TipoDoc = Strings.Left(TipoDoc, pos - 1);
							strQuerySource = "select REL_ValueOutput from CTL_Relations where REL_Type='DOC_2_PATH' and REL_ValueInput=@TipoDoc";
                            TSRecordSet rs1 = cdf.GetRSReadFromQuery_(strQuerySource, ApplicationCommon.Application.ConnectionString, sqlParams);
                            if (rs1.RecordCount > 0)
                            {
                                rs1.MoveFirst();
                                _RetrievePath = CStr(rs1["REL_ValueOutput"]);
                                break;
                            }
                        }
                    }
                }
                else
                {
                    rs.MoveFirst();
                    _RetrievePath = CStr(rs["REL_ValueOutput"]);
                }
            }
            catch
            {
                //err.Clear
            }
            return _RetrievePath;
        }
    }
}
