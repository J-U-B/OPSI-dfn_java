############################################################
# OPSI package Makefile (JAVA)
# Version: 1.5
# Jens Boettge <boettge@mpi-halle.mpg.de>
# 2017-08-24 07:07:56 +0200
############################################################

.PHONY: header clean mpimsp dfn mpimsp_test dfn_test all_test all_prod all help
#.DEFAULT_GOAL := mpimsp_test
.DEFAULT_GOAL := help

OPSI_BUILDER = opsi-makeproductfile
BUILD_DIR = ./BUILD
PACKAGE_DIR = ./PACKAGES
SRC_DIR = ./SRC

PYSTACHE = ./SRC/pystache_opsi.py
BUILD_JSON = $(BUILD_DIR)/build.json
CONTROL_IN = $(SRC_DIR)/OPSI/control.in
CONTROL = $(BUILD_DIR)/OPSI/control
OPSI_FILES := control preinst postinst
# FILES_IN := checkinstance.opsiinc delsub.opsiinc exit_code_msi.opsiinc setup.opsiscript
FILES_IN := $(basename $(shell (cd $(SRC_DIR)/CLIENT_DATA; ls *.in)))

PACKAGE ?= full
PACKAGE_TYPES="[jre] [jdk] [full]"
PKGX := $(firstword $(PACKAGE))
PKGY := $(shell echo $(PKGX) | tr A-Z a-z)

TODAY := $(shell date +"%Y-%m-%d")

ifeq (, $(findstring [$(PKGY)],$(PACKAGE_TYPES)))
	PKG = full
else
	PKG = $(PKGY)
endif

ifeq (jre,$(PKG))
	BUILD_FOR_JRE = true
	BUILD_FOR_JDK = false
else ifeq  ($(PKG),jdk)
	BUILD_FOR_JRE = false
	BUILD_FOR_JDK = true
else
	BUILD_FOR_JRE = true
	BUILD_FOR_JDK = true
endif


ARCHIVE_FORMAT ?= cpio
ARCHIVE_TYPES :="[cpio] [tar]"
AFX := $(firstword $(ARCHIVE_FORMAT))
AFY := $(shell echo $(AFX) | tr A-Z a-z)

ifeq (,$(findstring [$(AFY)],$(ARCHIVE_TYPES)))
	BUILD_FORMAT = cpio
else
	BUILD_FORMAT = $(AFY)
endif

leave_err:
	exit 1

var_test:
	@echo "=================================================================="
	@echo "* Choosen package type: \n\t[$(PACKAGE)][$(PKGX)][$(PKGY)][$(PKGZ)]" 
	@echo "	 --> $(PKG)	[build JRE:$(BUILD_FOR_JRE), build JDK:$(BUILD_FOR_JDK)]"
	@echo "* OPSI Archive Types: [$(ARCHIVE_TYPES)]"
	@echo "* OPSI Archive Format: [$(ARCHIVE_FORMAT)][$(AFX)][$(AFY)][$(AFZ)] \n\t--> $(BUILD_FORMAT)"
	@echo "=================================================================="


header:
	@echo "=================================================================="
	@echo "                      Building OPSI package(s)"
	@echo "=================================================================="

mpimsp: header
	@echo "---------- building MPIMSP package -------------------------------"
	@make 	TESTPREFIX=""	 \
			ORGNAME="MPIMSP" \
			ORGPREFIX=""     \
			STAGE="release"  \
	build

dfn: header
	@echo "---------- building DFN package ----------------------------------"
	@make 	TESTPREFIX=""    \
			ORGNAME="DFN"    \
			ORGPREFIX="dfn_" \
			STAGE="release"  \
	build

mpimsp_test: header
	@echo "---------- building MPIMSP testing package -----------------------"
	@make 	TESTPREFIX="0_"	 \
			ORGNAME="MPIMSP" \
			ORGPREFIX=""     \
			STAGE="testing"  \
	build

dfn_test: header
	@echo "---------- building DFN testing package --------------------------"
	@make 	TESTPREFIX="test_"  \
			ORGNAME="DFN"    \
			ORGPREFIX="dfn_" \
			STAGE="testing"  \
	build

dfn_test_0: header
	@echo "---------- building DFN testing package --------------------------"
	@make 	TESTPREFIX="0_"  \
			ORGNAME="DFN"    \
			ORGPREFIX="dfn_" \
			STAGE="testing"  \
	build

dfn_test_noprefix: header
	@echo "---------- building DFN testing package --------------------------"
	@make 	TESTPREFIX=""    \
			ORGNAME="DFN"    \
			ORGPREFIX="dfn_" \
			STAGE="testing"  \
	build

