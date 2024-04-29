using Core.Authentication.DTO.Core;
using System.Threading.Tasks;

namespace Core.Authentication.Interfaces
{
    public interface ILoginManager
    {
        /// <summary>
        /// Standalone Login from client application. Login verify if valid Username and Password
        /// are given (check to SQL DB). If the account is not of type 2, then a login with the TSID
        /// system is performed.
        /// </summary>
        /// <param name="user">should have valid value on Username and Password</param>
        /// <returns></returns>
        Task<bool> Login(LoginDTO user);

        /// <summary>
        /// Generate new JWT Token from expired JWT token and related refresh token. Input data
        /// should contain valid (but expired) JWT token and the related refresh token (not expired).
        ///
        /// </summary>
        /// <param name="user">Should have valid value on Token and RefreshToken</param>
        /// <returns></returns>
        Task<bool> Refresh(LoginDTO user);

        /// <summary>
        /// Generate new JWT for administrator users who can work on more than one
        /// tenant. The user must have valid JWT token to change the working tenant,
        /// and the user have to be enabled on the requested tenant.
        /// </summary>
        /// <param name="user">should have valid value for JWT Token and WorkingTenant</param>
        /// <returns></returns>
        Task<bool> LoginOnSpecificTenant(LoginDTO user);

    }
}
