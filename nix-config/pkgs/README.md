# Custom nix packages

Under the rare condition that the upstream fixes to the nix packages is not
committed to the unstable package that you need right now, place the
corresponding files in this directory. You can the load the custom fixes using
the in the nix-modules using something like (notice the braces):

```nix
(pkgs.callPackage ../../pkgs/kicad.nix { })
```

By default this directory should be empty.
