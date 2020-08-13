NAME ?= RZ-OneUI2-exynos9810

DATE := $(shell date +'%Y%m%d-%H%M')

ZIP := $(NAME)-$(DATE).zip

EXCLUDE := \
	Makefile README.md LICENSE make.sh *.git* "$(NAME)-"*.zip* \

all: $(ZIP)

$(ZIP):
	@echo "Creating ZIP: $(ZIP)"
	@zip -r9 "$@" . -x $(EXCLUDE)
	@echo "Done."

clean:
	@rm -vf "$(NAME)-"*.zip*
	@rm -rf *lte
	@echo "Done."
