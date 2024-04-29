using FTM.Cloud.Common.Interfaces;
using System;

namespace FTM.Cloud.Common.AbsClasses
{
	public abstract class AbsSerializer<T, TSer> : ISerializer<T>
	{
		public T Obj { get; set; }
		public string Serialized { get; set; }
		protected TSer Serializer { get; }

		protected AbsSerializer(T obj, string serialized, TSer serializer)
		{
			Obj = obj;
			Serialized = serialized;
			Serializer = serializer;
		}

		public virtual T Deserialize()
		{
			throw new NotImplementedException();
		}

		public virtual string Serialize()
		{
			throw new NotImplementedException();
		}
	}
}