clean_packages: header
	@echo "---------- cleaning packages, checksums and zsync ----------------"
	@rm -f $(PACKAGE_DIR)/*.md5 $(PACKAGE_DIR)/*.opsi $(PACKAGE_DIR)/*.zsync
	
clean: header
	@echo "---------- cleaning  build directory -----------------------------"
	@rm -rf $(BUILD_DIR)	
	
help: header
	@echo "Valid targets: "
	@echo "	mpimsp"
	@echo "	mpimsp_test"
	@echo "	dfn"
	@echo "	dfn_test"
	@echo "	dfn_test_0"
	@echo "	dfn_test_noprefix"
	@echo "	all_prod"
	@echo "	all_test"
	@echo "	clean"
	@echo "	clean_packages"
	@echo ""
	@echo "Options:"
	@echo "	PACKAGE=[jre|jdk|full]          (default: full)"
	@echo "	ARCHIVE_FORMAT=[cpio|tar]       (default: cpio)"

all_test:  header mpimsp_test dfn_test dfn_test_0

all_prod : header mpimsp dfn

build_dirs:
	@echo "* Creating/checking directories"
	@if [ ! -d "$(BUILD_DIR)" ]; then mkdir -p "$(BUILD_DIR)"; fi
	@if [ ! -d "$(BUILD_DIR)/OPSI" ]; then mkdir -p "$(BUILD_DIR)/OPSI"; fi
	@if [ ! -d "$(BUILD_DIR)/CLIENT_DATA" ]; then mkdir -p "$(BUILD_DIR)/CLIENT_DATA"; fi
	
copy_from_src:	build_dirs
	@echo "* Copying files"
	@cp -upL $(SRC_DIR)/CLIENT_DATA/LICENSE  $(BUILD_DIR)/CLIENT_DATA/
	@cp -upL $(SRC_DIR)/CLIENT_DATA/readme.md  $(BUILD_DIR)/CLIENT_DATA/
	@cp -upr $(SRC_DIR)/CLIENT_DATA/bin  $(BUILD_DIR)/CLIENT_DATA/
	@cp -upr $(SRC_DIR)/CLIENT_DATA/*.opsiscript  $(BUILD_DIR)/CLIENT_DATA/
	@cp -upr $(SRC_DIR)/CLIENT_DATA/*.opsiinc     $(BUILD_DIR)/CLIENT_DATA/
	@if [ -d "$(SRC_DIR)/CLIENT_DATA/custom" ]; then  cp -upr $(SRC_DIR)/CLIENT_DATA/custom     $(BUILD_DIR)/CLIENT_DATA/ ; fi
	@if [ -d "$(SRC_DIR)/CLIENT_DATA/files" ];  then  cp -upr $(SRC_DIR)/CLIENT_DATA/files      $(BUILD_DIR)/CLIENT_DATA/ ; fi
	@if [ -d "$(SRC_DIR)/CLIENT_DATA/images" ];  then  \
		mkdir -p "$(BUILD_DIR)/CLIENT_DATA/images"; \
		cp -up $(SRC_DIR)/CLIENT_DATA/images/*.png  $(BUILD_DIR)/CLIENT_DATA/images/; \
	fi
	@if [ -f  "$(SRC_DIR)/OPSI/control" ];  then cp -up $(SRC_DIR)/OPSI/control   $(BUILD_DIR)/OPSI/; fi
	@if [ -f  "$(SRC_DIR)/OPSI/preinst" ];  then cp -up $(SRC_DIR)/OPSI/preinst   $(BUILD_DIR)/OPSI/; fi 
	@if [ -f  "$(SRC_DIR)/OPSI/postinst" ]; then cp -up $(SRC_DIR)/OPSI/postinst  $(BUILD_DIR)/OPSI/; fi
	
	
	
build: copy_from_src
	@echo "* Choosen package type: $(PACKAGE)  [JRE:$(BUILD_FOR_JRE), JDK:$(BUILD_FOR_JDK)]"
	@$(if $(filter $(STAGE),testing), $(eval TESTING :="true"), $(eval TESTING : = "false"))
	@echo "* Creating $(BUILD_JSON)"
	@rm -f $(BUILD_JSON)
	$(PYSTACHE) spec.json "{ \"BUILD_FOR_JDK\": \"$(BUILD_FOR_JDK)\", \
	                         \"BUILD_FOR_JRE\": \"$(BUILD_FOR_JRE)\", \
	                         \"M_TODAY\"      : \"$(TODAY)\",         \
	                         \"M_STAGE\"      : \"$(STAGE)\",         \
	                         \"M_ORGNAME\"    : \"$(ORGNAME)\",       \
	                         \"M_ORGPREFIX\"  : \"$(ORGPREFIX)\",     \
	                         \"M_TESTPREFIX\" : \"$(TESTPREFIX)\",    \
	                         \"M_TESTING\"    : \"$(TESTING)\"        }" > $(BUILD_JSON)
	
	@echo "* Creating $(CONTROL)"
	@rm -f $(CONTROL)
	@$(PYSTACHE) $(CONTROL_IN) $(BUILD_JSON) > $(CONTROL)

	@echo "* Creating OPSI/postinst"
	@rm -f $(BUILD_DIR)/OPSI/postinst
	@${PYSTACHE} $(SRC_DIR)/OPSI/postinst.in $(BUILD_JSON) > $(BUILD_DIR)/OPSI/postinst
	
	for F in $(FILES_IN); do \
		echo "* Creating CLIENT_DATA/$$F"; \
		rm -f $(BUILD_DIR)CLIENT_DATA/$$F; \
		${PYSTACHE} $(SRC_DIR)/CLIENT_DATA/$$F.in $(BUILD_JSON) > $(BUILD_DIR)/CLIENT_DATA/$$F; \
	done
	
	@echo "* OPSI Archive Format: $(BUILD_FORMAT)"
	@echo "* Building OPSI package"
	@cd "$(CURDIR)/$(PACKAGE_DIR)" && $(OPSI_BUILDER) -F $(BUILD_FORMAT) -k -m $(CURDIR)/$(BUILD_DIR)
	
	cd $(CURDIR)


all_test:  header mpimsp_test dfn_test

all_prod : header mpimsp dfn

all : header mpimsp dfn mpimsp_test dfn_test
