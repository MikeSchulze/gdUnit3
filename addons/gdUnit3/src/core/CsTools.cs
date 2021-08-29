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

        // used from GdScript side to verify it given resource a gdunit test-suite
        public static bool IsTestSuite(String classPath)
        {
            try
            {
                var instance = (Godot.Object)Godot.ResourceLoader.Load<Godot.CSharpScript>(classPath).New();
                System.Type type = instance.GetType();
                instance.Free();

                if (type == null)
                {
                    return false;
                }
                return Attribute.IsDefined(type, typeof(TestSuiteAttribute));
            }
#pragma warning disable CS0168
            catch (Exception e)
            {
#pragma warning restore CS0168
                // ignore exception
                return false;
            }

        }
    }
}
