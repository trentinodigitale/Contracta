using Cloud.Core.Common.Interfaces;
using Cloud.Core.Common.Types;
using KellermanSoftware.CompareNetObjects;
using System.Collections.Generic;
using System.Linq;

namespace Cloud.Core.Common.AbstractClasses
{
    public abstract class AbsObjectComparer : IObjectComparer
    {
        protected CompareLogic Comparer { get; } = new CompareLogic();

        protected AbsObjectComparer()
        { }

        protected virtual ICompareResult ExecuteCompare(object expected, object actual, object rules = null)
        {
            if (rules != null)
                Comparer.Config.CustomComparers.Add((dynamic)rules);

            var res = Comparer.Compare(expected, actual);
            return new CompareResult
            {
                AreEquals = res.AreEqual,
                Differences = res.DifferencesString
            };
        }

        public virtual ICompareResult Compare<T>(T expected, T actual)
        {
            return ExecuteCompare(expected, actual);
        }

        public virtual ICompareResult Compare<T1, T2>(T1 expected, T2 actual)
        {
            return ExecuteCompare(expected, actual);
        }

        public virtual bool Compare<T>(IEnumerable<T> expected, IEnumerable<T> actual)
        {
            return !expected.Except(actual).Any();
        }
    }
}
