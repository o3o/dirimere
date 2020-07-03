# Dirimere
A tool for D language that installs dependencies from arbitrary git repos/branches locally.

Based on work by [Timur Gafarov](https://github.com/gecko0307/resolve).


## Usage
1. Create a `dirimere.json` file in your Dub project. It should look like this:

```json
[
   {"name": "alyx2", "version": "v0.13.0", "url" : "git@gitlab.com:o3o_d/alyx2.git"},
   {"name": "bindbc-raylib", "version": "0.1.0", "url" : "git@github.com:o3o/bindbc-raylib.git"}
]
```

2. Modify your dub file on order to use `.mirror`
```
//dub.sdl
dependency "alyx2:db" path="./.mirror/alyx2-0.13.0"
```

3. Install `dirimere` and run it:
```
dub fetch dirimere
dub run dirimere
```
It will create `.mirror` folder and clone the repositories. It is recommended to add `.mirror` folder to `.gitignore`.

4. Build your project with Dub as usual.

## Json file
### name
Name of package. Will be used to create the path where the gits get cloned to.

### version
Version of package. Will be used to get the tag and create the path where the gits get cloned to.
Must be v`m.n.p` or `m.n.p`. (examples `v0.1.0`, `1.5.0`, etc)

### url
Repository URL.



## References
- [resolve](https://github.com/gecko0307/resolve)
- [dubproxy](https://github.com/symmetryinvestments/dubproxy)
