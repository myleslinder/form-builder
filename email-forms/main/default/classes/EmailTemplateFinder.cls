public with sharing class EmailTemplateFinder {
  @AuraEnabled(cacheable=true)
  public static List<Email_Template__mdt> getEmailTemplates() {
    return [
      SELECT Id, MasterLabel, DeveloperName, HTML_Email_String__c
      FROM Email_Template__mdt
    ];
  }

  public static Email_Template__mdt getEmailTemplate(Id templateId) {
    try {
      return [
        SELECT Id, MasterLabel, DeveloperName, HTML_Email_String__c
        FROM Email_Template__mdt
        WHERE Id = :templateId
      ];
    } catch (Exception e) {
      return null;
    }
  }
}
