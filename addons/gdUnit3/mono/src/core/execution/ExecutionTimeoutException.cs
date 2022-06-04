namespace GdUnit3.Executions
{
    internal sealed class ExecutionTimeoutException : System.Exception
    {
        public ExecutionTimeoutException(string message, int line) : base(message)
        {
            LineNumber = line;
        }

        public int LineNumber
        { get; private set; }
    }
}
