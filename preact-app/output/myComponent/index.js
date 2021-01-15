import { render, h } from "preact";
import Hello from "components/hello";

function App() {
  return h(Hello);
}

const fallbackValue = 10;
export const props = [
  "recordId",
  "objectApiName",
  ["somethingInMyXML", `${fallbackValue}`]
];

export default function renderApp(renderElement, props) {
  render(h(App, props), renderElement);
}
