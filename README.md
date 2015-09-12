# PromptEd
Whether functional or purely pretty, a custom prompt is essential for any command line enthusiast.

PromptEd simplifies the process of prompt customization, offering a handful of builtin prompts, providing a straighforward means of creating new prompts, and making it easy to dynamically modify and switch between different prompts.  It also offers the ability to add "prompt tasks" - code which executes on every prompt drawing, unrelated to drawing the prompt UI itself.

# Quick Start
Grab the necessary files by cloning this repo:
```
git clone https://github.com/jimmehc/PromptEd.git
```

And import the PromptEd module:
```
Import-Module PromptEd\PromptEd.psm1
```
Use the `Get-BuiltinPromptNames` cmdlet to see what builtin prompts are currently available.  Use `Set-Prompt` to change your prompt and see what these look like.  If you find one you like, import PromptEd in your `$profile`, and add `Set-Prompt <Name>` below that.  To get your old prompt back, just unload the module.  If you'd like to further customize your prompt and learn more about what this module can do, read on!

# Customizing your Prompt
A PromptEd prompt consists of a list of "prompt elements", which are simply ScriptBlocks (or functions\*) which should output nothing to the pipeline, and use `Write-Host` to write to the screen, usually using `-NoNewLine`, and setting a foreground colour to a configured "prompt colour" (more on that later) with `-ForegroundColor`.

(\* Functions in PowerShell are just ScriptBlocks stored in the "function:" directory, which are easily callable from the shell.)

Set your prompt to a builtin, as is described above, and run `Get-PromptElements` to see the prompt elements of the current prompt.  A list of indices of the prompt elements' positions and their contents is displayed.

To remove a prompt element, simply run `Remove-PromptElement` with the index of the element you wish to remove.

To add a prompt element, run `Add-PromptElement` with an index and a prompt element ScriptBlock. A number of prompt elements are already defined by the module as functions, using the "pe\_" prefix as the convention for distinguishing them.  You can view them with a simple regex search:

```
dir function: | ?{ $\_.Name -match "^pe\_" }
```

If no index is specified, the element is added to the end.  If one is specified, the element is inserted before the element currently at that index.  For example, to insert the "pe\_BracketedTime" element at the start of your prompt (position 0):

```
Add-PromptElement $function:pe_BracketedTime 0
```

If you peek at the definitions of the builtin prompt elements, you'll see that they use `Write-Host` calls with `-ForeGroundColor` set to a "prompt colour".  Using the name of that color, you can use the `Set-PromptColor` cmdlet to dynamically change the color of the applicable part of that element.  e.g. This will change the whole pe\_BracketedTime to green:
```
Set-PromptColor Time Green
```

You can define new colours for use in custom prompts with the `Add-PromptColor` cmdlet, and retrieve them with `Get-PromptColor`.
