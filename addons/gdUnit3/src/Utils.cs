
using System;
using System.IO;
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


        private const string GDUNIT_TEMP = "user://tmp";

        internal static string GodotTempDir() =>
            Path.GetFullPath(Godot.ProjectSettings.GlobalizePath(GDUNIT_TEMP));

        /// <summary>
        /// Creates a tempory folder under Godot managed user directory
        /// </summary>
        /// <param name="path">a relative path</param>
        /// <returns>the full path to the created temp direcory</returns>
        public static string CreateTempDir(string path)
        {
            var tempFolder = Path.Combine(GodotTempDir(), path);
            if (!new FileInfo(tempFolder).Exists)
                Directory.CreateDirectory(tempFolder);
            return tempFolder;
        }

        /// <summary>
        /// Deletes the GdUnit temp directory recursively
        /// </summary>
        public static void ClearTempDir()
        {
            var tempFolder = GodotTempDir();
            if (Directory.Exists(tempFolder))
                Directory.Delete(tempFolder, true);
        }
    }
}
