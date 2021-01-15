const sharedStyles = "font-family: sans-serif;";

const label = `
  ${sharedStyles}
  display: block;
  font-weight: 600;
  font-family: sans-serif;
  font-size: 14px;
  font-variant-caps: all-small-caps;
  color: #333;
  margin-bottom: 5px;
`;

const input = `
    ${sharedStyles}
    width: 100%;
    padding: 8px;
    color: #222;
    border: 1px solid #999;
    border-radius: 6px;
    margin-bottom: 10px;
`;
const textarea = input;

export default {
  label,
  input,
  textarea,
  select: `${sharedStyles} width:100%;`,
  form: `width:100%;text-align:left;`,
  button: `width:100%;display:block;`
};
