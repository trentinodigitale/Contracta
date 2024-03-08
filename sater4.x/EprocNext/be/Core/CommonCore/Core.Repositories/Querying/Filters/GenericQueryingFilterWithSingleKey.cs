using Core.Repositories.Abstractions.AbstractClasses;
using Core.Repositories.Interfaces;
using Dapper;
using System.Linq;

namespace Core.Repositories.Querying.Filters
{
    public class GenericQueryingFilterWithSingleKey<TDto> : AbsQueryingFilter where TDto : class, IDtoResolver, ISecurityDTO, new()
    {
        public object Key { get; set; }

        public override string CacheKey => $"{nameof(TDto)}_{Key}";
        
        public override string Query
        {
            get
            {
                var keyProp = typeof(TDto)
                    .GetProperties()
                    .Where(p =>
                        p.GetCustomAttributes(true)
                        .Any(attr => attr.GetType() == typeof(KeyAttribute))
                    )
                    .FirstOrDefault()
                    .Name;

                return $"{keyProp}=@{nameof(Key)}";
            }
        }
        
        public override object Params => new { Key };
    }
}
