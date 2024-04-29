using Core.Logger.HelkLogEntry.Types;

namespace Core.Logger.Interfaces
{
    public interface IUserInfoProvider
    {
        CustomerInfo GetCustomerInfo(long userId);
    }
}
