@IsTest
public with sharing class Test_InboundEmailHandler {
  @IsTest
  static void itSendsBackVerification() {
    Test.startTest();
    // System.runAs(contextuser){}
    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEmail.Header fromHeader = new Messaging.InboundEmail.Header();
    fromHeader.name = 'From';
    fromHeader.value = 'Verification <forwarding-noreply@google.com>';

    email.headers = new List<Messaging.InboundEmail.Header>{ fromHeader };
    email.subject = 'Verification Email for myles@emergencelabs.io';
    email.plainTextBody = 'This is a verification email';
    email.htmlBody = '<p>This is a verification email</p>';
    Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
    InboundEmailHandler handler = new InboundEmailHandler();
    Messaging.InboundEmailResult res = handler.handleInboundEmail(
      email,
      envelope
    );
    System.assert(res == null);
    System.assert(Limits.getEmailInvocations() > 0);
    Test.stopTest();
  }

  @IsTest
  static void itOnlyInsertsIfLeadWithEmail() {
    Lead l = new Lead(
      FirstName = 'Myles',
      LastName = 'Linder',
      Email = 'success@emergencelabs.io',
      Company = 'Emergence Labs'
    );
    insert l;
    Test.startTest();
    // System.runAs(contextuser) {}
    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEmail.Header fromHeader = new Messaging.InboundEmail.Header();
    Messaging.InboundEmail.Header toHeader = new Messaging.InboundEmail.Header();
    fromHeader.name = 'From';
    fromHeader.value = 'Myles Linder <success@emergencelabs.io>';
    toHeader.name = 'To';
    toHeader.value = '<myles@emergencelabs.io>';
    email.headers = new List<Messaging.InboundEmail.Header>{
      fromHeader,
      toHeader
    };
    email.subject = 'RE: That email you sent me!';
    email.plainTextBody = 'These are my thoughts on that email';
    email.htmlBody = '<p>These are my thoughts on that email</p>';
    Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
    InboundEmailHandler handler = new InboundEmailHandler();
    Messaging.InboundEmailResult res = handler.handleInboundEmail(
      email,
      envelope
    );
    System.assert(res == null);
    Inbound_Email__c inbound = [
      SELECT Id, Matched_Multiple_Leads__c, Lead__c, Subject__c, To_Email__c
      FROM Inbound_Email__c
      WHERE From_Email__c = 'success@emergencelabs.io'
    ];
    System.assert(inbound.Matched_Multiple_Leads__c == false);
    System.assert(inbound.Lead__c == l.Id);
    System.assert(inbound.Subject__c == email.subject);
    System.assert(inbound.To_Email__c == 'myles@emergencelabs.io');
    Test.stopTest();
  }
}
