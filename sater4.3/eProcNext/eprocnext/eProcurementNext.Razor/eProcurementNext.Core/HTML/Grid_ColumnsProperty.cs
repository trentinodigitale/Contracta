namespace eProcurementNext.HTML
{
    public class Grid_ColumnsProperty
    {
        public string Name;

        public string width;
        public int Length;
        public string Alignment;
        public string vAlignment;

        public string Style;
        public string OnClickCell;
        public bool Total;
        public bool Sort;  //-- sulle griglie normali indica se si puo fare il sort, sulle multidimensionali 0 asc 1 desc
        public bool Wrap;  //-- esclude se attivo la propietà nowrap delle celle

        public string Dimension;       //-- sulle griglie multidimensionali contiene dove si trova l'attributo row, col, inf

        public bool Hide;              //-- true indica che il campo non deve essere visualizzato

        public string Expr; //-- espressione da utilizzarsi nelle griglie multidim
        public bool bSumm; //-- true l'attributo è sommabile nelle griglie multidim
        public string FormatCondition;

        public Grid_ColumnsProperty Clone()
        {
            Grid_ColumnsProperty newobj = new Grid_ColumnsProperty();

            newobj.width = width;
            newobj.Length = Length;
            newobj.Alignment = Alignment;
            newobj.vAlignment = vAlignment;
            newobj.Total = Total;

            newobj.Style = Style;
            newobj.OnClickCell = OnClickCell;
            newobj.Sort = Sort;
            newobj.Wrap = Wrap;
            newobj.Dimension = Dimension;
            newobj.Name = Name;
            newobj.Hide = Hide;

            newobj.FormatCondition = FormatCondition;
            newobj.Expr = Expr;
            newobj.bSumm = bSumm;

            return newobj;
        }
    }
}
