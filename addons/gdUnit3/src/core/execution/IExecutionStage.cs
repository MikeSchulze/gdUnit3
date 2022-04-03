using System.Threading.Tasks;

namespace GdUnit3.Executions
{
    internal interface IExecutionStage
    {
        public string StageName();

        public Task Execute(ExecutionContext context);
    }
}
