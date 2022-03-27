using System;
using System.Threading;
using System.Threading.Tasks;

using System.Linq;

namespace GdUnit3
{
    using Asserts;
    using Godot;
    using static Assertions;

    public static class GdUnitAwaiter
    {
        public static async Task<T> WithTimeout<T>(this Task<T> task, int timeoutMillis)
        {
            var wrapperTask = Task.Run(async () => await task);
            using var token = new CancellationTokenSource();
            var completedTask = await Task.WhenAny(wrapperTask, Task.Delay(timeoutMillis, token.Token));
            if (completedTask == wrapperTask)
            {
                token.Cancel();
                return await task;
            }
            throw new TimeoutException($"AwaitOnSignal: timed out after {timeoutMillis}ms.");
        }

        public static async Task<IAssertBase<V>> WithTimeout<V>(this Task<IAssertBase<V>> task, int timeoutMillis)
        {
            var wrapperTask = Task.Run(async () => await task);
            using var token = new CancellationTokenSource();
            var completedTask = await Task.WhenAny(wrapperTask, Task.Delay(timeoutMillis, token.Token));
            if (completedTask == wrapperTask)
            {
                token.Cancel();
                return await task;
            }
            throw new TimeoutException($"Assertion: timed out after {timeoutMillis}ms.");
        }


        public static async Task<object> AwaitSignal(this GdUnit3.ISceneRunner runner, string signal, params object[] args)
        {
            object[] signalArgs = await runner.Scene().ToSignal(runner.Scene(), signal);
            if (signalArgs.SequenceEqual(args))
                return default;
            return await AwaitSignal(runner, signal, args);
        }


        public sealed class GodotMethodAwaiter<V>
        {
            private string MethodName { get; }
            private Node Instance { get; }
            private object[] Args { get; }

            public GodotMethodAwaiter(Node instance, string methodName, params object[] args)
            {
                Instance = instance;
                MethodName = methodName;
                Args = args;
                if (!Instance.HasMethod(methodName))
                    throw new MissingMethodException($"The method '{methodName}' not exist on loaded scene.");
            }

            public async Task<IAssertBase<V>> IsEqual(V expected)
            {
                return await Task.Run<IAssertBase<V>>(async () =>
                {
                    var current = Instance.Call(MethodName, Args);
                    if (current is GDScriptFunctionState)
                    {
                        object[] result = await Instance.ToSignal(current as GDScriptFunctionState, "completed");
                        if (Comparable.IsEqual(result[0], expected).Valid)
                            return (IAssertBase<V>)AssertThat<V>((V)result[0]);
                    }
                    else if (Comparable.IsEqual(current, expected).Valid)
                        return (IAssertBase<V>)AssertThat<V>((V)current);

                    return await IsEqual(expected);
                });
            }
        }


        public static async Task<object> AwaitSignal(this Godot.Node node, string signal, params object[] args)
        {
            object[] signalArgs = await node.ToSignal(node, signal);
            if (signalArgs.SequenceEqual(args))
                return default;
            return await AwaitSignal(node, signal, args);
        }

    }
}

namespace GdUnit3.Core
{
    using Godot;
    using Executions;
    using Tools;
    internal sealed class SceneRunner : GdUnit3.ISceneRunner
    {
        private SceneTree SceneTree { get; set; }
        private Node CurrentScene { get; set; }
        private bool Verbose { get; set; }
        private bool SceneAutoFree { get; set; }
        private Vector2 CurrentMousePos { get; set; }
        private double TimeFactor { get; set; }
        private int SavedIterationsPerSecond { get; set; }

        public SceneRunner(string resourcePath, bool autoFree = false, bool verbose = false)
        {
            Verbose = verbose;
            SceneAutoFree = autoFree;
            ExecutionContext.RegisterDisposable(this);
            SceneTree = Godot.Engine.GetMainLoop() as SceneTree;
            CurrentScene = (Godot.ResourceLoader.Load(resourcePath) as PackedScene).Instance();
            SceneTree.Root.AddChild(CurrentScene);
            CurrentMousePos = default;
            SavedIterationsPerSecond = (int)ProjectSettings.GetSetting("physics/common/physics_fps");
            SetTimeFactor(1.0);
        }

        public GdUnit3.ISceneRunner SetMousePos(Vector2 position)
        {
            CurrentScene.GetViewport().WarpMouse(position);
            CurrentMousePos = position;
            return this;
        }

        public GdUnit3.ISceneRunner SimulateKeyPress(KeyList key_code, bool shift = false, bool control = false)
        {
            PrintCurrentFocus();
            var action = new InputEventKey();
            action.Pressed = true;
            action.Scancode = ((uint)key_code);
            action.Shift = shift;
            action.Control = control;

            Print("	process key event {0} ({1}) <- {2}:{3}", CurrentScene, SceneName(), action.AsText(), action.IsPressed() ? "pressing" : "released");
            SceneTree.InputEvent(action);
            return this;
        }

        public GdUnit3.ISceneRunner SimulateKeyPressed(KeyList key_code, bool shift = false, bool control = false)
        {
            SimulateKeyPress(key_code, shift, control);
            SimulateKeyRelease(key_code, shift, control);
            return this;
        }

        public GdUnit3.ISceneRunner SimulateKeyRelease(KeyList key_code, bool shift = false, bool control = false)
        {
            PrintCurrentFocus();
            var action = new InputEventKey();
            action.Pressed = false;
            action.Scancode = ((uint)key_code);
            action.Shift = shift;
            action.Control = control;

            Print("	process key event {0} ({1}) <- {2}:{3}", CurrentScene, SceneName(), action.AsText(), action.IsPressed() ? "pressing" : "released");
            SceneTree.InputEvent(action);
            return this;
        }

