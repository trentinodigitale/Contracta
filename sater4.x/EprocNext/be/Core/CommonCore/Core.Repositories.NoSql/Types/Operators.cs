namespace Core.Repositories.NoSql.Types
{
    /// <summary>
    /// It contains all Search's comparison operators
    /// </summary>
    public static class ComparisonOperators
    {
        public const string Equal = "equals";
        public const string Contains = "contains";
        public const string StartsWith = "startswith";
        public const string EndsWith = "endswith";
        public const string GreaterThan = "greaterthan";
        public const string LessThan = "lessthan";
        public const string RangeDate = "rangedate";
    }

    public static class SortOperators
    {
        public const string Asc = "asc";
        public const string Desc = "desc";
    }
}
