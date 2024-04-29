namespace eProcurementNext.CommonDB
{
    public interface IClsDomain
    {
        string? ConnectionString { get; set; }
        string? Desc { get; set; }
        bool Dynamic { get; set; }
        string? DynamicReload { get; set; }
        Dictionary<string, dynamic>? Elem { get; set; }
        string? Filter { get; set; }
        string? Id { get; set; }
        DateTime LastLoad { get; set; }
        string? Query { get; set; }
        // TSRecordSet RsElem { get; set; }
        string? StrFormat { get; set; }
        string? Suffix { get; set; }
        IDomElem? FindCode(string id);
        string FindDesc(string Desc);
        string FindDescLeft(string Desc);
        string FindDescMultiValue(dynamic objField, string strMultiCod, string strSep = "</br>");
        string FindDescOrFirstOccurency(string Desc);
        string FindDescOrFirstOccurencyExt(string Desc, string format);
        IDomElem? FindExtCode(string ext);
        TSRecordSet GetRsElem();
        string GetSingleValue(string strFormat = "");
        IDomElem index(int id);
    }
}
