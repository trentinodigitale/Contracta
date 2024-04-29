using System.Collections;
using System.Collections.Generic;

namespace Cloud.Core.Common.Interfaces
{
    public interface ICompareResult
    {
        bool AreEquals { get; set; }
        string Differences { get; set; }
    }

    public interface IComparerRules<T>
    {
        object GetComparer();
    }

    public interface IComparerRules<T1, T2>
    {
        object GetComparer();
    }

    public interface IObjectComparer
    {
        ICompareResult Compare<T>(T exptected, T actual);

        ICompareResult Compare<T1, T2>(T1 exptected, T2 actual);

        bool Compare<T>(IEnumerable<T> expected, IEnumerable<T> actual);
    }
}
