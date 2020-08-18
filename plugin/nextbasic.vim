"the root of the plugin 
let s:nextbasicDir = expand('<sfile>:p:h:h')
"the plugin subfolder (where this file is located)
let s:nextbasicDirPlugin = expand('<sfile>:p:h')


" in this context "compile" means convert from plain text format to zx
" spectrum tokenized .bas file
function! Compile()

	" the default command is a python script, user can configure the
	" python command keeping the default script
	if !exists("g:nextbasic_python_executable")
		let g:nextbasic_python_executable = "python"
	endif

	" or the whole txt2nextbasic command can be customized, should the
	" user have another alternative
	if !exists("g:nextbasic_txt2nextbasic_command")
		let g:nextbasic_txt2nextbasic_command = g:nextbasic_python_executable . " " . s:nextbasicDirPlugin . "/txt2nextbasic.py"
	endif

	" the default command needs some command line arguments, we will use
	" __BASFILE__ and __TXTBASFILE__ as place holders, so that the user
	" can customize freely the command line arguments
	if !exists("g:nextbasic_txt2nextbasic_command_args")
		let g:nextbasic_txt2nextbasic_command_args = " -i BASFILE -o TXTBASFILE "
	endif
	" current file name, with full path
	let s:txtbasfile = expand("%:p")
	" current file name extension (should be .txtbas)
	let s:txtbasfileExtension = expand("%:e")
	" current file name without file extension but with full path
	let s:txtbasfileNoExtension = expand("%:p:r")
	" the compiled one will be bas
	let s:basfile = s:txtbasfileNoExtension . ".bas"

	" now we can substitute __BASFILE__ and __TXTBASFILE__ in the command
	" line arguments
	echo (g:nextbasic_txt2nextbasic_command_args)
	let s:compile_command_args = substitute(g:nextbasic_txt2nextbasic_command_args, "BASFILE", escape(s:txtbasfile, '\ '), "")
	echo (s:compile_command_args)
	let s:compile_command_args = substitute(s:compile_command_args, "TXTBASFILE", escape(s:basfile, '\ '), "")
	echo (s:compile_command_args)
	let s:compile_command = g:nextbasic_txt2nextbasic_command . s:compile_command_args
             

	execute ("!".s:compile_command)

endfunction

