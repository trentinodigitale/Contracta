using Cloud.Core.Common.Interfaces;
using System;
using System.Collections.Generic;
using System.Text;

namespace Cloud.Core.Common.Types
{
    public class CompareResult : ICompareResult
    {
        public bool AreEquals { get; set; }
        public string Differences { get; set; }
    }
}
