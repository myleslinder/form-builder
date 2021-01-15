import svelte from "rollup-plugin-svelte";
import resolve from "@rollup/plugin-node-resolve";
import postcss from "rollup-plugin-postcss";

const production = !process.env.ROLLUP_WATCH;

export default {
  input: "src/main.js",
  output: {
    name: "App",
    format: "esm",
    file: "../force-app/main/default/lwc/app/build.js",
  },
  external: [/@salesforce/, /lightning\//],
  plugins: [
    svelte({
      // enable run-time checks when not in production
      emitCss: true,
      compilerOptions: {
        dev: !production,
      },
    }),
    postcss({
      plugins: [],
      extract: "app.css",
    }),
    resolve({
      browser: true,
      dedupe: ["svelte"],
    }),
  ],
  watch: {
    clearScreen: false,
  },
};
