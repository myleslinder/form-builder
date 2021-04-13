import { LightningElement, api } from "lwc";

export default class SingleFormField extends LightningElement {
  @api field;
  @api index;
  @api fieldCount;

  get disableUp() {
    return this.index === 0;
  }
  get disableDown() {
    return this.index === this.fieldCount - 1;
  }

  dispatchMoveEvent({ target: { value } }) {
    const up = value === "up";

    this.dispatchEvent(
      new CustomEvent("move", {
        detail: { field: this.field, currentIndex: this.index, up }
      })
    );
  }
  dispatchDeleteEvent() {
    console.log(this.field);

    this.dispatchEvent(
      new CustomEvent("removefield", {
        detail: { field: this.field }
      })
    );
  }
}
