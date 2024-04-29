using Core.Repositories.NoSql.AbstractClasses;
using Core.Repositories.NoSql.ExtensionMethods;
using Core.Repositories.NoSql.Interfaces;
using Core.Repositories.NoSql.Model;
using Core.Repositories.Types;
using MongoDB.Bson;
using MongoDB.Driver;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Core.Repositories.NoSql.Querying
{
    public class PipelineQuerying<TContext, TOutput>: AbsNoSqlPipelineQuerying, IPipelineQuerying<TContext, TOutput>
    {
        private INoSqlDBContext<TContext> DbContext { get; }

        public PipelineQuerying(INoSqlDBContext<TContext> dBContext, INoSqlSessionProvider session): base(session)
        {
            DbContext = dBContext;
        }

        public IEnumerable<TOutput> Get(IEnumerable<BsonDocument> aggregatePipeline, IClientSessionHandle session = null)
        {
            var pipeline = PipelineDefinition<TContext, TOutput>.Create(aggregatePipeline);
            var cursor = session is null ? DbContext.Collection.Aggregate(pipeline) : DbContext.Collection.Aggregate(session, pipeline);
            var result = cursor.ToList();
            result.ForEach(d => CalculateHash(d));
            return result;
        }

        public async Task<IEnumerable<TOutput>> GetAsync(IEnumerable<BsonDocument> aggregatePipeline, IClientSessionHandle session = null)
        {
            var pipeline = PipelineDefinition<TContext, TOutput>.Create(aggregatePipeline);
            var task = session is null ? await DbContext.Collection.AggregateAsync(pipeline) : await DbContext.Collection.AggregateAsync(session, pipeline);
            var result = await task.ToListAsync();
            result.ForEach(d => CalculateHash(d));
            return result;
        }

        #region Match stage
        public BsonDocument BuildMatchStage<T>(BsonDocument startMatchFilter, LookUpNoSqlFilter filter)
        {
            BsonDocument matchFilters = startMatchFilter ?? new BsonDocument();
            if (filter.Filters != null)
            {
                var pInfo = typeof(T).GetProperties().ToList();
                foreach (var flt in filter.Filters)
                {
                    var pObj = pInfo.Where(c => c.Name.Equals(flt.ColumnName, StringComparison.InvariantCultureIgnoreCase)).FirstOrDefault();
                    if (pObj != null)
                    {
                        try
                        {
                            var bsonFilter = Type.GetTypeCode(pObj.PropertyType)
                            switch
                            {
                                TypeCode.String => new BsonDocument
                                {
                                    {
                                        pObj.Name.ToCamelCase(),
                                        new BsonDocument
                                        {
                                            { "$regex", new Regex(flt.Value) },
                                            { "$options", "ix" }
                                        }
                                    }
                                },
                                var num when
                                    num == TypeCode.Int64 ||
                                    num == TypeCode.Int32 ||
                                    num == TypeCode.Int16 ||
                                    num == TypeCode.Decimal ||
                                    num == TypeCode.Double ||
                                    num == TypeCode.Boolean ||
                                    num == TypeCode.Object && pObj.PropertyType == typeof(Nullable<Int64>) ||
                                    num == TypeCode.Object && pObj.PropertyType == typeof(Nullable<Int32>) ||
                                    num == TypeCode.Object && pObj.PropertyType == typeof(Nullable<Int16>) ||
                                    num == TypeCode.Object && pObj.PropertyType == typeof(Nullable<Decimal>) ||
                                    num == TypeCode.Object && pObj.PropertyType == typeof(Nullable<Double>) ||
                                    num == TypeCode.Object && pObj.PropertyType == typeof(Nullable<Boolean>)
                                => ((Func<BsonDocument>)(() =>
                                {
                                    Type nullableType = pObj.PropertyType;
                                    nullableType = Nullable.GetUnderlyingType(nullableType) ?? nullableType;
                                    // this check is needed because Convert.ChangeType fails with nullable types
                                    dynamic val = null;
                                    if (flt.Value != null)
                                    {
                                        if (nullableType.IsEnum)
                                        {
                                            val = Enum.Parse(nullableType, flt.Value);
                                        }
                                        else
                                        {
                                            val = Convert.ChangeType(flt.Value, nullableType);
                                        }
                                    }
                                    return new BsonDocument
                                        {
                                            { pObj.Name.ToCamelCase(), val }
                                        };
                                }))(),
                                var dt when
                                    dt == TypeCode.DateTime || dt == TypeCode.Object && pObj.PropertyType == typeof(Nullable<DateTime>) => ((Func<BsonDocument>)(() =>
                                    {
                                        DateTime dtStart = Convert.ToDateTime(flt.Value);
                                        DateTime dtStop = dtStart.AddDays(1);
                                        return new BsonDocument
                                        {
                                            {
                                                pObj.Name.ToCamelCase(),
                                                new BsonDocument
                                                {
                                                    {"$gte", dtStart },
                                                    { "$lt", dtStop }
                                                }
                                            }
                                        };
                                    }))(),
                                /*
                                 TODO: Complete others TypeCode. types
                                     */
                                _ => null
                            };

                            matchFilters.AddRange(bsonFilter);
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine(ex.Message);
                        }
                    }
                }
            }

            return new BsonDocument("$match", matchFilters);
        }
        #endregion Match stage

        #region Sort stage
        public BsonDocument BuildSortStage<T>(BsonDocument startSortFilter, LookUpNoSqlFilter filter)
        {
            BsonDocument sortFilters = startSortFilter ?? new BsonDocument();
            if (filter.Sorting != null)
            {
                var pInfo = typeof(T).GetProperties().ToList();
                foreach (var ordBy in filter.Sorting)
                {
                    var pObj = pInfo.Where(c => c.Name.Equals(ordBy.ColumnName, StringComparison.InvariantCultureIgnoreCase)).FirstOrDefault();
                    sortFilters.AddRange(new BsonDocument { { pObj.Name.ToCamelCase(), ordBy.Direction == LookupSortingDirection.Asc ? 1 : -1 } });
                }
            }
            return new BsonDocument("$sort", sortFilters);
        }
        #endregion Sort stage
    }
}
