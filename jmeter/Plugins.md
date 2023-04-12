## Plugins

The following is from the [JMeter - Getting Started by Esteban Herrera](https://www.pluralsight.com/courses/jmeter-getting-started) course.

- Plugins are distributed as JAR files.

- How to install plugins? There are two ways to install the plugins.

  - Place the plugin's JAR file in the **_JMeter-Home/lib/ext_** folder and restart JMeter(if it is running). JMeter automatically finds classes from the JAR files in the **_lib_** folder. The root **_lib_** folder in the JMeter installation folder is used for utility or dependency JAR files. The \*J**Meter-Home/lib/ext\*** folder is intended for JMeter components and plugins.
  - Use the JMeter plugins Manager. You can download the JMeter plugins manager from [JMeter-Plugins.org - JMeter Plugins Manager](https://jmeter-plugins.org/wiki/PluginsManager/). To install it, download the JAR file of the Plugins manager and place it in the **_JMeter-Home/lib/ext_** folder. You can find the Plugins manager under the **_Options_** menu or click on the Plugins manager icon in the toolbar. You can install or remove plugins by ☑ or un ☑ the plugin in the **_JMeter plugins manager's Installed Plugins_** or **_Available Plugins_** tab.

- Helpful plugins
  - [Custom thread groups](https://jmeter-plugins.org/wiki/ConcurrencyThreadGroup/)
  - [3 basic graphs](https://jmeter-plugins.org/wiki/ResponseTimesOverTime/)
  - [Throughput shaping timer](https://jmeter-plugins.org/wiki/ThroughputShapingTimer/)
  - [Dummy sampler](https://jmeter-plugins.org/wiki/DummySampler/)
