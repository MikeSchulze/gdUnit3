using System;
using System.Diagnostics.Contracts;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;

using GdUnit3.Executions;

namespace GdUnit3.Tools
{
    public class CsTools : Godot.Reference
    {
        public static Type loadClass(String classPath)
        {
            //AppDomain currentDomain = AppDomain.CurrentDomain;
            //var types = currentDomain.GetAssemblies().First(a => a.GetName().Name == "gdUnit3").GetTypes();

            //.First( t => t.Name);
            //.ToList().ForEach(a => Godot.GD.PrintS(a.GetTypes()));
            //Assembly compiledAssembly = CSScriptLibrary.CSScript.LoadCode(classPath, null, true);


            //var instance = (Godot.Object)Godot.ResourceLoader.Load<Godot.CSharpScript>(classPath).New();
            //System.Type type = instance.GetType();
            //instance.Free()

            try
            {
                var assembly = typeof(CsTools).Assembly;
                var fi = new FileInfo(classPath);
                if (!fi.Exists)
                {
                    return null;
                }
                return assembly.GetTypes()
                        .First(type => fi.Name.StartsWith(type.Name));
            }
#pragma warning disable CS0168
            catch (Exception e)
            {
#pragma warning restore CS0168
                // ignore exception
                return null;
            }
        }

        public static bool IsTestSuite(String classPath)
        {
            var classType = loadClass(classPath);
            return classType != null ? Attribute.IsDefined(classType, typeof(TestSuiteAttribute)) : false;
        }

        public static Godot.Node ParseTestSuite(String classPath)
        {
            try
            {
                var classType = loadClass(classPath);
                var testSuite = new Godot.Node();
                testSuite.SetMeta("CS_TESTSUITE", true);
                testSuite.SetMeta("ResourcePath", classPath);
                testSuite.Name = classType.Name;
                LoadTestCases(classType)
                    .ToList()
                    .ForEach(testCase =>
                    {
                        var child = new Godot.Node();
                        child.Name = testCase.Name;
                        child.SetMeta("LineNumber", testCase.Line);
                        child.SetMeta("ResourcePath", classPath);
                        testSuite.AddChild(child);
                    });
                return testSuite;
            }
#pragma warning disable CS0168
            catch (Exception e)
            {
#pragma warning restore CS0168
                // ignore exception
                return null;
            }
        }

        private static IEnumerable<Executions.TestCase> LoadTestCases(Type type) => type.GetMethods()
            .Where(m => m.IsDefined(typeof(TestCaseAttribute)))
            .Select(mi => new Executions.TestCase(mi));

    }
}
