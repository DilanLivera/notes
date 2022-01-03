# C# Clean Coding Tips

## Principles

- The right tool for thr right job
  - Watch for boundaries
  - Stay native
  - One language per file
- High signal to noise ratio
  - Don't repeat yourself
  - Look for patterns
- Self-documenting
  - Clear intent
  - Layers of abstractions
  - Format for readability
  - Favor code over comments

## Naming

- Class naming guidelines
  - Noun
  - Be specific
  - Single responsibility
  - Avoid generic suffixes
- Avoid side effects. Eg.
  - CheckPassword shouldn't log users out
  - ValidateSubmission shouldn't save
  - GetUser shouldn't create their session
- Naming warning signs
  - And
  - If
  - Or
- Avoid abbreviations
- Booleans should sound true/false
- Strive for symmetry
- Verbalize when struggling

## Conditionals

- Compare booleans implicitly.
  - ❌

    ```C#
      if (loggedIn == true)
    ```

  - ✔

    ```C#
      if (loggedIn)
    ```

- Assign booleans implicitly.
  - ❌

    ```C#
      bool goingToChipotleForLunch;
      if (cashInWallet > 6.00)
      {
        goingToChipotleForLunch = true;
      }
      else
      {
        goingToChipotleForLunch = false;
      }
    ```

  - ✔

    ```C#
      bool goingToChipotleForLunch = cashInWallet > 6.00;
    ```

- Be positive
  - ❌

    ```C#
      if (!isNotLoggedIn)
    ```

  - ✔

    ```C#
      if (loggedIn)
    ```

- Ternary is beautiful
  - ❌

    ```C#
      int registrationFee;
      if (isSpeaker)
      {
        registrationFee = 0;
      } 
      else
      {
        registrationFee = 50;
      }
    ```

  - ✔

    ```C#
      int registrationFee = isSpeaker ? 0 : 50;
    ```

- Be strongly typed, Not **Stringly** typed
  - ❌

    ```C#
      if (employeeType == "manager")
    ```

  - ✔

    ```C#
      if (employee.type == EmployeeType.Manager)
    ```

- Magic numbers
  - ❌

    ```C#
      if (age > 21)
      {
        // body here
      }

      if (status == 2)
      {
        // body here
      }
    ```

  - ✔

    ```C#
      const int legalDrinkingAge = 21;
      if (age > legalDrinkingAge)
      {
        // body here
      }

      if (status == Status.active)
      {
        // body here
      }
    ```

- Complex conditionals
  - ❌

    ```C#
      if (employee.Age > 55 && 
          employee.YearsEmployed > 10 && 
          employee.IsRetired)
      {
        // body here
      }

      //Check for valid file extensions, confirm is admin or active
      if ((fileExt == ".mp4" || fileExt == ".mpg" || fileExt == ".avi")
          && (isAdmin || isActiveFile))
    ```

  - ✔
    1. Intermediate variables

        ```C#
          bool eligibleForPension = employee.Age > 55
            && employee.YearsEmployed > 10
            && employee.IsRetired;
        ```

    2. Encapsulte via function

        ```C#
          private bool ValidFileRequest(
            string fileExtension, 
            bool isActiveFile, 
            bool isAdmin)
          {
            return (fileExt == ".mp4" 
              || fileExt == ".mpg" 
              || fileExt == ".avi")
              && (isAdmin || isActiveFile))
          }

          //better way
          private bool ValidFileRequest(
            string fileExtension, 
            bool isActiveFile, 
            bool isAdmin)
          {
            var validFileExtensions = new List<string>() { "mp4", "mpg", "avi" };
            bool validFileType = validFileExtensions.Contains(fileExtension);
            bool userIsAllowedToViewFile = isActiveFile || isAdmin;
            
            return validFileType && userIsAllowedToViewFile;
          }    
        ```

- Favor polymorphism over switch
  - ❌

    ```C#
      public void LoginUser(User user)
      {
        switch (user.Status)
        {
          case Status.Active:
            // active user logic
            break;
          case Status.Inactive:
            // inactive user logic
            break;
          case Status.Locked:
            // locked user logic
            break;
        }
      }
    ```

  - ✔

    ```C#
      public void LoginUser(User user)
      {
        user.Login();
      }

      public abstract class User 
      {
        public string FirstName;
        public string LastName;
        public int Status;
        public int AccountBalance;

        public abstract void Login();
      }

      public class ActiveUser : User
      {
        public override void Login() 
        {
          //Active user logic here
        }
      }

      public class InactiveUser : User
      {
        public override void Login() 
        {
          //Inactive user logic here
        }
      }

      public class LockedUser : User
      {
        public override void Login() 
        {
          //Locked user logic here
        }
      }
    ```

    ***Note: We still need a switch statement in the factory class to create the correct user class***
