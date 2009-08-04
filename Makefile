
VERSION := $(shell cd src && lua -e "require [[Coat]]; print(Coat._VERSION)")
TARBALL := lua-Coat-$(VERSION).tar.gz

manifest_pl := \
use strict; \
use warnings; \
my @files = qw(MANIFEST); \
while (<>) { \
    chomp; \
    next if m{^\.}; \
    push @files, $$_; \
} \
print join qq{\n}, sort @files;

rockspec_pl := \
use strict; \
use warnings; \
use Digest::MD5; \
my $$file = q{$(TARBALL)}; \
open my $$FH, $$file or die qq{$$!}; \
binmode $$FH; \
my %%config = ( \
    version => q{$(VERSION)}, \
    md5     => Digest::MD5->new->addfile($$FH)->hexdigest(), \
); \
close $$FH; \
while (<>) { \
    s/@(\w+)@/$$config{$$1}/g; \
    print; \
}

version:
	@echo $(VERSION)

tag:
	git tag -a -m 'tag release $(VERSION)' $(VERSION)

MANIFEST:
	git ls-files | perl -e '$(manifest_pl)' > MANIFEST

$(TARBALL): MANIFEST
	cat MANIFEST | tar -zc -T - -f $(TARBALL)

dist: $(TARBALL)

rockspec: $(TARBALL)
	perl -e '$(rockspec_pl)' rockspec.in > rockspec

test:
	$(MAKE) -C test

clean:
	rm -f MANIFEST rockspec

.PHONY: test

