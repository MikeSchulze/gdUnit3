using System.Threading.Tasks;

namespace GdUnit3.Tests
{
    using GdUnit3.Asserts;
    using Executions;

    using static Assertions;

    [TestSuite]
    class SceneRunnerTest
    {

        [TestCase]
        public async Task RunScene()
        {

            SceneRunner runner = SceneRunner.Load("res://addons/gdUnit3/test/mocker/resources/scenes/TestScene.tscn");
            runner.ShowScene();
            runner.SimulateKeyPressed(Godot.KeyList.Enter);


            runner.SimulateMouseMove(Godot.Vector2.One);
            runner.Scene().Call("start_color_cycle");

            await runner.Scene().ToSignal(runner.Scene(), "panel_color_change");

            //await runner.DoWaitSignal("panel_color_change", runner.Scene()._Get("_box1"), Godot.Colors.Red);
            await runner.SimulateFrames(100);
        }
    }
}
