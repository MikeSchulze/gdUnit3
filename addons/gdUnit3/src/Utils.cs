

using System.Threading;
using System.Threading.Tasks;

namespace GdUnit3
{

    public sealed class Utils
    {
        public async static Task<long> DoWait(long timeout)
        {
            System.Diagnostics.Stopwatch stopwatch = new System.Diagnostics.Stopwatch();
            stopwatch.Start();

            using (var tokenSource = new CancellationTokenSource())
            {
                await Task.Delay(System.TimeSpan.FromMilliseconds(timeout), tokenSource.Token);
            }

            stopwatch.Stop();
            return stopwatch.ElapsedMilliseconds;
        }
    }
}
