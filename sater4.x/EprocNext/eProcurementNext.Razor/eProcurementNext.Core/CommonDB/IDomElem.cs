namespace eProcurementNext.CommonDB
{
    public interface IDomElem
    {
        string? CodExt { get; set; }
        int? Deleted { get; set; }
        string Desc { get; set; }
        string Father { get; set; }
        string id { get; set; }
        string? Image { get; set; }
        int? Level { get; set; }
        int? Sort { get; set; }
        string? ToolTip { get; set; }
    }
}
