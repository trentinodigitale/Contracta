using Core.Repositories.Interfaces;
using Dapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace Core.Repositories.ExtensionMethods
{
    public static class IEnumerableDTOExtensions
    {
        public static DataTable ToDataTable<T>(this IEnumerable<T> self)
        {
            if (!Attribute.IsDefined(typeof(T), typeof(TableAttribute)))
                return null;

            var properties = typeof(T).GetProperties();

            var dataTable = new DataTable();
            foreach (var info in properties)
                dataTable.Columns.Add(info.Name, Nullable.GetUnderlyingType(info.PropertyType) ?? info.PropertyType);

            foreach (var entity in self)
                dataTable.Rows.Add(properties.Select(p => p.GetValue(entity)).ToArray());

            return dataTable;
        }
    }
}
