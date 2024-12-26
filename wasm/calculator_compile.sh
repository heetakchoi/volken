emcc -o calculator.html calculator.c --shell-file html_template/skeleton.html -s NO_EXIT_RUNTIME=1 -s "EXPORTED_RUNTIME_METHODS=['ccall']"
