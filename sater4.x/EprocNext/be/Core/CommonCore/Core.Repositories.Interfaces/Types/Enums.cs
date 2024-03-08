namespace Core.Repositories.Types
{
    public enum LookupFilterOperation
    {
        Contains,
        StartsWith,
        EndsWith,
        Equals,
        Less,
        LessOrEquals,
        More,
        MoreOrEquals,
        RangeDate
    }

    public enum LookupSortingDirection
    {
        Asc,
        Desc
    }
}
