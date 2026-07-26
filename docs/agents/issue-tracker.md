# Issue tracker

This repo uses **GitHub Issues** for issue tracking.

## Where issues live

Issues live in the GitHub repository: [132564-n/hm_Motionbook](https://github.com/132564-n/hm_Motionbook/issues)

## Workflow

- **Create an issue:** use `gh issue create` or the GitHub web UI.
- **Update an issue:** use `gh issue edit` or the GitHub web UI.
- **Close an issue:** use `gh issue close` or the GitHub web UI, or reference the issue number in a commit message with `closes #N`.

## Labels

Standard triage labels:
- `needs-triage` — new issues waiting for triage
- `needs-info` — issue needs more information to proceed
- `ready-for-agent` — ready for an agent to work on
- `ready-for-human` — needs human review or decision
- `wontfix` — will not be addressed

## PRs as a request surface

External pull requests are NOT automatically included in the triage queue. This is a solo project with no expectation of external contributions. To change this, set `prs_as_request_surface: true` below.

### Configuration

```yaml
provider: github
repo: 132564-n/hm_Motionbook
prs_as_request_surface: false
```
