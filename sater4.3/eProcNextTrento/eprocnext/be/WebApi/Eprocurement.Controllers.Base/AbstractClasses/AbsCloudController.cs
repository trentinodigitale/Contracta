using Core.Controllers.Types;
using Core.DTO.Common;
using Core.Logger.Interfaces;
using EprocNext.Controllers.Base.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace EprocNext.Controllers.Base.Common.AbstractClasses
{
    [ApiVersion("1.0")]
    [Route("api/v{v:apiVersion}/[controller]")]
    [ApiController]
    [Authorize]
    public abstract class AbsCloudController : ControllerBase
    {
        protected DecodedUserClaims UserClaims { get; }

        protected IHelkLogger Logger { get; }

        protected AbsCloudController(IUserClaimProvider userClaimsProvider, IHelkLogger logger)
        {
            UserClaims = userClaimsProvider.Claims;
            Logger = logger;
        }

        protected ObjectResult CloudErrorActionResult(HttpStatusCode responseStatusCode, ErrorClientResponse error)
        {
            // return new ObjectResult(error) { StatusCode = (int?) responseStatusCode };
            return StatusCode((int) responseStatusCode, error);
        }
    }
}