        public GdUnit3.ISceneRunner SimulateMouseMove(Vector2 relative, Vector2 speed = default)
        {
            var action = new InputEventMouseMotion();
            action.Relative = relative;
            action.Speed = speed == default ? Vector2.One : speed;

            Print("	process mouse motion event {0} ({1}) <- {2}", CurrentScene, SceneName(), action.AsText());
            SceneTree.InputEvent(action);
            return this;
        }

        public GdUnit3.ISceneRunner SimulateMouseButtonPressed(ButtonList buttonIndex)
        {
            SimulateMouseButtonPress(buttonIndex);
            SimulateMouseButtonRelease(buttonIndex);
            return this;
        }

        public GdUnit3.ISceneRunner SimulateMouseButtonPress(ButtonList buttonIndex)
        {
            PrintCurrentFocus();
            var action = new InputEventMouseButton();
            action.ButtonIndex = (int)buttonIndex;
            action.ButtonMask = (int)buttonIndex;
            action.Pressed = true;
            action.Position = CurrentMousePos;
            action.GlobalPosition = CurrentMousePos;

            Print("	process mouse button event {0} ({1}) <- {2}", CurrentScene, SceneName(), action.AsText());
            SceneTree.InputEvent(action);
            return this;
        }

        public GdUnit3.ISceneRunner SimulateMouseButtonRelease(ButtonList buttonIndex)
        {
            var action = new InputEventMouseButton();
            action.ButtonIndex = (int)buttonIndex;
            action.ButtonMask = 0;
            action.Pressed = false;
            action.Position = CurrentMousePos;
            action.GlobalPosition = CurrentMousePos;

            Print("	process mouse button event {0} ({1}) <- {2}", CurrentScene, SceneName(), action.AsText());
            SceneTree.InputEvent(action);
            return this;
        }

        public GdUnit3.ISceneRunner SetTimeFactor(double timeFactor = 1.0)
        {
            TimeFactor = Math.Min(9.0, timeFactor);
            ActivateTimeFactor();

            Print("set time factor: {0}", TimeFactor);
            Print("set physics iterations_per_second: {0}", SavedIterationsPerSecond * TimeFactor);
            return this;
        }

        public async Task<GdUnit3.ISceneRunner> SimulateFrames(uint frames, uint deltaPeerFrame)
        {
            for (int frame = 0; frame < frames; frame++)
                await AwaitMillis(deltaPeerFrame);
            return this;
        }

        public async Task<GdUnit3.ISceneRunner> SimulateFrames(uint frames)
        {
            var timeShiftFrames = Math.Max(1, frames / TimeFactor);
            for (int frame = 0; frame < timeShiftFrames; frame++)
                await AwaitIdleFrame();
            return this;
        }

        private void ActivateTimeFactor()
        {
            Engine.TimeScale = (float)TimeFactor;
            Engine.IterationsPerSecond = (int)(SavedIterationsPerSecond * TimeFactor);
        }

        private void DeactivateTimeFactor()
        {
            Engine.TimeScale = 1;
            Engine.IterationsPerSecond = SavedIterationsPerSecond;
        }

        private void Print(string message, params object[] args)
        {
            if (Verbose)
                Console.WriteLine(String.Format(message, args));
        }

        private void PrintCurrentFocus()
        {
            if (!Verbose)
                return;
            var focusedNode = (CurrentScene as Control)?.GetFocusOwner();

            if (focusedNode != null)
                Console.WriteLine("	focus on {0}", focusedNode);
            else
                Console.WriteLine("	no focus set");
        }

        private string SceneName()
        {
            var sceneScript = CurrentScene.GetScript();

            if (!(sceneScript is Script))
                return CurrentScene.Name;
            if (!CurrentScene.Name.BeginsWith("@"))
                return CurrentScene.Name;

            return (sceneScript as Script).ResourceName.BaseName();
        }

        public Node Scene() => CurrentScene;

        public GdUnitAwaiter.GodotMethodAwaiter<V> AwaitMethod<V>(string methodName) =>
            new GdUnitAwaiter.GodotMethodAwaiter<V>(CurrentScene, methodName);

        public SignalAwaiter AwaitIdleFrame() => SceneTree.ToSignal(SceneTree, "idle_frame");

        public async Task AwaitMillis(uint timeMillis)
        {
            using (var tokenSource = new CancellationTokenSource())
            {
                await Task.Delay(System.TimeSpan.FromMilliseconds(timeMillis), tokenSource.Token);
            }
        }

        public SignalAwaiter AwaitSignal(string signal) => SceneTree.ToSignal(CurrentScene, signal);

        public object Invoke(string name, params object[] args)
        {
            if (!CurrentScene.HasMethod(name))
                throw new MissingMethodException($"The method '{name}' not exist on loaded scene.");
            return CurrentScene.Call(name, args);
        }

        public T GetProperty<T>(string name)
        {
            var property = CurrentScene.Get(name);
            if (property != null)
            {
                return (T)property;
            }
            throw new MissingFieldException($"The property '{name}' not exist on loaded scene.");
        }

        public Node FindNode(string name, bool recursive = true) => CurrentScene.FindNode(name, recursive, false);

        public void MoveWindowToForeground()
        {
            OS.WindowMaximized = true;
            OS.CenterWindow();
            OS.MoveWindowToForeground();
        }

        public void Dispose()
        {
            DeactivateTimeFactor();
            OS.WindowMaximized = false;
            OS.WindowMinimized = true;
            SceneTree.Root.RemoveChild(CurrentScene);
            if (SceneAutoFree)
                CurrentScene.Free();
            SceneTree = null;
            CurrentScene = null;
            // we hide the scene/main window after runner is finished 
            OS.WindowMaximized = false;
            OS.WindowMinimized = true;
        }
    }
}
