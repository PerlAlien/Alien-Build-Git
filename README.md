# Alien::Build::Git [![Build Status](https://secure.travis-ci.org/plicease/Alien-Build-Git.png)](http://travis-ci.org/plicease/Alien-Build-Git)

Alien::Build tools for interacting with git

# SYNOPSIS

Using helper from [Alien::git](https://metacpan.org/pod/Alien::git):

```perl
use alienfile;

share {

  download [
    [ '%{git}', 'clone', 'http://example.com/project-foo.git' ],
  ];

  ...

};
```

Using plugin [Alien::Build::Plugin::Download::Git](https://metacpan.org/pod/Alien::Build::Plugin::Download::Git):

```perl
use alienfile;

meta->prop->{start_url} = 'http://example.com/project-foo.git';
plugin 'Download::Git' =>(
  version => qr/^v([0-9\.]+)$/,
);
```

# DESCRIPTION

This module is documentation only for how to use `git` as a download source
from [alienfile](https://metacpan.org/pod/alienfile) + [Alien::Build](https://metacpan.org/pod/Alien::Build).  Depending on the project source that you
are using and the way your [alienfile](https://metacpan.org/pod/alienfile) is structured, you will want to use
one of three modules that come with the distribution `Alien-Build-Git`.
See the synopsis above and the modules in the SEE ALSO section below.  To decide
which you need.

Also please carefully consider NOT using one of these modules.  If you can,
using http or ftp to download your target project will probably require fewer
and less error-prone dependencies.

# SEE ALSO

- [Alien::git](https://metacpan.org/pod/Alien::git)
- [Alien::Build::Plugin::Download::Git](https://metacpan.org/pod/Alien::Build::Plugin::Download::Git)
- [Alien::Build::Plugin::Fetch::Git](https://metacpan.org/pod/Alien::Build::Plugin::Fetch::Git)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
