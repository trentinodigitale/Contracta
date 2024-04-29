using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;

namespace Cloud.Core.Common.ExtensionMethods
{
    public static class ReflectionExtensions
    {
        public static PropertyInfo GetPropertyInfo(this object obj, string propertyName)
        {
            if (obj == null)
                throw new ArgumentNullException("obj");

            if (string.IsNullOrEmpty(propertyName))
                throw new ArgumentNullException("propertyName");

            Type type = obj.GetType();
            PropertyInfo[] properties = type.GetProperties(BindingFlags.Public | BindingFlags.Instance);
            PropertyInfo property = properties.SingleOrDefault(s => string.Equals(propertyName, s.Name));

            if (property != null)
                return property;

            throw new Exception(string.Format("Missing property named {0} of type {1}", propertyName, type.Name));
        }

        public static object GetPropertyValue(this object obj, string propertyName)
        {
            if (obj == null)
                throw new ArgumentNullException("obj");

            if (String.IsNullOrEmpty(propertyName))
                throw new ArgumentNullException("propertyName");

            PropertyInfo property = GetPropertyInfo(obj, propertyName);
            return property.GetValue(obj);
        }
    }
}
