SYSCONFDIR = /etc
PREFIX ?= /usr
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/share/man
LIBDIR = $(PREFIX)/lib

RCDIR = $(SYSCONFDIR)/rc
RCLIBDIR = $(LIBDIR)/rc
RCSVDIR = /usr/share/rc/sv.d
RCENABLEDDIR = /etc/rc/sv.d
RCRUNDIR = /run/sv.d
RUNITDIR = /etc/runit
RUNITRUNDIR = /run/runit

RCBIN = \
	script/modules-load \
	script/service

RCSTAGE1 = \
    stage1/00-pseudofs \
    stage1/01-cgroups \
    stage1/01-static-devnodes \
    stage1/02-modules \
    stage1/02-udev \
    stage1/03-console-setup \
    stage1/03-hwclock \
    stage1/04-rootfs \
    stage1/05-btrfs \
    stage1/06-fsck \
    stage1/07-mountfs \
    stage1/08-misc \
    stage1/11-sysctl \
    stage1/99-cleanup

RCLVM1 = stage1/05-lvm

RCLVM3 = stage3/40-lvm

RCCRYPT1 = stage1/06-cryptsetup

RCCRYPT3 = stage3/50-cryptsetup

RCSTAGE3 = \
    stage3/10-misc \
    stage3/30-killall \
    stage3/40-filesystem \
    stage3/99-remount-root

CONF = script/rc.conf

RCFUNC = script/functions script/cgroup-release-agent

LN = ln -sf
RM = rm -f
RMD = rm -fr --one-file-system
M4 = m4 -P
CHMODAW = chmod a-w
CHMODX = chmod +x

EDIT = sed \
	-e "s|@RCDIR[@]|$(RCDIR)|g" \
	-e "s|@RCLIBDIR[@]|$(RCLIBDIR)|g" \
	-e "s|@RCSVDIR[@]|$(RCSVDIR)|g" \
	-e "s|@RUNITDIR[@]|$(RUNITDIR)|g" \
	-e "s|@RUNITRUNDIR[@]|$(RUNITRUNDIR)|g" \
	-e "s|@RCRUNDIR[@]|$(RCRUNDIR)|g" \
	-e "s|@RCENABLEDDIR[@]|$(RCENABLEDDIR)|g"

%: %.in Makefile
	@echo "GEN $@"
	@$(RM) "$@"
	@$(M4) $@.in | $(EDIT) >$@
	@$(CHMODAW) "$@"
	@$(CHMODX) "$@"

all: all-rc

all-rc: $(RCBIN) $(RCSTAGE1) $(RCSTAGE3) $(RCCRYPT1) $(RCCRYPT3) $(RCLVM1) $(RCLVM3) $(RCFUNC) $(CONF)

install-rc:

	install -d $(DESTDIR)$(RCDIR)
	install -m755 $(CONF) $(DESTDIR)$(RCDIR)

	install -d $(DESTDIR)$(BINDIR)
	install -m755 $(RCBIN) $(DESTDIR)$(BINDIR)

	install -d $(DESTDIR)$(RCLIBDIR)
	install -m755 $(RCFUNC) $(DESTDIR)$(RCLIBDIR)

	install -d $(DESTDIR)$(RCSVDIR)
	install -m755 $(RCSVD) $(DESTDIR)$(RCSVDIR)

	install -d $(DESTDIR)$(RCENABLEDDIR)

	install -d $(DESTDIR)$(RCLIBDIR)/stage1
	install -m755 $(RCSTAGE1) $(DESTDIR)$(RCLIBDIR)/stage1/

	install -d $(DESTDIR)$(RCLIBDIR)/stage3/
	install -m755 $(RCSTAGE3) $(DESTDIR)$(RCLIBDIR)/stage3/

	install -d $(DESTDIR)$(MANDIR)/man8
	install -m644 man/modules-load.8 $(DESTDIR)$(MANDIR)/man8
	install -m644 man/service.8 $(DESTDIR)$(MANDIR)/man8

install-lvm:
	install -d $(DESTDIR)$(RCLIBDIR)/stage1
	install -m755 $(RCCRYPT1) $(DESTDIR)$(RCLIBDIR)/stage1/

	install -d $(DESTDIR)$(RCLIBDIR)/stage3/
	install -m755 $(RCCRYPT3) $(DESTDIR)$(RCLIBDIR)/stage3/

install-crypt:
	install -d $(DESTDIR)$(RCLIBDIR)/stage1
	install -m755 $(RCCRYPT1) $(DESTDIR)$(RCLIBDIR)/stage1/

	install -d $(DESTDIR)$(RCLIBDIR)/stage3/
	install -m755 $(RCCRYPT3) $(DESTDIR)$(RCLIBDIR)/stage3/

install-services:
	install -d $(DESTDIR)$(RCSVDIR)/binfmt
	install -m755 sv.d/binfmt/up $(DESTDIR)$(RCSVDIR)/binfmt
	install -m755 sv.d/binfmt/down $(DESTDIR)$(RCSVDIR)/binfmt
	install -d $(DESTDIR)$(RCSVDIR)/netmount
	install -m755 sv.d/netmount/up $(DESTDIR)$(RCSVDIR)/netmount
	install -m755 sv.d/netmount/down $(DESTDIR)$(RCSVDIR)/netmount
	install -d $(DESTDIR)$(RCSVDIR)/staticnet
	install -m755 sv.d/staticnet/up $(DESTDIR)$(RCSVDIR)/staticnet
	install -m755 sv.d/staticnet/down $(DESTDIR)$(RCSVDIR)/staticnet

install: install-rc

clean-rc:
	-$(RM) $(RCBIN) $(RCSVD) $(RCSTAGE1) $(RCSTAGE3) $(RCCRYPT1) $(RCCRYPT3) $(RCLVM1) $(RCLVM3) $(RCFUNC) $(CONF)

clean: clean-rc

.PHONY: all install clean install-rc clean-rc all-rc install-lvm install-crypt
