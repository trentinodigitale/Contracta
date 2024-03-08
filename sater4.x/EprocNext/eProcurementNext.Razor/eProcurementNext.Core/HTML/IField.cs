using eProcurementNext.CommonModule;

namespace eProcurementNext.HTML
{
    public interface IField
    {
        void CaptionHtmlCenter(CommonModule.IEprocResponse objResp);
        int getType();
        void Html(IEprocResponse objResp, bool? pEditable = null);
        void HtmlExtended(IEprocResponse objResp, dynamic? Request = null);
        void HtmlExtended2(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null);
        void HtmlExtended3(IEprocResponse objResp, dynamic? Request = null, dynamic? session = null);
        void Init(int iType, string oName = "", object oValue = null, ClsDomain? oDom = null, ClsDomain? oumDom = null, string oFormat = "", bool oEditable = true, bool oObbligatory = false, bool oValidazioneFormale = false);
        void JScript(Dictionary<string, string> js, string Path = "../CTL_Library/");
        dynamic? RSValue();
        void SetFilterDomain(string strFilter, string strSep = ",", bool InOut = true);
        void SetPrintDescription(string str);
        void SetSelectDescription(string str);
        void SetSelezionatiDescription(string str);
        void SetSenzaModali(string str);
        string SQLValue();
        string TechnicalValue();
        void toPrint(IEprocResponse objResp, bool? pEditable = null);
        void toPrintExtraContent(IEprocResponse objResp, dynamic OBJSESSION, string params_ = "", string startPage = "", string strHtmlHeader = "", string strHtmlFooter = "", bool contaPagine = false);
        string TxtValue();
        string validateField();
        void ValueExcel(IEprocResponse objResp, bool? pEditable = null);
        void ValueHtml(IEprocResponse objResp, bool? pEditable = null);
        void xml(IEprocResponse objResp, string tipo);
        void UpdateFieldVisual(string objResp, string strDocument = "");
        bool validate();
        void Excel(CommonModule.IEprocResponse objResp, bool? pEditable = null);
    }
}