KERNEL_NAME ?= RZ-LineageOS-exynos8895

DATE := $(shell date +'%Y%m%d-%H%M')

ZIP := $(KERNEL_NAME)-$(DATE).zip

EXCLUDE := \
	Makefile README.md LICENSE make.sh *.git* "$(KERNEL_NAME)-"*.zip* \

all: $(ZIP)

$(ZIP):
	@echo "Creating ZIP: $(ZIP)"
	@zip -r9 "$@" . -x $(EXCLUDE)
	@echo "Done."

clean:
	@rm -vf "$(KERNEL_NAME)-"*.zip*
	@rm -rf *lte
	@echo "Done."
