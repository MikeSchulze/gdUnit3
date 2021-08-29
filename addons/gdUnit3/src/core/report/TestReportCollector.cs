using System;
using System.Linq;
using System.Collections.Generic;

namespace GdUnit3
{
    public sealed class TestReportCollector : Godot.Reference
    {

        private List<TestReport> _reports = new List<TestReport>();
        public TestReportCollector()
        { }

        // called by GdScript, will be removed after full gd to cs refactoring
        public void consume(Godot.Resource report)
        {
            TestReport.TYPE type = (TestReport.TYPE)Enum.ToObject(typeof(TestReport.TYPE), (int)report.Call("type"));
            Consume(new TestReport(type, (int)report.Call("line_number"), (string)report.Call("message")));
        }

        public void Consume(TestReport report) => _reports.Add(report);

        public void Clear() => _reports.Clear();


        public IEnumerable<TestReport> Reports
        { get => _reports; }


        public IEnumerable<TestReport> Failures => _reports.Where(r => r.IsFailure);

        public IEnumerable<TestReport> Errors => _reports.Where(r => r.IsError);

        public IEnumerable<TestReport> Warnings => _reports.Where(r => r.IsWarning);
    }
}
