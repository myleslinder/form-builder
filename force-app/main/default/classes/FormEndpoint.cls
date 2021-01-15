@RestResource(urlMapping='/form/*')
global without sharing class FormEndpoint {
  @HttpGet
  global static void handleFormSubmit() {
    RestRequest request = RestContext.request;
    RestResponse response = RestContext.response;
    Map<String, String> params = request.params;

    String render = request.requestURI.substring(
      request.requestURI.lastIndexOf('/') + 1
    );
    if (render != null) {
      response.addHeader('Content-Type', 'text/html');
      response.statusCode = 200;
      response.responseBody = Blob.valueOf(
        '<html><body><h1>Myles dope site</h1></body></html>'
      );
      return;
    }

    String recordId = params.get('recordId');
    String objectApiName = params.get('objectApiName');
    String fields = '';
    String queryString;
    try {
      for (String fieldName : params.keySet()) {
        if (fieldName != 'recordId' && fieldName != 'objectApiName') {
          fields += ', ';
          fields += fieldName;
        }
      }
      queryString =
        'SELECT Id' +
        fields +
        ' FROM ' +
        objectApiName +
        ' WHERE Id = \'' +
        recordId +
        '\'';
      SObject obj = Database.query(queryString).get(0);
      Map<String, Object> results = new Map<String, Object>();
      results.put(
        'meta',
        new Map<String, Object>{
          'Id' => recordId,
          'objectName' => objectApiName
        }
      );

      for (String fieldName : params.keySet()) {
        if (
          fieldName != 'recordId' &&
          fieldName != 'objectApiName' &&
          obj.get(fieldName) != null &&
          params.get(fieldName) != null
        ) {
          results.put(
            fieldName,
            new Map<String, Object>{
              'new' => obj.get(fieldName),
              'old' => params.get(fieldName)
            }
          );
        }
      }
    } catch (Exception e) {
      return;
      // return 'Exception' +
      //   e.getMessage() +
      //   'Object Api Name: ' +
      //   objectApiName +
      //   ' |||| Record Id' +
      //   recordId +
      //   ' |||| Query String: ' +
      //   queryString;
    }
    //for(String param : params){}

    return;
  }

  //String formId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
}