- Be declarative
  - ❌

    ```C#
      List<User> matchingUsers = new List<User>();
      foreach (var user in users)
      {
        if (user.AccountBalance < minAccountBalance && 
            user.Status == Status.Active)
        {
          matchingUsers.Add(user);
        }
      }

      return matchingUsers;
    ```

  - ✔

    ```C#
      return users
        .Where(u => u.AccountBalance < minAccountBalance)
        .Where(u => u.Status == Status.Active);
    ```

- Table driven methods
  - ❌

    ```C#
      if (age < 20)
      {
        return 345.60m;
      }
      else if (age < 30)
      {
        return 419.50m;
      }
      else if (age < 40)
      {
        return 476.38m;
      }
      else if (age < 50)
      {
        return 516.25m;
      }
    ```

  - ✔
    | InsuranceRateId  |  MaximumAge  |  Rate  |
    |----------------- | ------------ | ------ |
    |        1         |      20      | 346.60 |
    |        2         |      30      | 420.50 |
    |        3         |      40      | 476.38 |
    |        4         |      50      | 516.25 |
  
    ```C#
      return Repository.GetInsuranceRate(age);
    ```

  - Great for dynamic logic
  - Avoids hard coding
  - Write less code
  - Avoids complex data structures
  - Make changes without a code deployment

## Methods

- When To Create a Function
  - Duplication
  - Indentation
  - Unclear intent
  - if > 1 task
- Look for Patterns
- Eliminate excessive Indentation (Arrow Code). Solutions for excessive indentation
  - Extract Method
    - Before

      ```C#
        if
          if
            while
              do some complicated thing
            end while
          end if
        end if
      ```

    - After

      ```C#
        if
          if
            DoComplicatedThing()
          end if
        end if

        DoComplicatedThing()
        {
          while
            do some complicated thing
          end while
        }
      ```

  - Fail Fast
    - ❌

      ```C#
        public void RegisterUser(string username, string password) 
        {
          if (!string.isNullOrWhitespace(username)) 
          {
            if (!string.isNullOrWhitespace(password)) 
            { 
              // register user
            } 
            else 
            {
              throw new ArgumentException("Username is required.");
            }
            
            throw new ArgumentException("Password is required.");
          }
        }
      ```

    - ✔

      ```C#
        public void RegisterUser(string username, string password) 
        {
          if (string.isNullOrWhitespace(username)) //Guard Clauses
          {
            throw new ArgumentException("Username is required.");
          }

          if (!string.isNullOrWhitespace(password)) //Guard Clauses
          { 
            throw new ArgumentException("Password is required.");
          }
          // register user
        }
      ```

  - Return Early
    - ❌

      ```C#
        private bool ValidUsername(string username)
        {
          bool isValid = false;
          const int MinUsernameLength = 6;
          if (username.Length >= MinUsernameLength)
          {
            const int MaxUsernameLength = 25;
            if (username.Length <= MaxUsernameLength)
            {
              bool isAlphaNumeric = username.All(Char.IsLetterOrDigit);
              if (isAlphaNumeric)
              {
                if (!ContainsCurseWords(username))
                {
                  isValid = IsUniqueUsername(username);
                }
              }
            }
          }
          
          return isValid;
        }
      ```

    - ✔

      ```C#
        private bool ValidUsername(string username)
        {
          const int MinUsernameLength = 6;
          if (username.Length < MinUsernameLength) return false;

          const int MaxUsernameLength = 25;
          if (username.Length > MaxUsernameLength) return false;

          bool isAlphaNumeric = username.All(Char.IsLetterOrDigit);
          if (!isAlphaNumeric) return false;

          if (ContainsCurseWords(username)) return false;

          return IsUniqueUsername(username); 
        }
      ```

- Do One Thing
  - Aids the reader
  - Promotes reuse
  - Eases naming and testing
  - Avoids side-effects
- Limit variable lifetime (Mayfly Variables)
  - Initialize variables just-in-time
  - Do one thing
