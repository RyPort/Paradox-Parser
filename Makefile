update-protobufs:
	$(SED) -i '1isyntax = "proto2";\n\npackage deadlock;\noption go_package = "github.com/RyPort/paradox-parser/deadlock;deadlock";\n' deadlock/*.proto