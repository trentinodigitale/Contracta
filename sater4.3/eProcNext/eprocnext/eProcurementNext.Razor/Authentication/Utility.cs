namespace eProcurementNext.Authentication
{
    public static class Utility
    {
        public static string? ParseBearer(string? bearer)
        {
            if (string.IsNullOrEmpty(bearer)) return null;
            return bearer.Replace("Bearer ", "");
        }
    }
}