- How Many Parameters?
  - ❌

    ```C#
      public void SaveUser(string firstName, string lastName, string state, string zip, string eyeColor, string phone, string fax, string maidenName, bool sendEmail, int emailFormat, bool printReport, bool sendBill)
    ```

  - ✔

    ```C#
      public void SaveUser(User user)
    ```

- Avoid Flag Arguments
  - ❌

    ```C#
      private void SaveUser(User user, bool emailUser)
      {
        //save user here, then…
        if (emailUser)
        {
          //email user
        }
      }
    ```

  - ✔

    ```C#
      private void SaveUser(User user)
      {
        //save user
      }

      private void EmailUser(User user)
      {
        //email user
      }
    ```

- Signs It’s Too Long
  - Whitespace & Comments
  - Scrolling required
  - Naming issues
  - Multiple conditionals
  - Hard to digest

  ***Note:***
  - ***Rarely be over 20 lines. Rarely over 3 parameters.***
  - ***Simple functions can be longer. Complex functions should be short.***

- Exception Types
  - Unrecoverable. Avoid catching unrecoverable exceptions.
    1. Null reference
    2. File not found
    3. Access denied
  - Recoverable
    1. Retry connection
    2. Try different file
    3. Wait and try again
  - Ignorable
    1. Logging click
- Try/Catch Body Standalone
  - ❌

    ```C#
      try
      {
        //many lines of complicated logic here
      } 
      catch(Exception exception)
      {
        //do something here
      }
    ```

  - ✔

    ```C#
      try
      {
        SaveThePlanet();
      }
      catch (Exception e)
      {
        //do something here
      }

      private void SaveThePlanet()
      {
        //many lines of complicated logic here
      }
    ```

## Classes

- When to create a class  
  - New concept - Abstract or real-world
  - Low cohesion - Methods should relate
  - Promote reuse - Small, targeted => reuse
  - Reduce complexity - Solve once, hide away
  - Clarify parameters - Identify a group of data
- Classes responsibilities should be strongly-related
  - Enhances readability
  - Increases likelihood of reuse
  - Avoids attracting the lazy
  - Watch for
    - Standalone methods
    - Fields used by only one method
    - Classes that change often
- Low vs High Cohesion
  - Low Cohesion
    - Edit vehicle options
    - Update pricing
    - Schedule maintenance
    - Send maintencance reminder
    - Select financing
    - Calculate monthly payment
  - High Cohesion
    - Vehicle
      - Edit vehicle options
      - Update pricing
    - VehicleMaintenance
      - Schedule maintenance
      - Send maintencance reminder
    - VehicleFinance
      - Select financing
      - Calculate monthly payment
  - Broad names lead to poor cohesion. Specific names lead to smaller more cohesive classes
- Signs of a too small class
  - Inappropriate intimacy
  - Feature envy
  - Too many pieces
- Primitive Obsession
  - ❌

    ```C#
      private void SaveUser(string firstName, string lastName, string state, string zip, string eyeColor, string phone, string fax, string maidenName)
    ```

  - ✔

    ```C#
      private void SaveUser(User user)
    ```

- Proximity Principle. Make code read top to bottom when possible. Keep related actions together

  ```C#
    private void ValidateRegistration()
    {
      ValidateData();

      if (!SpeakerMeetsOurRequirements())
      {
        throw new SpeakerDoesNotMeetRequirementsException();
      }

      ApproveSessions();
    }

    private void ValidateData()
    {
      if (string.IsNullOrEmpty(FirstName)) 
        throw new ArgumentNullException("First name is required");

      if (string.IsNullOrEmpty(LastName))
        throw new ArgumentNullException("Last name is required");

      if (string.IsNullOrEmpty(Email))
        throw new ArgumentNullException("Email is required");

      if (Sessions.Count() == 0) 
      throw new ArgumentNullException("Can't register speaker with no sessions to present");
    }

    private bool SpeakerMeetsOurRequirements()
    {
      return IsExceptionalOnPaper() || !ObviousRedFlags();
    }
  ```

- Outline rule
  - Multiple layers of abstraction
  - Should read like a high-level outline

    ```C#
      Class
        MethodOne
          MethodOneA
            MethodOneA_I
            MethodOneA_II
          MethodOneB
          MethodOneC
        MetodTwo
          MethodTwoA
          MethodTwoB
    ```

## Comments

- A necessity and a crutch
  - Prefer expressive code over comments
  - Use comments when code isn't sufficient
