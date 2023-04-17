# {YOUR-REPO-NAME} Contributing Guide

Hi! Thanks for taking the time to contribute to {YOUR-REPO-NAME}.

_You can contribute in many ways_

- Join the [discussion](https://github.com/EPFL-ENAC/{YOUR-REPO-NAME}/discussions)

_Before submitting your contribution, please make sure to take a moment and read through the following guidelines_

- [Code of Conduct](https://github.com/EPFL-ENAC/{YOUR-REPO-NAME}/blob/main/CODE_OF_CONDUCT.md)
- [Issue Reporting Guidelines](#issue-reporting-guidelines)
- [Pull Request Guidelines](#pull-request-guidelines)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Github Flow](#github-flow)
- [Commit Lint](#commit-lint)

## Issue Reporting Guidelines

- Always use [ issue templates ](https://github.com/EPFL-ENAC/{YOUR-REPO-NAME}/issues/new/choose)
- If you don't find a corresponding issue template please use the template to ask a new template

## Pull Request Guidelines

### Timeline example

1. Create an issue (fix/feature/etc..)
2. Create branch from issue
   - the issue's title should be what you expect your branch name to be
3. Checkout locally, push commits to github
4. Create pull-request from branch
5. Merge pull-request

   - To avoid merge commit like this:
     'Merge pull request #3 from EPFL-ENAC/2-bug-remove-ecoinvent-embodied-data
   - Replace the github automatic merge commit message by the a conventional-changelog valid commit message usually a simple copy/paste from the pull-request title is enough
   - see this [blog post](https://mokacoding.com/blog/better-merging-for-github-pull-requests/) for an example

6. Issue is auto-close

### We Develop with Github

We use github to host code, to track issues and feature requests, as well as accept pull requests.

### We Use [Github Flow](https://docs.github.com/en/get-started/quickstart/github-flow),

- All Code Changes Happen Through Pull Requests.
  Pull requests are the best way to propose changes to the codebase (we use [Github Flow](https://docs.github.com/en/get-started/quickstart/github-flow)). We actively welcome your pull requests:

- If your pull request addresses an issue, link the issue so that issue stakeholders are aware of the pull request and vice versa.

- It's better to create a branch from an issue, the issue number will directly be in the branch name
  - see [discussion for reference](https://github.com/github-community/community/discussions/12290)

### Before you start

1. Setup your environment to have immediate feedback on your changes:

   - [Setup ESLint plugin](https://eslint.org/docs/user-guide/integrations) in your editor.
   - [Setup Prettier plugin](https://prettier.io/docs/en/editors.html) in your editor.
   - [Setup TypeScript](https://www.typescriptlang.org/index.html#download-links) or Flow in your editor.
   - [Setup stylelint](https://stylelint.io/user-guide/complementary-tools#editor-plugins) in your editor.

2. Read your team’s coding standards and style guides.

## JavaScript

- JavaScript code is following team standards.

## HTML

- All code is [WCAG Level AA](https://www.w3.org/TR/2006/WD-WCAG20-20060427/appendixB.html) compliant.
  - _See [tools and techniques to use to test accessibility](https://daverupert.com/2018/07/assistive-technologies-i-test-with/)._
- Semantic tags are used where possible instead of `div`s and `span`s (headings, paragraphs, lists, etc.)
  - _See [Semantic HTML Tutorial](https://www.internetingishard.com/html-and-css/semantic-html/) for some examples._
- All interactive elements (links, buttons, form elements) are keyboard accessible and have visible focus states.
- Tab order of all interactive elements follows a logical pattern, usually their position on the screen and order in the DOM.
- All non-standard elements have appropriate ARIA roles.
- All interactive elements have accessible labels.
  - _For example, add accessible text using the VisuallyHidden component or something similar._
- All non-text content has a text alternative.
  - _For example, images have appropriate alt texts, clickable icons have titles, and videos have captions._
- UI looks good on any screen size (mobile, desktop, etc.).
- UI looks good with 200% page zoom.

## CSS

- CSS code is following team standards. _stylelint_
- No hardcoded colors, font sizes, whitespace, breakpoints and z-indices.
  - _Always use design tokens instead._
- No style overrides of any component library components.
- No unnecessary CSS, ideally there’s no CSS at all.
  - _For example, prefer to use primitive and layout components instead of custom styles._
- Try to use rem and em instead of px: here is a good recommendation
  - Border width (px) - Relative border width is ugly.
  - Icon size (rem) - When inline with text.
  - Margin for typography (rem) - Case for margin between heading and paragraph.
  - Padding for typography (em) - Case for different button size.
  - Font size (rem) - Case for heading font size and secondary font size. (em is not recommended)
  - Root font size (px) - It is the root! Why bother with relative units? Relative to what??
  - Line height (rem) - Because it needs to be relative to the font size. Unless you want to set a vertical rhythm and such.

## Python

- We follow the pep8 and the python-guide writing style
  - https://docs.python-guide.org/writing/style/

### maybe todo ?

1. Fork the repo and create your branch from `dev`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs or added breaking change, update the documentation and notify the users.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

### Recommendation for the pull request

- Add screenshots or GIFs for any UI changes. This will help the person reviewing your code to understand what you’ve changed and how it works.
  - _Hint: use [Kap](https://getkap.co/) or [Licecap](https://www.cockos.com/licecap/) to record your screen._
- If your team uses a particular template for pull requests, fill it. Otherwise at least make sure you have:

  - the user problem you are solving;
  - acceptance criteria of the ticket;
  - testing you have done or plan to do before release;
  - any pull request that are dependent on this one, or any tickets on which this pull request depends.

- The `main` branch is just a snapshot of the latest stable release. All development should be done in dedicated branches. **Do not submit PRs against the `main` branch.**

- Checkout a topic branch from the relevant branch, e.g. `dev`, and merge back against that branch.

- Work in the `frontend` folder and **DO NOT** checkin `dist` in the commits.

- It's OK to have multiple small commits as you work on the PR - GitHub will automatically squash it before merging.

- If adding a new feature:

  - Add accompanying test case.
  - Provide a convincing reason to add this feature. Ideally, you should open a suggestion issue first and have it approved before working on it.
  - Present your issue in the 'discussion' part of this repo

- If fixing bug:
  - If you are resolving a special issue, add `(fix #xxxx[,#xxxx])` (#xxxx is the issue id) in your PR title for a better release log, e.g. `update entities encoding/decoding (fix #3899)`.
  - Provide a detailed description of the bug in the PR. Live demo preferred.
  - Add appropriate test coverage if applicable.

### Code review checklist

- Ask to people to review your code:
  - a person who knows the domain well and can spot bugs in the business logic;
  - an expert in the technologies you’re using who can help you improve the code quality.
- When you’re done with the changes after a code review, do another self review of the code and write a comment to notify the reviewer, that the pull request is ready for another iteration.
- Review all the review comments and make sure they are all addressed before the next review iteration.
- Make sure you don’t have similar issues anywhere else in your pull request.
- If you’re not going to follow any of the code review recommendations, please add a comment explaining why.
- Avoid writing comment like "done" of "fixed" on each code review comment. Reviewers assume you’ll do all suggested changes, unless you have a reason not to do some of them.
- Sometimes it’s okay to postpone changes — in this case you’ll need to add a ticket number to the pull request and to the code itself.

## Development Setup

You will need [Node.js](http://nodejs.org) **lts** and [npm](https://pnpm.io/). And also Gnu Make

After cloning the repo, run:

```bash
$ make install # install the dependencies of the project
```

## Project Structure

- **`db`**: contains the data and database bootstrap code for the db
- **`frontend`**: contains the source code. The codebase is written in typescript using class components for vue2 and vuetify as the library component. And ECharts as the chart library.

## Financial Contribution

We also welcome financial contributions. Please contact us directly.

## Commit Lint

We follow a commit message convention, to have consistent git messages. The goal is to increase readability and ease of contribution. We use [commit-lint with the conventional-changelog extension](https://github.com/conventional-changelog/commitlint)

## Credits

Thank you to all the people who have already contributed to {YOUR-REPO-NAME} repository!
