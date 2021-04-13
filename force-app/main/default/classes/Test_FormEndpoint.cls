@IsTest
public inherited sharing class Test_FormEndpoint {
  @IsTest
  static void itHandlesUpdateForm() {
    Test.startTest();
    Lead lead = new Lead(
      FirstName = 'Myles',
      Email = 'myles@emergencelabs.io',
      LastName = 'Lead',
      Company = 'Company',
      Description = 'hi there'
    );
    insert lead;
    Email_Form__c form = new Email_Form__c(
      Email_Template_Metadata_Id__c = 'm001k000000BP8A',
      Form_HTML__c = '<form action="{{FORM_ACTION}}" method="get" style=width:100%;text-align:left;margin-top: 10px;><input type="hidden" value="Lead" name="objectApiName"/><input type="hidden" value="{{FORM_ID}}" name="formId"/><button type="submit" style="font-family: Helvetica;box-sizing:border-box;width: 100%;display: blockbackground-color: #345beb;border: none;padding: 10px;color: #fff;font-size: 15px;border-radius: 6px;margin-bottom: 10px;">Submit</button></form>',
      Form_JSON__c = '{"introFields":["Name"],"outroFields":["Description"],"selectedFields":["Status"]}',
      Intro_Text__c = '{{Name}}',
      Object_API_Name__c = 'Lead',
      Outro_Text__c = '{{Description}}',
      Type__c = 'Update',
      Recipient_Email_Field__c = 'Email',
      Recipient_Name_Field__c = 'FirstName'
    );
    insert form;
    FormAPI.EmailSendParams params = new FormAPI.EmailSendParams();
    params.siteUrl = 'https://www.example.com';
    params.formId = form.Id;
    params.recordId = lead.Id;
    params.senderEmailAddress = 'myles@emergencelabs.io';
    params.senderName = 'Myles';
    params.recipientEmailAddress = 'test@example.com';
    params.recipientName = 'Example Name';
    FormAPI.sendEmail(new List<FormAPI.EmailSendParams>{ params });

    Email_Form_Send__c formSend = [SELECT Id FROM Email_Form_Send__c];

    RestRequest request = new RestRequest();
    RestResponse response = new RestResponse();

    request.requestUri =
      'https://cipdev-endpoints.cs195.force.com/services/apexrest/form/' +
      formSend.Id;
    request.httpMethod = 'GET';
    request.addParameter('formId', formSend.Id);
    request.addParameter('objectApiName', 'Lead');
    request.addParameter('recordId', lead.Id);
    request.addParameter('Description', 'hello');
    RestContext.request = request;
    RestContext.response = response;
    FormEndpoint.handleFormSubmit();

    Test.stopTest();
  }

  @IsTest
  static void itHandlesCreateForm() {
    Test.startTest();

    Email_Form__c form = new Email_Form__c(
      Email_Template_Metadata_Id__c = 'm001k000000BP8A',
      Form_HTML__c = '<form action="{{FORM_ACTION}}" method="get" style=width:100%;text-align:left;margin-top: 10px;><input type="hidden" value="Lead" name="objectApiName"/><input type="hidden" value="{{FORM_ID}}" name="formId"/><button type="submit" style="font-family: Helvetica;box-sizing:border-box;width: 100%;display: block;background-color: #345beb;border: none;padding: 10px;color: #fff;font-size: 15px;border-radius: 6px;margin-bottom: 10px;">Submit</button></form>',
      Form_JSON__c = '{"introFields":[],"outroFields":[],"selectedFields":[]}',
      Intro_Text__c = 'hi',
      Object_API_Name__c = 'Lead',
      Outro_Text__c = 'bye',
      Type__c = 'Create'
    );
    insert form;
    FormAPI.EmailSendParams params = new FormAPI.EmailSendParams();
    params.siteUrl = 'https://www.example.com';
    params.formId = form.Id;
    params.senderEmailAddress = 'myles@emergencelabs.io';
    params.senderName = 'Myles';
    params.recipientEmailAddress = 'test@example.com';
    params.recipientName = 'Example Name';
    FormAPI.sendEmail(new List<FormAPI.EmailSendParams>{ params });

    Email_Form_Send__c formSend = [SELECT Id FROM Email_Form_Send__c];

    RestRequest request = new RestRequest();
    RestResponse response = new RestResponse();

    request.requestUri =
      'https://cipdev-endpoints.cs195.force.com/services/apexrest/form/' +
      formSend.Id;
    request.httpMethod = 'GET';
    request.addParameter('formId', formSend.Id);
    request.addParameter('objectApiName', 'Lead');
    RestContext.request = request;
    RestContext.response = response;
    FormEndpoint.handleFormSubmit();

    Test.stopTest();
  }
}
