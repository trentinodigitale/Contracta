using System;
using System.Threading.Tasks;
using Core.Logger.Interfaces;
using Core.Logger.Types;
using Core.Authentication.DTO.Core;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Core.Authentication.Interfaces;

namespace FTM.Cloud.Services.Controllers
{
    [ApiVersion("1.0")]
    [Route("api/v{v:apiVersion}/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        ILoginManager LoginManager { get; }
        IHelkLogger Logger { get; }

        public AuthController(ILoginManager loginManager, IHelkLogger logger)
        {
            LoginManager = loginManager;
            Logger = logger;
        }

        [HttpPost, Route("login"), AllowAnonymous]
        [ProducesResponseType(typeof(LoginResultDTO), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(LoginDTO), StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Login([FromBody]LoginDTO user)
        {
            Exception ex = null;
            try
            {
                if (user == null || user.Password == null || user.UserName == null)
                    return BadRequest("Invalid client request");

                if (await LoginManager.Login(user))
                {
                    return Ok(new LoginResultDTO
                    {
                        Token = user.Token,
                        RefreshToken = user.RefreshToken,
                        SessionToken = user.SessionToken
                    });
                }

                return Unauthorized(user);
            }
            catch (Exception exc)
            {
                ex = exc;
                return StatusCode(StatusCodes.Status500InternalServerError, exc.Message);
            }
            finally
            {
                //await Logger.LogAsync(new LogEntryData
                //{
                //    Level = ex is null ? !string.IsNullOrEmpty(user.Token) ? LogLevel.info : LogLevel.warning : LogLevel.error,
                //    Message = new LogEntryMessageBuilder<LoginDTO>(nameof(Login), ex is null ? !string.IsNullOrEmpty(user.Token) ? "User logged" : "Wrong username or password" : $"Method throw exception", new LoginDTO { UserName = user.UserName, Email = user.Email }).ToString(),
                //    LogException = ex,
                //    ResponseStatusCode = ex is null ? !string.IsNullOrEmpty(user.Token) ? StatusCodes.Status200OK : StatusCodes.Status401Unauthorized : StatusCodes.Status500InternalServerError,
                //});
            }
        }

        [HttpPost, Route("refresh"), AllowAnonymous]
        [ProducesResponseType(typeof(LoginResultDTO), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(LoginDTO), StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Refresh([FromBody]LoginDTO user)
        {
            Exception ex = null;
            bool wasRefreshed = false;
            try
            {
                if (user == null || user.Token == null || user.RefreshToken == null)
                    return BadRequest("Invalid client request: Token or Refresh Token not specified");

                wasRefreshed = await LoginManager.Refresh(user);
                if (wasRefreshed)
                {
                    return Ok(new LoginResultDTO
                    {
                        Token = user.Token,
                        RefreshToken = user.RefreshToken,
                        SessionToken = user.SessionToken
                    });
                }

                return Unauthorized(user);
            }
            catch (Exception exc)
            {
                ex = exc;
                return StatusCode(StatusCodes.Status500InternalServerError, exc.Message);
            }
            finally
            {
                //await Logger.LogAsync(new LogEntryData
                //{
                //    Level = ex is null ? wasRefreshed ? LogLevel.info : LogLevel.warning : LogLevel.error,
                //    Message = new LogEntryMessageBuilder<LoginDTO>(nameof(Refresh), ex is null ? wasRefreshed ? "Token refreshed" : "Wrong jwt token or refresh token" : "Method throw exception", new LoginDTO
                //    {
                //        UserName = user.UserName,
                //        Token = user.Token,
                //        RefreshToken = user.RefreshToken
                //    }).ToString(),
                //    LogException = ex,
                //    ResponseStatusCode = ex is null ? wasRefreshed ? StatusCodes.Status200OK : StatusCodes.Status401Unauthorized : StatusCodes.Status500InternalServerError,
                //});
            }
        }

        [HttpPost, Route("tenant_login"), Authorize]
        [ProducesResponseType(typeof(LoginResultDTO), StatusCodes.Status200OK)]
        [ProducesResponseType(typeof(string), StatusCodes.Status400BadRequest)]
        [ProducesResponseType(typeof(LoginDTO), StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> TenantLogin([FromBody] LoginDTO user)
        {
            Exception ex = null;
            bool loginSuccess = false;
            try
            {
                if (user is null)
                    return BadRequest("User data not valid");

                loginSuccess = await LoginManager.LoginOnSpecificTenant(user);
                if (loginSuccess)
                {
                    return Ok(new LoginResultDTO
                    {
                        Token = user.Token,
                        RefreshToken = user.RefreshToken,
                        SessionToken = user.SessionToken
                    });
                }

                return Unauthorized(user);
            }
            catch (Exception exc)
            {
                ex = exc;
                return StatusCode(StatusCodes.Status500InternalServerError, exc.Message);
            }
            finally
            {
                //await Logger.LogAsync(new LogEntryData
                //{
                //    Level = ex is null ? loginSuccess ? LogLevel.info : LogLevel.warning : LogLevel.error,
                //    Message = new LogEntryMessageBuilder<LoginDTO>(nameof(TenantLogin), ex is null ? loginSuccess ? "Admin logged on specific tenant" : "Wrong jwt token" : "Method throw exception", new LoginDTO
                //    {
                //        UserName = user.UserName,
                //        Token = user.Token,
                //        RefreshToken = user.RefreshToken
                //    }).ToString(),
                //    LogException = ex,
                //    ResponseStatusCode = ex is null ? loginSuccess ? StatusCodes.Status200OK : StatusCodes.Status401Unauthorized : StatusCodes.Status500InternalServerError,
                //});
            }
        }
    }
}
