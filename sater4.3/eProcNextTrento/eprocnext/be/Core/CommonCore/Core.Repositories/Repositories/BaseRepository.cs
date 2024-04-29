using Core.Repositories.Interfaces;
using Dapper;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection;

namespace Core.Repositories.Repositories
{
    public class BaseRepository : IBaseRepository
    {
        public BaseRepository(IConfiguration config)
        {
            Connection = new SqlConnection(config.GetConnectionString("Repository"));
        }

        public IDbConnection Connection { get; }

        public IDbTransaction BeginTransaction() => Connection.BeginTransaction(IsolationLevel.ReadCommitted);

        internal static IEnumerable<PropertyInfo> GetIdProperties(Type type)
        {
            List<PropertyInfo> list = ((IEnumerable<PropertyInfo>)TypeExtensions.GetProperties(type)).Where(p => CustomAttributeExtensions.GetCustomAttributes(p, true).Any(attr => attr.GetType().Name == typeof(KeyAttribute).Name)).ToList();
            return !list.Any() ? ((IEnumerable<PropertyInfo>)TypeExtensions.GetProperties(type)).Where(p => p.Name.Equals("Id", StringComparison.OrdinalIgnoreCase)) : list;
        }

        internal static List<object> KeyIdValues<T>(T dto)
        {
            var keys = GetIdProperties(typeof(T));
            List<object> ids = new List<object>();
            if (dto != null)
            {
                foreach (var propertyInfo in keys)
                {
                    ids.Add(propertyInfo.GetValue(dto));
                }
            }
            return ids;
        }

        internal static IEnumerable<string> KeyIdColumName<T>()
        {
            return GetIdProperties(typeof(T))?.Select(p=> p.Name);
        }
    }
}
