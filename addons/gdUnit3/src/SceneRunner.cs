using System;
using System.Threading.Tasks;

namespace GdUnit3
{
    using Godot;

    /// <summary>
    /// Scene runner to test interactions like keybord/mouse inputs on a Godot scene.
    /// </summary>
    public interface SceneRunner : IDisposable
    {

        public static SceneRunner Load(string resourcePath)
        {
            return new Core.SceneRunner(resourcePath, true);
        }

        /// <summary>
        /// Simulates that a key has been pressed
        /// </summary>
        /// <param name="keyCode">the key code e.g. 'KeyList.Enter'</param>
        /// <param name="shift">false by default set to true if simmulate shift is press</param>
        /// <param name="control">false by default set to true if simmulate control is press</param>
        /// <returns>SceneRunner</returns>
        SceneRunner SimulateKeyPressed(KeyList keyCode, bool shift = false, bool control = false);


        /// <summary>
        /// Simulates that a key is pressed
        /// </summary>
        /// <param name="keyCode">the key code e.g. 'KeyList.Enter'</param>
        /// <param name="shift">false by default set to true if simmulate shift is press</param>
        /// <param name="control">false by default set to true if simmulate control is press</param>
        /// <returns></returns>
        SceneRunner SimulateKeyPress(KeyList keyCode, bool shift = false, bool control = false);


        /// <summary>
        /// Simulates that a key has been released
        /// </summary>
        /// <param name="keyCode">the key code e.g. 'KeyList.Enter'</param>
        /// <param name="shift">false by default set to true if simmulate shift is press</param>
        /// <param name="control">false by default set to true if simmulate control is press</param>
        /// <returns></returns>
        SceneRunner SimulateKeyRelease(KeyList keyCode, bool shift = false, bool control = false);

        /// <summary>
        /// Simulates a mouse moved to relative position by given speed
        /// </summary>
        /// <param name="relative">The mouse position relative to the previous position (position at the last frame).</param>
        /// <param name="speed">The mouse speed in pixels per second.</param>
        /// <returns></returns>
        SceneRunner SimulateMouseMove(Vector2 relative, Vector2 speeds = default);

        /// <summary>
        /// Simulates a mouse button pressed
        /// </summary>
        /// <param name="button">The mouse button identifier, one of the ButtonList button or button wheel constants.</param>
        /// <returns></returns>
        SceneRunner SimulateMouseButtonPressed(ButtonList button);

        /// <summary>
        /// Simulates a mouse button press (holding)
        /// </summary>
        /// <param name="button">The mouse button identifier, one of the ButtonList button or button wheel constants.</param>
        /// <returns></returns>
        SceneRunner SimulateMouseButtonPress(ButtonList button);

        /// <summary>
        /// Simulates a mouse button released
        /// </summary>
        /// <param name="button">The mouse button identifier, one of the ButtonList button or button wheel constants.</param>
        /// <returns></returns>
        SceneRunner SimulateMouseButtonRelease(ButtonList button);

        /// <summary>
        /// Sets how fast or slow the scene simulation is processed (clock ticks versus the real).
        /// It defaults to 1.0. A value of 2.0 means the game moves twice as fast as real life,
        /// whilst a value of 0.5 means the game moves at half the regular speed.
        /// </summary>
        /// <param name="timeFactor"></param>
        /// <returns></returns>
        /// 
        SceneRunner SetTimeFactor(double timeFactor = 1.0);


        /// <summary>
        /// Simulates scene processing for a certain number of frames by given delta peer frame by ignoring the time factor
        /// </summary>
        /// <param name="frames">amount of frames to process</param>
        /// <param name="deltaPeerFrame">the time delta between a frame in ms</param>
        /// <returns></returns>
        Task<SceneRunner> Simulate(int frames, long deltaPeerFrame);

        /// <summary>
        /// Simulates scene processing for a certain number of frames
        /// </summary>
        /// <param name="frames">amount of frames to process</param>
        /// <returns></returns>
        Task<SceneRunner> SimulateFrames(int frames);

        /// <summary>
        /// Waits until next frame (idle_frame)
        /// </summary>
        /// <returns>SignalAwaiter</returns>
        public SignalAwaiter OnIdleFrame();

        /// <summary>
        /// Waits for a specific amount of seconds
        /// </summary>
        /// <param name="timeSec">Seconds to wait. 1.0 for one Second</param>
        /// <returns></returns>
        public SignalAwaiter OnWait(float timeSec);

        /// <summary>
        /// Access to current running scene
        /// </summary>
        /// <returns>Node</returns>
        public Node Scene();

        /// <summary>
        /// Shows the running scene and moves the window to the foreground. 
        /// </summary>
        public void ShowScene();
    }

}
