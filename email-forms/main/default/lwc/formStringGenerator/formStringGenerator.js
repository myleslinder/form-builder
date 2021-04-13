import { LightningElement, api, wire } from "lwc";
import getPicklistOptionsForObject from "@salesforce/apex/OrgAPI.getPicklistOptionsForObject";

import { elementString } from "./elementGenerator";
import elementStyles from "./elementStyles";

export default class FormStringGenerator extends LightningElement {
  @api objectApiName;

  wiredPicklistOptions;
  @wire(getPicklistOptionsForObject, { objectApiName: "$objectApiName" })
  getOpts(res) {
    this.wiredPicklistOptions = res;
    this.allReady++;
    console.log("opts", res.data);
  }

  // NEED TO AUGMENT FIELDS WITH OPTIONS FROM WIRED VAL ABOVE
  // NO RECORD TYPE SUPPORT
  @api
  form(isCreate, fields) {
    let augmentedFields = fields.map((field) => {
      return {
        ...field,
        options:
          field.dataType === "Picklist"
            ? this.wiredPicklistOptions.data[field.apiName]
            : []
      };
    });
    return `
    <form action="{{FORM_ACTION}}" method="get" style=${elementStyles.form}>
      ${augmentedFields.map(elementString).join("")}
      ${
        isCreate
          ? `<input type="hidden" value='{{RECORD_ID}}' name="recordId"/>`
          : ""
      }
      <input type="hidden" value='${this.objectApiName}' name="objectApiName"/>
      <input type="hidden" value='{{FORM_ID}}' name="formId"/>
      <button type="submit" style="${elementStyles.button}">Submit</button>
    </form>
  `;
  }
}
