using Cloud.Core.HelkLogger.Types;
using Core.Logger.Interfaces;
using Core.Logger.Types;
using Core.Repositories.Interfaces;
using EprocNext.Controllers.Base.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Data.SqlClient;
using System.Net.Mime;
using System.Threading.Tasks;

namespace EprocNext.Controllers.Base.Common.AbstractClasses
{
    public abstract class AbsCloudControllerCRU<TEntity, TRepository> : AbsCloudControllerR<TEntity, TRepository> where TEntity : class, ISecurityDTO where TRepository : IRepositoryCrud<TEntity>
    {
        protected AbsCloudControllerCRU(IUserClaimProvider userClaim, TRepository repository, IHelkLogger logger) : base(userClaim, repository, logger)
        { }

        protected async Task<int> CreateEntiry(TEntity entity)
        {
            var result = await Repository.InsertAsync(UserClaims.TenantId, entity);
            return (int)(result ?? -1);
        }

        [HttpPost]
        [Consumes(MediaTypeNames.Application.Json)]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async virtual Task<ActionResult<TEntity>> Post([FromBody] TEntity entity)
        {
            try
            {
                ActionResult<TEntity> result = BadRequest();
                if (!(entity is null))
                {
                    var id = await CreateEntiry(entity);
                    if(id > 0)
                        result = CreatedAtAction(nameof(this.GetById), new { id }, entity);
                }

                //await Logger.LogAsync(new LogEntryData
                //{
                //    Level = result is BadRequestResult ? LogLevel.warning : LogLevel.info,
                //    Message = new LogEntryMessageBuilder(nameof(Post), $"Result: {GetStatusCode(result)}", entity).ToString(),
                //    ResponseStatusCode = GetStatusCode(result)
                //});

                return result;
            }
            catch (Exception e)
            {
                //await Logger.LogAsync(new LogEntryData
                //{
                //    Level = LogLevel.error,
                //    Message = new LogEntryMessageBuilder(nameof(Post), $"Method throws an exception", entity).ToString(),
                //    LogException = e,
                //    ResponseStatusCode = 500
                //});

                throw;
            }
        }

        [HttpPut("{id}")]
        [Consumes(MediaTypeNames.Application.Json)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async virtual Task<ActionResult<TEntity>> Put(string id, [FromBody] TEntity entity)
        {
            try
            {
                ActionResult<TEntity> result = BadRequest();

                if (!(id is null || entity is null))
                {
                    var searchResult = await Repository.GetAsync(UserClaims.TenantId, id);
                    if (searchResult is null)
                    {
                        var newId = await CreateEntiry(entity);
                        if (newId > 0)
                            result = CreatedAtAction(nameof(this.GetById), new { id = newId }, entity);
                    }
                    else
                        result = await UpdateEntity(entity);
                }

                //await Logger.LogAsync(new LogEntryData { Level = result is BadRequestResult ? LogLevel.warning : LogLevel.info, Message = new LogEntryMessageBuilder<TEntity>(nameof(Put), $"Result: {GetStatusCode(result)}", entity).ToString(), ResponseStatusCode = GetStatusCode(result) });

                return result;
            }
            catch (Exception e)
            {
                //await Logger.LogAsync(new LogEntryData { Level = LogLevel.error, Message = new LogEntryMessageBuilder<TEntity>(nameof(Put), $"Method throws an exception", entity).ToString(), LogException = e, ResponseStatusCode = 500 });
                throw;
            }
        }

        protected async Task<ActionResult<TEntity>> UpdateEntity(TEntity entity)
        {
            try
            {
                var result = await Repository.UpdateAsync(entity);
                if (result >= 0)
                    return NoContent();

                return BadRequest();
            }
            catch (UnauthorizedAccessException)
            {
                return Unauthorized();
            }
            catch (SqlException)
            {
                return Conflict();
            }
            catch (Exception)
            {
                throw;
            }
        }

        [HttpPatch("{id}")]
        [NonAction] // Disabled HttpPatch because not already supported by repository
        [Consumes(MediaTypeNames.Application.Json)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async virtual Task<ActionResult<TEntity>> Patch(string id, [FromBody]JsonPatchDocument<TEntity> patch)
        {
            try
            {
                ActionResult<TEntity> result = BadRequest();
                if (!(id is null || patch is null))
                {
                    var searchResult = await Repository.GetAsync(UserClaims.TenantId, id);
                    if (searchResult is null)
                        result = NotFound();
                    else
                    {
                        patch.ApplyTo(searchResult);
                        result = await UpdateEntity(searchResult);
                    }
                }

                //await Logger.LogAsync(new LogEntryData { Level = result is BadRequestResult ? LogLevel.warning : LogLevel.info, Message = new LogEntryMessageBuilder<JsonPatchDocument<TEntity>>(nameof(Patch), $"Result: {GetStatusCode(result)}", patch).ToString(), ResponseStatusCode = GetStatusCode(result) });
                return result;
            }
            catch (Exception e)
            {
                //await Logger.LogAsync(new LogEntryData { Level = LogLevel.error, Message = new LogEntryMessageBuilder<JsonPatchDocument<TEntity>>(nameof(Patch), $"Method throws an exception", patch).ToString(), LogException = e, ResponseStatusCode = 500 });
                throw;
            }
        }
    }
}
