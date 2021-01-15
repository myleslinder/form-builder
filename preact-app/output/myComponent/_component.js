import { LightningElement, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";

export default class SampleComponent extends LightningElement {
  wiredAccountObjectInfo;
  @wire(getObjectInfo, { objectApiName: "$wireObjectApiNamed" })
  objInfo(res) {
    this.wiredAccountObjectInfo = res;
    this.allReady++;
    console.log("info", res.data);
  }
}
