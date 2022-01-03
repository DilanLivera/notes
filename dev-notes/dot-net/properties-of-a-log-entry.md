# Properties of a Log entry

| Field                | Description                                                       | Sample                                                          |
| -------------------- | ----------------------------------------------------------------- | --------------------------------------------------------------- |
| Timestamp            | Time of the log entry                                             |                                                                 |
| Level                | Level of the entry                                                | Error, Warning, etc.                                            |
| MessageTemplate      | Entry with replaceable placeholders                               | {UserId} did {ActivityName}                                     |
| Message              | Entry with replacements made                                      | 123 did Book Submission                                         |
| SourceContext        | Category for the log entry                                        | BookClub.API.Controllers.BookController                         |
| ActionId             | Identifier for the Action (spans requests)                        | 4348b30c-93de-48e8-8eec-2b680c0311de                            |
| ActionName           | Fully-qualified namespace/class/method for action                 | BookClub.API.Controllers.BookController.GetBooks (BookClub.API) |
| RequestId            | Unique id for the request                                         | 80000017-0002-f700-b63f-84710c7967bb                            |
| RequestPath          | Local path for the request                                        | /api/Book                                                       |
| CorrelationId        | Something like session id to track user activity within a session |                                                                 |
| <replacement values> | Replacement values for MessageTemplate                            |                                                                 |
| Exception            | ToString() representation                                         |                                                                 |

### What’s Missing?

- Machine name
- Environment
- User Id
- Role(s)
- Entry Assembly
- Version
- Customer Id
- HttpContext
- Include what’s important to YOU

💡 _Include what is important to you in the log entry(Think about what will assist you in troubleshooting/analyze an issue). Don't log what you don't need. It can be expensive._

## Credits

[Effective Logging in ASP.NET Core by Erik Dahl](https://www.pluralsight.com/courses/asp-dotnet-core-effective-logging)

#logging
