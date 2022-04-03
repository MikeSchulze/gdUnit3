using System.Linq;
using System.Collections.Generic;

namespace GdUnit3
{
    public sealed class TestReportCollector : Godot.Reference
    {
        private List<TestReport> _reports = new List<TestReport>();
        public TestReportCollector()
        { }

        public void Consume(TestReport report) => _reports.Add(report);

        public void PushFront(TestReport report) => _reports.Insert(0, report);

        public void Clear() => _reports.Clear();


        public IEnumerable<TestReport> Reports
        { get => _reports; }

        public IEnumerable<TestReport> Failures => _reports.Where(r => r.IsFailure);

        public IEnumerable<TestReport> Errors => _reports.Where(r => r.IsError);

        public IEnumerable<TestReport> Warnings => _reports.Where(r => r.IsWarning);
    }
}
