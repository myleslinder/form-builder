#!/usr/bin/env node
const fs = require("fs");

const sfcDir = fs.readdirSync("./force-app/main/default/components");
const ROOT = "./force-app/main/default";
const htmlFile = fs
  .readFileSync(`${ROOT}/components/myComponent.html`)
  .toString();
const scriptStart = htmlFile.indexOf("<script>") + "<script>".length;
const scriptEnd = htmlFile.indexOf("</script>");
const templateStart = htmlFile.indexOf("<template>");
const templateEnd = htmlFile.indexOf("</template>") + "</template>".length;
const styleStart = htmlFile.indexOf("<style>") + "<style>".length;
const styleEnd = htmlFile.indexOf("</style>");

const script = htmlFile.slice(scriptStart, scriptEnd);
const template = htmlFile.slice(templateStart, templateEnd);
const style = htmlFile.slice(styleStart, styleEnd);
console.log(script);
console.log(style);
console.log(template);

try {
  fs.unlinkSync(`${ROOT}/lwc/myComponent/myComponent.html`);
} catch (error) {
  /* */
}
try {
  fs.unlinkSync(`${ROOT}/lwc/myComponent/myComponent.css`);
} catch (error) {
  /* */
}
try {
  fs.unlinkSync(`${ROOT}/lwc/myComponent/myComponent.js`);
} catch (error) {
  /* */
}
fs.writeFileSync(`${ROOT}/lwc/myComponent/myComponent.js`, script);
fs.writeFileSync(`${ROOT}/lwc/myComponent/myComponent.html`, template);
fs.writeFileSync(`${ROOT}/lwc/myComponent/myComponent.css`, style);
