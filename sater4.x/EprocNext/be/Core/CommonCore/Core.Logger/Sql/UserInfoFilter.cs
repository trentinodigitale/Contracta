namespace Core.Logger.Sql
{
    public class UserInfoFilter
    {
        public long Tenant { get; set; }

        public long User { get; set; }

        public override string ToString()
        {
            return $"{Tenant}_{User}";
        }
    }
}
