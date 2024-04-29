using System;
using System.IO;
using System.Text;
using System.Xml.Serialization;
using FTM.Cloud.Common.AbsClasses;

namespace FTM.Cloud.Common.Helpers
{
	public class GenericXmlSerializer<T> : AbsSerializer<T, XmlSerializer> where T: class
	{
		public GenericXmlSerializer(T obj = null, string serialized = null) : base(obj, serialized, new XmlSerializer(typeof(T)))
		{ }

		public GenericXmlSerializer(string xmlNamespace, T obj = null, string serialized = null) : base(obj, serialized, new XmlSerializer(typeof(T), xmlNamespace))
		{ }

		public override T Deserialize()
		{
			if (Serialized is null)
				return null;

			using (var reader = new StringReader(Serialized))
			{
				try
				{
					Obj = (T)Serializer.Deserialize(reader);
				}
				catch (Exception ex)
				{
					throw ex;
				}
			}

			return Obj;
		}

		public override string Serialize()
		{
			if (Obj is null)
				return null;

			using (var ms = new MemoryStream())
			{
				try
				{
					Serializer.Serialize(ms, Obj);
					Serialized = Encoding.UTF8.GetString(ms.ToArray());
				}
				catch (Exception ex)
				{
					throw ex;
				}
			}

			return Serialized;
		}
	}
}
