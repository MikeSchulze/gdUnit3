namespace GdUnit3
{
    public interface IExecutionStage
    {

        public string StageName();


        public void Execute(ExecutionContext context);
    }
}
