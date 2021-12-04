using System.ComponentModel;
using System.Collections;
using System.Collections.Generic;
using System.Threading;

namespace GdUnit3
{
    /// <summary>
    /// A collection of assertions and helpers to verify values
    /// </summary>
    public sealed class Assertions
    {
        public enum EXPECT : int
        {
            [Description("assert expects ends with success")]
            SUCCESS = 0,
            [Description("assert expects ends with failure")]
            FAIL = 1
        }

        /// <summary>
        /// An Assertion to verify boolean values
        /// </summary>
        /// <param name="current">The current boolean value to verify</param>
        /// <returns>IBoolAssert</returns>
        public static IBoolAssert AssertBool(bool current, EXPECT expectResult = EXPECT.SUCCESS) =>
             new BoolAssert(TestInstance, current, expectResult);


        /// <summary>
        /// An Assertion to verify string values
        /// </summary>
        /// <param name="current">The current string value to verify</param>
        /// <param name="expectResult"></param>
        /// <returns></returns>
        public static IStringAssert AssertString(string current, EXPECT expectResult = EXPECT.SUCCESS) =>
             new StringAssert(TestInstance, current, expectResult);


        /// <summary>
        /// An Assertion to verify integer values
        /// </summary>
        /// <param name="current">The current integer value to verify</param>
        /// <param name="expectResult"></param>
        /// <returns></returns>
        public static IIntAssert AssertInt(int current, EXPECT expectResult = EXPECT.SUCCESS) =>
             new IntAssert(TestInstance, current, expectResult);

        /// <summary>
        /// An Assertion to verify double values
        /// </summary>
        /// <param name="current">The current double value to verify</param>
        /// <param name="expectResult"></param>
        /// <returns></returns>
        public static IDoubleAssert AssertFloat(double current, EXPECT expectResult = EXPECT.SUCCESS) =>
             new DoubleAssert(TestInstance, current, expectResult);

        /// <summary>
        /// An Assertion to verify object values
        /// </summary>
        /// <param name="current">The current double value to verify</param>
        /// <param name="expectResult"></param>
        /// <returns></returns>        
        public static IObjectAssert AssertObject(object current, EXPECT expectResult = EXPECT.SUCCESS) =>
             new ObjectAssert(TestInstance, current, expectResult);

        /// <summary>
        /// An Assertion to verify array values
        /// </summary>
        /// <param name="current">The current array value to verify</param>
        /// <param name="expectResult"></param>
        /// <returns></returns>  
        public static IArrayAssert AssertArray(IEnumerable current, EXPECT expectResult = EXPECT.SUCCESS) =>
             new ArrayAssert(TestInstance, current, expectResult);

        /// ----------- Helpers -------------------------------------------------------------------------------------------------------

        ///<summary>
        /// A litle helper to auto freeing your created objects after test execution
        /// </summary>
        public static T AutoFree<T>(T obj) => MemoryPool.RegisterForAutoFree(obj);

        /// <summary>
        /// Buils a tuple by given values
        /// </summary>
        public static ITuple Tuple(params object[] args) => new Tuple(args);

        /// <summary>
        ///  Builds an extractor by given method name and optional arguments
        /// </summary>
        public static IValueExtractor Extr(string methodName, params object[] args) => new ValueExtractor(methodName, args);



        /// <summary>
        /// Enable/Disables the fail fast behavior
        /// It is enabled the first failing assert will interupt the current executed test case
        /// </summary>
        /// <param name="enable"></param>
        public static void EnableInterupptOnFailure(bool enable) => Thread.SetData(Thread.GetNamedDataSlot("EnableInterupptOnFailure"), enable);

        /// <summary>
        /// Indicates whether fail fast is enabled
        /// </summary>
        /// <returns></returns>
        public static bool IsEnableInterupptOnFailure() => (bool)Thread.GetData(Thread.GetNamedDataSlot("EnableInterupptOnFailure"));

        /// <summary>
        ///  A helper to return given enumerable as string representation
        /// </summary>
        public static string AaString(IEnumerable values)
        {
            var items = new List<string>();
            foreach (var value in values)
            {
                items.Add(value != null ? value.ToString() : "Null");
            }
            return string.Join(", ", items);
        }

        private static object TestInstance => Thread.GetData(Thread.GetNamedDataSlot("TestInstance"));
    }
}
