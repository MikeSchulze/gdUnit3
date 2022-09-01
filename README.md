
<h1 align="center">GdUnit3 <img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/MikeSchulze/gdunit3" width="12%"> </h1>
<h2 align="center">A Godot Embedded Unit Testing Framework</h2>

<p align="center">
  <img src="https://img.shields.io/badge/Godot-v3.3.3-%23478cbf?logo=godot-engine&logoColor=cyian&color=brightgreen">
  <img src="https://img.shields.io/badge/Godot-v3.3.4-%23478cbf?logo=godot-engine&logoColor=cyian&color=brightgreen">
  <img src="https://img.shields.io/badge/Godot-v3.4.1-%23478cbf?logo=godot-engine&logoColor=cyian&color=brightgreen">
  <img src="https://img.shields.io/badge/Godot-v3.4.2-%23478cbf?logo=godot-engine&logoColor=cyian&color=brightgreen">
  <img src="https://img.shields.io/badge/Godot-v3.4.4-%23478cbf?logo=godot-engine&logoColor=cyian&color=brightgreen">
  <img src="https://img.shields.io/badge/Godot-v3.4.5-%23478cbf?logo=godot-engine&logoColor=cyian&color=brightgreen">
  <img src="https://img.shields.io/badge/Godot-v3.5-%23478cbf?logo=godot-engine&logoColor=cyian&color=brightgreen">
  <img src="https://img.shields.io/badge/Godot-v4.x.x-%23478cbf?logo=godot-engine&logoColor=cyian&color=red">
</p>

<p align="center"><a href="https://github.com/MikeSchulze/gdUnit3"><img src="https://github.com/MikeSchulze/gdUnit3/blob/master/assets/gdUnit3-animated.gif" width="100%"/></p><br/>


<p align="center">
  <img alt="GitHub branch checks state" src="https://img.shields.io/github/checks-status/MikeSchulze/gdunit3/master"></br>
  <img src="https://github.com/MikeSchulze/gdUnit3/actions/workflows/selftest-3.3.x.yml/badge.svg?branch=master"></br>
  <img src="https://github.com/MikeSchulze/gdUnit3/actions/workflows/selftest-3.4.x.yml/badge.svg?branch=master"></br>
  <img src="https://github.com/MikeSchulze/gdUnit3/actions/workflows/selftest-3.5.x.yml/badge.svg?branch=master"></br>
  <img src="https://github.com/MikeSchulze/gdUnit3/actions/workflows/selftest-3.3.x-mono.yml/badge.svg?branch=master"></br>
</p>



## What is GdUnit3
GdUnit3 is a framework for testing Gd-Scrips/C# and Scenes within the Godot editor. GdUnit3 is very useful for test-driven development and will help you get your code bug-free.
 
 
## Features
* Fully embedded in the Godot editor
* Run test-suite(s) by using the context menu on FileSystem, ScriptEditor or GdUnitInspector
* Create tests directly from the ScriptEditor
* Configurable template for the creation of a new test-suite
* A spacious set of Asserts use to verify your code
* Argument matchers to verify the behavior of a function call by a specified argument type.
* Fluent syntax support
* Test Fuzzing support
* Mocking a class to simulate the implementation in which you define the output of the certain function
* Spy on an instance to verify that a function has been called with certain parameters.
* Mock or Spy on a Scene 
* Provides a scene runner to simulate interactions on a scene 
  * Simulate by Input events like mouse and/or keyboard
  * Simulate scene processing by a certain number of frames
  * Simulate scene processing by waiting for a specific signal
* Update Notifier to install the latest version from GitHub
* Command Line Tool
* CI - Continuous Integration support
  * generates HTML report
  * generates JUnit report 
* With v2.0.0 C# testing support (beta)
* Visual Studio Code extension
---

 
## Short Example
 ```
 # this assertion succeeds
assert_int(13).is_not_negative()

# this assertion fails because the value '-13' is negative
assert_int(-13).is_not_negative()
 ```
 
 ---

## Documentation
<p align="left" style="font-family: Bedrock; font-size:21pt; color:#7253ed; font-style:bold">
  <a href="https://mikeschulze.github.io/gdUnit3/first_steps/install/">How to Install GdUnit</a>
</p>

<p align="left" style="font-family: Bedrock; font-size:21pt; color:#7253ed; font-style:bold">
  <a href="https://mikeschulze.github.io/gdUnit3/">API Documentation</a>
</p>



---

### You are welcome to:
  * [Give Feedback](https://github.com/MikeSchulze/gdUnit3/discussions/228)
  * [Suggest Improvements](https://github.com/MikeSchulze/gdUnit3/issues/new?assignees=MikeSchulze&labels=enhancement&template=feature_request.md&title=)
  * [Report Bugs](https://github.com/MikeSchulze/gdUnit3/issues/new?assignees=MikeSchulze&labels=bug%2C+task&template=bug_report.md&title=)



<h1 align="center"></h1>
<p align="left">
  <img alt="GitHub issues" src="https://img.shields.io/github/issues/MikeSchulze/gdunit3">
  <img alt="GitHub closed issues" src="https://img.shields.io/github/issues-closed-raw/MikeSchulze/gdunit3"></br>
  <!-- <img src="https://img.shields.io/packagecontrol/dm/SwitchDictionary.svg">
  <img src="https://img.shields.io/packagecontrol/dt/SwitchDictionary.svg">
   -->
  <img alt="GitHub top language" src="https://img.shields.io/github/languages/top/MikeSchulze/gdunit3">
  <img alt="GitHub code size in bytes" src="https://img.shields.io/github/languages/code-size/MikeSchulze/gdunit3">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg">
</p>

<p align="left">
  <a href="https://discord.gg/rdq36JwuaJ"><img src="https://discordapp.com/api/guilds/885149082119733269/widget.png?style=banner4" alt="Join GdUnit3 Server"/></a>
</p>

### Thank you for supporting my project!
---
## Sponsors:
[<img src="https://github.com/musicm122.png" alt="musicm122" width="125"/>](https://github.com/musicm122)



