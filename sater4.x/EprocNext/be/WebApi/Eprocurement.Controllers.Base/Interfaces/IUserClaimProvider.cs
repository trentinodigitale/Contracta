using Core.DTO.Common;

namespace EprocNext.Controllers.Base.Interfaces
{
    public interface IUserClaimProvider
    {
        DecodedUserClaims Claims { get; }
    }
}
