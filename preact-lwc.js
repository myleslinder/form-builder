#!/usr/bin/env node
import resolve from "@rollup/plugin-node-resolve";
import postcss from "rollup-plugin-postcss";

export default {
  input: "src/main.js",
  output: {
    name: "App",
    format: "esm",
    file: "../force-app/main/default/lwc/app/build.js"
  },
  external: [/@salesforce/, /lightning\//],
  plugins: [
    postcss({
      plugins: [],
      extract: "app.css"
    }),
    resolve({
      browser: true
    })
  ]
};

const fs = require("fs");

fs.readdirSync("./preact-app/output");

//for each root component folder
//https://javascript.info/modules-dynamic-imports
// get the props export from the index.js
// create the lwc bundle to mount the preact app
// run the index.js through rollup (handling css with emit) and inserting into bundle
// create the html file with template containing mount target
// create the js file with
// import of the preactApp from bundled rollup file
// a properlyNamed LightningElement subclass with renderedCallback() to mount the preact app
