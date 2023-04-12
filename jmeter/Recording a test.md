## Recording a Test

The following is from the [JMeter - Getting Started by Esteban Herrera](https://www.pluralsight.com/courses/jmeter-getting-started) course.

To be able to record a HTTPS application, you have to use JMeter's SSL certificate. It is generated when you start the test script recorder and placed in the **_JMeter_Home/bin_** folder(**_JMeter_Home/bin/ApacheJMeterTemporaryRootCA.cert_**).

By default, the certificate is valid for 7 days. You can change the duration by setting the `proxy.cert.validity` property in the **_JMeter_Home/bin/jmeter.properties_** file. You will need to import the certificate to your browser as a Certificate Authority to record the requests.

### Tips for recoding a test

-   Use of the recording templates
-   Apply a naming policy
-   Plan how to manage static resources

💡 _In a real world performance test, it is recommended to run JMeter and the application under test in separate machines._

💡 Use the GUI mode to create the test and CLI mode to run the test.

💡 _Before running the test in command line, it is recommended to disable all listeners. Also, in **Transaction Controllers**, it is recommended to uncheck the **Generate parent sample** option to get the most accurate results._

💡 **\*APDEX** (Application Performance Index) measures user's satisfaction by taking into account the response time of the application.\*

💡 _JMeter use properties to customize the HTML report generated for a test file. All these properties can be found in the **JMeter_Home/bin/reportgenerator.properties** file. It is recommended to copy the properties you like to customize to the **JMeter_Home/bin/user.properties** file and modify them._

