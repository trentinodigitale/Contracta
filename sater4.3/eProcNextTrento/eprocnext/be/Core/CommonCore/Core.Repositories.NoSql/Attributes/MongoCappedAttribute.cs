using System;

namespace Core.Repositories.NoSql.Attributes
{
    [AttributeUsage(AttributeTargets.Class)]
    public class MongoCappedAttribute:Attribute
    {
        public long Size { get; set; }

        public MongoCappedAttribute(int size = 0)
        {
            Size = size;
        }
    }
}
