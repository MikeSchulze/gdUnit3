using Godot;
using System.Threading.Tasks;

namespace GdUnit3.Tests.Asserts
{
    using Executions;
    using static Assertions;
    using static Utils;

    [TestSuite]
    public class ExampleTestSuite
    {
        [Before]
        public void Before()
        {
            GD.PrintS("calling Before");
        }

        [After]
        public void After()
        {
            GD.PrintS("calling After");
        }

        [BeforeTest]
        public void BeforeTest()
        {
            GD.PrintS("calling BeforeTest");
        }

        [AfterTest]
        public void AfterTest()
        {
            GD.PrintS("calling AfterTest");
        }

        [TestCase]
        public void TestFoo()
        {
            AssertBool(true).IsEqual(true);
        }

        [TestCase]
        public void TestBar()
        {
            AssertBool(true).IsEqual(true);
        }

        [TestCase]
        public async Task waiting()
        {
            await DoWait(5000);
        }


        [TestCase]
        public void TestFooBar()
        {
            AssertBool(true).IsEqual(true);
        }
    }
}