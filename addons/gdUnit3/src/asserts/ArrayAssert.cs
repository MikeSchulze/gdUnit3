using System.Collections;
using System.Collections.Generic;
using System.Linq;

using static GdUnit3.Assertions;

namespace GdUnit3.Asserts
{
    internal sealed class ArrayAssert : AssertBase<IEnumerable>, IArrayAssert
    {
        public ArrayAssert(IEnumerable? current) : base(current)
        {
            Current = current?.Cast<object>();
        }

        private new IEnumerable<object>? Current { get; set; }

        public IArrayAssert IsEqualIgnoringCase(IEnumerable expected)
        {
            var result = Comparable.IsEqual(Current, expected, Comparable.MODE.CASE_INSENSITIVE);
            if (!result.Valid)
                ThrowTestFailureReport(AssertFailures.IsEqualIgnoringCase(Current, expected), Current, expected);
            return this;
        }

        public IArrayAssert IsNotEqualIgnoringCase(IEnumerable expected)
        {
            var result = Comparable.IsEqual(Current, expected, Comparable.MODE.CASE_INSENSITIVE);
            if (result.Valid)
                ThrowTestFailureReport(AssertFailures.IsNotEqualIgnoringCase(Current, expected), Current, expected);
            return this;
        }

        public IArrayAssert IsEmpty()
        {
            var count = Current?.Count() ?? -1;
            if (count != 0)
                ThrowTestFailureReport(AssertFailures.IsEmpty(count, Current == null), Current, count);
            return this;
        }

        public IArrayAssert IsNotEmpty()
        {
            var count = Current?.Count() ?? -1;
            if (count == 0)
                ThrowTestFailureReport(AssertFailures.IsNotEmpty(), Current, null);
            return this;
        }

        public IArrayAssert HasSize(int expected)
        {
            var count = Current?.Count();
            if (count != expected)
                ThrowTestFailureReport(AssertFailures.HasSize(count == null ? "unknown" : count, expected), Current, null);
            return this;
        }

        public IArrayAssert Contains(params object?[] expected)
        {
            // we test for contains nothing
            if (expected.Length == 0)
                return this;
            var e = expected.Cast<object>();
            var notFound = ArrayContainsAll(Current, e);
            if (notFound.Count > 0)
                ThrowTestFailureReport(AssertFailures.Contains(Current, e, notFound), Current, expected);
            return this;
        }

        public IArrayAssert Contains(IEnumerable expected)
        {
            var Expected = expected.Cast<object>().ToArray();
            // we test for contains nothing
            if (Expected.Length == 0)
                return this;

            var notFound = ArrayContainsAll(Current, Expected);
            if (notFound.Count > 0)
                ThrowTestFailureReport(AssertFailures.Contains(Current, Expected, notFound), Current, expected);
            return this;
        }

        public IArrayAssert ContainsExactly(params object?[] expected)
        {
            // we test for contains nothing
            if (expected.Length == 0)
                return this;
            var e = expected.Cast<object>();
            // is equal than it contains same elements in same order
            if (Comparable.IsEqual(Current, e).Valid)
                return this;

            var diff = DiffArray(Current, e);
            var notExpected = diff.NotExpected;
            var notFound = diff.NotFound;
            if (notFound.Count > 0 || notExpected.Count > 0 || (notFound.Count == 0 && notExpected.Count == 0))
                ThrowTestFailureReport(AssertFailures.ContainsExactly(Current, e, notFound, notExpected), Current, expected);
            return this;
        }

        public IArrayAssert ContainsExactly(IEnumerable expected)
        {
            var Expected = expected is string ? new object[] { expected } : expected.Cast<object>().ToArray();
            // we test for contains nothing
            if (Expected.Length == 0)
                return this;
            // is equal than it contains same elements in same order
            if (Comparable.IsEqual(Current, Expected).Valid)
                return this;

            var diff = DiffArray(Current, Expected);
            var notExpected = diff.NotExpected;
            var notFound = diff.NotFound;
            if (notFound.Count > 0 || notExpected.Count > 0 || (notFound.Count == 0 && notExpected.Count == 0))
                ThrowTestFailureReport(AssertFailures.ContainsExactly(Current, Expected, notFound, notExpected), Current, expected);
            return this;
        }

        public IArrayAssert ContainsExactlyInAnyOrder(params object?[] expected)
        {
            // we test for contains nothing
            if (expected.Length == 0)
                return this;
            var e = expected.Cast<object>();
            var diff = DiffArray(Current, e);
            var notExpected = diff.NotExpected;
            var notFound = diff.NotFound;

            // no difference and additions found
            if (notExpected.Count != 0 || notFound.Count != 0)
                ThrowTestFailureReport(AssertFailures.ContainsExactlyInAnyOrder(Current, e, notFound, notExpected), Current, expected);
            return this;
        }

        public IArrayAssert ContainsExactlyInAnyOrder(IEnumerable expected)
        {
            var Expected = expected.Cast<object>().ToArray();
            // we test for contains nothing
            if (Expected.Length == 0)
                return this;

            var diff = DiffArray(Current, Expected);
            var notExpected = diff.NotExpected;
            var notFound = diff.NotFound;
            // no difference and additions found
            if (notExpected.Count != 0 || notFound.Count != 0)
                ThrowTestFailureReport(AssertFailures.ContainsExactlyInAnyOrder(Current, Expected, notFound, notExpected), Current, expected);
            return this;
        }

        public IArrayAssert Extract(string funcName, params object[] args)
        {
            return ExtractV(new ValueExtractor(funcName, args));
        }

        public IArrayAssert ExtractV(params IValueExtractor[] extractors)
        {
            Current = Current?.Select(v =>
            {
                object[] values = extractors.Select(e => e.ExtractValue(v)).ToArray<object>();
                return values.Count() == 1 ? values.First() : Tuple(values);
            }).ToList();
            return this;
        }

        public new IArrayAssert OverrideFailureMessage(string message)
        {
            base.OverrideFailureMessage(message);
            return this;
        }

        private List<object> ArrayContainsAll(IEnumerable<object>? left, IEnumerable<object> right)
        {
            var notFound = right?.ToList() ?? new List<object>();

            if (left != null)
                foreach (var c in left.ToList())
                {
                    foreach (var e in right.ToList())
                    {
                        if (Comparable.IsEqual(c, e).Valid)
                        {
                            notFound.Remove(e);
                            break;
                        }
                    }
                }
            return notFound;
        }

        private class ArrayDiff
        {
            public List<object> NotExpected { get; set; } = new List<object>();
            public List<object> NotFound { get; set; } = new List<object>();
        }

        private ArrayDiff DiffArray(IEnumerable<object>? left, IEnumerable<object>? right)
        {
            var ll = left?.ToList() ?? new List<object>();
            var rr = right?.ToList() ?? new List<object>();

            var notExpected = left?.ToList() ?? new List<object>();
            var notFound = right?.ToList() ?? new List<object>();

            foreach (var c in ll)
            {
                foreach (var e in rr)
                {
                    if (Comparable.IsEqual(c, e).Valid)
                    {
                        notExpected.Remove(c);
                        notFound.Remove(e);
                        break;
                    }
                }
            }
            return new ArrayDiff() { NotExpected = notExpected, NotFound = notFound };
        }
    }
}
