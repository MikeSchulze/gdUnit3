using System;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;
using System.Linq;

namespace GdUnit3
{
    using Asserts;
    using Executions;
    using Godot;
    using static Assertions;

    public static class GdUnitAwaiter
    {
        public static async Task WithTimeout(this Task task, int timeoutMillis)
        {
            var lineNumber = GetWithTimeoutLineNumber();
            var wrapperTask = Task.Run(async () => await task);
            using var token = new CancellationTokenSource();
            var completedTask = await Task.WhenAny(wrapperTask, Task.Delay(timeoutMillis, token.Token));
            if (completedTask != wrapperTask)
                throw new ExecutionTimeoutException($"Timed out after {timeoutMillis}ms.", lineNumber);
            token.Cancel();
            await task;
        }

        public static async Task<T> WithTimeout<T>(this Task<T> task, int timeoutMillis)
        {
            var lineNumber = GetWithTimeoutLineNumber();
            var wrapperTask = Task.Run(async () => await task);
            using var token = new CancellationTokenSource();
            var completedTask = await Task.WhenAny(wrapperTask, Task.Delay(timeoutMillis, token.Token));
            if (completedTask != wrapperTask)
                throw new ExecutionTimeoutException($"Timed out after {timeoutMillis}ms.", lineNumber);
            token.Cancel();
            return await task;
        }

        public static async Task<IAssertBase<V>> WithTimeout<V>(this Task<IAssertBase<V>> task, int timeoutMillis)
        {
            var lineNumber = GetWithTimeoutLineNumber();
            var wrapperTask = Task.Run(async () => await task);
            using var token = new CancellationTokenSource();
            var completedTask = await Task.WhenAny(wrapperTask, Task.Delay(timeoutMillis, token.Token));
            if (completedTask != wrapperTask)
                throw new ExecutionTimeoutException($"Assertion: timed out after {timeoutMillis}ms.", lineNumber);
            token.Cancel();
            return await task;
        }

        private static int GetWithTimeoutLineNumber()
        {
            StackTrace saveStackTrace = new StackTrace(true);
            return saveStackTrace.FrameCount > 4 ? saveStackTrace.GetFrame(4).GetFileLineNumber() : -1;
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

            public async Task<IAssertBase<V>> IsEqual(V expected) =>
                await Task.Run<IAssertBase<V>>(async () => await IsReturnValue((current) => Comparable.IsEqual(current, expected).Valid));

            public async Task<IAssertBase<V>> IsNull() =>
                await Task.Run<IAssertBase<V>>(async () => await IsReturnValue((current) => current == null));

            public async Task<IAssertBase<V>> IsNotNull() =>
                await Task.Run<IAssertBase<V>>(async () => await IsReturnValue((current) => current != null));

            private delegate bool Comperator(object current);
            private async Task<IAssertBase<V>> IsReturnValue(Comperator comperator)
            {
                while (true)
                {
                    var current = Instance.Call(MethodName, Args);
                    if (current is GDScriptFunctionState)
                    {
                        object[] result = await Instance.ToSignal(current as GDScriptFunctionState, "completed");
                        current = result[0];
                    }
                    if (comperator(current))
                        return (IAssertBase<V>)AssertThat<V>((V)current);
                }
            }
        }

        public static async Task AwaitSignal(this Godot.Node node, string signal, params object[]? expectedArgs)
        {
            while (true)
            {
                object[] signalArgs = await Engine.GetMainLoop().ToSignal(node, signal);
                if (expectedArgs?.Length == 0 || signalArgs.SequenceEqual(expectedArgs))
                    return;
            }
        }
    }
}

namespace GdUnit3.Core
{
    using Godot;
    using Executions;
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
            SceneTree = (SceneTree)Godot.Engine.GetMainLoop();
            CurrentScene = ((PackedScene)Godot.ResourceLoader.Load(resourcePath)).Instance();
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

        public async Task SimulateFrames(uint frames, uint deltaPeerFrame)
        {
            for (int frame = 0; frame < frames; frame++)
                await AwaitMillis(deltaPeerFrame);
        }

        public async Task SimulateFrames(uint frames)
        {
            var timeShiftFrames = Math.Max(1, frames / TimeFactor);
            for (int frame = 0; frame < timeShiftFrames; frame++)
                await AwaitIdleFrame();
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
            Script? sceneScript = (Script?)CurrentScene.GetScript();

            if (!(sceneScript is Script))
                return CurrentScene.Name;
            if (!CurrentScene.Name.BeginsWith("@"))
                return CurrentScene.Name;

            return sceneScript.ResourceName.BaseName();
        }

        public Node Scene() => CurrentScene;

        public GdUnitAwaiter.GodotMethodAwaiter<V> AwaitMethod<V>(string methodName) =>
            new GdUnitAwaiter.GodotMethodAwaiter<V>(CurrentScene, methodName);

        public async Task AwaitIdleFrame() => await Task.Run(() => SceneTree.ToSignal(SceneTree, "idle_frame"));

        public async Task AwaitMillis(uint timeMillis)
        {
            using (var tokenSource = new CancellationTokenSource())
            {
                await Task.Delay(System.TimeSpan.FromMilliseconds(timeMillis), tokenSource.Token);
            }
        }

        public async Task AwaitSignal(string signal, params object[] args) =>
            await GdUnitAwaiter.AwaitSignal(CurrentScene, signal, args);

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
            // we hide the scene/main window after runner is finished 
            OS.WindowMaximized = false;
            OS.WindowMinimized = true;
        }
    }
}
