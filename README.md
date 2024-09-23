Debug tools that I use in all Flutter development projects that help make development and on device debuging easier.

Two ways to include

1. Using Git submodule to checkout the repo into another repository and then adding a link in the projects `pubspec.yml`:

   ```yml
   debug_tools:
    path: ../debug_tools
   ```
This allows local development on the branch and changes are tracked to the correct repo.

2. Pulling through from the repository directly:

```yml
debug_tools:
  git:
      url: <link to this repo>
      ref: main # branch name
```
