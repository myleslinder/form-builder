import typeMap from "./typeMap";
import elementStyles from "./elementStyles";

const label = (s, elStr = "") =>
  `<label for="${s.apiName}" style="${elementStyles.label}">${s.label}${elStr}</label>`;

const input = (source, attributes) => {
  const el = (s, a) => {
    return `
  <input
    style="${elementStyles.input}"
    type="${a.type}"
    ${a.placeholder ? `placeholder="${s.placeholder}"` : ""}
    name="${s.apiName}"
    ${s.prefill ? `value="${s.prefill}"` : ""}
    ${a.type === "checkbox" && a.checked ? `checked` : ""}
  />`;
  };
  // THIS IS BROKEN
  if (attributes.type === "radio") {
    return `
      <fieldset>
      <legend>${source.label}</legend>
        ${source.options.map(label(source, el(source, attributes))).join("")};
      </fieldset>
    `;
  }
  return `${label(source)} ${el(source, attributes)}`;
};

/*
<fieldset>
  <legend>Favourite color</legend>
  <label>Red
    <input type="radio" name="color" value="r">
    <div class="button red"></div>
  </label>
  <label>Blue
    <input type="radio" name="color" value="b">
    <div class="button blue"></div>
  </label>
</fieldset>
*/

const select = (source, attributes) => {
  const option = ({ label: l, value: v }) =>
    `<option value="${v}">${l}</option>`;

  return `
  ${label(source)}
  <select name="${source.apiName}" value="${source.prefill}">
    ${source.options.map(option).join("")}
  </select>
`;
};

const textarea = (source, attributes) =>
  `${label(source)} <textarea name="${source.apiName}" value="${
    source.prefill
  }"></textarea>`;

const elementFunctions = {
  input,
  textarea,
  select
};

export const elementString = (source) => {
  let typeAttributes = typeMap[source.dataType];

  let element = elementFunctions[typeAttributes.htmlElement];

  return element(source, typeAttributes.attributes);
};
