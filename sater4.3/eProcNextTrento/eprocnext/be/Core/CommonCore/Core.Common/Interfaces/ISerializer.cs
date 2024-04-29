namespace FTM.Cloud.Common.Interfaces
{
	interface ISerializer<T>
	{
		string Serialize();
		T Deserialize();
	}
}
