const sharedStyles = "font-family: Helvetica;box-sizing:border-box;";

const label = `
  ${sharedStyles}
  display: block;
  font-weight: 600;
  font-size: 14px;
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
const textarea = `
    ${input}
    height: 80px;
  `;

const select = `
  ${sharedStyles}
  width: 100%;
  padding: 10px;
  border: 1px solid #999;
  border-radius: 6px;
  margin-bottom: 10px;
`;
const button = `
  ${sharedStyles}
  width: 100%;
  display: block;
  background-color: #345beb;
  border: none;
  padding: 10px;
  color: #fff;
  font-size: 15px;
  border-radius: 6px;
  margin-bottom: 10px;
`;

export default {
  label,
  input,
  textarea,
  select,
  form: `width:100%;text-align:left;margin-top: 10px;`,
  button
};
