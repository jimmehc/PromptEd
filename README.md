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
Use the `Get-BuiltinPromptNames` cmdlet to see what builtin prompts are currently available.  Use `Set-Prompt` to change your prompt and see what these look like.  If you find one you like, import PromptEd in your $profile, and add `Set-Prompt <Name>` below that.  If you'd like to further customize your prompt and learn more about what this module can do, read on!

