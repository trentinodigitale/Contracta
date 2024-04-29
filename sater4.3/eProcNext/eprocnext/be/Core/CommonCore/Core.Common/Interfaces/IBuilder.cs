namespace FTM.Cloud.Common.Interfaces
{
    public interface IBuilder<T>
    {
        void Build();
        T GetResult();
    }
}
