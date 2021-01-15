import postcss from "rollup-plugin-postcss";
import resolve from "@rollup/plugin-node-resolve";
import includePaths from "rollup-plugin-includepaths";
import commonjs from "rollup-plugin-commonjs";

let includePathOptions = {
  include: {},
  external: [/@salesforce/, /lightning\//, /preact/],
  extensions: [".js"]
};

export default {
  input: "./output/myComponent/bundle.js",
  output: {
    sourcemap: false,
    format: "esm",
    name: "app",
    file: "./output/myComponent/bundle.js"
  },
  external: [/@salesforce/, /lightning\//, /preact/],
  plugins: [
    postcss({
      plugins: [],
      extract: "./output/myComponent/app.css"
    }),
    includePaths(includePathOptions),
    resolve({
      moduleDirectories: ["src/"]
    }),
    commonjs()
  ]
};
