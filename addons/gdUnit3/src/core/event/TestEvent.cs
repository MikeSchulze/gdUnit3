using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace GdUnit3
{

    public class TestEvent : Godot.Reference
    {

        enum TYPE
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
        const string SKIPPED_COUNT = "skipped_count";

        private IDictionary _data = new Dictionary<string, object>();
#nullable enable
        private TestEvent(TYPE type, string resourcePath, string suiteName, string testName, int totalCount = 0, IEnumerable? statistics = null, IEnumerable<TestReport>? reports = null)
        {
            _data.Add("type", type);
            _data.Add("resource_path", resourcePath);
            _data.Add("suite_name", suiteName);
            _data.Add("test_name", testName);
            _data.Add("total_count", totalCount);
            //var _statistics = statistics ?? Enumerable.Empty<object>();
            if (statistics != null)
            {
                _data.Add("statistics", statistics);
            }
            if (reports != null)
            {
                var serializedReports = reports.Select(report => report.Serialize()).ToArray();
                _data.Add("reports", new Godot.Collections.Array(serializedReports));
            }
        }

        public static TestEvent Before(string resourcePath, string suiteName, int totalCount)
        {
            return new TestEvent(TYPE.TESTSUITE_BEFORE, resourcePath, suiteName, "", totalCount);
        }

        public static TestEvent After(string resourcePath, string suiteName, IEnumerable statistics)
        {
            return new TestEvent(TYPE.TESTSUITE_AFTER, resourcePath, suiteName, "", 0, statistics);
        }

        public static TestEvent BeforeTest(string resourcePath, string suiteName, string testName)
        {
            return new TestEvent(TYPE.TESTCASE_BEFORE, resourcePath, suiteName, testName);
        }
        public static TestEvent AfterTest(string resourcePath, string suiteName, string testName, IEnumerable? statistics = null, IEnumerable<TestReport>? reports = null)
        {
            return new TestEvent(TYPE.TESTCASE_AFTER, resourcePath, suiteName, testName, 0, statistics, reports);
        }
#nullable disable

        public static IDictionary BuildStatistics(int orphan_count,
            bool isError, int error_count,
            bool isFailure, int failure_count,
            bool is_warning,
            bool is_skipped, int skippedCount,
            int elapsed_since_ms)
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

        public System.Collections.IDictionary AsDictionary()
        {
            return _data;
        }
    }
}
