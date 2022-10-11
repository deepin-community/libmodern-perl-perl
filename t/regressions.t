#! perl

use Test::More 0.98;

use Modern::Perl ();

if ($ENV{PERL5OPT}) {
    plan( skip_all => "Cannot reliably test with PERL5OPT set" );
    exit 0;
}

$SIG{__WARN__} = sub
{
    return if $_[0] =~ /Number found where operator expected/;
    return if $_[0] =~ /Do you need to predeclare/;
    return if $_[0] =~ /future reserved word/;
    return if $_[0] =~ /given is experimental/;
    warn shift
};

eval 'sub { given (0) {} }';
isnt $@, '', 'use Modern::Perl () does not enable switch';
eval 'sub { say 0 }';
isnt $@, '', 'use Modern::Perl () does not enable say';
eval 'state $x;';
isnt $@, '', 'use Modern::Perl () does not enable state';
is uc "\xdf", "\xdf", 'Modern::Perl () does not enable unicode_strings';

{
    use Modern::Perl 2009;
    eval 'sub { given (0) {} }';
    is $@, '', q|use Modern::Perl 2009 enables switch|;
    eval 'sub { say 0 }';
    is $@, '', q|use Modern::Perl 2009 enables say|;
    eval 'state $x';
    is $@, '', q|use Modern::Perl 2009 enables state|;
    is uc "\xdf", "\xdf", 'but not unicode_strings';
}

{
    use Modern::Perl 2010;
    eval 'sub { given (0) {} }';
    is $@, '', q|use Modern::Perl 2010 enables switch|;
    eval 'sub { say 0 }';
    is $@, '', q|use Modern::Perl 2010 enables say|;
    eval 'state $x';
    is $@, '', q|use Modern::Perl 2010 enables state|;
    is uc "\xdf", "\xdf", 'but not unicode_strings';
}

if ($] >= 5.012)
{
    eval <<'END_HERE';
    use Modern::Perl 2011;
    eval 'sub { given (0) {} }';
    is $@, '', q|use Modern::Perl 2011 enables switch|;
    eval 'sub { say 0 }';
    is $@, '', q|use Modern::Perl 2011 enables say|;
    eval 'state $x';
    is $@, '', q|use Modern::Perl 2011 enables state|;
    is uc "\xdf", "SS", '2011 enables unicode_strings';
END_HERE
}

if ($] >= 5.014)
{
    eval <<'END_HERE';
    use Modern::Perl 2012;
    eval 'sub { given (0) {} }';
    is $@, '', q|use Modern::Perl 2012 enables switch|;
    eval 'sub { say 0 }';
    is $@, '', q|use Modern::Perl 2012 enables say|;
    eval 'state $x';
    is $@, '', q|use Modern::Perl 2012 enables state|;
    is uc "\xdf", "SS", '2012 enables unicode_strings';
END_HERE
}

eval 'sub { given (0) {} }';
isnt $@, "", 'switch feature does not leak out';
eval 'sub { say 0 }';
isnt $@, '', 'say feature does not leak out';
eval 'state $x';
isnt $@, '', 'state feature does not leak out';
is uc "\xdf", "\xdf", 'unicode_strings feature does not leak out';


# RT #80304: warning on Modern::Perl->VERSION()
{
    my    $warning           = '';
    local $SIG{__WARN__}     = sub { $warning = shift };
    $Modern::Perl::VERSION ||= '1.20121103';

    my   $version            = Modern::Perl->VERSION;
    like $version, qr/1\.20\d/,
        'VERSION() should return version number, given no argument';
    is $warning, '', '... without warning about undef argument';
}

done_testing;
