using EprocNext.Repositories.Models;
using Core.Repositories.Interfaces;
using System.Threading.Tasks;

namespace EprocNext.Repositories.Interfaces
{

    public partial interface IProfiliUtenteRepository
    {
        /// <summary>
        /// Perform SQL Query on Account table for exec login
        /// </summary>
        /// <param name="username">login user-name</param>
        /// <param name="password">login password</param>
        /// <returns>The An03Account data which correspond to given user name and password</returns>
        ProfiliUtenteDTO GetAccountForLogin(string username, string password = null);

        /// <summary>
        /// Perform SQL Query on Account table for exec login, async version
        /// </summary>
        /// <param name="username">login user-name</param>
        /// <param name="password">login password</param>
        /// <returns>The ProfiliUtente data which correspond to given user name and password</returns>
        Task<ProfiliUtenteDTO> GetAccountForLoginAsync(string username, string password = null);

        /// <summary>
        /// Used by the login system to update the last
        /// login date at the moment of login by the given
        /// user.
        /// </summary>
        /// <param name="accountId">An03 table Id</param>
        /// <returns>true if the login account was successfully updated</returns>
        bool UpdateLastAccessDate(long accountId, string refreshToken, string tsIdToken = null);

        /// <summary>
        /// Used by refresh process to get account info
        /// for the requested refresh token
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        ProfiliUtenteDTO Get(long id);
    }

}
