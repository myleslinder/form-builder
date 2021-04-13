public with sharing class FormAPI {
  @AuraEnabled(cacheable=true)
  public static Email_Form__c getEmailForm(Id formId) {
    try {
      return [
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
          Type__c
        FROM Email_Form__c
        WHERE Id = :formId
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void saveForm(Email_Form__c form) {
    try {
      update form;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @InvocableMethod(label='Send Email Form')
  public static void sendEmail(List<EmailSendParams> params) {
    for (EmailSendParams param : params) {
      Email_Form_Send__c sendRecord = new Email_Form_Send__c(
        Email_Form__c = param.formId,
        Target_Record_Id__c = param.recordId,
        Status__c = 'Pending'
      );
      insert sendRecord;
      try {
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
            Type__c
          FROM Email_Form__c
          WHERE Id = :param.formId
        ];
        Boolean isUpdateForm = targetForm.Type__c == 'Update';

        String recipientEmail = param.recipientEmailAddress;
        String recipientName = param.recipientName;

        String templateHTML;
        if (isUpdateForm) {
          Map<String, String> updateEmailDetails = buildUpdateFormEmail(
            param.siteUrl,
            param.recordId,
            sendRecord.Id,
            targetForm.Object_API_Name__c,
            targetForm.Email_Template_Metadata_Id__c,
            targetForm.Intro_Text__c,
            targetForm.Outro_Text__c,
            targetForm.Form_HTML__c,
            targetForm.Form_JSON__c,
            recipientEmail,
            recipientName,
            targetForm.Recipient_Email_Field__c,
            targetForm.Recipient_Name_Field__c
          );
          templateHTML = updateEmailDetails.get('templateHTML');
          recipientEmail = updateEmailDetails.get('recipientEmail');
          recipientName = updateEmailDetails.get('recipientName');
        } else {
          templateHTML = buildCreateFormEmail(
            param.siteUrl,
            targetForm.Email_Template_Metadata_Id__c,
            sendRecord.Id,
            targetForm.Intro_Text__c,
            targetForm.Outro_Text__c,
            targetForm.Form_HTML__c
          );
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        sendRecord.Recipient_Email__c = recipientEmail;
        String[] toAddresses = new List<String>{ recipientEmail };
        mail.setToAddresses(toAddresses);
        mail.setReplyTo(param.senderEmailAddress);
        mail.setSenderDisplayName(param.senderName);
        mail.setSubject(param.subject);
        mail.setPlainTextBody(templateHTML);

        mail.setHtmlBody(templateHTML);
        sendRecord.Sent_HTML__c = templateHTML;
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        sendRecord.Status__c = 'Sent';
      } catch (Exception e) {
        sendRecord.Status__c = 'Failed';
        sendRecord.Failure_Reason__c = e.getMessage();
      } finally {
        update sendRecord;
      }
    }
    return;
  }

  private static Map<String, String> buildUpdateFormEmail(
    String siteUrl,
    Id recordId,
    Id formSendId,
    String objectApiName,
    Id templateId,
    String introText,
    String outroText,
    String formHTML,
    String formJSON,
    String recipientEmail,
    String recipientName,
    String emailFieldName,
    String nameFieldName
  ) {
    String introTextCopy = introText;
    String outroTextCopy = outroText;
    String formHTMLCopy = formHTML;
    Email_Template__mdt template = EmailTemplateFinder.getEmailTemplate(
      templateId
    );
    String templateHTML = template.HTML_Email_String__c;
    Set<String> fieldsToQuerySet = new Set<String>{ 'Id' };

    Map<String, Object> fieldsJSON = (Map<String, Object>) JSON.deserializeUntyped(
      formJSON
    );
    List<String> introFields = new List<String>();
    if (fieldsJSON.get('introFields') != null) {
      List<Object> intros = (List<Object>) fieldsJSON.get('introFields');
      for (Object field : intros) {
        introFields.add((String) field);
      }
    }

    List<String> outroFields = new List<String>();
    if (fieldsJSON.get('outroFields') != null) {
      List<Object> outros = (List<Object>) fieldsJSON.get('outroFields');
      for (Object field : outros) {
        outroFields.add((String) field);
      }
    }

    List<String> selectedFields = new List<String>();
    if (fieldsJSON.get('selectedFields') != null) {
      List<Object> selecteds = (List<Object>) fieldsJSON.get('selectedFields');
      for (Object field : selecteds) {
        selectedFields.add((String) field);
      }
    }

    fieldsToQuerySet.addAll(introFields);
    fieldsToQuerySet.addAll(outroFields);
    fieldsToQuerySet.addAll(selectedFields);
    if (emailFieldName != null) {
      fieldsToQuerySet.add(emailFieldName);
    }
    if (nameFieldName != null) {
      fieldsToQuerySet.add(nameFieldName);
    }
    List<String> fieldsToQueryList = new List<String>();
    fieldsToQueryList.addAll(fieldsToQuerySet);
    String fieldsToQuery = String.join(fieldsToQueryList, ',');
    SObject targetRecord = Database.query(
        'SELECT ' +
        fieldsToQuery +
        ' FROM ' +
        objectApiName +
        ' WHERE Id = :recordId'
      )
      .get(0);

    for (String mergeField : introFields) {
      introTextCopy = introTextCopy.replaceAll(
        '\\{\\{' +
        mergeField +
        '\\}\\}',
        pluckValue(targetRecord, mergeField)
      );
    }
    for (String mergeField : outroFields) {
      outroTextCopy = outroTextCopy.replaceAll(
        '\\{\\{' +
        mergeField +
        '\\}\\}',
        pluckValue(targetRecord, mergeField)
      );
    }
    formHTMLCopy = formHTML.replaceAll('\\{\\{RECORD_ID\\}\\}', recordId);
    String emailAddress = recipientEmail;
    if (recipientEmail == null && emailFieldName != null) {
      emailAddress = pluckValue(targetRecord, emailFieldName);
    }
    String emailName = recipientName;
    if (recipientName == null && nameFieldName != null) {
      emailName = pluckValue(targetRecord, nameFieldName);
    }
    return new Map<String, String>{
      'recipientEmail' => emailAddress,
      'recipientName' => emailName,
      'templateHTML' => buildPopulatedEmailTemplate(
        siteUrl,
        templateId,
        formSendId,
        introTextCopy,
        outroTextCopy,
        formHTMLCopy
      )
    };
  }

  private static String buildCreateFormEmail(
    String siteUrl,
    Id templateId,
    Id formSendId,
    String introText,
    String outroText,
    String formHTML
  ) {
    return buildPopulatedEmailTemplate(
      siteUrl,
      templateId,
      formSendId,
      introText,
      outroText,
      formHTML
    );
  }

  private static String buildPopulatedEmailTemplate(
    String siteUrl,
    Id templateId,
    Id formSendId,
    String introText,
    String outroText,
    String formHTML
  ) {
    Email_Template__mdt template = EmailTemplateFinder.getEmailTemplate(
      templateId
    );
    String templateHTML = template.HTML_Email_String__c;
    String formHTMLCopy = formHTML;
    templateHTML = templateHTML.replace('{{REPLACE_WITH_INTRO}}', introText);
    templateHTML = templateHTML.replace('{{REPLACE_WITH_SIGNOFF}}', outroText);
    String formActionUrl = siteUrl + '/services/apexrest/form/' + formSendId;
    formHTMLCopy = formHTMLCopy.replaceAll(
      '\\{\\{FORM\\_ACTION\\}\\}',
      formActionUrl
    );
    formHTMLCopy = formHTMLCopy.replaceAll('\\{\\{FORM\\_ID\\}\\}', formSendId);
    templateHTML = templateHTML.replaceAll(
      '\\{\\{REPLACE\\_WITH\\_FORM\\}\\}',
      formHTMLCopy
    );
    templateHTML = templateHTML.replaceAll(
      ('\\{\\{REPLACE\\_WITH\\_FALLBACK\\}\\}'),
      '<p style="width: 100%;text-align: center;"><span style="padding-right: 5px;color: #333;text-decoration: none;font-style: normal;">Something wrong?</span> <a class="fallback-btn" href="' +
      formActionUrl +
      '">Open this email in a new tab</a></p>'
    );
    return templateHTML;
  }

  private static String pluckValue(SObject targetRecord, String fieldName) {
    Boolean isRelationship = fieldName.contains('.');
    if (isRelationship) {
      Object val = targetRecord.getSObject(
          fieldName.substring(0, fieldName.indexOf('.'))
        )
        .get(fieldName.substring(fieldName.indexOf('.') + 1));
      return val != null ? String.valueOf(val) : '';
    } else {
      return targetRecord.get(fieldName) != null
        ? String.valueOf(targetRecord.get(fieldName))
        : '';
    }
  }

  public class EmailSendParams {
    @InvocableVariable(
      label='The Site.com URL (no trailing slash)'
      required=true
    )
    public String siteUrl;

    @InvocableVariable(label='Id of the Email Form' required=true)
    public Id formId;
    @InvocableVariable(
      label='Id of the Target Record (Update form Only)'
      description='This Id must be for a record of the Form target Object type'
    )
    public Id recordId;
    @InvocableVariable(
      label='The email address to send the email from'
      required=true
    )
    public String senderEmailAddress;
    @InvocableVariable(
      label='The name of the individual to send the email from'
      required=true
    )
    public String senderName;
    @InvocableVariable(
      label='The email address to send the email to'
      description='Required if Create Form otherwise this will overwrite any derived values from the Form'
    )
    public String recipientEmailAddress;
    @InvocableVariable(
      label='The name of the recipient'
      description='Required if Create Form otherwise this will overwrite any derived values from the Form'
    )
    public String recipientName;
    @InvocableVariable(label='The email subject' required=true)
    public String subject;
  }
}
