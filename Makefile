WAT2WASM=~/Documents/prog/wabt/bin/wat2wasm

main.wasm: main.wat
	$(WAT2WASM) main.wat
