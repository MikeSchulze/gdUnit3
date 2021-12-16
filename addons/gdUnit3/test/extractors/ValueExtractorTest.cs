using GdUnit3;
using Godot;

using static GdUnit3.Assertions;
using static GdUnit3.Assertions.EXPECT;

[TestSuite]
public class ValueExtractorTest : TestSuite
{

    class TestObject
    {
        public enum STATE
        {
            INIT,
            RUN
        }
        public TestObject()
        {
            State = STATE.INIT;
            TypeA = "aaa";
            TypeB = "bbb";
            TypeC = "ccc";
        }


        public TestObject.STATE State { get; private set; }

        public string TypeA { get; private set; }

        protected string TypeB { get; private set; }
        private string TypeC { get; set; }
        public string GetA()
        {
            return "getA";
        }

        protected string GetB()
        {
            return "getB";
        }

        private string GetC()
        {
            return "getC";
        }
    }


    [TestCase]
    public void ExtractValue_NotExists()
    {
        var obj = new TestObject();
        AssertString(new ValueExtractor("GetNNN").ExtractValue(obj) as string).IsEqual("n.a.");
    }


    [TestCase]
    public void ExtractValue_publicMethod()
    {
        var obj = new TestObject();
        AssertString(new ValueExtractor("GetA").ExtractValue(obj) as string).IsEqual("getA");
    }


    [TestCase]
    public void ExtractValue_protectedMethod()
    {
        var obj = new TestObject();

        AssertString(new ValueExtractor("GetB").ExtractValue(obj) as string).IsEqual("getB");
    }

    [TestCase]
    public void ExtractValue_privateMethod()
    {
        var obj = new TestObject();

        AssertString(new ValueExtractor("GetC").ExtractValue(obj) as string).IsEqual("getC");
    }

    [TestCase]
    public void ExtractValue_publicProperty()
    {
        var obj = new TestObject();

        AssertString(new ValueExtractor("TypeA").ExtractValue(obj) as string).IsEqual("aaa");
    }

    [TestCase]
    public void ExtractValue_protectedProperty()
    {
        var obj = new TestObject();

        AssertString(new ValueExtractor("TypeB").ExtractValue(obj) as string).IsEqual("bbb");
    }

    [TestCase]
    public void ExtractValue_privateProperty()
    {
        var obj = new TestObject();

        AssertString(new ValueExtractor("TypeC").ExtractValue(obj) as string).IsEqual("ccc");
    }


    [TestCase]
    public void ExtractValue_enum()
    {
        var obj = new TestObject();

        AssertObject(new ValueExtractor("State").ExtractValue(obj)).IsEqual(TestObject.STATE.INIT);
    }

}