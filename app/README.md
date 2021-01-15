<div>
    Preview will use the selected fields from above and their type to render out
    the stylized form fields. So I'll need a component hierarchy that takes in a
    list of field types and then renders out the inputs. Once I have all the
    fields and their input equivalents known then I need to somehow get that to
    be able to be rendered inside a VF page and inside an email. I guess there
    would be two outputs? Although I would be able to render the email in the VF
    page if i just .innerHTML it and store that in the form record that I
    create. That makes sense so I just need to make the html string. // have an
    account Id provided and use that with a query string based on the selected
    // fields to pre-fill the values for the fields to be put in the form //
    store this form in the db // have a site.com public endpoint ready to
    capture the form submission // the real question is how to make the email
    (and create the page as a site) // it seems there's no good way to
    client-side produce the html string with the styles // the simples way to do
    it would be to produce a series of options with the builder (no preview?) //
    and then have a way to insert only a simple plain html form section into a
    template that already has // the css styles inlined, essentially a string
    replace, actually not a bad idea // use custom metadata or something to have
    the string output with a single REPLACE_ME where the // form gets inserted
    and the css is bundled in the builder as well so the class names can easily
    // get carried through // you could certainly do multiple replacements for
    like intro text, greeting, etc // you could obviously show a preview by
    innerHTMLing yourself // and for the page you would have a visualforce page
    that shows the exact same html as the email? // or it could just have the
    same dynamic replacement setup, likely makes the most sense // the only real
    challenge with that is that you have two sources of the same html and css //
    that aren't tied to each other at all, actually you can SSR a part of the
    style tag in VF // so the style could just be stored and injected into both
    things as the same value // you get no editor interface for it, unless you
    served it as a static resource which you can get // the string out of while
    using apex so thats actually pretty chill // you could have the wrapper
    htmnl be a static resource as well
  </div>

_Looking for a shareable component template? Go here --> [sveltejs/component-template](https://github.com/sveltejs/component-template)_

---

# svelte app

This is a project template for [Svelte](https://svelte.dev) apps. It lives at https://github.com/sveltejs/template.

To create a new project based on this template using [degit](https://github.com/Rich-Harris/degit):

```bash
npx degit sveltejs/template svelte-app
cd svelte-app
```

_Note that you will need to have [Node.js](https://nodejs.org) installed._

## Get started

Install the dependencies...

```bash
cd svelte-app
npm install
```

...then start [Rollup](https://rollupjs.org):

```bash
npm run dev
```

Navigate to [localhost:5000](http://localhost:5000). You should see your app running. Edit a component file in `src`, save it, and reload the page to see your changes.

By default, the server will only respond to requests from localhost. To allow connections from other computers, edit the `sirv` commands in package.json to include the option `--host 0.0.0.0`.

If you're using [Visual Studio Code](https://code.visualstudio.com/) we recommend installing the official extension [Svelte for VS Code](https://marketplace.visualstudio.com/items?itemName=svelte.svelte-vscode). If you are using other editors you may need to install a plugin in order to get syntax highlighting and intellisense.

## Building and running in production mode

To create an optimised version of the app:

```bash
npm run build
```

You can run the newly built app with `npm run start`. This uses [sirv](https://github.com/lukeed/sirv), which is included in your package.json's `dependencies` so that the app will work when you deploy to platforms like [Heroku](https://heroku.com).

## Single-page app mode

By default, sirv will only respond to requests that match files in `public`. This is to maximise compatibility with static fileservers, allowing you to deploy your app anywhere.

If you're building a single-page app (SPA) with multiple routes, sirv needs to be able to respond to requests for _any_ path. You can make it so by editing the `"start"` command in package.json:

```js
"start": "sirv public --single"
```

## Using TypeScript

This template comes with a script to set up a TypeScript development environment, you can run it immediately after cloning the template with:

```bash
node scripts/setupTypeScript.js
```

Or remove the script via:

```bash
rm scripts/setupTypeScript.js
```

## Deploying to the web

### With [Vercel](https://vercel.com)

Install `vercel` if you haven't already:

```bash
npm install -g vercel
```

Then, from within your project folder:

```bash
cd public
vercel deploy --name my-project
```

### With [surge](https://surge.sh/)

Install `surge` if you haven't already:

```bash
npm install -g surge
```

Then, from within your project folder:

```bash
npm run build
surge public my-project.surge.sh
```
