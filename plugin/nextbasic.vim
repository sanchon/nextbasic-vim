" the root folder of the plugin 
let s:nextbasicDir = expand('<sfile>:p:h:h')
" the "ftplugin" subfolder (where this file is/will be located)
let s:nextbasicDirPlugin = expand('<sfile>:p:h')




"name of the file being edited (with .txtbas file extension)
function s:txtbasFileName()
	return expand("%:t")
endfunction


"location of the file being edited (.txtbas file extension)
function s:txtbasPath()
	return expand("%:p")
endfunction


"name of the compiled file (with .bas file extension)
function s:basFileName()
	return expand("%:t:r") . ".bas"
endfunction

"location of the compiled file (same as .txtbas but with .bas file extension)
function s:basPath()
	return expand("%:p:r") . ".bas"
endfunction



" in this context "compile" means convert from plain text format to zx
" spectrum tokenized .bas file
function! Compile()
   call s:compile(s:txtbasPath(), s:basPath())
endfunction


" compile a .txtbasfile into a .bas file, full paths please
function! s:compile(txtbasfile, basfile)

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
	let s:compile_command_args = substitute(g:nextbasic_txt2nextbasic_command_args, "BASFILE", escape(a:txtbasfile, '\ '), "")
	let s:compile_command_args = substitute(s:compile_command_args, "TXTBASFILE", escape(a:basfile, '\ '), "")
	let s:compile_command = g:nextbasic_txt2nextbasic_command . s:compile_command_args
        
	" run command
	let s:command_res = system (s:compile_command)
	if (v:shell_error != 0)
		throw("Error converting .txtbas " . a:txtbasfile . " to .bas " . a:basfile . "ERROR: " . s:command_res)
	endif

endfunction




" TODO remove this 
let g:nextbasic_zxnextImg_file = 'C:\Users\hugo\Documents\Spectrum\devel\cspect-next-2gb\cspect-next-2gb.img'


function! Deploy()

	call s:deploy(s:basPath(), "devel")

endfunction

" "Deploy" means copy the .bas file (tokenized) into the .img (hdf) file that
" cspect uses to emulate zx next
function! s:deploy(localfile, remotepath)

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

	" create requested remote path if it does not existe
	let s:deploy_command = g:nextbasic_hdfmonkey_executable . " mkdir " . g:nextbasic_zxnextImg_file . " " . a:remotepath
	let s:command_res = system (s:deploy_command)
	if (v:shell_error != 0)
		if stridx(s:command_res, "directory already exists") == 0
			throw("Error creating devel directory in .img file: " . s:command_res)
		else
			"directory already exists, that's ok
		endif
	endif

	" put file into remote directory
	let s:deploy_command = g:nextbasic_hdfmonkey_executable . " put " . g:nextbasic_zxnextImg_file . " " . a:localfile . " " . a:remotepath
	let s:command_res = system (s:deploy_command)
	if (v:shell_error != 0)
		throw("Error putting .bas file into .img file: " . s:command_res)
	endif

endfunction


" "Run" means copy a custom made autoexec.bas into the HDF file and then
" launching the emulator. So far, cspect.
function! Run()

endfunction


function! s:createAutoexecBas()

	"create a file called "autoexec.bastxt" that autoruns the .bas file
	let l:text =            ["#program autoexec"]
	call add(l:text, "#autostart")
	call add(l:text, "10 .cd devel")
	call add(l:text, '20 ; ON ERROR PRINT "Error": ERROR TO e,l,s,b: INK 7: PAPER 0: PRINT AT 0,0;"code ";e;" at ";l;":";statement: PAUSE 0: ON ERROR: STOP')
	call add(l:text, '30 LOAD "' . s:basFileName() . '": RUN: PAUSE 0')
	let l:autoexecTxtbasPath = expand("%:p:h") . "/autoexec.txtbas"
	let l:autoexecBasPath = expand("%:p:h") . "/autoexec.bas"
  	call writefile(l:text, l:autoexecTxtbasPath)
	
	" compile (tokenize) into a suitable autoexec.bas file
	call s:compile(l:autoexecTxtbasPath, l:autoexecBasPath)	

	" push it to the hdf (.img) file
	call s:deploy(l:autoexecBasPath, "NEXTZXOS")


endfunction


function! Test()
    call s:createAutoexecBas()
endfunction


