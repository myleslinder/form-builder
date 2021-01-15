public with sharing class FormAPI {
  @AuraEnabled
  public static void saveForm(String htmlString) {
    try {
      return;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Boolean sendEmail(String email, String htmlString) {
    try {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      String[] toAddresses = new List<String>{ email };
      mail.setToAddresses(toAddresses);
      mail.setReplyTo('myles@emergencelabs.io');
      mail.setSenderDisplayName('Myles Dope Form');
      mail.setSubject('Dope Form Incoming');
      mail.setPlainTextBody('Nothing to see here');

      mail.setHtmlBody(htmlString);
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
      return true;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
