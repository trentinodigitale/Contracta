using System;

namespace Common.NoSql.Attributes
{
    [AttributeUsage(AttributeTargets.Property)]
    public class MongoIndexAttribute : Attribute
    {
        public string Name { get; set; }

        public bool Unique { get; set; }

        public bool Sparse { get; set; }

        public MongoIndexAttribute(string name = null, bool unique = false, bool sparse = true)
        {
            Name = name;
            Unique = unique;
            Sparse = sparse;
        }
    }
}
