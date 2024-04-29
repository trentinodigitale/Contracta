using Dapper;
using System;
using System.Linq;

namespace Core.Repositories.Common
{

    public static class AttributeExtensions
    {
        private static TValue GetAttributeValue<TAttribute, TValue>(
            this Type type,
            Func<TAttribute, TValue> valueSelector)
            where TAttribute : Attribute
        {
            var att = type.GetCustomAttributes(
                typeof(TAttribute), true
            ).FirstOrDefault();
            return att switch
            {
                TAttribute attrCst => valueSelector(attrCst),
                _ => default(TValue),
            };
        }

        public static string DbTableName(this Type type) =>
            type.GetAttributeValue((TableAttribute tma) => tma.Name);
    }
}
