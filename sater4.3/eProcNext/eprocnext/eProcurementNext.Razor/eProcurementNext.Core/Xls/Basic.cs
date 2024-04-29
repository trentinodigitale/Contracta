using System.Globalization;

namespace eProcurementNext.Xls
{
    public class Basic
    {
        public static bool IsNumber(object value)
        {
            return value is sbyte
                    || value is byte
                    || value is short
                    || value is ushort
                    || value is int
                    || value is uint
                    || value is long
                    || value is ulong
                    || value is float
                    || value is double
                    || value is decimal;
        }

        public static string ValueToString(dynamic value)
        {
            if (value == null)
            {
                return "";
            }

            if (IsNumber(value))
            {
                return value.ToString("#,###.##", CultureInfo.InvariantCulture).Replace(",", "");
            }
            else if (value.GetType() == typeof(DateTime))
            {
                return value.ToString("yyyy-MM-dd HH:mm:ss.fff");
            }

            return value.ToString();
        }

    }
}
