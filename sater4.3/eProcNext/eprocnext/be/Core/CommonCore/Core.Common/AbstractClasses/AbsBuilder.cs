using FTM.Cloud.Common.Interfaces;

namespace FTM.Cloud.Common.AbstractClasses
{
    public abstract class AbsBuilder<T> : IBuilder<T>
    {
        public abstract void Build();
        public abstract T GetResult();
    }
}
