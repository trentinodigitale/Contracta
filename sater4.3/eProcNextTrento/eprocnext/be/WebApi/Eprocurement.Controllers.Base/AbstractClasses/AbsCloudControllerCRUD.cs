using Core.Controllers.Types;
using Core.Logger.Interfaces;
using Core.Logger.Types;
using Core.Repositories.Interfaces;
using EprocNext.Controllers.Base.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mime;
using System.Threading.Tasks;


namespace EprocNext.Controllers.Base.Common.AbstractClasses
{
    public abstract class AbsCloudControllerCRUD<TEntity, TRepository> : AbsCloudControllerCRU<TEntity, TRepository> where TEntity : class, ISecurityDTO where TRepository : IRepositoryCrud<TEntity>
    {
        protected AbsCloudControllerCRUD(IUserClaimProvider userClaim, TRepository repository, IHelkLogger logger) : base(userClaim, repository, logger)
        { }

        [HttpDelete("{id}/{hash}")]
        [Consumes(MediaTypeNames.Application.Json)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public virtual async Task<ActionResult<TEntity>> Delete(string id, string hash)
        {
            try
            {
                ActionResult<TEntity> result = BadRequest();
                if (!(id is null || hash is null))
                {
                    var res = await Repository.DeleteAsync(id, Convert.ToUInt32(hash));
                    if (res == 0)
                        result = NotFound();
                    else
                        result = NoContent();
                }

                //await Logger.LogAsync(new LogEntryData { Level = result is BadRequestResult ? LogLevel.warning : LogLevel.info, Message = new LogEntryMessageBuilder<Tuple<string, string>>(nameof(Delete), $"Result: {GetStatusCode(result)}", new Tuple<string, string>(id, hash)).ToString(), ResponseStatusCode = GetStatusCode(result) });

                return result;
            }
            catch (Exception e)
            {
                //await Logger.LogAsync(new LogEntryData { Level = LogLevel.error, Message = new LogEntryMessageBuilder<Tuple<string, string>>(nameof(Delete), $"Method throws exception", new Tuple<string, string>(id, hash)).ToString(), LogException = e, ResponseStatusCode = 500 });
                throw;
            }
        }

        [HttpDelete]
        [Consumes(MediaTypeNames.Application.Json)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public virtual async Task<IActionResult> DeleteMultiple([FromBody] IEnumerable<DeleteItem> ids)
        {
            try
            {
                IActionResult result = BadRequest();
                if (ids != null && ids.Any() && ids.All(i => i.Id != null))
                {
                    result = NoContent();
                    //TODO :
                    //var res = await Repository.BulkDeleteAsync(ids.Select(i => (Convert.ToInt64(i.Id.ToString()), i.Hash)));
                    //if (res == 0)
                    //    result = CloudErrorActionResult(System.Net.HttpStatusCode.UnprocessableEntity, new ErrorClientResponse()
                    //    {
                    //        InternalMessage = "Cancellazione non riuscita",
                    //        UserMessage = "Cancellazione non riuscita",
                    //    });
                    //else
                    //    result = NoContent();
                }
                var status = result is NoContentResult ? StatusCodes.Status204NoContent : StatusCodes.Status422UnprocessableEntity;
                //await Logger.LogAsync(new LogEntryData { Level = result is NoContentResult ? LogLevel.info : LogLevel.warning, Message = new LogEntryMessageBuilder<IEnumerable<DeleteItem>>(nameof(DeleteMultiple), $"Result: {status}", ids).ToString(), ResponseStatusCode = status });

                return result;
            }
            catch (Exception e)
            {
                //await Logger.LogAsync(new LogEntryData { Level = LogLevel.error, Message = new LogEntryMessageBuilder<IEnumerable<DeleteItem>>(nameof(Delete), $"Method throws exception", ids).ToString(), LogException = e, ResponseStatusCode = StatusCodes.Status500InternalServerError });
                throw;
            }
        }
    }
}
