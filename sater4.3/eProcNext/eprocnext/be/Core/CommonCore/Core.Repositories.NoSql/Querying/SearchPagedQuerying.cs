using Core.Repositories.NoSql.AbstractClasses;
using Core.Repositories.NoSql.Data;
using Core.Repositories.NoSql.ExtensionMethods;
using Core.Repositories.NoSql.Interfaces;
using Core.Repositories.NoSql.Model;
using Core.Repositories.NoSql.Types;
using Core.Repositories.Types;
using MongoDB.Driver;
using MongoDB.Driver.Linq;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;

namespace Core.Repositories.NoSql.Querying
{
    public class SearchPagedQuerying<TContext> : AbsNoSqlQuerying<ILookUpFilter, PageItems<TContext>, TContext> where TContext : class, INoSqlCollection
    {
        public SearchPagedQuerying(INoSqlDBContext<TContext> dBContext, INoSqlSessionProvider session) : base(dBContext, session) { }

        public override PageItems<TContext> Execute(ILookUpFilter param, IClientSessionHandle session = null)
        {
            return ExecuteAsync(param).Result;
        }

        public override async Task<PageItems<TContext>> ExecuteAsync(ILookUpFilter param, IClientSessionHandle session = null)
        {
            param ??= new LookUpFilter();
            var (filterDefinitions, propertiesTypeInfo) = BuildFilter<TContext>(param.Filters);
            IFindFluent<TContext, TContext> query;
            if(session is null)
                query = param.isFiltered ? Collection.Find(filterDefinitions) : Collection.Find(_ => true);
            else
                query = param.isFiltered ? Collection.Find(session, filterDefinitions) : Collection.Find(session, _ => true);
            var queryOrdered = BuildOrderBy(query, param.Sorting, propertiesTypeInfo);
            IFindFluent<TContext, TContext> queryToExecute = queryOrdered;

            // check if param contain field to exclude
            if (param.FieldsToInclude.Length > 0)
            {
                var listOfField = string.Join(",", param.FieldsToInclude.Select(el => $@"""{el.ToCamelCase()}"":1"));
                queryToExecute = queryToExecute.Project<TContext>($@"{{ {listOfField} }}");
            }

            var totResult = queryToExecute.CountDocumentsAsync();
            var itemTasks = queryToExecute
                .Skip((param.PageNumber > 0 ? param.PageNumber - 1 : param.PageNumber) * param.PageSize)
                .Limit(param.PageSize)
                .ToListAsync();
            await Task.WhenAll(totResult, itemTasks);

            itemTasks.Result.ForEach(i => CalculateHash(i));
            return new PageItems<TContext>
            {
                Data = itemTasks.Result,
                TotalPages = (totResult.Result / param.PageSize) + 1,
                TotalRecords = totResult.Result
            };
        }

        /// <summary>
        /// Recursive function to produce list of object properties
        /// </summary>
        /// <param name="typeToExplore">Type to explore by traversing</param>
        /// <returns>List of properties, their names and types</returns>
        private List<TypeDetail> Traverse(Type typeToExplore, string nameAccumulator = "")
        {
            if (typeToExplore == null)
                return new List<TypeDetail>();

            var firstStep = typeToExplore
                .GetProperties(BindingFlags.Instance | BindingFlags.Public)
                .Where(p => p.CanRead && p.CanWrite)
                .Where(p => p.GetGetMethod(true).IsPublic)
                .Where(p => p.GetSetMethod(true).IsPublic);

            List<TypeDetail> properties = firstStep.Select(p => new TypeDetail { Name = p.Name, FullName = $"{(nameAccumulator != "" ? $"{nameAccumulator}." : "")}{p.Name.ToCamelCase()}", TypeName = p.PropertyType.Name, TypeFullName = p.PropertyType.FullName, PType = p.PropertyType, IsPrimitive = p.PropertyType.IsPrimitive }).ToList();
            var notPrimitive = properties.Where(p => !p.IsPrimitive && !p.PType.Name.Equals("Enum") && !p.TypeName.Equals("Enum") && !p.TypeName.Equals("ObjectId") && !p.TypeName.Equals("String") && !p.TypeName.Equals("Int64") && !p.TypeName.Equals("Int32") && !p.TypeName.Equals("DateTime"));
            if (notPrimitive.Count() > 0)
                notPrimitive.ToList().ForEach(p => { properties.AddRange(Traverse(p.PType, $"{(nameAccumulator != "" ? $"{nameAccumulator}." : "")}{p.Name.ToCamelCase()}")); });

            return properties;
        }

        /// <summary>
        /// It build theMongoDB orderby filter from orderby filter passed as input parameter
        /// </summary>
        /// <typeparam name="T">TDocument of the target MongoDB target Collection</typeparam>
        /// <param name="query">MongoDB Filter object</param>
        /// <param name="orderBy">OrderBy object. It takes only the first value</param>
        /// <param name="propertiesTypeInfo">List of T property info produced by BuildFilter</param>
        /// <returns>input query Object with orderby Filter concatenated</returns>
        protected IFindFluent<T, T> BuildOrderBy<T>(IFindFluent<T, T> query, ILookUpOrderBy[] orderBy, List<TypeDetail> propertiesTypeInfo)
        {
            if (orderBy == null || (orderBy != null && orderBy.Length == 0))
                return query;

            var columnOrderType = propertiesTypeInfo.Where(elTp => elTp.FullName.Contains(orderBy[0].ColumnName, StringComparison.InvariantCultureIgnoreCase)).FirstOrDefault();
            if (columnOrderType == null)
                throw new ArgumentException($"Colum order {orderBy[0].ColumnName} not found");

            return orderBy[0].Direction switch
            {
                LookupSortingDirection.Asc => query.Sort($"{{ '{columnOrderType.FullName}': 1 }}"),
                LookupSortingDirection.Desc => query.Sort($"{{ '{columnOrderType.FullName}': -1 }}"),
                _ => throw new ArgumentException($"{orderBy[0].Direction} is not a valid value. The only values available are: [{SortOperators.Asc}, {SortOperators.Desc}]"),
            };
        }

        /// <summary>
        /// It compose the filter into MongoDB driver format by filter passed as a input parameter
        /// </summary>
        /// <typeparam name="T">TDocument of the target MongoDB target Collection</typeparam>
        /// <param name="lookupFilters">Input filters used by compose MongoDB filters</param>
        /// <returns>Tuple of MongoDB filterDefinitions and propertiesTypeInfo produced by traversing the Generic type T</returns>
        protected (FilterDefinition<T> filterDefinitions, List<TypeDetail> propertiesTypeInfo) BuildFilter<T>(ILookUpFilterClauses[] lookupFilters)
        {
            var builder = Builders<T>.Filter;
            FilterDefinition<T> filter = null;
            var lookUpTypes = Traverse(typeof(T));

            lookupFilters.Where(t => t != null).ToList().ForEach(lf =>
            {
                var columnFilterType = lookUpTypes.Where(elTp => elTp.FullName.Contains(lf.ColumnName, StringComparison.InvariantCultureIgnoreCase)).FirstOrDefault();

                dynamic getValue(TypeDetail filterType, string filterValue) => filterType.TypeName.Equals("String") ? filterValue : filterType.PType.IsEnum ? Enum.Parse(filterType.PType, filterValue) : Convert.ChangeType(filterValue, filterType.PType);

                FilterDefinition<T> AND(FilterDefinition<T> left, FilterDefinition<T> right) => left != null ? left & right : right;

                void CheckIfColumnTypeIsNumber(TypeDetail columnFilter) { if (!(columnFilterType.PType == typeof(Nullable<Int32>) || columnFilterType.PType == typeof(Nullable<Int64>) || columnFilterType.PType == typeof(Int32) || columnFilterType.PType == typeof(Int64) || columnFilterType.PType == typeof(Decimal) || columnFilterType.PType == typeof(Double))) throw new ArgumentException($"{columnFilterType.Name} must be a number type!"); }

                string resolveSilngleDatatimeFilter(TypeDetail _filter, ILookUpFilterClauses currentFilter)
                {
                    string fromDate = currentFilter.Value;
                    if (!DateTime.TryParse(currentFilter.Value, out _))
                        throw new InvalidCastException($"{_filter.FullName} filter is not a valid Datetime");

                    string toDateString = "";
                    if (DateTime.TryParse(currentFilter.Value, out DateTime toDate))
                    {
                        toDateString = toDate.AddDays(1).ToString("yyyy-MM-dd");
                    }

                    return $"{{ '{columnFilterType.FullName}' : {{ $gte: ISODate('{fromDate}'), $lt: ISODate('{toDateString}') }} }}";
                }

                switch (lf.Operation)
                {
                    case LookupFilterOperation.Equals:
                        if (columnFilterType.PType == typeof(DateTime) || columnFilterType.PType == typeof(DateTime?))
                            filter = AND(filter, resolveSilngleDatatimeFilter(columnFilterType, lf));
                        else
                            filter = AND(filter, builder.Eq(columnFilterType.FullName, getValue(columnFilterType, lf.Value)));
                        break;

                    #region String filters --------------------------------------------------------------------------------------------
                    case LookupFilterOperation.Contains:
                        if (columnFilterType.PType == typeof(DateTime) || columnFilterType.PType == typeof(DateTime?))
                            filter = AND(filter, resolveSilngleDatatimeFilter(columnFilterType, lf));
                        else
                            filter = AND(filter, $"{{ '{columnFilterType.FullName}' : {{ $regex : '{lf.Value}', $options: 'i' }} }}");
                        break;
                    case LookupFilterOperation.StartsWith:
                        filter = AND(filter, $"{{ '{columnFilterType.FullName}' : {{ $regex : '^{lf.Value}.*', $options: 'i' }} }}");
                        break;
                    case LookupFilterOperation.EndsWith:
                        filter = AND(filter, $"{{ '{columnFilterType.FullName}' : {{ $regex : '.*{lf.Value}$', $options: 'i' }} }}");
                        break;
                    #endregion String filters ----------------------------------------------------------------------------------------

                    #region Number filters -------------------------------------------------------------------------------------------
                    case LookupFilterOperation.More:
                        CheckIfColumnTypeIsNumber(columnFilterType);
                        filter = AND(filter, $"{{ '{columnFilterType.FullName}' : {{ $gte : {lf.Value} }} }}");
                        break;
                    case LookupFilterOperation.Less:
                        CheckIfColumnTypeIsNumber(columnFilterType);
                        filter = AND(filter, $"{{ '{columnFilterType.FullName}' : {{ $lt : {lf.Value} }} }}");
                        break;
                    #endregion Number filters -------------------------------------------------------------------------------------------

                    #region Date filters --------------------------------------------------------------------------------------------
                    case LookupFilterOperation.RangeDate:
                        if (columnFilterType.PType == typeof(DateTime) || columnFilterType.PType == typeof(DateTime?))
                        {
                            string fromDate = lf.dateFrom.Value.ToString("o", CultureInfo.InvariantCulture);
                            string toDate = lf.dateTo.Value.ToString("o", CultureInfo.InvariantCulture);
                            filter = AND(filter, $"{{ '{columnFilterType.FullName}' : {{ $gte: ISODate('{fromDate}'), $lt: ISODate('{toDate}') }} }}");
                        }
                        else
                            throw new ArgumentException($"{columnFilterType.Name} must be a DateTime type!");
                        break;
                        #endregion Date filters ------------------------------------------------------------------------------------------
                }
            });
            return (filterDefinitions: filter ?? default, propertiesTypeInfo: lookUpTypes);
        }
    }
}
