namespace eProcurementNext.WebAPI.Model
{
    public class ToolbarButtonModel
    {
        public string Id { get; set; }
        public string OnClick { get; set; }
        public string Title { get; set; }
        public string Url { get; set; }
        public bool Enabled { get; set; }
        public string Value { get; set; }

        public ToolbarButtonModel(
            string _Id,
            string _OnClick,
            string _Title,
            string _Url,
            bool _Enabled,
            string _Value
            )
        {
            Id = _Id;
            OnClick = _OnClick;
            Title = _Title;
            Url = _Url;
            Enabled = _Enabled;
            Value = _Value;
        }

    }
}
