using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace GdUnit3
{
    using Asserts;

    /// <summary>
    /// A collection of assertions and helpers to verify values
    /// </summary>
    public sealed class Assertions
    {
        /// <summary>
        /// An Assertion to verify boolean values
        /// </summary>
        /// <param name="current">The current boolean value to verify</param>
        /// <returns>IBoolAssert</returns>
        public static IBoolAssert AssertBool(bool current) => new BoolAssert(current);

        /// <summary>
        /// An Assertion to verify string values
        /// </summary>
        /// <param name="current">The current string value to verify</param>
        /// <param name="expectResult"></param>
        /// <returns></returns>
        public static IStringAssert AssertString(string? current) => new StringAssert(current);

        /// <summary>
        /// An Assertion to verify integer values
        /// </summary>
        /// <param name="current">The current integer value to verify</param>
        /// <param name="expectResult"></param>
        /// <returns></returns>
        public static IIntAssert AssertInt(int current) => new IntAssert(current);

        /// <summary>
        /// An Assertion to verify double values
        /// </summary>
        /// <param name="current">The current double value to verify</param>
        /// <param name="expectResult"></param>
        /// <returns></returns>
        public static IDoubleAssert AssertFloat(double current) => new DoubleAssert(current);

        /// <summary>
        /// An Assertion to verify object values
        /// </summary>
        /// <param name="current">The current double value to verify</param>
        /// <param name="expectResult"></param>
        /// <returns></returns>        
        public static IObjectAssert AssertObject(object? current) => new ObjectAssert(current);

        /// <summary>
        /// An Assertion to verify array values
        /// </summary>
        /// <param name="current">The current array value to verify</param>
        /// <param name="expectResult"></param>
        /// <returns></returns>  
        public static IArrayAssert AssertArray(IEnumerable? current) => new ArrayAssert(current);


        /// <summary>
        /// An Assertion used by test generation to notify the test is not yet implemented
        /// </summary>
        /// <returns></returns>
        public static bool AssertNotYetImplemented() => throw new Exceptions.TestFailedException("Test not yet implemented!", -1);


        public static IAssertBase<T> AssertThat<T>(T? current)
        {
            if (typeof(string) == typeof(T))
                return (IAssertBase<T>)AssertString(Convert.ToString(current));
            if (typeof(bool) == typeof(T))
                return (IAssertBase<T>)AssertBool(Convert.ToBoolean(current));
            if (typeof(int) == typeof(T))
                return (IAssertBase<T>)AssertInt(Convert.ToInt32(current));
            if (typeof(double) == typeof(T))
                return (IAssertBase<T>)AssertFloat(Convert.ToDouble(current));
            if (typeof(IEnumerable) == typeof(T))
                return (IAssertBase<T>)AssertArray(current as IEnumerable);
            return (IAssertBase<T>)AssertObject(current as object);
        }

        public static IStringAssert AssertThat(string current) => AssertString(current);
        public static IBoolAssert AssertThat(bool current) => AssertBool(current);
        public static IIntAssert AssertThat(int current) => AssertInt(current);
        public static IDoubleAssert AssertThat(double current) => AssertFloat(current);
        public static IObjectAssert AssertThat(object current) => AssertObject(current);
        public static IArrayAssert AssertThat(IEnumerable current) => AssertArray(current);


        /// <summary>
        /// An Assertion to verify for expecting exceptions
        /// </summary>
        /// <param name="supplier">A function callback where throw possible exceptions</param>
        /// <returns>IExceptionAssert</returns>
        public static IExceptionAssert AssertThrown<T>(Func<T> supplier) => new ExceptionAssert<T>(supplier);

        /// <summary>
        /// An Assertion to verify for expecting exceptions when performing a task.
        /// <example>
        /// <code>
        ///     await AssertThrown(task.WithTimeout(500))
        ///        .ContinueWith(result => result.Result.HasMessage("timed out after 500ms."));
        /// </code>
        /// </example>
        /// </summary>
        /// <param name="task">A task where throw possible exceptions</param>
        /// <returns>a task of <c>IExceptionAssert</c> to await</returns>
        public async static Task<IExceptionAssert?> AssertThrown<T>(Task<T> task)
        {
            try
            {
                await task;
                return default;
            }
            catch (Exception e)
            {
                return new ExceptionAssert<T>(e);
            }
        }

        public async static Task<IExceptionAssert?> AssertThrown(Task task)
        {
            try
            {
                await task;
                return default;
            }
            catch (Exception e)
            {
                return new ExceptionAssert<object>(e);
            }
        }

        /// ----------- Helpers -------------------------------------------------------------------------------------------------------

        ///<summary>
        /// A litle helper to auto freeing your created objects after test execution
        /// </summary>
        public static T AutoFree<T>(T obj) where T : Godot.Object => Executions.Monitors.MemoryPool.RegisterForAutoFree(obj);

        /// <summary>
        /// Buils a tuple by given values
        /// </summary>
        public static ITuple Tuple(params object?[] args) => new GdUnit3.Asserts.Tuple(args);

        /// <summary>
        ///  Builds an extractor by given method name and optional arguments
        /// </summary>
        public static IValueExtractor Extr(string methodName, params object[] args) => new ValueExtractor(methodName, args);

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
    }
}
