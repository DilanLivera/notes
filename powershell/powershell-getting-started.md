# PowerShell - Getting Started

## Tips 💡

- `Cmdlets: Verb-Noun`

- Native commands work (`Ping`, `IPConfig`, `calc`, `notepad`, `cls`, `ls, dir`)

- Figure things out using the help system. First make sure your help is up to date by running `Update-Help -force` cmdlet. Then run `Get-Help <command-name>` or `help <command-name>` or `man <command-name>` to search for your cmdlet. You can use wildcards to help you with search(eg. `help *service*` or `help g*service*`). If you need more details(eg. parameter description) use the `-Detailed` parameter (eg. `Get-Help <command-name> -Detailed`) or `-full` parameter (eg. `Get-Help <command-name> -full`).

- Use `|` character to connect cmdlets(eg. `Get-Service | Select-Object name, status | Sort-Object name`). Cmdlets can be broken into several lines to increase readability.

## Resources

- [Microsoft Docs: PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
- [Youtube: PowerShell For Beginners Full Course | PowerShell Beginner tutorial Full Course](https://www.youtube.com/watch?v=UVUd9_k9C6A)

## Tags

#powershell
