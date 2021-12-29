using GdUnit3;
using System.Collections.Generic;

using static GdUnit3.Assertions;


[TestSuite]
public class ObjectAssertTest : TestSuite
{

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
        AssertThrown(() => AssertObject(new Godot.CubeMesh()).IsEqual(new Godot.Skin()))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 30)
            .HasMessage("Expecting be equal:\n"
                + "  <Godot.Skin> but is <Godot.CubeMesh>");
        AssertThrown(() => AssertObject(new object()).IsEqual(new List<int>()))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 35)
            .HasMessage("Expecting be equal:\n"
                + "  System.Collections.Generic.List<System.Int32>\n"
                + " but is\n"
                + "  <System.Object>");
    }

    [TestCase]
    public void IsNotEqual()
    {
        AssertObject(new Godot.CubeMesh()).IsNotEqual(new Godot.Skin());
        AssertObject(new object()).IsNotEqual(new List<object>());
        // should fail because the current is an CubeMesh and we expect not equal to a CubeMesh
        AssertThrown(() => AssertObject(new Godot.CubeMesh()).IsNotEqual(new Godot.CubeMesh()))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 50)
            .HasMessage("Expecting be NOT equal:\n"
                + "  <Godot.CubeMesh> but is <Godot.CubeMesh>");
        AssertThrown(() => AssertObject(new object()).IsNotEqual(new object()))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 55)
            .HasMessage("Expecting be NOT equal:\n"
                + "  <System.Object> but is <System.Object>");
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
        AssertThrown(() => AssertObject(AutoFree(new Godot.Path())).IsInstanceOf<Godot.Tree>())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 80)
            .HasMessage("Expected be instance of:\n"
                + "  <Godot.Tree> but is <Godot.Path>");
        AssertThrown(() => AssertObject(null).IsInstanceOf<Godot.Tree>())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 85)
            .HasMessage("Expected be instance of:\n"
                + "  <Godot.Tree> but is <Null>");
        AssertThrown(() => AssertObject(new CustomClass()).IsInstanceOf<CustomClassB>())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 90)
            .HasMessage("Expected be instance of:\n"
                + "  <ObjectAssertTest+CustomClassB> but is <ObjectAssertTest+CustomClass>");
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
        AssertThrown(() => AssertObject(AutoFree(new Godot.Path())).IsNotInstanceOf<Godot.Node>())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 110)
            .HasMessage("Expecting be NOT a instance of:\n"
                + "  <Godot.Node>");
        AssertThrown(() => AssertObject(AutoFree(new CustomClassB())).IsNotInstanceOf<CustomClass>())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 115)
            .HasMessage("Expecting be NOT a instance of:\n"
                + "  <ObjectAssertTest+CustomClass>");
    }

    [TestCase]
    public void IsNull()
    {
        AssertObject(null).IsNull();
        // should fail because the current is not null
        AssertThrown(() => AssertObject(AutoFree(new Godot.Node())).IsNull())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 127)
            .StartsWithMessage("Expecting be <Null>:\n"
                + " but is\n"
                + "  <Godot.Node>");
        AssertThrown(() => AssertObject(AutoFree(new object())).IsNull())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 133)
            .StartsWithMessage("Expecting be <Null>:\n"
                + " but is\n"
                + "  <System.Object>");
    }

    [TestCase]
    public void IsNotNull()
    {
        AssertObject(AutoFree(new Godot.Node())).IsNotNull();
        AssertObject(new object()).IsNotNull();
        // should fail because the current is null
        AssertThrown(() => AssertObject(null).IsNotNull())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 147)
            .HasMessage("Expecting be NOT <Null>:");
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

        AssertThrown(() => AssertObject(null).IsSame(obj1))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 168)
            .HasMessage("Expecting be same:\n"
                + "  <Godot.Node>\n"
                + " to refer to the same object\n"
                + "  <Null>");
        AssertThrown(() => AssertObject(obj1).IsSame(obj3))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 175)
            .HasMessage("Expecting be same:\n"
                + "  <Godot.Node>\n"
                + " to refer to the same object\n"
                + "  <Godot.Node>");
        AssertThrown(() => AssertObject(obj3).IsSame(obj1))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 182)
            .HasMessage("Expecting be same:\n"
                + "  <Godot.Node>\n"
                + " to refer to the same object\n"
                + "  <Godot.Node>");
        AssertThrown(() => AssertObject(obj3).IsSame(obj2))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 189)
            .HasMessage("Expecting be same:\n"
                + "  <Godot.Node>\n"
                + " to refer to the same object\n"
                + "  <Godot.Node>");
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

        AssertThrown(() => AssertObject(obj1).IsNotSame(obj1))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 215)
            .HasMessage("Expecting be NOT same: <Godot.Node>");
        AssertThrown(() => AssertObject(obj1).IsNotSame(obj2))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 219)
            .HasMessage("Expecting be NOT same: <Godot.Node>");
        AssertThrown(() => AssertObject(obj2).IsNotSame(obj1))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 223)
            .HasMessage("Expecting be NOT same: <Godot.Node>");
    }

    [TestCase]
    public void MustFail_IsPrimitive()
    {
        AssertThrown(() => AssertObject(1))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 232)
            .HasMessage("ObjectAssert inital error: current is primitive <System.Int32>");
        AssertThrown(() => AssertObject(1.3))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 236)
            .HasMessage("ObjectAssert inital error: current is primitive <System.Double>");
        AssertThrown(() => AssertObject(true))
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 240)
            .HasMessage("ObjectAssert inital error: current is primitive <System.Boolean>");
    }

    [TestCase]
    public void OverrideFailureMessage()
    {
        AssertThrown(() => AssertObject(AutoFree(new Godot.Node()))
                .OverrideFailureMessage("Custom failure message")
                .IsNull())
            .IsInstanceOf<TestFailedException>()
            .HasPropertyValue("LineNumber", 249)
            .HasMessage("Custom failure message");
    }

    [TestCase]
    public void Interrupt_IsFailure()
    {
        // we disable failure reportion until we simmulate an failure
        ExecutionContext.Current.FailureReporting = false;
        // try to fail
        AssertObject(null).IsNotNull();
        ExecutionContext.Current.FailureReporting = true;

        // expect this line will never called because of the test is interrupted by a failing assert
        AssertBool(true).OverrideFailureMessage("This line shold never be called").IsFalse();
    }
}
