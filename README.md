# PromptEd
![](http://i.imgur.com/MhDVchm.gif)

PromptEd simplifies the process of prompt customization for PowerShell, offering a handful of builtin prompts, providing a straighforward means of creating new prompts, and making it easy to dynamically modify and switch between different prompts.  It also offers the ability to add "prompt tasks" - code which executes on every prompt drawing, unrelated to drawing the prompt UI itself.

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
A PromptEd prompt consists of a list of "prompt elements", which are simply ScriptBlocks (or functions\*) which should output nothing to the pipeline, and use `Write-Host` to write to the screen, usually using `-NoNewLine`, and setting a foreground colour to a configured "prompt colour" (more on that later) with `-ForegroundColor`.  They can be anything from printing "username@computername", the current path, current directory, the time etc.

(\* Functions in PowerShell are just ScriptBlocks stored in the "function:" directory, which are easily callable from the shell.)

## Adding/Removing Prompt Elements
Set your prompt to a builtin, as is described above, and run `Get-PromptElements` to see the prompt elements of the current prompt.  A list of indices of the prompt elements' positions and their contents is displayed.

To remove a prompt element, simply run `Remove-PromptElement` with the index of the element you wish to remove.

To add a prompt element, run `Add-PromptElement` with an index and a prompt element ScriptBlock. A number of prompt elements are already defined by the module as functions, using the "pe\_" prefix as the convention for distinguishing them.  You can view them with a simple regex search:

```
dir function: | ?{ $_.Name -match "^pe_" }
```

If no index is specified, the element is added to the end.  If one is specified, the element is inserted before the element currently at that index.  For example, to insert the "pe\_BracketedTime" element at the start of your prompt (position 0):

```
Add-PromptElement $function:pe_BracketedTime 0
```

## Prompt Colours
If you peek at the definitions of the builtin prompt elements, you'll see that they use `Write-Host` calls with `-ForeGroundColor` set to a "prompt colour".  Using the name of that colour, you can use the `Set-PromptColor` cmdlet to dynamically change the colour of the applicable part of that element.  e.g. This will change the whole pe\_BracketedTime to green:
```
Set-PromptColor Time Green
```

You can define new colours for use in custom prompts with the `Add-PromptColor` cmdlet, and retrieve them with `Get-PromptColor`.

## Custom Prompt Elements
You needn't just use the few prompt elements which come with PromptEd, you can create custom ones too.

Firstly, decide upon, or create a new, prompt colour for your element.  You should try to reuse the relevant colour if writing a variant on an element which already exists (i.e. elements displaying the path should use the "Path" color, or the "Time" color for the time.
```
Add-PromptColor HelloWorld Red
```

Now, you can just add a ScriptBlock to your prompt inline, like this:
```
Add-PromptElement { Write-Host "[HelloWorld]" -ForegroundColor (Get-PromptColor HelloWorld) -NoNewLine }
```

However, I recommend creating a "pe\_\*", function and using that:
```
function pe_HelloWorld { Write-Host "[HelloWorld]" -ForegroundColor (Get-PromptColor HelloWorld) -NoNewLine }
Add-PromptElement $function:pe_HelloWorld
```

## Adding a Builtin Prompt
Once you've decided upon what you'd like your prompt to look like, and created the necessary prompt colours and elements, you can then register it as a builtin prompt, and switch to it with `Set-Prompt`.  The `Add-BuiltinPrompt` cmdlet takes a name, and an ordered array of elements like this:
```
Add-BuiltinPrompt HelloWorldPrompt @($function:pe_HelloWorld, $function:pe_FullPath, $function:pe_NoSeparator, $function:pe_GreaterThan)
```

### pe\_NoSeparator
Prompt elements are usually separated with a space.  pe\_NoSeparator is a special prompt element which writes nothing, but which instructs PromptEd not to insert this space between elements.  

# Prompt Tasks
As one's PowerShell prompt is defined via a function, it is possible to add other code to it, which is unrelated to the actual prompt writing.  Prompt Tasks are PromptEd's means of letting you do this, independent of whatever prompt is being drawn.

A Prompt Tasks are simply functions which execute prior to prompt writing. `Add-PromptTask` can be used to add one, and they are executed in the order in which they are added.  Prompt Tasks have names, and can be removed by passing that name to `Remove-PromptTask`.

A simple example would be a task which updates the console's window title with the current path:
```
Add-PromptTask WindowTitlePath {           
    $host.UI.RawUI.WindowTitle = $pwd.Path 
}                                          
```

Prompt Tasks can also be used to modify the current prompt elements.  A common inclusion in prompts is code to change a prompt's colour to red on a non-zero exit code.  The following is a simple example of how this could be done with a Prompt Task (pinging a non-existent host returns a non-zero code, whereas a successful one returns 0).  Notice how the prompt can be changed without affecting how the task works:

![](http://i.imgur.com/fvsYTTl.png)

Another example might be to add a prompt element indicating the number of passed and failed tests, when one cds to a directory in which tests are run from (in this instance "RunTests" populates environment variables with the number of passed and failed tests):

![](http://i.imgur.com/9B8isIs.png)

# For Module Writers
Adding information to users' prompts is often useful in modules.  Unfortunately, this is usually done by trashing a user's current prompt, requiring that user to perform manual edits to retain both the module's additions and their own customizations.  

By using PromptEd, a module could simply add a new prompt element to users' prompts on load.  Making dynamic modifications in response to how the module is used is also made much simpler.

# Contributing
Contributions are very welcome.  A really simple way to contribute is to simply add more builtin prompts and/or utility functions to BuiltInPrompts.ps1, as there are not many right now.  Deeper design modifications and ideas are also very welcome, as there are definitely many areas for improvement.
