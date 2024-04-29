using System;

namespace Common.NoSql.Attributes
{
    [AttributeUsage(AttributeTargets.Property)]
    public class MongoMultipleIndexAttribute : Attribute
    {
        public bool Unique { get; set; }

        public string Name { get; set; }

        public MongoMultipleIndexAttribute(string name, bool unique = false)
        {
            Name = name;
            Unique = unique;
        }
    }
}
