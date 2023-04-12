## Configuring a Test Plan

The following is from the [JMeter - Getting Started by Esteban Herrera](https://www.pluralsight.com/courses/jmeter-getting-started) course.

![[components_of_a_test_script.png]]

- **_setUp_** thread group is used to perform actions before JMeter start executing a regular thread group. **_tearDown_** thread group is run after the test has finished.

- Generally, **_Configuration Elements_** is used to set up default configurations, and variables for later use by other components. You can place **_Configuration Elements_** under any component and classify them into four types.

  - Elements that allow us to define variables (CSV Data Set Config, Counter or Random Variable)
  - Elements that allow us to define a configuration (JDBC Connection Configuration, Keystore Configuration or Login Config Element).
  - Managers that allow us to manage configuration parameters (HTTP Header Manager, HTTP Cookie Manager or HTTP Cache Manager).
  - Default configuration elements allow us to define the fill configurations for request types (HTTP Request Defaults, FTP Request Defaults, or Java Requests Defaults).

- **_Controllers_** are the children of the thread group.

- **_Logic Controllers_** - Let you customize the logic to decide when to send requests (e.g. when a condition becomes true).

- **_Samplers_** - Perform a request, generating one or more results.

- **_Timers_** allows you to introduce a delay between requests. Specifically, timers will introduce a delay before each sampler in their scope, simulating the time the user takes to perform an action on a web page and avoid overwhelming the server with an unrealistic load. **_Timers_** can be added at any level of the tree. **_Timers_** are only processed in conjunction with a sampler. If there are no samplers in the scope of a timer, they will not be executed.

💡 _JMeter executes requests in sequence and without pauses._

- **_Assertions_** allow you to validate a response is as expected. **_Assertions_** can be added at the **_Thread Group_**, **_Controller_** or **_Sampler_** level, and they will apply to all the samplers in their scope.

💡 **_Assertions_** like XPath, XML or HTML consumes a lot of resources.

💡 If a **_Sub-sample_** assertion fails and the **_Main sample_** is successful, the main sample will be set to a failed status.

- JMeter collects information about the request it performs. _**Listeners**_ provide access to that information by listening to responses and aggregating metrics.

💡 **_Listeners_** can be added at any level. However, they will collect information only from the elements at or below their level.

💡 All **_Listeners_** save the same data. The only difference is the way the data is presented.

💡 **_Listeners_** can use a lot of memory.

- Components or elements of a **_Test Plan_** can be classified into two categories.

  - Ordered - **_Controllers_** and **_Samplers_**
  - Hierarchical (scoped) - Everything else (**_Configuration Elements_**, **_Assertions_**, **_Timers_** etc.)

- JMeter executes the elements of a **_Test Plan_** in the following order,

    ![[execution_order_of_elements_in_a_test_plan.png]]

💡 The last three are not executed if there is no server response. And **_Timers_**, **_Assertions_**, **_Pre_** and **_Post-processors_** are only executed if there is a sampler to which they can be applied.
