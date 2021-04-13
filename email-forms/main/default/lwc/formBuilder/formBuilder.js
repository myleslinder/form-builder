import { LightningElement, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getObjectsInOrg from "@salesforce/apex/OrgAPI.getObjectsInOrg";
import getEmailForm from "@salesforce/apex/FormAPI.getEmailForm";
import saveForm from "@salesforce/apex/FormAPI.saveForm";
import getEmailTemplates from "@salesforce/apex/EmailTemplateFinder.getEmailTemplates";

export default class FormBuilder extends LightningElement {
  richTextFormats = [
    "font",
    "size",
    "bold",
    "italic",
    "underline",
    "strike",
    "list",
    "indent",
    "align",
    "link",
    "clean",
    "color"
  ];

  @api recordId;
  recordValues;

  @wire(getObjectsInOrg)
  objectsInOrg;

  @wire(getEmailTemplates)
  emailTemplates;

  @wire(getEmailForm, { formId: "$recordId" })
  wiredEmailForm({ error, data }) {
    if (error) console.error(error);
    if (data) {
      this.recordValues = { ...data };
      console.log(this.recordValues);
    }
  }

  get emailTemplateOptions() {
    console.log(this.emailTemplates);
    if (this.emailTemplates.data) {
      return this.emailTemplates.data.map((template) => ({
        label: template.MasterLabel,
        value: template.Id
      }));
    }
    return [];
  }

  get formTypeOptions() {
    return [
      { label: "Create", value: "Create" },
      { label: "Update", value: "Update" }
    ];
  }

  selectTargetObject({ detail: { value } }) {
    this.recordValues.Object_API_Name__c = value;
    this.recordValues = { ...this.recordValues };
    console.log(this.recordValues);
  }

  selectFormType({ detail: { value } }) {
    this.recordValues.Type__c = value;
    this.recordValues = { ...this.recordValues };
    console.log(this.recordValues);
  }
  get introValidity() {
    let el = this.template.querySelector(".intro-text");
    if (
      el &&
      el.value &&
      (el.value.includes("{{") || el.value.includes("}}"))
    ) {
      return this.recordValues.Type__c === "Update";
    }
    return true;
  }
  get outroValidity() {
    let el = this.template.querySelector(".outro-text");
    if (
      el &&
      el.value &&
      (el.value.includes("{{") || el.value.includes("}}"))
    ) {
      return this.recordValues.Type__c === "Update";
    }
    return true;
  }

  selectEmailTemplate({ detail: { value } }) {
    this.recordValues.Email_Template_Metadata_Id__c = value;
    this.recordValues = { ...this.recordValues };
  }
  selectEmailField({ detail: { value } }) {
    this.recordValues.Recipient_Email_Field__c = value;
    this.recordValues = { ...this.recordValues };
  }
  selectNameField({ detail: { value } }) {
    this.recordValues.Recipient_Name_Field__c = value;
    this.recordValues = { ...this.recordValues };
  }
  setIntroMessage({ detail: { value } }) {
    this.recordValues.Intro_Text__c = value;
    this.recordValues = { ...this.recordValues };
  }
  setOutroMessage({ detail: { value } }) {
    this.recordValues.Outro_Text__c = value;
    this.recordValues = { ...this.recordValues };
  }

  get isCreateForm() {
    return this.recordValues.Type__c === "Create";
  }
  get isUpdateForm() {
    return this.recordValues.Type__c === "Update";
  }

  async save() {
    try {
      let fieldSelectorEl = this.template.querySelector("c-field-selector");
      let fieldsString = fieldSelectorEl.getSelectedFields();
      console.log(fieldsString);
      let fields = JSON.parse(fieldsString);
      let stringGeneratorEl = this.template.querySelector(
        "c-form-string-generator"
      );
      console.log({ fields });
      this.recordValues.Form_HTML__c = stringGeneratorEl.form(
        this.isCreateForm,
        fields
      );

      // get all fields from the merge tags, if any
      let selectedFields = fieldSelectorEl.getFieldsForJson();
      let introFields = this.recordValues.Intro_Text__c.split(
        /(\{\{)|(\}\})/
      ).filter((v) => v && /^\w/.test(v));
      let outroFields = this.recordValues.Outro_Text__c.split(
        /(\{\{)|(\}\})/
      ).filter((v) => v && /^\w/.test(v));

      let formJSON = {
        introFields,
        outroFields,
        selectedFields
      };

      this.recordValues.Form_JSON__c = JSON.stringify(formJSON);
      console.log({ record: this.recordValues });

      await saveForm({ form: this.recordValues });
      this.saveNotification(
        "Saved",
        "Successfully saved Email Form",
        "success"
      );
    } catch (e) {
      this.saveNotification("Error", e.message, "error");
    }
  }

  saveNotification(title, message, variant) {
    const evt = new ShowToastEvent({
      title,
      message,
      variant
    });
    this.dispatchEvent(evt);
  }
}
