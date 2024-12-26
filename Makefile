.PHONY: dev release clean

dev:
	@./scripts/build.sh Debug

release: clean
	@./scripts/build.sh Release

clean:
	@rm -rf build
	@echo "Cleaned build directory"
