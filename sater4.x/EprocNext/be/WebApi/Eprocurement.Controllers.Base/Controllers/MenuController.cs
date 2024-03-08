using Core.Logger.Interfaces;
using EprocNext.Controllers.Base.Common.AbstractClasses;
using EprocNext.Controllers.Base.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using Cloud.EprocNext.DTO;

namespace Cloud.Core.Controllers.Controllers
{
    [Authorize]
    public class MenuController : AbsCloudController
    {
        //public ILicensingBiz Licensing { get; }

        //public MenuController(IUserClaimProvider userClaim, IHelkLogger logger, ILicensingBiz licensingBiz) : base(userClaim, logger)
        //{
        //    //Licensing = licensingBiz;
        //}

        public MenuController(IUserClaimProvider userClaim, IHelkLogger logger) : base(userClaim, logger)
        {
            //Licensing = licensingBiz;
        }

        //[HttpGet]
        //[ProducesResponseType(typeof(Menu), StatusCodes.Status200OK)]
        //[ProducesResponseType(StatusCodes.Status400BadRequest)]
        //public async Task<IActionResult> GetMenu()
        //{
        //    var result = await Licensing.GetMenuAsync(UserClaims.TenantId, UserClaims.Profile, "STANDARD");
        //    if (result != null)
        //        return Ok(result);

        //    return BadRequest();
        //}
    }
}
