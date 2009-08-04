
PROJECT = lua-Coat
VERSION = $(shell cd src && lua -e "require 'Coat'; print(Coat._VERSION)")
DISTFILE= $(PROJECT)-$(VERSION).tar.gz

manifest_pl = \
use strict; \
use warnings; \
my @files = qw(MANIFEST); \
while (<>) { \
    chomp; \
    next if m{^\.}; \
    push @files, $$_; \
} \
print join qq{\n}, sort @files;

rockspec_pl = \
use strict; \
use warnings; \
use Digest::MD5; \
my $$file = q{$(DISTFILE)}; \
open my $$FH, $$file or die qq{$$!}; \
binmode $$FH; \
my $$md5 = Digest::MD5->new->addfile($$FH)->hexdigest(); \
while (<>) { \
    s/VERSION/$(VERSION)/; \
    s/MD5/$$md5/; \
    print; \
}

version:
	@echo $(VERSION)

tag:
	git tag -a -m 'tag release $(VERSION)' $(VERSION)

MANIFEST:
	git ls-files | perl -e '$(manifest_pl)' > MANIFEST

$(DISTFILE): MANIFEST
	cat MANIFEST | tar -zc -T - -f $(DISTFILE)

dist: $(DISTFILE)

rockspec: $(DISTFILE)
	perl -e '$(rockspec_pl)' rockspec.tmpl > rockspec

test:
	$(MAKE) -C test

clean:
	rm -f MANIFEST rockspec

.PHONY: test

