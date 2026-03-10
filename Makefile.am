# not a GNU package. You can remove this line, if
# have all needed files, that a GNU package needs
AUTOMAKE_OPTIONS = gnu 1.6

# make sure we pass the correct jimtcl flags to distcheck
DISTCHECK_CONFIGURE_FLAGS = --disable-install-jim

# do not run Jim Tcl tests (esp. during distcheck)
check-recursive: SUBDIRS :=



SUBDIRS =
DIST_SUBDIRS =
bin_PROGRAMS =
noinst_LTLIBRARIES =
info_TEXINFOS =
dist_man_MANS =
EXTRA_DIST =

if INTERNAL_JIMTCL
SUBDIRS += jimtcl
DIST_SUBDIRS += jimtcl
endif

# common flags used in openocd build
AM_CFLAGS = $(GCC_WARNINGS)

AM_CPPFLAGS = $(HOST_CPPFLAGS)\
			  -I$(top_srcdir)/src \
			  -I$(top_builddir)/src \
			  -I$(top_srcdir)/src/helper \
			  -DPKGDATADIR=\"$(pkgdatadir)\" \
			  -DBINDIR=\"$(bindir)\"

if INTERNAL_JIMTCL
AM_CPPFLAGS += -I$(top_srcdir)/jimtcl \
			   -I$(top_builddir)/jimtcl
endif
EXTRA_DIST += \
	NEWTAPS \
	$(EXTRA_DIST_NEWS) \
	tools/logger.pl \
	tools/rlink_make_speed_table \
	tools/st7_dtc_as

libtool: $(LIBTOOL_DEPS)
	$(SHELL) ./config.status --recheck



TCL_PATH = tcl
# command to find paths of script files, relative to TCL_PATH
TCL_FILES = find $(srcdir)/$(TCL_PATH) -name '*.cfg' -o -name '*.tcl' -o -name '*.txt' | \
		sed -e 's,^$(srcdir)/$(TCL_PATH),,'

dist-hook:
	if test -d $(srcdir)/.git -a \( ! -e $(distdir)/ChangeLog -o -w $(distdir)/ChangeLog \) ; then \
		git --git-dir $(srcdir)/.git log | $(srcdir)/tools/git2cl/git2cl > $(distdir)/ChangeLog ; \
	fi
	for i in $$($(TCL_FILES)); do \
		j="$(distdir)/$(TCL_PATH)/$$i" && \
		mkdir -p "$$(dirname $$j)" && \
		$(INSTALL_DATA) $(srcdir)/$(TCL_PATH)/$$i $$j; \
	done

install-data-hook:
	for i in $$($(TCL_FILES)); do \
		j="$(DESTDIR)$(pkgdatadir)/scripts/$$i" && \
		mkdir -p "$$(dirname $$j)" && \
		$(INSTALL_DATA) $(srcdir)/$(TCL_PATH)/$$i $$j; \
	done

uninstall-hook:
	rm -rf $(DESTDIR)$(pkgdatadir)/scripts

distclean-local:
	rm -f $(srcdir)/jimtcl/configure.gnu

DISTCLEANFILES =

METASOURCES = AUTO

BUILT_SOURCES =
CLEANFILES =

MAINTAINERCLEANFILES = \
	%D%/INSTALL \
	%D%/configure \
	%D%/Makefile.in \
	%D%/depcomp \
	%D%/config.guess \
	%D%/config.sub \
	%D%/config.h.in \
	%D%/config.h.in~ \
	%D%/compile \
	%D%/ltmain.sh \
	%D%/missing \
	%D%/aclocal.m4 \
	%D%/install-sh

include src/Makefile.am

