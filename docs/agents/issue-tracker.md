# Issue tracker

This repo uses **local markdown** for issue tracking.

## Where issues live

Issues are markdown files under `.scratch/<feature>/`:

```
.scratch/
  <feature-slug>/
    001-short-issue-title.md
    002-another-issue.md
```

Each feature or workstream gets its own folder. Each issue is one `.md` file, prefixed with a zero-padded number for sort order.

## Workflow

- **Create an issue:** write a new `.md` file under the relevant `.scratch/<feature>/` folder.
- **Update an issue:** edit the file in place.
- **Close an issue:** move the file out of `.scratch/` (e.g. to `.scratch/<feature>/done/`) or delete it.

## Why local markdown

No git remote is configured for this repo, and the project is small enough that a separate issue tracker would be overhead. Local markdown keeps issues co-located with the code and version-controlled alongside it once the repo is initialised.
