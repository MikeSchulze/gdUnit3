using GdUnit3;

using System.Collections.Generic;

using static GdUnit3.Assertions;
using static GdUnit3.Assertions.EXPECT;


[TestSuite]
public class ObjectAssertTest : TestSuite
{
    [BeforeTest]
    public void Setup()
    {
        // disable default fail fast behavior because we tests also for failing asserts see EXPECT.FAIL
        EnableInterruptOnFailure(false);
    }

    class CustomClass
    {
        public class InnerClassA : Godot.Node { }

        public class InnerClassB : InnerClassA { }

        public class InnerClassC : Godot.Node { }
    }
    class CustomClassB : CustomClass
    {
    }

    [TestCase]
    public void IsEqual()
    {
        AssertObject(new Godot.CubeMesh()).IsEqual(new Godot.CubeMesh());
        AssertObject(new object()).IsEqual(new object());

        // should fail because the current is an CubeMesh and we expect equal to a Skin
        AssertObject(new Godot.CubeMesh(), FAIL)
            .IsEqual(new Godot.Skin())
            .HasFailureMessage("Expecting:\n"
                + " <Godot.Skin>\n"
                + " but was\n"
                + " <Godot.CubeMesh>");
        AssertObject(new object(), FAIL)
            .IsEqual(new List<int>())
            .HasFailureMessage("Expecting:\n"
                + " empty System.Collections.Generic.List<System.Int32>\n"
                + " but was\n"
                + " <System.Object>");
    }

    [TestCase]
    public void IsNotEqual()
    {
        AssertObject(new Godot.CubeMesh()).IsNotEqual(new Godot.Skin());
        AssertObject(new object()).IsNotEqual(new List<object>());
        // should fail because the current is an CubeMesh and we expect not equal to a CubeMesh
        AssertObject(new Godot.CubeMesh(), FAIL)
            .IsNotEqual(new Godot.CubeMesh())
            .HasFailureMessage("Expecting:\n"
                + " <Godot.CubeMesh>\n"
                + " not equal to\n"
                + " <Godot.CubeMesh>");
        AssertObject(new object(), FAIL)
            .IsNotEqual(new object())
            .HasFailureMessage("Expecting:\n"
                + " <System.Object>\n"
                + " not equal to\n"
                + " <System.Object>");
    }

    [TestCase]
    public void IsInstanceOf()
    {
        // engine class test
        AssertObject(AutoFree(new Godot.Path())).IsInstanceOf<Godot.Node>();
        AssertObject(AutoFree(new Godot.Camera())).IsInstanceOf<Godot.Camera>();
        // script class test
        // inner class test
        AssertObject(AutoFree(new CustomClass.InnerClassA())).IsInstanceOf<Godot.Node>();
        AssertObject(AutoFree(new CustomClass.InnerClassB())).IsInstanceOf<CustomClass.InnerClassA>();
        // c# class
        AssertObject(new object()).IsInstanceOf<object>();
        AssertObject("").IsInstanceOf<object>();
        AssertObject(new CustomClass()).IsInstanceOf<object>();
        AssertObject(new CustomClassB()).IsInstanceOf<object>();
        AssertObject(new CustomClassB()).IsInstanceOf<CustomClass>();

        // should fail because the current is not a instance of `Tree`
        AssertObject(AutoFree(new Godot.Path()), FAIL)
            .IsInstanceOf<Godot.Tree>()
            .HasFailureMessage("Expected instance of:\n"
                + " <Godot.Tree>\n"
                + " But it was <Godot.Path>");
        AssertObject(null, FAIL)
            .IsInstanceOf<Godot.Tree>()
            .HasFailureMessage("Expected instance of:\n"
                + " <Godot.Tree>\n"
                + " But it was 'Null'");
        AssertObject(new CustomClass(), FAIL)
            .IsInstanceOf<CustomClassB>()
            .HasFailureMessage("Expected instance of:\n"
                + " <ObjectAssertTest+CustomClassB>\n"
                + " But it was <ObjectAssertTest+CustomClass>");
    }

    [TestCase]
    public void IsNotInstanceOf()
    {
        AssertObject(null).IsNotInstanceOf<Godot.Node>();
        // engine class test
        AssertObject(AutoFree(new Godot.Path())).IsNotInstanceOf<Godot.Tree>();
        // inner class test
        AssertObject(AutoFree(new CustomClass.InnerClassA())).IsNotInstanceOf<Godot.Tree>();
        AssertObject(AutoFree(new CustomClass.InnerClassB())).IsNotInstanceOf<CustomClass.InnerClassC>();
        // c# class
        AssertObject(new CustomClass()).IsNotInstanceOf<CustomClassB>();

        // should fail because the current is not a instance of `Tree`
        AssertObject(AutoFree(new Godot.Path()), FAIL)
            .IsNotInstanceOf<Godot.Node>()
            .HasFailureMessage("Expecting: not be a instance of <Godot.Node>");
        AssertObject(AutoFree(new CustomClassB()), FAIL)
            .IsNotInstanceOf<CustomClass>()
            .HasFailureMessage("Expecting: not be a instance of <ObjectAssertTest+CustomClass>");
    }

