SNAP_NAME=python0

python_dir=python-0.9.1

# Hand-crafted classic snap build magic, because as of snapcraft 2.24 it is not
# provided to the make plugin.
arch := $(shell $(CC) -dumpmachine)
SNAP_CORE=core

# Don't search in default locations
LDFLAGS += -Wl,-z,nodefaultlib
LDFLAGS += -Wl,--enable-new-dtags
# Search in the core snap
LDFLAGS += -Wl,-rpath,/snap/$(SNAP_CORE)/current/lib/$(arch):/snap/$(SNAP_CORE)/current/usr/lib/$(arch)
# Use the dynamic linker from the core snap
LDFLAGS += -Wl,--dynamic-linker=/snap/$(SNAP_CORE)/current/lib/$(arch)/ld-linux-x86-64.so.2

.PHONY: all
all:
	patch src/Makefile ../../../Makefile.patch
	$(MAKE) -C src \
		DEFPYTHONPATH=.:/snap/$(SNAP_NAME)/current/usr/lib/python0 \
		LDFLAGS="$(LDFLAGS)" \
		CFLAGS="-Wno-implicit-function-declaration"

.PHONY:
install:
	install -m 0755 --strip -D src/python $(DESTDIR)/usr/bin/python0
	install -d $(DESTDIR)/usr/lib/python0 
	install -m 0644 lib/*.py $(DESTDIR)/usr/lib/python0/

# The clobber target is like clean
.PHONY: clean
clean:
	$(MAKE) -C src clobber
