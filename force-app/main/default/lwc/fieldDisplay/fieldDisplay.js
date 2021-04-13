import { LightningElement, api, track } from "lwc";

export default class FieldDisplay extends LightningElement {
  @api fields;
  @track fieldSortInfo = {};
  get orderedFields() {
    if (this.fields) {
      let ordered = [...this.fields].sort((f1, f2) => {
        return (this.fieldSortInfo[f1] ?? 0) - (this.fieldSortInfo[f2] ?? 0);
      });
      console.log(ordered);
      return ordered;
    }
    return [];
  }

  handleDeleteRequest({ detail: { field } }) {
    console.log(field);
    this.dispatchEvent(
      new CustomEvent("removefield", {
        detail: { field }
      })
    );
  }

  handleMoveRequest({ detail: { field, currentIndex, up } }) {
    let increase = up ? 1 : -1;
    Object.keys(this.fieldSortInfo).forEach((apiName) => {
      let needsModification = up
        ? this.fieldSortInfo[apiName] < currentIndex
        : this.fieldSortInfo[apiName] > currentIndex;
      if (needsModification) {
        this.fieldSortInfo[apiName] = this.fieldSortInfo[apiName] + increase;
      }
      if (apiName === field) {
        this.fieldSortInfo[apiName] = this.fieldSortInfo[apiName] - increase;
      }
    });
    this.fieldSortInfo = { ...this.fieldSortInfo };
  }

  @api
  getOrderedFieldsForJson() {
    return this.orderedFields;
  }
  @api
  getOrderedFields() {
    return this.orderedFields;
  }

  renderedCallback() {
    console.log({ sort: this.fieldSortInfo });
    this.fields.forEach((f, i) => {
      this.fieldSortInfo[f] = this.fieldSortInfo[f] ?? i;
    });
  }
}
