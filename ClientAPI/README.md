This is a client API example, exemplifying how to call the REST API from a couple popular languages: TypeScript and JavaScript.

This API is simply intended to be an example of how to call the REST API and is not necessarily authoritative and not necessarily maintained (or tested!). To understand how to interact with the REST API, directly interacting with and reading the REST API's test cases and codebase in general is the authoritative form of documentation.

This API does not depend on any libraries outside of what's included in the browser's V8 JavaScript engine.

To include this as a JavaScript API in your client-side ES6 JavaScript project, simply run:
$ `npm install`
$ `npm run build` to generate `clientAPI.js` directly from `clientAPI.ts`.

Alternatively, to include this as a JavaScript API in your client-side ES5 JavaScript / Node.js project, simply run:
$ `npm install`
$ `npm run build-es5` to generate `clientAPI.js` directly from `clientAPI.ts`.

This client-side API is written in a modular, self-documenting style, so to get started with using it, please have a look through the commented clientAPI.ts/js file.