import { LightningElement, wire, api, track } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";

import typeMap from "./typeMap";

export default class FormStringGenerator extends LightningElement {
  @api formJson;

  @api objectApiName = "Lead";
  get wireObjectApiNamed() {
    return this.objectApiName
      ? { objectApiName: this.objectApiName }
      : undefined;
  }

  @wire(getObjectInfo, { objectApiName: "$wireObjectApiNamed" })
  wiredAccountObjectInfo({ error, data }) {
    console.log({ error, data });
    if (data) {
      this._fields = data.fields;
    }
  }

  get allowedFields() {
    let data = this._fields;
    if (this._fields) {
      return Object.keys(data)
        .filter(
          (k) =>
            typeMap[data[k].dataType] &&
            data[k].updateable &&
            !this.selectedFields.includes(data[k].apiName)
        )
        .map((k) => data[k]);
    }
    return null;
  }

  _fields;
  get fieldOptions() {
    if (this.allowedFields) {
      let data = this.allowedFields;
      console.log({ data });
      return this.allowedFields.map((k) => ({
        label: k.label,
        value: k.apiName
      }));
    }
    return [];
  }

  @track selectedFields = [];
  addField() {
    const fieldEl = this.template.querySelector(".field-selector");
    this.selectedFields = [...this.selectedFields, fieldEl.value];
  }
  removeField({ detail: { field } }) {
    console.log(field);
    this.selectedFields = this.selectedFields.filter((existingField) => {
      console.log(existingField, field);
      return existingField !== field;
    });
  }

  @api getFieldsForJson() {
    let fieldDislpayEl = this.template.querySelector("c-field-display");
    if (fieldDislpayEl) {
      return fieldDislpayEl.getOrderedFieldsForJson();
    }
    return [];
  }
  @api getSelectedFields() {
    let fieldDislpayEl = this.template.querySelector("c-field-display");
    if (fieldDislpayEl) {
      let mapped = fieldDislpayEl.getOrderedFields().map((apiName) => {
        return this._fields[apiName];
      });
      console.log({ mapped });
      return JSON.stringify(mapped);
    }
    return JSON.stringify([]);
  }

  connectedCallback() {
    if (this.formJson) {
      this.selectedFields = JSON.parse(this.formJson).selectedFields;
    }
  }
}
