using Core.Repositories.NoSql.Interfaces;
using Core.Repositories.NoSql.Model;
using MongoDB.Bson;
using System;
using System.Linq;
using System.Text.RegularExpressions;

namespace Core.Repositories.NoSql.ExtensionMethods
{
    public static class NoSqlRepositoryExtensions
    {
        public static BsonDocument BuildMatchStage<T>(this INoSqlRepository<T> repository, BsonDocument startMatchFilter, LookUpFilter filter) where T: class, INoSqlCollection
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
                                    num == TypeCode.Object && pObj.PropertyType == typeof(Nullable<Int64>) ||
                                    num == TypeCode.Object && pObj.PropertyType == typeof(Nullable<Int32>) ||
                                    num == TypeCode.Object && pObj.PropertyType == typeof(Nullable<Int16>) ||
                                    num == TypeCode.Object && pObj.PropertyType == typeof(Nullable<Decimal>) ||
                                    num == TypeCode.Object && pObj.PropertyType == typeof(Nullable<Double>)
                                => ((Func<BsonDocument>)(() => {
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
                                    dt == TypeCode.DateTime || dt == TypeCode.Object && pObj.PropertyType == typeof(Nullable<DateTime>) => ((Func<BsonDocument>)(() => {
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

        public static BsonDocument BuildSortStage<T>(this INoSqlRepository<T> repository, BsonDocument startSortFilter, LookUpFilter filter) where T : class, INoSqlCollection
        {
            BsonDocument sortFilters = startSortFilter ?? new BsonDocument();
            if (filter.Sorting != null)
            {
                var pInfo = typeof(T).GetProperties().ToList();
                foreach (var ordBy in filter.Sorting)
                {
                    var pObj = pInfo.Where(c => c.Name.Equals(ordBy.ColumnName, StringComparison.InvariantCultureIgnoreCase)).FirstOrDefault();
                    sortFilters.AddRange(new BsonDocument { { pObj.Name.ToCamelCase(), ordBy.Direction == Repositories.Types.LookupSortingDirection.Asc ? 1 : -1 } });
                }
            }
            return new BsonDocument("$sort", sortFilters);
        }
    }
}
