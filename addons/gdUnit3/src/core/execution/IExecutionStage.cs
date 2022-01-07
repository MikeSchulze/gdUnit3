using System.Threading.Tasks;

namespace GdUnit3
{
    internal interface IExecutionStage
    {
        public string StageName();

        public Task Execute(ExecutionContext context);
    }
}
