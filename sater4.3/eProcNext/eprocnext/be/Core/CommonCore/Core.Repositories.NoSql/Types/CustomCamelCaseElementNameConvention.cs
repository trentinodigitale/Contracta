using Core.Repositories.NoSql.ExtensionMethods;
using MongoDB.Bson.Serialization;
using MongoDB.Bson.Serialization.Conventions;

namespace Core.Repositories.NoSql.Types
{
    public class CustomCamelCaseElementNameConvention : IMemberMapConvention, IConvention
    {
        public string Name => "CustomCamelCase";

        public void Apply(BsonMemberMap memberMap)
        {
            memberMap.SetElementName(memberMap.MemberName.ToCamelCase());
        }
    }
}
