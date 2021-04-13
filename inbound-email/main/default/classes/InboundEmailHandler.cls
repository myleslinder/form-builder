global with sharing class InboundEmailHandler implements Messaging.InboundEmailHandler {
  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope env
  ) {
    try {
      Messaging.InboundEmail.Header[] headers = email.headers;
      String fromEmail;
      String toEmail;
      for (Messaging.InboundEmail.Header header : headers) {
        if (header.name == 'From') {
          fromEmail = parseFromHeader(header.value);
        } else if (header.Name == 'To') {
          toEmail = parseFromHeader(header.value);
        }
      }
      if (fromEmail == 'forwarding-noreply@google.com') {
        sendBack(email);
      } else {
        System.debug(fromEmail);
        List<Lead> l = [
          SELECT Id
          FROM Lead
          WHERE Email = :fromEmail
          ORDER BY LastModifiedDate
        ];
        if (l.size() > 0) {
          Inbound_Email__c inboundEmailRecord = new Inbound_Email__c(
            From_Email__c = fromEmail,
            Lead__c = l.get(0).Id,
            Matched_Multiple_Leads__c = l.size() > 1,
            HTML_Body__c = email.htmlBody,
            Text_Body__c = email.plainTextBody,
            Subject__c = email.subject,
            To_Email__c = toEmail
          );

          insert inboundEmailRecord;
        }
      }

      return null;
    } catch (Exception e) {
      return null;
    }
  }

  private static String parseFromHeader(String fromHeader) {
    if(fromHeader.indexOf('<') != -1){
      return fromHeader.substring(
        fromHeader.indexOf('<') + 1,
        fromHeader.indexOf('>')
      );
    }
    return fromHeader;
  }

  private static void sendBack(Messaging.InboundEmail email) {
    String subject = email.subject;
    String originEmail = subject.substring(subject.lastIndexOf(' '));
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new List<String>{ originEmail };
    mail.setToAddresses(toAddresses);
    mail.setReplyTo(originEmail);
    mail.setSenderDisplayName('Salesforce Email Service');
    mail.setSubject(subject);
    mail.setPlainTextBody(email.plainTextBody);

    mail.setHtmlBody(email.htmlBody);
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
  }
}
