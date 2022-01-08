using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace GdUnit3
{

    public class TestEvent : Godot.Reference
    {

        public enum TYPE
        {
            INIT,
            STOP,
            TESTSUITE_BEFORE,
            TESTSUITE_AFTER,
            TESTCASE_BEFORE,
            TESTCASE_AFTER,
        }
        const string WARNINGS = "warnings";
        const string FAILED = "failed";
        const string ERRORS = "errors";
        const string SKIPPED = "skipped";
        const string ELAPSED_TIME = "elapsed_time";
        const string ORPHAN_NODES = "orphan_nodes";
        const string ERROR_COUNT = "error_count";
        const string FAILED_COUNT = "failed_count";
        const string TOTAL_COUNT = "total_count";
        const string SKIPPED_COUNT = "skipped_count";

        private IDictionary<string, object> _data = new Dictionary<string, object>();

#nullable enable
        private List<TestReport>? _reports;

        private TestEvent(TYPE type, string resourcePath, string suiteName, string testName, int totalCount = 0, IDictionary? statistics = null, IEnumerable<TestReport>? reports = null)
        {
            Type = type;
            _data.Add("type", type);
            _data.Add("resource_path", resourcePath);
            _data.Add("suite_name", suiteName);
            _data.Add("test_name", testName);
            _data.Add(TOTAL_COUNT, totalCount);
            _data.Add("statistics", statistics ?? new Dictionary<string, object>());

            _reports = reports?.ToList();
            if (reports != null)
            {
                var serializedReports = reports.Select(report => report.Serialize()).ToArray();
                _data.Add("reports", new Godot.Collections.Array(serializedReports));
            }
        }

        public static TestEvent Before(string resourcePath, string suiteName, int totalCount)
        {
            return new TestEvent(TYPE.TESTSUITE_BEFORE, resourcePath, suiteName, "Before", totalCount);
        }

        public static TestEvent After(string resourcePath, string suiteName, IDictionary statistics, IEnumerable<TestReport> reports)
        {
            return new TestEvent(TYPE.TESTSUITE_AFTER, resourcePath, suiteName, "After", 0, statistics, reports);
        }

        public static TestEvent BeforeTest(string resourcePath, string suiteName, string testName)
        {
            return new TestEvent(TYPE.TESTCASE_BEFORE, resourcePath, suiteName, testName);
        }
        
        public static TestEvent AfterTest(string resourcePath, string suiteName, string testName, IDictionary? statistics = null, IEnumerable<TestReport>? reports = null)
        {
            return new TestEvent(TYPE.TESTCASE_AFTER, resourcePath, suiteName, testName, 0, statistics, reports);
        }
#nullable disable

        public static IDictionary BuildStatistics(int orphan_count,
            bool isError, int error_count,
            bool isFailure, int failure_count,
            bool is_warning,
            bool is_skipped, int skippedCount,
            long elapsed_since_ms)
        {
            return new Dictionary<string, object>() {
                    { ORPHAN_NODES, orphan_count},
                    { ELAPSED_TIME, elapsed_since_ms},
                    { WARNINGS, is_warning},
                    { ERRORS, isError},
                    { ERROR_COUNT, error_count},
                    { FAILED, isFailure},
                    { FAILED_COUNT, failure_count},
                    { SKIPPED, is_skipped},
                    { SKIPPED_COUNT, skippedCount}};
        }

        // used as bridge  to serialize GdUnitRunner:PublishEvent
        public IDictionary<string, object> AsDictionary() => _data;

        public TestEvent.TYPE Type { get; private set; }
        public string SuiteName => _data["suite_name"] as string;
        public string TestName => _data["test_name"] as string;

        public IDictionary Statistics => _data["statistics"] as IDictionary;

        public IEnumerable<TestReport> Reports => _reports ?? new List<TestReport>();
        public int TotalCount => _data.ContainsKey(TOTAL_COUNT) ? (int)_data[TOTAL_COUNT] : 0;
        public int ErrorCount => Statistics.Contains(ERROR_COUNT) ? (int)Statistics[ERROR_COUNT] : 0;
        public int FailedCount => Statistics.Contains(FAILED_COUNT) ? (int)Statistics[FAILED_COUNT] : 0;
        public int OrphanCount => Statistics.Contains(ORPHAN_NODES) ? (int)Statistics[ORPHAN_NODES] : 0;
        public bool IsWarning => Statistics.Contains(WARNINGS) ? (bool)Statistics[WARNINGS] : false;
        public bool IsFailed => Statistics.Contains(FAILED) ? (bool)Statistics[FAILED] : false;
        public bool IsError => Statistics.Contains(ERRORS) ? (bool)Statistics[ERRORS] : false;
        public bool IsSkipped => Statistics.Contains(SKIPPED) ? (bool)Statistics[SKIPPED] : false;
        public bool IsSuccess => !IsWarning && !IsFailed && !IsError && !IsSkipped;

        public override string ToString()
        {
            return string.Format("Event: {0} {1}:{2}, {3} ", Type, SuiteName, TestName, "");
        }
    }
}
