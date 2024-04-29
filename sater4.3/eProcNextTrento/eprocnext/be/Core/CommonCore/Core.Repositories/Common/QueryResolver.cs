using Core.Repositories.Abstractions.Interfaces;
using Core.Repositories.Common;
using Core.Repositories.Interfaces;
using Core.Repositories.Types;
using Dapper;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using TSQL;
using TSQL.Statements;
using TSQL.Tokens;

namespace Core.Repositories
{
    public class QueryResolver : IClauseNormalizer
    {
        private readonly List<IResolver> _resolvers;

        public QueryResolver(IResolver resolver)
        {
            _resolvers = new List<IResolver>() { resolver };
        }

        /// <summary>
        /// Used to add resolver for join evaluation
        /// </summary>
        /// <param name="resolver"></param>
        public void AddResolver(IResolver resolver)
        {
            _resolvers.Add(resolver);
        }

        public string NormalizeFrom<TDto>(string query) where TDto : IDtoResolver, ISecurityDTO, new()
        {
            if (string.IsNullOrEmpty(query)) return query;
            var tblDtoName = typeof(TDto).Name;
            var tblMapName = typeof(TDto).DbTableName();
            string pattern = $"{tblDtoName}";
            MatchEvaluator evaluator = new MatchEvaluator((Match match) => { return tblMapName; });
            var queryNormalized = Regex.Replace(query, pattern, evaluator,
                RegexOptions.IgnoreCase,
                TimeSpan.FromSeconds(.25));
            return queryNormalized;
        }

        private string LookupClauseToSqlClause(LookupFilterOperation lookupClause, object value,
            ref IDictionary<string, object> parameter)
        {
            string paramName = $"@LookupFilter_{parameter.Count}";
            object val = lookupClause switch
            {
                LookupFilterOperation.Contains => $"%{value}%",
                LookupFilterOperation.StartsWith => $"{value}%",
                LookupFilterOperation.EndsWith => $"%{value}",
                _ => value
            };
            string where = lookupClause switch
            {
                LookupFilterOperation.Contains => $"LIKE {paramName}",
                LookupFilterOperation.StartsWith => $"LIKE {paramName}",
                LookupFilterOperation.EndsWith => $"LIKE {paramName}",
                LookupFilterOperation.Equals => $"= {paramName}",
                LookupFilterOperation.Less => $"< {paramName}",
                LookupFilterOperation.LessOrEquals => $"<= {paramName}",
                LookupFilterOperation.More => $"> {paramName}",
                LookupFilterOperation.MoreOrEquals => $">= {paramName}",
                _ => throw new NotImplementedException("Filter operation not implemented")
            };
            parameter.Add(paramName, val);
            return where;
        }

        public string NormalizeLookUpFilter(IEnumerable<ILookupFilterDTO> lookupFilter, ref IDictionary<string, object> parameters)
        {
            if (lookupFilter == null || lookupFilter?.Count() == 0)
                return string.Empty;

            var sqlWhere = new List<string>();
            foreach (var el in lookupFilter)
            {
                sqlWhere.Add($"{el.ColumnName} {LookupClauseToSqlClause(el.Operation, el.Value, ref parameters)}");
            }
            string sql = string.Join(" AND ", sqlWhere);
            return sql;
        }

        public string NormalizeLookUpOrderBy(IEnumerable<ILookupSortingDTO> lookupSorting)
        {
            if (lookupSorting == null || lookupSorting?.Count() == 0) return "";
            return lookupSorting.Select(el => $"{el.ColumnName} {el.Direction}").Aggregate((curr, next) => $"{curr}, {next}");
        }

        public string NormalizeWhere(string whereCondition)
        {
            if (string.IsNullOrWhiteSpace(whereCondition))
                return whereCondition;

            foreach (TSQLToken token in TSQLTokenizer.ParseTokens(whereCondition).Where(t => t.Type == TSQLTokenType.Identifier))
            {
                whereCondition = whereCondition.Replace(token.Text, _resolvers.FirstOrDefault().FieldResolver(token.Text));
            }
            return whereCondition;
        }

        public string NormalizeorderBy(string orderByCondition)
        {
            if (string.IsNullOrEmpty(orderByCondition)) return orderByCondition;
            var splittedorderBy = orderByCondition.Split(new[] { "," }, StringSplitOptions.None);

            foreach (string field in splittedorderBy)
            {
                string trimField = Regex.Replace(field.Trim(), @"\s+asc|\s+desc", "", RegexOptions.IgnoreCase);

                orderByCondition = orderByCondition.Replace(trimField, _resolvers.FirstOrDefault().FieldResolver(trimField?.Trim()));
            }
            return orderByCondition;
        }

        public string CreateBaseSelect<TDto>()
        {
            var tblMapName = typeof(TDto).DbTableName();
            return $"SELECT * FROM {tblMapName}";
        }

        public IDictionary<string, object> MergeAnonimousQueryParameters(object params1, object params2)
        {
            IDictionary<string, object> dynamicParam = new Dictionary<string, object>();
            if (params1 != null)
            {
                MergeAnonimousQueryParametersFromDictory(ref dynamicParam, params1);
            }
            if (params2 != null)
            {
                MergeAnonimousQueryParametersFromDictory(ref dynamicParam, params2);
            }
            return dynamicParam;
        }

