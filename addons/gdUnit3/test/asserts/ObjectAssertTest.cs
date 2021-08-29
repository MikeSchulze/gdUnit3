using Godot;
using GdUnit3;
using static GdUnit3.IAssert.EXPECT;

[TestSuite]
public class ObjectAssertTest : TestSuite
{

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
    public void IsInstanceof()
    {
        // engine class test
        AssertObject(auto_free(new Path())).IsInstanceof<Node>();
        AssertObject(auto_free(new Camera())).IsInstanceof<Camera>();
        // script class test
        // inner class test
        AssertObject(auto_free(new CustomClass.InnerClassA())).IsInstanceof<Node>();
        AssertObject(auto_free(new CustomClass.InnerClassB())).IsInstanceof<CustomClass.InnerClassA>();

        // should fail because the current is not a instance of `Tree`
        AssertObject(auto_free(new Path()), FAIL)
            .IsInstanceof<Tree>()
            .HasFailureMessage("Expected instance of:\n 'Godot.Tree'\n But it was 'Godot.Path'");
        AssertObject(null, FAIL)
            .IsInstanceof<Tree>()
            .HasFailureMessage("Expected instance of:\n 'Godot.Tree'\n But it was 'Null'");
    }

    [TestCase]
    public void IsNotInstanceof()
    {
        AssertObject(null).IsNotInstanceof<Node>();
        // engine class test
        AssertObject(auto_free(new Path())).IsNotInstanceof<Tree>();
        // inner class test
        AssertObject(auto_free(new CustomClass.InnerClassA())).IsNotInstanceof<Tree>();
        AssertObject(auto_free(new CustomClass.InnerClassB())).IsNotInstanceof<CustomClass.InnerClassC>();

        // should fail because the current is not a instance of `Tree`
        AssertObject(auto_free(new Path()), FAIL)
            .IsNotInstanceof<Node>()
            .HasFailureMessage("Expected not be a instance of <Godot.Node>");
    }

    [TestCase]
    public void IsNull()
    {
        AssertObject(null).IsNull();
        // should fail because the current is not null
        AssertObject(auto_free(new Node()), FAIL)
            .IsNull()
            .StartsWithFailureMessage("Expecting: 'Null' but was <Node>");
    }

    [TestCase]
    public void IsNotNull()
    {
        AssertObject(auto_free(new Node())).IsNotNull();
        // should fail because the current is null
        AssertObject(null, FAIL)
            .IsNotNull()
            .HasFailureMessage("Expecting: not to be 'Null'");
    }

    [TestCase]
    public void IsSame()
    {
        var obj1 = auto_free(new Node());
        var obj2 = obj1;
        var obj3 = auto_free(obj1.Duplicate());
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
        var obj1 = auto_free(new Node());
        var obj2 = obj1;
        var obj3 = auto_free(obj1.Duplicate());
        AssertObject(null).IsNotSame(obj1);
        AssertObject(obj1).IsNotSame(obj3);
        AssertObject(obj3).IsNotSame(obj1);
        AssertObject(obj3).IsNotSame(obj2);

        AssertObject(obj1, FAIL).IsNotSame(obj1);
        AssertObject(obj1, FAIL).IsNotSame(obj2);
        AssertObject(obj2, FAIL).IsNotSame(obj1);
    }

    [TestCase]
    public void must_fail_has_invlalid_type()
    {
        AssertObject(1, FAIL).HasFailureMessage("GdUnitObjectAssert inital error, unexpected type <int>");
        AssertObject(1.3, FAIL).HasFailureMessage("GdUnitObjectAssert inital error, unexpected type <float>");
        AssertObject(true, FAIL).HasFailureMessage("GdUnitObjectAssert inital error, unexpected type <bool>");
        AssertObject("foo", FAIL).HasFailureMessage("GdUnitObjectAssert inital error, unexpected type <String>");
    }

    [TestCase]
    public void OverrideFailureMessage()
    {
        AssertObject(auto_free(new Node()), FAIL)
            .OverrideFailureMessage("Custom failure message")
            .IsNull()
            .HasFailureMessage("Custom failure message");
    }

}
