using System;
using System.Threading.Tasks;

namespace GdUnit3
{
    using Godot;

    /// <summary>
    /// Scene runner to test interactions like keybord/mouse inputs on a Godot scene.
    /// </summary>
    public interface ISceneRunner : IDisposable
    {

        /// <summary>
        /// Loads a scene into the SceneRunner to be simmulated.
        /// </summary>
        /// <param name="resourcePath">The path to the scene resource.</param>
        /// <param name="autofree">If true the loaded scene will be automatic freed when the runner is freed.</param>
        /// <param name="verbose">Prints detailt infos on scene simmulation.</param>
        /// <returns></returns>
        public static ISceneRunner Load(string resourcePath, bool autofree = false, bool verbose = false) => new Core.SceneRunner(resourcePath, autofree, verbose);

        /// <summary>
        /// Sets the actual mouse position relative to the viewport.
        /// </summary>
        /// <param name="position">The position in x/y coordinates</param>
        /// <returns></returns>
        ISceneRunner SetMousePos(Vector2 position);

        /// <summary>
        /// Simulates that a key has been pressed.
        /// </summary>
        /// <param name="keyCode">the key code e.g. 'KeyList.Enter'</param>
        /// <param name="shift">false by default set to true if simmulate shift is press</param>
        /// <param name="control">false by default set to true if simmulate control is press</param>
        /// <returns>SceneRunner</returns>
        ISceneRunner SimulateKeyPressed(KeyList keyCode, bool shift = false, bool control = false);

        /// <summary>
        /// Simulates that a key is pressed.
        /// </summary>
        /// <param name="keyCode">the key code e.g. 'KeyList.Enter'</param>
        /// <param name="shift">false by default set to true if simmulate shift is press</param>
        /// <param name="control">false by default set to true if simmulate control is press</param>
        /// <returns>SceneRunner</returns>
        ISceneRunner SimulateKeyPress(KeyList keyCode, bool shift = false, bool control = false);

        /// <summary>
        /// Simulates that a key has been released.
        /// </summary>
        /// <param name="keyCode">the key code e.g. 'KeyList.Enter'</param>
        /// <param name="shift">false by default set to true if simmulate shift is press</param>
        /// <param name="control">false by default set to true if simmulate control is press</param>
        /// <returns>SceneRunner</returns>
        ISceneRunner SimulateKeyRelease(KeyList keyCode, bool shift = false, bool control = false);

        /// <summary>
        /// Simulates a mouse moved to relative position by given speed.
        /// </summary>
        /// <param name="relative">The mouse position relative to the previous position (position at the last frame).</param>
        /// <param name="speed">The mouse speed in pixels per second.</param>
        /// <returns>SceneRunner</returns>
        ISceneRunner SimulateMouseMove(Vector2 relative, Vector2 speeds = default);

        /// <summary>
        /// Simulates a mouse button pressed.
        /// </summary>
        /// <param name="button">The mouse button identifier, one of the ButtonList button or button wheel constants.</param>
        /// <returns>SceneRunner</returns>
        ISceneRunner SimulateMouseButtonPressed(ButtonList button);

        /// <summary>
        /// Simulates a mouse button press. (holding)
        /// </summary>
        /// <param name="button">The mouse button identifier, one of the ButtonList button or button wheel constants.</param>
        /// <returns>SceneRunner</returns>
        ISceneRunner SimulateMouseButtonPress(ButtonList button);

        /// <summary>
        /// Simulates a mouse button released.
        /// </summary>
        /// <param name="button">The mouse button identifier, one of the ButtonList button or button wheel constants.</param>
        /// <returns>SceneRunner</returns>
        ISceneRunner SimulateMouseButtonRelease(ButtonList button);

        /// <summary>
        /// Sets how fast or slow the scene simulation is processed (clock ticks versus the real).
        /// <code>
        ///     // It defaults to 1.0. A value of 2.0 means the game moves twice as fast as real life,
        ///     // whilst a value of 0.5 means the game moves at half the regular speed
        /// </code>
        /// </summary>
        /// <param name="timeFactor"></param>
        /// <returns>SceneRunner</returns>
        ISceneRunner SetTimeFactor(double timeFactor = 1.0);

