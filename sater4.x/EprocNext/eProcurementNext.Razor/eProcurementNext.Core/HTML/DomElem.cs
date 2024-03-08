using eProcurementNext.CommonDB;
using static eProcurementNext.CommonModule.Basic;

namespace eProcurementNext.HTML
{

    public class DomElem : IDomElem
    {
        public string id { get; set; }
        public string Father { get; set; }
        public int? Level { get; set; } = 0;
        public string Desc { get; set; }
        public string? Image { get; set; }
        public string? CodExt { get; set; }
        public int? Sort { get; set; } = 0;

        private int? _deleted;
        public int? Deleted
        {
            get
            {
                return _deleted;
            }
            set
            {
                if (value != null)
                    _deleted = value;
                else
                    _deleted = 0;

            }
        }

        public string? ToolTip { get; set; }

        public DomElem()
        {
            id = "";
            Father = "";
            Desc = "";
        }
        public DomElem(string id, string father = "", int level = 0, string desc = "", string image = "", string codExt = "", int sort = 0, int deleted = 0, string toolTip = "")
        {
            this.id = id;
            Father = father;
            Level = level;
            Desc = desc;
            Image = image;
            CodExt = codExt;
            Sort = sort;
            Deleted = deleted;
            ToolTip = toolTip;
        }
        public DomElem(TSRecordSet rs)
        {

            try
            {
                if (GetValueFromRS(rs.Fields["DMV_CodExt"]) == null)
                    this.CodExt = "";
                else
                    this.CodExt = CStr(rs.Fields["DMV_CodExt"]);

            }
            catch
            {
                this.CodExt = "";
            }

            try
            {

                if (GetValueFromRS(rs.Fields["DMV_DescML"]) == null)
                    this.Desc = "";
                else
                    this.Desc = CStr(GetValueFromRS(rs.Fields["DMV_DescML"]));

            }
            catch
            {
                this.Desc = "";
            }

            try
            {

                if (GetValueFromRS(rs.Fields["DMV_Father"]) == null)
                    this.Father = "";
                else
                    this.Father = CStr(GetValueFromRS(rs.Fields["DMV_Father"]));

            }
            catch
            {
                this.Father = "";
            }

            try
            {

                if (GetValueFromRS(rs.Fields["DMV_Cod"]) == null)
                    this.id = "";
                else
                    this.id = CStr(GetValueFromRS(rs.Fields["DMV_Cod"]));

            }
            catch
            {
                this.id = "";
            }

            try
            {

                if (GetValueFromRS(rs.Fields["DMV_Image"]) == null)
                    this.Image = "";
                else
                    this.Image = CStr(GetValueFromRS(rs.Fields["DMV_Image"]));

            }
            catch
            {
                this.Image = "";
            }

            try
            {

                if (GetValueFromRS(rs.Fields["DMV_Level"]) == null)
                    this.Level = 0;
                else
                    this.Level = CInt(GetValueFromRS(rs.Fields["DMV_Level"]));

            }
            catch
            {
                this.Level = 0;
            }

            try
            {
                if (GetValueFromRS(rs.Fields["DMV_Sort"]) == null)
                    this.Sort = 0;
                else
                    this.Sort = CInt(GetValueFromRS(rs.Fields["DMV_Sort"]));

            }
            catch
            {
                this.Sort = 0;
            }
            try
            {

                if (rs.ColumnExists("DMV_Deleted"))
                {
                    if (GetValueFromRS(rs.Fields["DMV_Deleted"]) == null)
                        this.Deleted = 0;
                    else
                        this.Deleted = CInt(GetValueFromRS(rs.Fields["DMV_Deleted"]));
                }
                else
                    this.Deleted = 0;
            }
            catch
            {
                this.Deleted = 0;
            }

            try
            {
                if (!(rs.ColumnExists("DMV_Tooltip")))
                    this.ToolTip = "";
                else
                    this.ToolTip = CStr(GetValueFromRS(rs.Fields["DMV_Tooltip"]));

            }
            catch
            {
                this.ToolTip = "";
            }
        }
    }
}
