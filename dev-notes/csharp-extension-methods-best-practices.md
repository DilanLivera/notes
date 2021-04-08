# C# extension methods best practices

## What

- Use sparingly
  - For multiple consumers
  - Otherwise stick to class methods
- Target specific types
  - Narrow the scope
  - Minimize risk of shadowing

## Where

- Separate assemblies
  - Logically group extensions
  - Minimize dependency graph
- Consider the namespace
  - Prefer custom namespaces
  - But target namespaces work too

## Who

- Sponsor class
  - Conventions help maintenance
  - Not seen by consumers
- Method name
  - Clear and explicit
  - Beware risk of shadowing

## How

- Minimize dependencies
  - Causes bloat for consumers
  - And versioning issues
- Document clearly
  - Pops in IntelliSense
  - XML summary as a minimum

## What you ***can*** and ***can not*** do

- Namespace defines scope. Consumers needs to have a reference to the library where the class is compiled and a using statement for your namespace.
- Namespace affects discoverability. You can use the target type's namespace or your own.
- Accessibility rules apply. Types must be accessible to the extension method library.

## Credits

- [C# Extension Methods](https://app.pluralsight.com/library/courses/c-sharp-extension-methods/)

## Resources

- [Extension Methods Best Practices (Extension Methods Part 6)](https://devblogs.microsoft.com/vbteam/extension-methods-best-practices-extension-methods-part-6/)