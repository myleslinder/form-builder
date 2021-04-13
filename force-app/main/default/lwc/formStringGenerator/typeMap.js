import {
  textTypeAttributes,
  checkboxInputAttributes
} from "./elementAttributes";

export default {
  Address: { htmlElement: "input", attributes: textTypeAttributes },
  Boolean: { htmlElement: "input", attributes: checkboxInputAttributes },
  ComboBox: {
    htmlElement: "select",
    attributes: { type: "single", placeholder: false }
  },
  Currency: {
    htmlElement: "input",
    attributes: { type: "number", placeholder: false }
  },
  Date: {
    htmlElement: "input",
    attributes: { type: "date", placeholder: false }
  },
  DateTime: {
    htmlElement: "input",
    attributes: { type: "datetime-local", placeholder: false }
  },
  Double: {
    htmlElement: "input",
    attributes: { type: "number", placeholder: false }
  },
  Email: {
    htmlElement: "input",
    attributes: { type: "email", placeholder: true }
  },
  Int: {
    htmlElement: "input",
    attributes: { type: "number", placeholder: false }
  },
  Location: { htmlElement: "input", attributes: textTypeAttributes },
  MultiPicklist: {
    htmlElement: "select",
    attributes: { type: "multi", placeholder: false }
  },
  Percent: {
    htmlElement: "input",
    attributes: { type: "number", placeholder: false }
  },
  Phone: {
    htmlElement: "input",
    attributes: { type: "tel", placeholder: true }
  },
  Picklist: {
    htmlElement: "select",
    attributes: { type: "single", placeholder: false }
  },
  String: { htmlElement: "input", attributes: textTypeAttributes },
  TextArea: {
    htmlElement: "textarea",
    attributes: { type: null, placeholder: true }
  },
  Time: {
    htmlElement: "input",
    attributes: { type: "time", placeholder: false }
  },
  Url: { htmlElement: "input", attributes: { type: "url", placeholder: true } },
  Hidden: {
    htmlElement: "input",
    attributes: { type: "hidden", placeholder: false }
  },
  Option: {
    htmlElement: "input",
    attributes: { type: "radio", placeholder: false }
  }
};