        public void MergeAnonimousQueryParametersFromDictory(ref IDictionary<string, object> dynamicParam, object par)
        {
            if (par != null)
            {
                if (par is IDictionary &&
                   par.GetType().IsGenericType &&
                   par.GetType().GetGenericTypeDefinition().IsAssignableFrom(typeof(Dictionary<,>)))
                {
                    foreach (DictionaryEntry di in (IDictionary)par)
                    {
                        dynamicParam.TryAdd($"@{di.Key}", di.Value);
                    }
                }
                else
                {
                    foreach (PropertyInfo fi in par.GetType().GetProperties())
                    {
                        dynamicParam.TryAdd($"@{fi.Name}", fi.GetValue(par, null));
                    }
                }
            }
        }

        public string NormalizeJoin(string sqlWithJoin)
        {
            if (string.IsNullOrEmpty(sqlWithJoin)) return sqlWithJoin;
            if (_resolvers == null) throw new ArgumentException("Resolvers are not initializated", "resolvers");
            string _sqlNormalized = sqlWithJoin;
            try
            {
                TSQLSelectStatement select = TSQLStatementReader.ParseStatements(sqlWithJoin)[0] as TSQLSelectStatement;
                var identifier = select.Tokens.Where(tkn => tkn.Type == TSQLTokenType.Identifier).Select(tkn => tkn.Text);

                foreach (var tbl in identifier)
                {
                    foreach (var res in _resolvers)
                    {
                        try
                        {
                            string tblResolved = res.FieldResolver(tbl?.Trim());
                            if (!tblResolved.Equals(tbl?.Trim()))
                            {
                                _sqlNormalized = Regex.Replace(_sqlNormalized, $@"\b({tbl})\b", tblResolved,
                                             RegexOptions.IgnoreCase);
                                break;
                            }
                        }
                        catch { }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Invalid sql: {sqlWithJoin}", ex);
            }

            return _sqlNormalized;
        }

        public void BuildInsertParameters<T>(StringBuilder sb)
        {
            sb.Append(typeof(T).GetProperties().ToList()
                .Where(x => !Attribute.IsDefined(x, typeof(KeyAttribute)) || Attribute.IsDefined(x, typeof(RequiredAttribute)))
                .Select(el => el.Name)
                .Aggregate((current, next) => $"{current}, {next}"));
        }

        private string ToSQLValue<T>(PropertyInfo property, T entity)
        {
            if (property.GetValue(entity) == null)
            {
                return $"NULL";
            }

            if (property.PropertyType == typeof(string) || property.PropertyType == typeof(char))
            {
                return $"'{property.GetValue(entity)}'";
            }

            if (property.PropertyType == typeof(int) || property.PropertyType == typeof(int?) ||
                property.PropertyType == typeof(uint) || property.PropertyType == typeof(uint?) ||
                property.PropertyType == typeof(float) || property.PropertyType == typeof(float?) ||
                property.PropertyType == typeof(decimal) || property.PropertyType == typeof(decimal?) ||
                property.PropertyType == typeof(byte) || property.PropertyType == typeof(byte?) ||
                property.PropertyType == typeof(Single) || property.PropertyType == typeof(Single?) ||
                property.PropertyType == typeof(sbyte) || property.PropertyType == typeof(sbyte?) ||
                property.PropertyType == typeof(short) || property.PropertyType == typeof(short?) ||
                property.PropertyType == typeof(long) || property.PropertyType == typeof(long?))
            {
                return $"{property.GetValue(entity) ?? "NULL"}";
            }
            if (property.PropertyType == typeof(bool))
            {
                var boolVal = (bool)property.GetValue(entity) ? "1" : "0";
                return $"{boolVal}";
            }
            if (property.PropertyType == typeof(bool?))
            {
                var boolVal = ((bool?)property.GetValue(entity)) == true ? "1" : "0";
                return $"{boolVal}";
            }
            if (property.PropertyType == typeof(DateTime) || property.PropertyType == typeof(DateTime?))
            {
                return $"{((DateTime)property.GetValue(entity)).ToString("yyyy-MM-dd HH:mm:ss.fff")}";
            }
            if (property.PropertyType == typeof(DateTime?))
            {
                return $"{((DateTime?)property.GetValue(entity))?.ToString("yyyy-MM-dd HH:mm:ss.fff")}";
            }

            return null;
        }

        public void BuildInsertValues<T>(StringBuilder sb, T entity)
        {
            var props = typeof(T)
                .GetProperties()
                .Where(x => !Attribute.IsDefined(x, typeof(KeyAttribute)) || Attribute.IsDefined(x, typeof(RequiredAttribute)));

            foreach (var property in props)
            {
                sb.Append($"{ToSQLValue(property, entity)},");
            }
            sb.Remove(sb.Length - 1, 1);
        }

        public void BuildUpdateParametersAndValues<T>(StringBuilder sb, T entity)
        {
            IList<string> whereCondition = new List<string>(); ;
            foreach (var property in typeof(T).GetProperties())
            {
                if (property.GetCustomAttribute<KeyAttribute>() != null)
                {
                    whereCondition.Add($"{property.Name}={ToSQLValue(property, entity)}");
                    continue;
                }
                sb.Append($"{property.Name}={ToSQLValue(property, entity)}, ");
            }
            sb.Remove(sb.Length - 2, 2);
            if (whereCondition.Count() == 0)
            {
                throw new Exception("Chiave non trovata");
            }
            var whereConditionSql = $" WHERE {string.Join(" AND ", whereCondition)}";
            sb.Append(whereConditionSql);
        }
    }
}