- Comments to avoid
  - Redundant
  
    ❌

    ```csharp
      int i = 1; // Set i = 1

      var cory = new User(); //Instantiate a new user
    
      /// <summary>
      /// Default Constructor
      /// </summary>
      public User()
      {
      }

      /// <summary>
      /// Calculates Total Charges
      /// </summary>
      private void CalculateTotalCharges()
      {
        //Total charges calculated here
      }
    ```

  - Intent
    - ❌

      ```csharp
        // Assure user’s account is deactivated.
        if (user.Status == 2)
      ```

    - ✔

      ```csharp
        if (user.Status == Status.Inactive)
      ```

    - Clarify intent without commnts
      - Improve function name
      - Declare intermediate variable
      - Declare a contant or enum
      - Ectract conditional to function
  - Apology
    - Don't appologize
    - Fix it before commit/merge
    - Add a `TODO` marker comment if you must
  - Warning
  - Zombie code (Code which is commented. Refactoring tools ignore these code bits which make them not upto date.)
    - Common causes
      - Risk aversion
      - Hoarding mentality
    - Optimize the signal to noise ratio
    - Ambiguity hinders debugging
      - What did this section do?
      - Was this accidentally commented?
      - Who did this?
      - Do I need to refactor this too?
      - How does my  change impact this code?
      - What if someone uncomments it later?
    - Add noize to searches
    - Code isn't **lost** anyway
    - Kill zombie code
    - About to comment out code? Ask:
      - When whould this be uncommented?
      - Can I just get it from source control later?
      - Is this incomplete work that should be worked via a branch?
      - Should this be toggled via configuration?
      - Did I refactor out the need for this code?
  - Divider

    ❌

    ```csharp
      private void MyLongFunction()
      {
        // lots
        // of
        // code
        // Start search for available concert tickets
        // lots
        // of
        // concert
        // search
        // code
        // End of concert ticket search
        // lots
        // more
        // code
      }
    ```

  - Brace tracker
    - ❌

      ```csharp
        private void AuthenticateUsers() 
        {
          bool validLogin = false;
          //deeply
          //nested
          //code
          if (validLogin)
          {
          // lots
          // of
          // code
          // here 
          } // end user login
          //even
          //more code
        }
      ```

    - ✔

      ```csharp
        private void AuthenticateUsers() 
        {
          bool validLogin = false;
          //deeply
          //nested
          //code
          if (validLogin)
          {
            LoginUser();
          }
          //even
          //more code
        }
      ```

  - Bloated header

    ```csharp
      //***************************************************
      // Filename: Monolith.cs                            *
      //                                                  *
      // Author: Cory House                               *
      // Created: 12/20/2019                              *
      // Weather that day: Patchy fog, then snow          *
      //                                                  *
      // Summary                                          *
      // This class does a great many things. To make it  *
      // extra useful I placed pretty much all the app    *
      // logic here. You wish your class was this         *
      // powerful. Bwahhahha!                             *
      //***************************************************
    ```

    - Avoid line endings
    - Don't repeat yourself
    - Follow conventions

  - Defect log

    ❌

    ```csharp
      // Defect #5274 DA 12/10/2010
      // We weren't checking for null here
      if (firstName != null)
      {
        //...
      }
    ```

    - Change metadata belongs in source control
    - A well written book isn't covered in author notes
- To Do comments

  ```csharp
    // TODO Refactor out duplication

    // HACK The API doesn't expose needed call yet.
  ```

  - Standardize
  - Watch out
    - May be an apology or warning comment in disguise
    - Often ignored
- Summary comments

  ```csharp
    // Encapsulates logic for calculating retiree benefits

    // Generates custom newsletter emails
  ```

  - Describes intent at general level higher than the code
  - Often useful to provide high level overview of classes
  - Rish : Don't use to simply augment poor naming/code level intent
- Documentation

  ```csharp
    // See microsoft.com/api for documentation
  ```

  - Useful when it can't be expressed in code

## Resources

- Steve McConnell - [stevemcconnell.com](https://stevemcconnell.com/)
- Robert C. Martin - [blog.cleancoder.com](https://blog.cleancoder.com/)
- Andrew Hunt David Thomas - [pragprog.com](https://pragprog.com/)
- Cory House - [Clean Coding Principles in C#](https://app.pluralsight.com/library/courses/csharp-clean-coding-principles/)
