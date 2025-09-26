update-protobufs:

	rm -rf deadlock/steammessages_base.proto
	@for f in deadlock/*.proto; do \
        printf 'syntax = "proto2";\n\npackage deadlock;\noption go_package = "github.com/RyPort/paradox-parser/deadlock;deadlock";\n\n' > "$$f.tmp" && cat "$$f" >> "$$f.tmp" && mv "$$f.tmp" "$$f"; \
    done

	sed -E -i 's/([[:blank:]])\.([A-Za-z_][A-Za-z0-9_.]*)/\1\2/g' deadlock/*.proto


	sed -E -i 's/\(\.([^)]*)\)/(\1)/g' deadlock/*.proto


generate:
	protoc -I deadlock --go_out=paths=source_relative:deadlock  deadlock/*.proto

