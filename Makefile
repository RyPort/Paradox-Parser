update-protobufs:
	@for f in deadlock/*.proto; do \
        printf 'syntax = "proto2";\n\npackage deadlock;\noption go_package = "github.com/RyPort/paradox-parser/deadlock;deadlock";\n\n' > "$$f.tmp" && cat "$$f" >> "$$f.tmp" && mv "$$f.tmp" "$$f"; \
    done

	@for f in deadlock/*.proto; do \
        tmp="$$f.tmp"; \
        # remove leading dot only when followed by an uppercase identifier (safe for .google.protobuf) \
        sed -E 's/\.([A-Z][A-Za-z0-9_.]*)/\1/g' "$$f" > "$$tmp" && mv "$$tmp" "$$f"; \
    done
