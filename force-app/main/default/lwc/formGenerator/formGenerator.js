import { LightningElement, wire, api } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import getPicklistOptionsForObject from "@salesforce/apex/OrgAPI.getPicklistOptionsForObject";
import exectureQueryString from "@salesforce/apex/OrgAPI.exectureQueryString";
import sendEmail from "@salesforce/apex/FormAPI.sendEmail";

import { elementString } from "./elementGenerator";
import elementStyles from "./elementStyles";
import typeMap from "./typeMap";
import emailTemplate from "./emailTemplate";

import { createMachine, interpret } from "robot3";

export default class FormGenerator extends LightningElement {
  @api objectApiName;
  @api recordId;

  preview;

  @api
  form = (action, fields) => `
    <form action=${action} method="get" style=${elementStyles.form}>
      ${fields.map(elementString).join("")}
      <input type="hidden" value='${this.recordId}' name="recordId"/>
      <input type="hidden" value='${this.objectApiName}' name="objectApiName"/>
      <button type="submit" style=${elementStyles.button}>Submit</button>
    </form>
  `;

  get wireObjectApiNamed() {
    return this.objectApiName
      ? { objectApiName: this.objectApiName }
      : undefined;
  }

  wiredPicklistOptions;
  @wire(getPicklistOptionsForObject, { objectApiName: "$objectApiName" })
  getOpts(res) {
    this.wiredPicklistOptions = res;
    this.allReady++;
    console.log("opts", res.data);
  }

  wiredAccountObjectInfo;
  @wire(getObjectInfo, { objectApiName: "$wireObjectApiNamed" })
  objInfo(res) {
    this.wiredAccountObjectInfo = res;
    this.allReady++;
    console.log("info", res.data);
  }

  wiredRecordValues = { data: undefined };

  queryString;
  allReady = 0;
  record;
  renderedCallback() {
    if (
      this.objectApiName &&
      this.recordId &&
      this.wiredAccountObjectInfo.data &&
      !this.queryString &&
      this.wiredPicklistOptions.data
    ) {
      let objFields = this.wiredAccountObjectInfo.data.fields;
      this.queryString = `SELECT ${Object.keys(objFields)
        .filter(
          (k) => typeMap[objFields[k].dataType] && objFields[k].updateable
        )
        .map((o) => objFields[o].apiName)
        .join(", ")} FROM ${this.objectApiName} WHERE Id = '${this.recordId}'`;
      console.log(this.queryString);
      exectureQueryString({ queryString: this.queryString }).then(
        (recordResults) => {
          this.allReady++;
          this.record = recordResults[0];
          let data = this.wiredAccountObjectInfo.data;
          let picklistOptions = this.wiredPicklistOptions.data;
          if (data && picklistOptions && recordResults) {
            let fields = Object.keys(data.fields)
              .filter(
                (k) =>
                  typeMap[data.fields[k].dataType] && data.fields[k].updateable
              )
              .map((k) => ({
                ...data.fields[k],
                options: picklistOptions[k] ?? [],
                prefill: recordResults[0][k] ?? ""
              }));
            this.preview = this.form(
              "https://sandbox-form-handler-developer-edition.cs77.force.com/services/apexrest/form/",
              fields
            );
          }
        }
      );
    }

    if (this.wiredAccountObjectInfo.error || this.wiredPicklistOptions.error) {
      console.error(this.wiredPicklistOptions.error);
      console.error(this.wiredAccountObjectInfo.error);
    }
  }

  async sendEmail() {
    try {
      let data = this.wiredAccountObjectInfo.data;
      let picklistOptions = this.wiredPicklistOptions.data;
      let greeting = this.template.querySelector(
        "lightning-input-rich-text.greeting"
      ).value;
      let signOff = this.template.querySelector(
        "lightning-input-rich-text.sign-off"
      ).value;

      let fields = Object.keys(data.fields)
        .filter((k) => {
          let inGreeting = greeting.includes(`{{${k}}}`);
          let inSignOff = signOff.includes(`{{${k}}}`);
          if (inGreeting) {
            greeting = greeting.replaceAll(`{{${k}}}`, this.record[k]);
          }
          if (inSignOff) {
            signOff = signOff.replaceAll(`{{${k}}}`, this.record[k]);
          }
          if (inGreeting || inSignOff) {
            return false;
          }
          return typeMap[data.fields[k].dataType] && data.fields[k].updateable;
        })
        .map((k) => ({
          ...data.fields[k],
          options: picklistOptions[k] ?? [],
          prefill: this.record[k]
        }));
      this.preview = this.form(
        "https://sandbox-form-handler-developer-edition.cs77.force.com/services/apexrest/form/",
        fields
      );
      await sendEmail({
        email:
          this.record && this.record.Email
            ? this.record.Email
            : "myles@emergencelabs.io",
        htmlString: emailTemplate
          .replace("{{REPLACE_WITH_FORM}}", this.preview)
          .replace(
            "{{REPLACE_WITH_GREETING}}",
            `Hi ${
              this.record && this.record.FirstName
                ? this.record.FirstName
                : "there"
            }!`
          )
          .replace("{{REPLACE_WITH_INTRO}}", greeting)
          .replace("{{REPLACE_WITH_SIGNOFF}}", signOff)
      });
      console.log("sent");
    } catch (e) {
      console.error(e);
    }
  }

  replaceRelationshipFields(string) {
    let populated = string;
    let start = string.indexOf("{{");
    let end = string.indexOf("}}", start);
    if (start && end) {
      //populated
    }
    return string;
  }
}
