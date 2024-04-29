using System;
using System.Collections.Generic;
using System.Text;

namespace Cloud.Core.Common.ExtensionMethods
{
    public static class IEnumerableExtensions
    {
        public static IEnumerable<IList<T>> ChunksOf<T>(this IEnumerable<T> sequence, int size)
        {
            List<T> chunk = new List<T>(size);

            foreach (T element in sequence)
            {
                chunk.Add(element);
                if (chunk.Count == size)
                {
                    yield return chunk;
                    chunk = new List<T>(size);
                }
            }
        }
    }
}
