# How to setup Elastic APM in .Net Core

- Add following package in your project. Or whatever version is latest.

  ```csharp
  <PackageReference Include="Elastic.Apm.NetCoreAll" Version="1.8.1" />
  ```

- Add Elastic APM to the application middleware by adding the following line inside configure method of ***Startup.cs*** file. Make sure this is first line in the method to get correct measurement of response time.

  ```csharp
  public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
  {
    app.UseAllElasticApm(Configuration);
  }
  ```

- Add following configuration in your ***appsettings.json*** file.

  ```json
  "ElasticApm": {
      "ServerUrl": "http://apm-server-svc-dev:8200",
      "Enabled": false,
      "ServiceName": "<Name of your application>",
      "TransactionSampleRate": 1.0,
      "Environment": "staging"
  }
  ```
  
- If your app is not ready for Elasticsearch you can still add all these but disable it by setting `Enabled = false` in your ***appsettings.json***.

- Reduce the log level of Elastic APM (Optional). Setup log settings as below in your  ***appsettings.json*** file's log section to control the log level of Elastic APM.

  ```json
  "MinimumLevel": {
    "Override": {
    "Elastic.Apm": "Warning"
    }
  }
  ```
  