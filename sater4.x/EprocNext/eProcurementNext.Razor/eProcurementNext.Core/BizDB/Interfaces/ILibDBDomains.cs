using eProcurementNext.CommonDB;
using eProcurementNext.HTML;
using eProcurementNext.Session;

namespace eProcurementNext.BizDB
{
    public interface ILibDBDomains
    {
        ClsDomain GetDom(string idDom, string suffix, int Context = 0, string strConnectionStringOpt = "");
        void ReloadDomain(ClsDomain dom);
        void Refresh();
        ClsDomain GetFilteredDomExt(string idDom, string suffix, long idPfu, string Filter, int Context, string strConnectionStringOpt, Session.ISession Session);
        ClsDomain LoadLocalDomain(string idDom, TSRecordSet rsD, long idPfu, string Filter, string suffix, int Context = 0, bool bExt = false, ISession? session = null);
        ClsDomain LoadExternalDomain(string idDom, TSRecordSet rsD, long idPfu, string Filter, string suffix, int Context = 0, bool bExt = false, ISession? session = null);
        void LoadRSDomain(ClsDomain dom, TSRecordSet rsE, LibDbMultiLanguage ml, string suffix);

        ClsDomain GetFilteredDom(string idDom, string suffix, long idPfu, string Filter, int Context = 0, string strConnectionStringOpt = "");
    }
}
