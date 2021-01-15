# Overview

Each top level folder (called a root component) in the `output` directory becomes an app builder exposed lightning web component (with whatever additional xml you configure). It's bundled up into a single executable js file with a css file for all the styles you reference (you can use SLDS classes as well). You'll write your other javasript files (components) or styles in any other folder in the project.

> Won't each of my component bundles have to include the preact runtime? Nope.

We tell rollup not to include preact in the root component bundles but we bundle the preact runtime itself into a separate lwc and rewrite the imports (using alias or something). This means that all instances of your root components will share the same preact instance overhead but create isolated preact component hierarchies. A similar approach could also use a root component as a way to share state between other root components.

Doing this means you can't write JSX in your root component JS files because all the root components are preprocess with `lwc-prebundle` and left for SF to bundle. That basically means whatever external dependencies you use in your root components will be split-out. There actually might be a way to call rollup babel without resolve to have all external dependencies served this way. That would greatly improve the chance that a root component stays under the size limit. It's also possible to 'tune' your build by using root components in root components (with no intellisense in the html though :(). You would probably incur a performance cost there though rendering the LWC once (and waterfall data fetching) and then rendering the next root. I don't know, doing that's not recommended and weird. Maybe not weird if you rolled a switch at the top level so as to act like a router, but that would be a different usecase. So if you wanted to have only one mount point how realistic would it be to keep a bundled app under 128KB without deps, and keep each bundled dep under 128KB, seems pretty achievable.

A root component folder has at minimum an `index.js` file with a default export of a render function that accepts a render element and props and should return the result of calling `render()`

This gets automatically converted into an LWC bundle that will mount that preact component to a div. Your `index.js` file can also optionally have a named export of `props` that will be added to the mounting LightningElement subclass instance and provided to the preact app. Whenever they change the entire preact app will re-render (it will not be re-mounted).

If you require anything more than props you can include a file named `_component.js` that will be the mounting component. Beware of `wire` methods not working how you would want when the component doesn't re-render or something like that. So there's some extra lifecycle control required in that case. If you have that file you are responsible for mounting your own component, passing in whatever props you want. You wouldn't use both the props export
and custom component method.
You can also optionally provide a `_component.html` file to pre-populate whatever html you want. In that case you need to ensure you have one element with the `_component` class for auto mount, unless you also have a `_component.js` file and are mounting yourself.

You can use all the imports from Salesforce (such as `lightning/navigation`, or any `@salesforce` module) within your components as they will be resolved when the containing LWCs are bundled. The exception to this is obviously anything that needs to use `@wire`.

Is there like a hash based router or some way we can allow for routing?

> external: [/@salesforce/, /lightning\//]

## Parsing Steps

- for each root component folder
  - [get the props export from index.js](https://javascript.info/modules-dynamic-imports)
  - create the lwc bundle to mount the preact app
  - run the index.js through rollup (handling css with emit) and inserting into bundle
  - create the html file with template containing mount target
  - create the js file with
    - import of the preactApp from bundled rollup file
    - a properlyNamed LightningElement subclass with renderedCallback() to mount the preact app

## The XML Component Configuration File

The top level folder should contain an xml file to add targets and stuff otherwise you just get the default
exposed one. The sfdx vscode extension now has good intelisense for those files

# Negatives

- You can't use anything that requires `@wire` such as PageReference or LightningMessageService without dropping down and mounting your own component
  - You can only have root components `@wire` things in which could be shitty with things like picklist values
- You can't use any of the Salesforce provided lightning web components except in your root component if you drop down

  - It's TBD if this is an issue if you go this route as that's just one of the tradeoffs, you could use preact/compat and use the react library salesforce provided but you also have the entire open source preact and react ecosystem at your disposal (could also roll this same approach with svelte, or vue, or even react)

- This also opens up the world of using something like storybook (mocks are available for all salesforce modules) because it's needed for Jest
- I wonder if could also use css-in-js if you wanted to? They usually need a runtime which is fine given the new approach but we need them to emit the generated css which i assume would probably be fine
- Is there a way to fix the lack of ability to integration test???
- You're basically writing a preact app with an lwc as the render target so at its core it's just like the example from munzprager just this is improved DX and has the dependency love

## Svelte

A very similar approach would work for Svelte except that you don't have an available lightning components drop-in, which could not matter, but the real drawback is that Svelte's runtime is per entry point so you would have to ship the (albeit small) Svelte runtime for each entrypoint which would add a few KBs per component, which is not desirable in a case with a bunch of entry point components on the page, like a community.

Should we be using esbuild??

Of course each of your entry components also comes with the LWC runtime and overhead but that should already be available because of it's use in the platform, no? Or at least shared between all your entry points.
