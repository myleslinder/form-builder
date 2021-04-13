@RestResource(urlMapping='/form/*')
global without sharing class FormEndpoint {
  private final static Map<String, String> htmlContainer {
    get {
      return new Map<String, String>{
        'open' => '<html><body style="font-family: Helvetica;background: #eee;display: flex;align-items: center;justify-content: center;"><div style="padding: 80px;background: #fff;border: 1px solid #ccc;border-radius: 8px;border-top: 5px solid #345beb;">',
        'close' => '</div></body></html>'
      };
    }
  }

  @HttpGet
  global static void handleFormSubmit() {
    RestRequest request = RestContext.request;
    RestResponse response = RestContext.response;
    Map<String, String> params = request.params;

    String formId = request.requestURI.substring(
      request.requestURI.lastIndexOf('/') + 1
    );
    response.addHeader('Content-Type', 'text/html');
    response.statusCode = 200;
    if (formId == null) {
      response.responseBody = Blob.valueOf(
        htmlContainer.get('open') +
        '<h1>Please provide a Form Send Id</h1>' +
        htmlContainer.get('close')
      );
      return;
    }
    Email_Form_Send__c targetSend = [
      SELECT
        Id,
        Recipient_Email__c,
        Target_Record_Id__c,
        Email_Form__c,
        Sent_HTML__c
      FROM Email_Form_Send__c
      WHERE Id = :formId
    ];
    if (params.get('formId') == null) {
      response.responseBody = Blob.valueOf(targetSend.Sent_HTML__c);
      return;
    }
    Email_Form__c targetForm = [
      SELECT
        Id,
        Email_Template_Metadata_Id__c,
        Form_HTML__c,
        Form_JSON__c,
        Intro_Text__c,
        Object_API_Name__c,
        Outro_Text__c,
        Recipient_Email_Field__c,
        Recipient_Name_Field__c,
        Type__c,
        Success_Message__c
      FROM Email_Form__c
      WHERE Id = :targetSend.Email_Form__c
    ];
    Boolean isCreate = targetForm.Type__c == 'Create';
    String objectApiName = params.get('objectApiName');
    List<String> privateFields = new List<String>{
      'recordId',
      'formId',
      'objectApiName'
    };
    try {
      Map<String, String> recordValues = new Map<String, String>();
      for (String fieldName : params.keySet()) {
        if (!privateFields.contains(fieldName)) {
          recordValues.put(fieldName, params.get(fieldName));
        }
      }
      if (isCreate) {
        handleCreateForm(objectApiName, recordValues);
      } else {
        handleUpdateForm(
          objectApiName,
          recordValues,
          targetSend.Target_Record_Id__c
        );
      }
    } catch (Exception e) {
      response.responseBody = Blob.valueOf(
        htmlContainer.get('open') +
        '<h1>Looks like something went wrong!</h1><p>We are aware of the problem and will be looking into it.</p>' +
        htmlContainer.get('close')
      );
      return;
    }
    String successMessage = targetForm.Success_Message__c != null
      ? targetForm.Success_Message__c
      : '<h1>Thanks for your submission</h1>';
    response.responseBody = Blob.valueOf(
      htmlContainer.get('open') +
      successMessage +
      htmlContainer.get('close')
    );

    return;
  }

  private static void handleUpdateForm(
    String objectApiName,
    Map<String, String> recordValues,
    String recordId
  ) {
    List<String> fields = new List<String>();
    fields.addAll(recordValues.keySet());
    String queryString =
      'SELECT ' +
      String.join(fields, ',') +
      ' FROM ' +
      objectApiName +
      ' WHERE Id = \'' +
      recordId +
      '\'';
    SObject sObj = Database.query(queryString).get(0);
    for (String fieldName : recordValues.keySet()) {
      sObj = typeCaster(recordValues.get(fieldName), fieldName, sObj);
    }

    update sObj;
  }

  private static void handleCreateForm(
    String objectApiName,
    Map<String, String> recordValues
  ) {
    sObject sObj = Schema.getGlobalDescribe().get(objectApiName).newSObject();

    for (String fieldName : recordValues.keySet()) {
      sObj = typeCaster(recordValues.get(fieldName), fieldName, sObj);
    }

    insert sObj;
  }

  // need to figure out
  // MultiPicklist
  // Time
  // Reference
  private static SObject typeCaster(
    String value,
    String fieldName,
    SObject obj
  ) {
    Schema.DisplayType targetDataTypeEnum = obj.getSObjectType()
      .getDescribe()
      .fields.getMap()
      .get(fieldName)
      .getDescribe()
      .getType();
    String targetDataType = targetDataTypeEnum.name();
    if (
      targetDataType == 'String' ||
      targetDataType == 'address' ||
      targetDataType == 'anytype' ||
      targetDataType == 'ComboBox' ||
      targetDataType == 'Email' ||
      targetDataType == 'Phone' ||
      targetDataType == 'TextArea' ||
      targetDataType == 'URL' ||
      targetDataType == 'Picklist'
    ) {
      obj.put(fieldName, value);
    } else if (targetDataType == 'Integer') {
      obj.put(fieldName, Integer.valueOf(value));
    } else if (
      targetDataType == 'Double' ||
      targetDataType == 'Currency' ||
      targetDataType == 'Percent'
    ) {
      obj.put(fieldName, Double.valueOf(value));
    } else if (targetDataType == 'Boolean') {
      obj.put(fieldName, Boolean.valueOf(value));
    } else if (targetDataType == 'Date') {
      obj.put(fieldName, Date.valueOf(value));
    } else if (targetDataType == 'DateTime') {
      obj.put(fieldName, Datetime.valueOf(value));
    } else if (targetDataType == 'Long') {
      obj.put(fieldName, Long.valueOf(value));
    }
    return obj;
  }
}