        /// <summary>
        /// Simulates scene processing for a certain number of frames by given delta peer frame by ignoring the current time factor
        /// <code>
        ///     // Waits until 100 frames are processed with a delta of 20ms peer frame
        ///     await runner.SimulateFrames(100, 20);
        /// </code>
        /// </summary>
        /// <param name="frames">amount of frames to process</param>
        /// <param name="deltaPeerFrame">the time delta between a frame in milliseconds</param>
        /// <returns>Task to wait</returns>
        Task SimulateFrames(uint frames, uint deltaPeerFrame);

        /// <summary>
        /// Simulates scene processing for a certain number of frames.
        /// <example>
        /// <code>
        ///     // Waits until 100 frames are processed
        ///     await runner.SimulateFrames(100);
        /// </code>
        /// </example>
        /// </summary>
        /// <param name="frames">amount of frames to process</param>
        /// <returns>Task to wait</returns>
        Task SimulateFrames(uint frames);

        /// <summary>
        /// Waits until next frame is processed (signal idle_frame)
        /// <example>
        /// <code>
        ///     // Waits until next frame is processed
        ///     await runner.AwaitIdleFrame();
        /// </code>
        /// </example>
        /// </summary>
        /// <returns>Task to wait</returns>
        Task AwaitIdleFrame();

        /// <summary>
        /// Returns a method awaiter to wait for a specific method result.
        /// <example>
        /// <code>
        ///     // Waits until '10' is returnd by the method 'calculateX()' or will be interrupted after a timeout of 3s
        ///     await runner.AwaitMethod("calculateX").IsEqual(10).WithTimeout(3000);
        /// </code>
        /// </example>
        /// </summary>
        /// <typeparam name="V">The expected result type</typeparam>
        /// <param name="methodName">The name of the method to wait</param>
        /// <returns>GodotMethodAwaiter</returns>
        GdUnitAwaiter.GodotMethodAwaiter<V> AwaitMethod<V>(string methodName);

        /// <summary>
        /// Waits for given signal is emited.
        /// <example>
        /// <code>
        ///     // Waits for signal "mySignal" is emited by the scene.
        ///     await runner.AwaitSignal("mySignal");
        /// </code>
        /// </example>
        /// </summary>
        /// <param name="signal">The name of the signal to wait</param>
        /// <returns>Task to wait</returns>
        Task AwaitSignal(string signal, params object[] args);

        /// <summary>
        /// Waits for a specific amount of milliseconds.
        /// <example>
        /// <code>
        ///     // Waits for two seconds
        ///     await runner.AwaitMillis(2000);
        /// </code>
        /// </example>
        /// </summary>
        /// <param name="timeMillis">Seconds to wait. 1.0 for one Second</param>
        /// <returns>Task to wait</returns>
        Task AwaitMillis(uint timeMillis);

        /// <summary>
        /// Access to current running scene
        /// </summary>
        /// <returns>Node</returns>
        Node Scene();

        /// <summary>
        /// Shows the running scene and moves the window to the foreground. 
        /// </summary>
        void MoveWindowToForeground();

        /// <summary>
        /// Invokes the method by given name and arguments.
        /// </summary>
        /// <param name="name">The name of method to invoke</param>
        /// <param name="args">The function arguments</param>
        /// <returns>The return value of invoked method</returns>
        /// <exception cref="MissingMethodException"/>
        public object Invoke(string name, params object[] args);

        /// <summary>
        /// Returns the property by given name.
        /// </summary>
        /// <typeparam name="T">The type of the property</typeparam>
        /// <param name="name">The parameter name</param>
        /// <returns>The value of the property or throws a MissingFieldException</returns>
        /// <exception cref="MissingFieldException"/>
        public T GetProperty<T>(string name);

        /// <summary>
        /// Finds the node by given name.
        /// </summary>
        /// <param name="name">The name of node to find</param>
        /// <param name="recursive">Allow recursive search</param>
        /// <returns>The node if found or Null</returns>
        public Node FindNode(string name, bool recursive = true);
    }
}
