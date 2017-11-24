############################################################
# OPSI package Makefile (JAVA)
# Version: 1.6
# Jens Boettge <boettge@mpi-halle.mpg.de>
# 2017-11-24 13:27:56 +0100
############################################################

.PHONY: header clean mpimsp dfn mpimsp_test dfn_test all_test all_prod all help
#.DEFAULT_GOAL := mpimsp_test
.DEFAULT_GOAL := help

OPSI_BUILDER = opsi-makeproductfile
BUILD_DIR = ./BUILD
DL_DIR = ./DOWNLOAD
PACKAGE_DIR = ./PACKAGES
SRC_DIR = ./SRC
PWD = ${CURDIR}

PYSTACHE = ./SRC/pystache_opsi.py
BUILD_JSON = $(BUILD_DIR)/build.json
CONTROL_IN = $(SRC_DIR)/OPSI/control.in
CONTROL = $(BUILD_DIR)/OPSI/control
DOWNLOAD_SH_IN = package_download.sh.in
DOWNLOAD_SH = package_download.sh
OPSI_FILES := control preinst postinst
# FILES_IN := checkinstance.opsiinc delsub.opsiinc exit_code_msi.opsiinc setup.opsiscript
FILES_IN := $(basename $(shell (cd $(SRC_DIR)/CLIENT_DATA; ls *.in)))

PACKAGE ?= full
PACKAGE_TYPES="[jre] [jdk] [full]"

ALLINC ?= false
ALLINC_SEL="[true] [false]"

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
	
realclean: header clean
	@echo "---------- cleaning  download directory --------------------------"
	@rm -rf $(DL_DIR)	
		
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
	@echo "	ALLINC=[true|false]             (default: false)"
	@echo "			...include software in OPSI package?"
	@echo "	ARCHIVE_FORMAT=[cpio|tar]       (default: cpio)"

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
	@if [ "$(ALLINC)" = "true" ]; then \
		echo "  * building all included package"; \
		if [ ! -d "$(BUILD_DIR)/CLIENT_DATA/files" ]; then mkdir -p "$(BUILD_DIR)/CLIENT_DATA/files"; fi; \
		rm -f $(BUILD_DIR)/CLIENT_DATA/files/* ; \
		if [ "$(BUILD_FOR_JRE)" = "true" ] ; then \
			echo "    * including JRE packages"; \
			for F in `ls $(PWD)/$(DL_DIR)/jre*`; do echo "      + $$F"; ln $$F $(BUILD_DIR)/CLIENT_DATA/files/; done; \
		fi; \
		if [ "$(BUILD_FOR_JDK)" = "true" ] ; then \
			echo "    * including JDK packages"; \
			for F in `ls $(PWD)/$(DL_DIR)/jdk*`; do echo "      + $$F"; ln $$F $(BUILD_DIR)/CLIENT_DATA/files/; done; \
		fi; \
	fi
	@if [ -d "$(SRC_DIR)/CLIENT_DATA/custom" ]; then  cp -upr $(SRC_DIR)/CLIENT_DATA/custom     $(BUILD_DIR)/CLIENT_DATA/ ; fi
	@if [ -d "$(SRC_DIR)/CLIENT_DATA/files" ];  then  cp -upr $(SRC_DIR)/CLIENT_DATA/files      $(BUILD_DIR)/CLIENT_DATA/ ; fi
	@if [ -d "$(SRC_DIR)/CLIENT_DATA/images" ];  then  \
		mkdir -p "$(BUILD_DIR)/CLIENT_DATA/images"; \
		cp -up $(SRC_DIR)/CLIENT_DATA/images/*.png  $(BUILD_DIR)/CLIENT_DATA/images/; \
	fi
	@if [ -f  "$(SRC_DIR)/OPSI/control" ];  then cp -up $(SRC_DIR)/OPSI/control   $(BUILD_DIR)/OPSI/; fi
	@if [ -f  "$(SRC_DIR)/OPSI/preinst" ];  then cp -up $(SRC_DIR)/OPSI/preinst   $(BUILD_DIR)/OPSI/; fi 
	@if [ -f  "$(SRC_DIR)/OPSI/postinst" ]; then cp -up $(SRC_DIR)/OPSI/postinst  $(BUILD_DIR)/OPSI/; fi

build_json:
	@if [ ! -d "$(BUILD_DIR)" ]; then mkdir -p "$(BUILD_DIR)"; fi
	@$(if $(filter $(STAGE),testing), $(eval TESTING :="true"), $(eval TESTING := "false"))
	@echo "* Creating $(BUILD_JSON)"
	@rm -f $(BUILD_JSON)
	$(PYSTACHE) spec.json "{ \"BUILD_FOR_JDK\": \"$(BUILD_FOR_JDK)\", \
	                         \"BUILD_FOR_JRE\": \"$(BUILD_FOR_JRE)\", \
	                         \"M_TODAY\"      : \"$(TODAY)\",         \
	                         \"M_STAGE\"      : \"$(STAGE)\",         \
	                         \"M_ORGNAME\"    : \"$(ORGNAME)\",       \
	                         \"M_ORGPREFIX\"  : \"$(ORGPREFIX)\",     \
	                         \"M_TESTPREFIX\" : \"$(TESTPREFIX)\",    \
	                         \"M_ALLINC\"     : \"$(ALLINC)\",    \
	                         \"M_TESTING\"    : \"$(TESTING)\"        }" > $(BUILD_JSON)


download: build_json
	@rm -f $(DOWNLOAD_SH)
	$(PYSTACHE) $(DOWNLOAD_SH_IN) $(BUILD_JSON) > $(DOWNLOAD_SH)
	@chmod +x $(DOWNLOAD_SH)
	@if [ ! -d "$(DL_DIR)" ]; then mkdir -p "$(DL_DIR)"; fi
	@DST=$(DL_DIR) ./$(DOWNLOAD_SH)
	
	
build: download copy_from_src
	@echo "* Choosen package type: $(PACKAGE)  [JRE:$(BUILD_FOR_JRE), JDK:$(BUILD_FOR_JDK)]"
	
	@make build_json
	
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


all_test:  header mpimsp_test dfn_test dfn_test_0

all_prod : header mpimsp dfn

all : header mpimsp dfn mpimsp_test qfn_test dfn_test_0