    [TestCase]
    public void IsNull()
    {
        AssertObject(null).IsNull();
        // should fail because the current is not null
        AssertObject(AutoFree(new Godot.Node()), FAIL)
            .IsNull()
            .StartsWithFailureMessage("Expecting: 'Null' but was <Godot.Node>");
        AssertObject(AutoFree(new object()), FAIL)
            .IsNull()
            .StartsWithFailureMessage("Expecting: 'Null' but was <System.Object>");
    }

    [TestCase]
    public void IsNotNull()
    {
        AssertObject(AutoFree(new Godot.Node())).IsNotNull();
        AssertObject(new object()).IsNotNull();
        // should fail because the current is null
        AssertObject(null, FAIL)
            .IsNotNull()
            .HasFailureMessage("Expecting: not to be 'Null'");
    }

    [TestCase]
    public void IsSame()
    {
        var obj1 = AutoFree(new Godot.Node());
        var obj2 = obj1;
        var obj3 = AutoFree(obj1.Duplicate());
        AssertObject(obj1).IsSame(obj1);
        AssertObject(obj1).IsSame(obj2);
        AssertObject(obj2).IsSame(obj1);
        var o1 = new object();
        var o2 = o1;
        AssertObject(o1).IsSame(o1);
        AssertObject(o1).IsSame(o2);
        AssertObject(o2).IsSame(o1);

        AssertObject(null, FAIL)
            .IsSame(obj1)
            .HasFailureMessage("Expecting:\n"
                + " <Godot.Node>\n"
                + " to refer to the same object\n"
                + " 'Null'");
        AssertObject(obj1, FAIL)
            .IsSame(obj3)
            .HasFailureMessage("Expecting:\n"
                + " <Godot.Node>\n"
                + " to refer to the same object\n"
                + " <Godot.Node>");
        AssertObject(obj3, FAIL)
            .IsSame(obj1)
            .HasFailureMessage("Expecting:\n"
                + " <Godot.Node>\n"
                + " to refer to the same object\n"
                + " <Godot.Node>");
        AssertObject(obj3, FAIL)
            .IsSame(obj2)
            .HasFailureMessage("Expecting:\n"
                + " <Godot.Node>\n"
                + " to refer to the same object\n"
                + " <Godot.Node>");
    }

    [TestCase]
    public void IsNotSame()
    {
        var obj1 = AutoFree(new Godot.Node());
        var obj2 = obj1;
        var obj3 = AutoFree(obj1.Duplicate());
        AssertObject(null).IsNotSame(obj1);
        AssertObject(obj1).IsNotSame(obj3);
        AssertObject(obj3).IsNotSame(obj1);
        AssertObject(obj3).IsNotSame(obj2);

        var o1 = new object();
        var o2 = new object();
        AssertObject(null).IsNotSame(o1);
        AssertObject(o1).IsNotSame(o2);
        AssertObject(o2).IsNotSame(o1);

        AssertObject(obj1, FAIL)
            .IsNotSame(obj1)
            .HasFailureMessage("Expecting not same: <Godot.Node>");
        AssertObject(obj1, FAIL)
            .IsNotSame(obj2)
            .HasFailureMessage("Expecting not same: <Godot.Node>");
        AssertObject(obj2, FAIL)
            .IsNotSame(obj1)
            .HasFailureMessage("Expecting not same: <Godot.Node>");
    }

    [TestCase]
    public void MustFail_IsPrimitive()
    {
        AssertObject(1, FAIL).HasFailureMessage("ObjectAssert inital error: current is primitive <System.Int32>");
        AssertObject(1.3, FAIL).HasFailureMessage("ObjectAssert inital error: current is primitive <System.Double>");
        AssertObject(true, FAIL).HasFailureMessage("ObjectAssert inital error: current is primitive <System.Boolean>");
    }

    [TestCase]
    public void OverrideFailureMessage()
    {
        AssertObject(AutoFree(new Godot.Node()), FAIL)
            .OverrideFailureMessage("Custom failure message")
            .IsNull()
            .HasFailureMessage("Custom failure message");
    }

    [TestCase]
    public void Interrupt_IsFailure()
    {
        // we want to interrupt on first failure
        EnableInterruptOnFailure(true);
        // try to fail
        AssertObject(null, FAIL).IsNotNull();

        // expect this line will never called because of the test is interrupted by a failing assert
        AssertBool(true).OverrideFailureMessage("This line shold never be called").IsFalse();
    }
}
