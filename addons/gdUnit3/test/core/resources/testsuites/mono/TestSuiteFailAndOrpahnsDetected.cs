using System.Collections.Generic;

namespace GdUnit3.Tests.Resources
{
    using static Assertions;

    // will be ignored because of missing `[TestSuite]` anotation
    // used by executor integration test
    //[TestSuite]
    public class TestSuiteFailAndOrpahnsDetected : TestSuite
    {

        List<Godot.Node> _orphans = new List<Godot.Node>();

        [Before]
        public void SetupSuite()
        {
            AssertString("Suite Before()").IsEqual("Suite Before()");
            _orphans.Add(new Godot.Node());
        }

        [After]
        public void TearDownSuite()
        {
            AssertString("Suite After()").IsEqual("Suite After()");
        }

        [BeforeTest]
        public void SetupTest()
        {
            AssertString("Suite BeforeTest()").IsEqual("Suite BeforeTest()");
            _orphans.Add(new Godot.Node());
            _orphans.Add(new Godot.Node());
        }

        [AfterTest]
        public void TearDownTest()
        {
            AssertString("Suite AfterTest()").IsEqual("Suite AfterTest()");
        }

        [TestCase]
        public void TestCase1()
        {
            _orphans.Add(new Godot.Node());
            _orphans.Add(new Godot.Node());
            _orphans.Add(new Godot.Node());
            AssertString("TestCase1").IsEqual("TestCase1");
        }

        [TestCase]
        public void TestCase2()
        {
            _orphans.Add(new Godot.Node());
            _orphans.Add(new Godot.Node());
            _orphans.Add(new Godot.Node());
            _orphans.Add(new Godot.Node());
            AssertString("TestCase2").IsEmpty();
        }

        // finally, we manually release the orphans from the simulated test suite to avoid memory leaks
        public override void _Notification(int what)
        {
            if (what == Godot.Object.NotificationPredelete)
            {
                _orphans.ForEach(n => n.Free());
                _orphans.Clear();
            }
        }

    }
}
