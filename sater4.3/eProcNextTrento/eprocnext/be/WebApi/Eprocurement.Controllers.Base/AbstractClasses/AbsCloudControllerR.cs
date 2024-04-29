using Core.Logger.Interfaces;
using Core.Logger.Types;
using Core.Repositories;
using Core.Repositories.Abstractions.Interfaces;
using Core.Repositories.Interfaces;
using EprocNext.Controllers.Base.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace EprocNext.Controllers.Base.Common.AbstractClasses
{
    public abstract class AbsCloudControllerR<TEntity, TRepository> : AbsCloudController where TEntity : class, ISecurityDTO where TRepository : IRepositoryCrud<TEntity>
    {
        protected TRepository Repository { get; }

        protected AbsCloudControllerR(IUserClaimProvider userClaim, TRepository repository, IHelkLogger logger) : base(userClaim, logger)
        {
            Repository = repository;
        }

        protected int? GetStatusCode<T>(ActionResult<T> result)
        {
            if (result is ObjectResult objectResult)
                return objectResult.StatusCode;
            else if (result is StatusCodeResult statusCode)
                return statusCode.StatusCode;

            return null;
        }

        protected int? GetStatusCode(IActionResult result)
        {
            if (result is ObjectResult objectResult)
                return objectResult.StatusCode;
            else if (result is StatusCodeResult statusCode)
                return statusCode.StatusCode;

            return null;
        }
        /// <summary>
        /// Override this in order to return specific filter for tenant
        /// key over specific TEntity type.
        /// </summary>
        /// <returns></returns>
        protected virtual string GetTenantConditionForSearch()
        {
            return "";
        }

        /// <summary>
        /// Returns a paged list of requested element for specified filters
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        [HttpGet]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async virtual Task<ActionResult<ILookupResultDTO<TEntity>>> Get([FromHeader(Name = "filter")] LookupRepositoryDTO filter)
        {
            try
            {
                ActionResult<ILookupResultDTO<TEntity>> result = BadRequest();
                if (!(filter is null))
                {
                    var search = await Repository.SearchAsync(UserClaims.TenantId, filter, GetTenantConditionForSearch());
                    if (search.TotalRecords > 0)
                        result = Ok(search);
                    else
                        result = NotFound();
                }

                //await Logger.LogAsync(new LogEntryData
                //{
                //    Level = result is BadRequestResult ? LogLevel.warning : LogLevel.info,
                //    Message = new LogEntryMessageBuilder<LookupRepositoryDTO>(nameof(Get), $"Result: {GetStatusCode(result)}", filter).ToString(),
                //    ResponseStatusCode = GetStatusCode(result)
                //});

                return result;
            }
            catch (Exception e)
            {
                //await Logger.LogAsync(new LogEntryData
                //{
                //    Level = LogLevel.error,
                //    Message = new LogEntryMessageBuilder<LookupRepositoryDTO>(nameof(Get), $"Method throw exception", filter).ToString(),
                //    LogException = e,
                //    ResponseStatusCode = 500
                //});
                throw;
            }
        }

        /// <summary>
        /// Return single item with specified identifier
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpGet("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async virtual Task<ActionResult<TEntity>> GetById(string id)
        {
            try
            {
                ActionResult<TEntity> result = BadRequest();
                if (!(id is null))
                {
                    var search = await Repository.GetAsync(UserClaims.TenantId, id);
                    if (search != null)
                        result = Ok(search);
                    else
                        result = NotFound();
                }

                //await Logger.LogAsync(new LogEntryData
                //{
                //    Level = result is BadRequestResult ? LogLevel.warning : LogLevel.info,
                //    Message = new LogEntryMessageBuilder<string>(nameof(GetById), $"Result: {GetStatusCode(result)}", id).ToString(),
                //    ResponseStatusCode = GetStatusCode(result)
                //});

                return result;
            }
            catch (Exception e)
            {
                //await Logger.LogAsync(new LogEntryData
                //{
                //    Level = LogLevel.error,
                //    Message = new LogEntryMessageBuilder<string>(nameof(GetById), $"Method throw an exception", id).ToString(),
                //    LogException = e,
                //    ResponseStatusCode = 500
                //});

                throw;
            }
        }
    }
}
