using Godot;
using GdUnit3;

using static GdUnit3.Assertions;
using static GdUnit3.Assertions.EXPECT;


[TestSuite]
public class ObjectAssertTest : TestSuite
{
    [BeforeTest]
    public void Setup()
    {
        // disable default fail fast behavior because we tests also for failing asserts see EXPECT.FAIL
        EnableInterupptOnFailure(false);
    }

    class CustomClass
    {
        public class InnerClassA : Node { }

        public class InnerClassB : InnerClassA { }

        public class InnerClassC : Node { }
    }

    [TestCase]
    public void IsEqual()
    {
        AssertObject(new CubeMesh()).IsEqual(new CubeMesh());
        // should fail because the current is an CubeMesh and we expect equal to a Skin
        AssertObject(new CubeMesh(), FAIL)
            .IsEqual(new Skin());
    }

    [TestCase]
    public void IsNotEqual()
    {
        AssertObject(new CubeMesh()).IsNotEqual(new Skin());
        // should fail because the current is an CubeMesh and we expect not equal to a CubeMesh
        AssertObject(new CubeMesh(), FAIL)
            .IsNotEqual(new CubeMesh());
    }

    [TestCase]
    public void IsInstanceOf()
    {
        // engine class test
        AssertObject(AutoFree(new Path())).IsInstanceOf<Node>();
        AssertObject(AutoFree(new Camera())).IsInstanceOf<Camera>();
        // script class test
        // inner class test
        AssertObject(AutoFree(new CustomClass.InnerClassA())).IsInstanceOf<Node>();
        AssertObject(AutoFree(new CustomClass.InnerClassB())).IsInstanceOf<CustomClass.InnerClassA>();

        // should fail because the current is not a instance of `Tree`
        AssertObject(AutoFree(new Path()), FAIL)
            .IsInstanceOf<Tree>()
            .HasFailureMessage("Expected instance of:\n 'Godot.Tree'\n But it was 'Godot.Path'");
        AssertObject(null, FAIL)
            .IsInstanceOf<Tree>()
            .HasFailureMessage("Expected instance of:\n 'Godot.Tree'\n But it was 'Null'");
    }

    [TestCase]
    public void IsNotInstanceOf()
    {
        AssertObject(null).IsNotInstanceOf<Node>();
        // engine class test
        AssertObject(AutoFree(new Path())).IsNotInstanceOf<Tree>();
        // inner class test
        AssertObject(AutoFree(new CustomClass.InnerClassA())).IsNotInstanceOf<Tree>();
        AssertObject(AutoFree(new CustomClass.InnerClassB())).IsNotInstanceOf<CustomClass.InnerClassC>();

        // should fail because the current is not a instance of `Tree`
        AssertObject(AutoFree(new Path()), FAIL)
            .IsNotInstanceOf<Node>()
            .HasFailureMessage("Expected not be a instance of <Godot.Node>");
    }

    [TestCase]
    public void IsNull()
    {
        AssertObject(null).IsNull();
        // should fail because the current is not null
        AssertObject(AutoFree(new Node()), FAIL)
            .IsNull()
            .StartsWithFailureMessage("Expecting: 'Null' but was <Node>");
    }

    [TestCase]
    public void IsNotNull()
    {
        AssertObject(AutoFree(new Node())).IsNotNull();
        // should fail because the current is null
        AssertObject(null, FAIL)
            .IsNotNull()
            .HasFailureMessage("Expecting: not to be 'Null'");
    }

    [TestCase]
    public void IsSame()
    {
        var obj1 = AutoFree(new Node());
        var obj2 = obj1;
        var obj3 = AutoFree(obj1.Duplicate());
        AssertObject(obj1).IsSame(obj1);
        AssertObject(obj1).IsSame(obj2);
        AssertObject(obj2).IsSame(obj1);
        AssertObject(null, FAIL).IsSame(obj1);
        AssertObject(obj1, FAIL).IsSame(obj3);
        AssertObject(obj3, FAIL).IsSame(obj1);
        AssertObject(obj3, FAIL).IsSame(obj2);
    }

    [TestCase]
    public void IsNotSame()
    {
        var obj1 = AutoFree(new Node());
        var obj2 = obj1;
        var obj3 = AutoFree(obj1.Duplicate());
        AssertObject(null).IsNotSame(obj1);
        AssertObject(obj1).IsNotSame(obj3);
        AssertObject(obj3).IsNotSame(obj1);
        AssertObject(obj3).IsNotSame(obj2);

        AssertObject(obj1, FAIL).IsNotSame(obj1);
        AssertObject(obj1, FAIL).IsNotSame(obj2);
        AssertObject(obj2, FAIL).IsNotSame(obj1);
    }

    [TestCase]
    public void MustFail_hasInvlalidType()
    {
        AssertObject(1, FAIL).HasFailureMessage("GdUnitObjectAssert inital error, unexpected type <int>");
        AssertObject(1.3, FAIL).HasFailureMessage("GdUnitObjectAssert inital error, unexpected type <float>");
        AssertObject(true, FAIL).HasFailureMessage("GdUnitObjectAssert inital error, unexpected type <bool>");
        AssertObject("foo", FAIL).HasFailureMessage("GdUnitObjectAssert inital error, unexpected type <String>");
    }

    [TestCase]
    public void OverrideFailureMessage()
    {
        AssertObject(AutoFree(new Node()), FAIL)
            .OverrideFailureMessage("Custom failure message")
            .IsNull()
            .HasFailureMessage("Custom failure message");
    }

    [TestCase]
    public void Interuppt_IsFailure()
    {
        // we want to interrupt on first failure
        EnableInterupptOnFailure(true);
        // try to fail
        AssertObject(null, FAIL).IsNotNull();

        // expect this line will never called because of the test is interuppted by a failing assert
        AssertBool(true).OverrideFailureMessage("This line shold never be called").IsFalse();
    }
}
