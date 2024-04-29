using Cloud.Core.Common.AbstractClasses;
using Cloud.Core.Common.Interfaces;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Cloud.Core.Common.Helpers
{
    public class Comparer : AbsObjectComparer
    { }

    public class ObjectComparer : AbsObjectComparer
    {
        protected IServiceProvider ServiceProvider { get; }

        public ObjectComparer(IServiceProvider svp)
        {
            ServiceProvider = svp;
        }

        public override ICompareResult Compare<T>(T expected, T actual)
        {
            IComparerRules<T> rules = null;
            try
            {
                if (ServiceProvider != null)
                    rules = ServiceProvider.GetRequiredService<IComparerRules<T>>();
            }
            catch { }
            
            return ExecuteCompare(expected, actual, rules?.GetComparer());
        }

        public override ICompareResult Compare<T1, T2>(T1 expected, T2 actual)
        {
            IComparerRules<T1, T2> rules = null;
            try
            {
                if (ServiceProvider != null)
                    rules = ServiceProvider.GetRequiredService<IComparerRules<T1, T2>>();
            }
            catch { }

            return ExecuteCompare(expected, actual, rules?.GetComparer());
        }

        public override bool Compare<T>(IEnumerable<T> expected, IEnumerable<T> actual)
        {
            IEqualityComparer<T> rules = null;
            try
            {
                if (ServiceProvider != null)
                    rules = ServiceProvider.GetRequiredService<IEqualityComparer<T>>();
            }
            catch { }

            var diff = rules is null ? expected.Except(actual) : expected.Except(actual, rules);
            return !diff.Any();
        }
    }
}
