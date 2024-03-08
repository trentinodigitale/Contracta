namespace eProcurementNext.Core.Security.Common
{
    public class LockObj
    {
        public dynamic? value { get; set; } = null;

        public LockObj(dynamic? initVal)
        {
            this.value = initVal;
        }

    }
}
