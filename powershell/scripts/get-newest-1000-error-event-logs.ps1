#Get newest 1000 error event logs
Cls
Get-EventLog System -EntryType Error -Newest 1000