using Core.Common.Constants.Authentication;
using Core.Authentication.DTO.Core;
using Core.Authentication.Interfaces;
using Core.Authentication.Types;
using Core.DistribuitedCache.Interfaces;
using Core.DistribuitedCache.Manager.Commands;
using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Options;
using System;
using System.Linq;
using System.Security.Claims;
using System.Text.Json;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.Extensions.DependencyInjection;
using EprocNext.Repositories.Interfaces;
using EprocNext.Repositories.Models;

namespace Core.Authentication.Auth
{
    /// <summary>
    /// Class used to perform login check and generate JWT Token
    /// </summary>
    public class LoginManager : ILoginManager
    {
        IDistributedCacheManager AccountCache { get; }
        IProfiliUtenteRepository Account { get; }
        IAuthTokenGenerator TokenGenerator { get; }
        ICryptoUtils CryptoUtils { get; }
        IJWTTokenValidator TokenValidator { get; }
        JwtGenerationSettings Configuration { get; }
        IAziendeRepository Aziende { get; }
        IUserClaimsIdentityProvider ClaimsProvider { get; }

        public LoginManager(IServiceProvider svp, IOptions<JwtGenerationSettings> configuration)
        {
            AccountCache = svp.GetRequiredService<IDistributedCacheManager>();
            Account = svp.GetRequiredService<IProfiliUtenteRepository>();
            TokenGenerator = svp.GetRequiredService<IAuthTokenGenerator>();
            CryptoUtils = svp.GetRequiredService<ICryptoUtils>();
            TokenValidator = svp.GetRequiredService<IJWTTokenValidator>();
            Aziende = svp.GetRequiredService<IAziendeRepository>();
            ClaimsProvider = svp.GetRequiredService<IUserClaimsIdentityProvider>();
            Configuration = configuration.Value;
        }

        private async Task<bool> GenerateToken(LoginDTO user, ProfiliUtenteDTO account, ClaimsIdentity claims = null)
        {
            // Generate new Jwt and Refresh Token
            var (jwtToken, refreshToken) = TokenGenerator.GenerateAuthTokens(claims ?? ClaimsProvider.GetClaimsIdentity(account, user.WorkingTenant.HasValue ? user.WorkingTenant : null));

            // Save Refresh and TsId Token on Database
            try
            {
                var refreshTokenStr = JsonSerializer.Serialize(refreshToken);
                account.pfuRefreshToken = refreshTokenStr;
                var cacheOptions = new DistributedCacheEntryOptions();
                cacheOptions.SetAbsoluteExpiration(DateTimeOffset.Now.AddHours(8));
                cacheOptions.SetSlidingExpiration(TimeSpan.FromMinutes(60));
                await AccountCache.ExecuteAsync(new SetCommand<ProfiliUtenteDTO>($"{account.pfuLogin}", account, cacheOptions));
            }
            catch
            {
                return false;
            }

            // Return created token
            user.Token = jwtToken;
            user.RefreshToken = refreshToken.Token;
            return true;
        }

        public async Task<bool> Login(LoginDTO user)
        {
            ProfiliUtenteDTO account = null;
            try
            {
                // 1. Search Account with user-name and password on DB
                account = await Task.Run(() => Account.GetAccountForLogin(user.UserName));
                if (account is null || account.pfuPassword != CryptoUtils.GetSha256String(user.Password))
                    return false;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Login error: {ex.Message}");
            }

            // 2. Generate Jwt token
            return account != null ? await GenerateToken(user, account) : false;
        }

        public async Task<bool> Refresh(LoginDTO user)
        {
            // 1. Validate expired token and get user claims
            if (!TokenValidator.ValidateToken(user.Token, out var claimsPrincipal))
                return false;

            var refreshUserName = claimsPrincipal?.FindFirstValue(BaseCustomClaims.Name);

            // 2. Get account data from cache/db (with tokens data)
            var getCommand = new GetCommand<ProfiliUtenteDTO>($"{refreshUserName}");
            await AccountCache.ExecuteAsync(getCommand);
            var account = getCommand.Result;
            if (account is null)
                return false;

            // 3. Check the validity of Refresh Token
            var refreshToken = JsonSerializer.Deserialize<RefreshToken>(account.pfuRefreshToken);
            if (user.RefreshToken != refreshToken.Token || (Configuration.BypassRefreshTokenExpiration || refreshToken.Expiration <= DateTime.Now))
                return false;

            // 4. Generate new JWT Token and new Refresh Token
            return await GenerateToken(user, account, claims: claimsPrincipal.Identities.FirstOrDefault());
        }


        public async Task<bool> LoginOnSpecificTenant(LoginDTO user)
        {
            // 1. Check if Working Tenant have value
            if (user.WorkingTenant is null)
                return false;

            // 2. Get account data from database
            var getCommand = new GetCommand<ProfiliUtenteDTO>($"{user.UserName}");
            await AccountCache.ExecuteAsync(getCommand);
            var account = getCommand.Result ?? Account.GetAccountForLogin(user.UserName);

            if (account is null )
                return false;

            // 3. Generate tokens
            return await GenerateToken(user, account);
        }
    }
}
