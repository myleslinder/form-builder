@IsTest
public inherited sharing class Test_EmailTemplateFinder {
  @IsTest
  static void itGetsEmailTemplates() {
    Test.startTest();
    List<Email_Template__mdt> templates = EmailTemplateFinder.getEmailTemplates();
    System.assert(templates.size() > 0);
    Email_Template__mdt template = EmailTemplateFinder.getEmailTemplate(
      'm001k000000BP8A'
    );
    System.assert(template == null);
    Test.stopTest();
  }
}
