## Configuration elements rules

The following is from the [JMeter - Getting Started by Esteban Herrera](https://www.pluralsight.com/courses/jmeter-getting-started) course.

- The **_User Defined Variables_** configuration element is processed at the start of a test, no matter where it is placed.

- A **_Configuration Element_** inside a tree brach has higher precedence than another element of the same type in a outer branch.

  - Configuration default elements are merged, Managers are not(They are replaced by elements with high precedence).

- Elements are rearranged according to the order of execution.

- Outer elements are executed before inner elements of the same type.

- Some elements(such as **_Assertions_** and **_Timers_**) are executed before or after each sampler in their scope.
  - If there is more than one element of the same type in the scope, all of them will be processed before(in the case of **_Timers_**) or after(in the case of **_Assertions_**) the sampler.
