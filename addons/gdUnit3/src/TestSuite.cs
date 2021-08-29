using Godot;
using System;
using System.Diagnostics;

namespace GdUnit3
{

    /** <summary>
    This class is the main class to implement your unit tests<br />
    You have to extend and implement your test cases as described<br />
    e.g<br />
    <br />
      For detailed instructions see <a href="https://github.com/MikeSchulze/gdUnit3/wiki/TestSuite">HERE</a> <br />
      
    <example>For example:
    
    <code>
    public class MyExampleTest : GdUnit3.GdUnitTestSuite
    {
         public void testCaseA()
         {
             AssertThat("value").IsEqual("value");
         }
     }
    </code>
    </example>
    </summary> */
    public abstract class TestSuite : Node
    {
        private String _active_test_case;

        private static Godot.Resource GdUnitTools = (Resource)GD.Load<GDScript>("res://addons/gdUnit3/src/core/GdUnitTools.gd").New();


        // current we overide it to get the correct count of tests
        public int get_child_count()
        {
            return TestCaseCount;
        }

        // A litle helper to auto freeing your created objects after test execution
        public T auto_free<T>(T obj)
        {
            GdUnitTools.Call("register_auto_free", obj, GetMeta("MEMORY_POOL"));
            return obj;
        }

        // Discard the error message triggered by a timeout (interruption).
        // By default, an interrupted test is reported as an error.
        // This function allows you to change the message to Success when an interrupted error is reported.
        public void discard_error_interupted_by_timeout()
        {
            //GdUnitTools.register_expect_interupted_by_timeout(self, __active_test_case)
        }

        // Creates a new directory under the temporary directory *user://tmp*
        // Useful for storing data during test execution. 
        // The directory is automatically deleted after test suite execution
        public String create_temp_dir(String relative_path)
        {
            //return GdUnitTools.create_temp_dir(relative_path)
            return "";
        }

        // Deletes the temporary base directory
        // Is called automatically after each execution of the test suite
        public void clean_temp_dir()
        {
            //GdUnitTools.clear_tmp()
        }

        public int TestCaseCount => CsTools.TestCaseCount(GetType());

        public string ResourcePath => (GetScript() as Script).ResourcePath;

        public bool Skipped => false;


        // === Asserts ==================================================================
        public IBoolAssert AssertBool(bool current, IAssert.EXPECT expectResult = IAssert.EXPECT.SUCCESS)
        {
            return new BoolAssert(this, current, expectResult);
        }

        public IStringAssert AssertString(string current, IAssert.EXPECT expectResult = IAssert.EXPECT.SUCCESS)
        {
            return new StringAssert(this, current, expectResult);
        }

        public IIntAssert AssertInt(int current, IAssert.EXPECT expectResult = IAssert.EXPECT.SUCCESS)
        {
            return new IntAssert(this, current, expectResult);
        }

        public IDoubleAssert AssertFloat(double current, IAssert.EXPECT expectResult = IAssert.EXPECT.SUCCESS)
        {
            return new DoubleAssert(this, current, expectResult);
        }

        public IObjectAssert AssertObject(object current, IAssert.EXPECT expectResult = IAssert.EXPECT.SUCCESS)
        {
            return new ObjectAssert(this, current, expectResult);
        }
    }

}
