using Core.Logger.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using EprocNext.Controllers.Base.Interfaces;
using Core.Repositories.Interfaces;
using EprocNext.Controllers.Base.Common.AbstractClasses;

namespace FTM.Cloud.Core.Controllers.Common.AbstractClasses
{
    public abstract class AbsCloudControllerMantainerCRUD<TEntity, TRepository> : AbsCloudControllerCRUD<TEntity, TRepository> where TEntity : class, ISecurityDTO where TRepository : IRepositoryCrud<TEntity>
    {
        protected AbsCloudControllerMantainerCRUD(IUserClaimProvider userClaim, TRepository repository, IHelkLogger logger) : base(userClaim, repository, logger)
        { }

        [Authorize(Roles = "Maintainer")]
        public override async Task<ActionResult<TEntity>> Put(string id, [FromBody] TEntity entity)
        {
            return await base.Put(id, entity);
        }

        [Authorize(Roles = "Maintainer")]
        public override async Task<ActionResult<TEntity>> Post([FromBody] TEntity entity)
        {
            return await base.Post(entity);
        }

        [Authorize(Roles = "Maintainer")]
        public override async Task<ActionResult<TEntity>> Patch(string id, [FromBody] JsonPatchDocument<TEntity> patch)
        {
            return await base.Patch(id, patch);
        }
    }
}
