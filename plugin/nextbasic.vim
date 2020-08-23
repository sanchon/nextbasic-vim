"the root of the plugin 
let s:nextbasicDir = expand('<sfile>:p:h:h')
"the plugin subfolder (where this file is located)
let s:nextbasicDirPlugin = expand('<sfile>:p:h')








function s:txtbasFile()
	return expand("%:p")
endfunction

function s:txtbasFileExtension()
	return expand ("%:e")
endfunction

function s:basFile()
	let l:txtbasfileNoExtension = expand("%:p:r")
	return l:txtbasfileNoExtension . ".bas"
endfunction







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
	" __BASFILE__ and __TXTBASFILE__ as placeholders, so that the user
	" can customize freely the command line arguments
	if !exists("g:nextbasic_txt2nextbasic_command_args")
		let g:nextbasic_txt2nextbasic_command_args = " -i BASFILE -o TXTBASFILE "
	endif

	" now we can substitute __BASFILE__ and __TXTBASFILE__ in the command
	" line arguments
	let s:compile_command_args = substitute(g:nextbasic_txt2nextbasic_command_args, "BASFILE", escape(s:txtbasFile(), '\ '), "")
	let s:compile_command_args = substitute(s:compile_command_args, "TXTBASFILE", escape(s:basFile(), '\ '), "")
	let s:compile_command = g:nextbasic_txt2nextbasic_command . s:compile_command_args
        
	" run command
	let s:command_res = system (s:compile_command)
	if (v:shell_error != 0)
		throw("Error converting .txtbas to .bas: " . s:command_res)
	endif

endfunction




" TODO remove this 
let g:nextbasic_zxnextImg_file = 'C:\Users\hugo\Documents\Spectrum\devel\cspect-next-2gb\cspect-next-2gb.img'

function! Deploy()

	" if hdfmonkey is available in system path it just works, otherwise we
	" need to know its path
	if !exists("g:nextbasic_hdfmonkey_executable")
		let g:nextbasic_hdfmonkey_executable = "hdfmonkey"
	endif

	" there is no sensible default for zxnext image file, so if there
	" isn't one we have to fail
	if !exists("g:nextbasic_zxnextImg_file")
		throw("I don't know where the disk image is, please assign a value to g:nextbasic_zxnextImg_file")
	endif

	" create a 'devel' directory inside zxnext image
	let s:deploy_command = g:nextbasic_hdfmonkey_executable . " mkdir " . g:nextbasic_zxnextImg_file . " devel"
	let s:command_res = system (s:deploy_command)
	if (v:shell_error != 0)
		if stridx(s:command_res, "directory already exists") == 0
			throw("Error creating devel directory in .img file: " . s:command_res)
		else
			"directory already exists, that's ok
		endif
	endif

	" put file into 'devel' directory
	let s:deploy_command = g:nextbasic_hdfmonkey_executable . " put " . g:nextbasic_zxnextImg_file . " " . s:basFile() . " devel "
	let s:command_res = system (s:deploy_command)
	if (v:shell_error != 0)
		throw("Error putting .bas file into .img file: " . s:command_res)
	endif

endfunction

