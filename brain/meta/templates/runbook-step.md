---
type: runbook
description: "<App> v<N> — step <NN>: <what>"
app: <app>
version: v<N>
step: <NN>
last-tested: <yyyy-mm-dd>
status: current
---

# <NN> — <Step title>

> Prerequisites: step <NN-1> completed. <Other prerequisites.>

## <Sub-step>

Goal: <one line, why this command>.

```bash
<exact command>
```

Expected output:

```
<expected output / success criterion>
```

> [!warning]
> <Gotcha if any, and its remedy.>

---
Next step: [<NN+1>-<slug>](<NN+1>-<slug>.md) · Contents: [runbook](../index.md)
