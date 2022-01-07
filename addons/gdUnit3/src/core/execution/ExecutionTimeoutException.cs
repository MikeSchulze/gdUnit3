using System.Diagnostics;

namespace GdUnit3
{
    internal sealed class ExecutionTimeoutException : System.Exception
    {
        public ExecutionTimeoutException(string message) : base(message)
        {
            StackFrame CallStack = new StackFrame(2, true);
            LineNumber = CallStack.GetFileLineNumber();
        }

        public int LineNumber
        { get; private set; }
    }
}
