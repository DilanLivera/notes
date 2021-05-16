# Call clients outside of hubs in SignalR

This can be done by using an `IHubContext<THub>`.

```csharp
public class VoteManager : IVoteManager
{
    private readonly IHubContext<VoteHub> _hubContext;
    public Dictionary<string, int> _votes;

    public VoteManager(IHubContext<VoteHub> hubContext)
    {
        _votes = new Dictionary<string, int>();
        _hubContext = hubContext;
    }

    public async Task CastVoteAsync(string voteFor)
    {
        _votes[voteFor]++;

        await _hubContext.Clients.All.SendAsync("updateVotes", _votes);
    }

    public Dictionary<string, int> GetCurrentVotes()
    {
        return _votes;
    }
}
```
