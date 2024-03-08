using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;

namespace Cloud.Core.Common.ExtensionMethods
{
    public static class EnumExtensions
    {
        public static TEnum GetValueFromAttribute<TEnum, TAttribute, TCheck>(TCheck value, Func<TAttribute, TCheck> selector) where TEnum : Enum where TAttribute : Attribute
        {
            foreach (var field in typeof(TEnum).GetFields())
            {
                if (Attribute.GetCustomAttribute(field, typeof(TAttribute)) is TAttribute attr)
                {
                    TCheck check = selector(attr);
                    if (check.Equals(value))
                        return (TEnum)field.GetValue(null);
                }
            }

            throw new ArgumentException("Not found", nameof(value));
        }

        public static TEnum GetValueFromName<TEnum>(string name) where TEnum: Enum
        {
            foreach (var field in typeof(TEnum).GetFields())
            {
                if (field.Name == name)
                    return (TEnum)field.GetValue(null);
            }

            throw new ArgumentException("Not found", nameof(name));
        }
    }
}
