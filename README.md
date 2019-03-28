# NAME

Perl::Critic::Policy::Catalyst::ProhibitUnreachableCode -
Don't write code after an unconditional Catalyst detach.

# DESCRIPTION

This module was forked from
[Perl::Critic::Policy::ControlStructures::ProhibitUnreachableCode](https://metacpan.org/pod/Perl::Critic::Policy::ControlStructures::ProhibitUnreachableCode)
version `1.132` and modified to fit.

The primary difference is this module looks for these two
Catalyst specific bits of code as signifying a terminating statement:

```
$c->detach();
$c->redirect_and_detach();
```

# SUPPORT

Please submit bugs and feature requests to the
Perl-Critic-Policy-Catalyst-ProhibitUnreachableCode GitHub issue tracker:

[https://github.com/bluefeet/Perl-Critic-Policy-Catalyst-ProhibitUnreachableCode/issues](https://github.com/bluefeet/Perl-Critic-Policy-Catalyst-ProhibitUnreachableCode/issues)

# AUTHORS

```
Aran Clary Deltac <bluefeet@gmail.com>
Peter Guzis <pguzis@cpan.org>
```

# ACKNOWLEDGEMENTS

Thanks to [ZipRecruiter](https://www.ziprecruiter.com/)
for encouraging their employees to contribute back to the open
source ecosystem.  Without their dedication to quality software
development this distribution would not exist.

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
