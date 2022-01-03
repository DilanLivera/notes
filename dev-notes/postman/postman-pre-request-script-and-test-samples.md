# Postman Pre-Request Scripts and Test Samples

## Pre-Request Scripts

- Check request header values exists

  ```javascript
  const requiredHeaders = new Set(['X-Transaction-ID', 'X-Session-ID', 'X-Device-ID','X-User-ID']);
  let missingHeaders = [];

  requiredHeaders.forEach((header) => {
      let value = pm.request.headers.get(header);

      if(!value)
      {
          missingHeaders.push(header);
      }
  });

  if(missingHeaders.length > 0)
  {
      throw Error("Missing reuired header/s : " + missingHeaders.toString());
  }
  ```

## Tests

- Status code

  ```javascript
  pm.test("Status code is 404", function () {
      pm.response.to.have.status(404);
  });
  ```

- Response type

  ```javascript
  pm.test("Response type is JSON", function () {
      const contentType = pm.response.headers.get('Content-Type');
      pm.expect(contentType).to.include('application/json');
  });
  ```

- Correct response

  ```javascript
  pm.test("JSON Response is correct", function () {
      const expectedResponse = {};
      const response = pm.response.json();
      pm.expect(response).to.eql(expectedResponse);
  });
  ```

## Resources

- [Postman - Getting Started](https://learning.postman.com/docs/getting-started/introduction/)
- [Postman Quick Reference Guide](https://postman-quick-reference-guide.readthedocs.io/en/latest/index.html)