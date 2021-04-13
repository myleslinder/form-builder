@IsTest
public inherited sharing class Test_FormAPI {
  @IsTest
  static void itSendsCreateForm() {
    Test.startTest();
    List<Email_Template__mdt> templates = EmailTemplateFinder.getEmailTemplates();
    Email_Form__c form = new Email_Form__c(
      Email_Template_Metadata_Id__c = templates.get(0).Id,
      Form_HTML__c = '',
      Form_JSON__c = '',
      Intro_Text__c = '',
      Object_API_Name__c = 'Lead',
      Outro_Text__c = '',
      Type__c = 'Create'
    );
    insert form;
    Email_Form__c retrievedForm = FormAPI.getEmailForm(form.Id);
    System.assert(retrievedForm.Id == form.Id);
    retrievedForm.Form_JSON__c = '{}';
    FormAPI.saveForm(retrievedForm);
    FormAPI.EmailSendParams params = new FormAPI.EmailSendParams();
    params.siteUrl = 'https://www.example.com';
    params.formId = form.Id;
    params.senderEmailAddress = 'myles@emergencelabs.io';
    params.senderName = 'Myles';
    params.recipientEmailAddress = 'test@example.com';
    params.recipientName = 'Example Name';
    FormAPI.sendEmail(new List<FormAPI.EmailSendParams>{ params });
    Test.stopTest();
  }

  @IsTest
  static void itSendsUpdateForm() {
    Test.startTest();
    Lead lead = new Lead(
      FirstName = 'Myles',
      Email = 'myles@emergencelabs.io',
      LastName = 'Lead',
      Company = 'Company',
      Description = 'hi there'
    );
    insert lead;
    List<Email_Template__mdt> templates = EmailTemplateFinder.getEmailTemplates();
    Email_Form__c form = new Email_Form__c(
      Email_Template_Metadata_Id__c = templates.get(0).Id,
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
    Test.stopTest();
  }
}
