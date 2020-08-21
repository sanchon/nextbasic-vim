nextbasic-vim
=============

vim plugin that helps with zx spectrum next basic development

Because vim cannot edit tokenized .bas files I've decided that I'll use the .txtbas (plain text "bas" files) as the nextbasic file extension, when compiled
they will be converted to .bas


BackLog
-------
  
  - [x] Detect .bas files as nextbasic files
  - [ ] Compile and run .bas files with CSpect and HDFMonkey
    * [x] Convert plain text bas (.txtbas) files into compiled (.bas) files with nextbasic2txt.py (by Kounch)
    * [x] Push files into disk image with hdfmonkey
    * [ ] Refactor the code that calculates .bas file path, join Compile() and Deploy() functions
  - [ ] Port language syntax to vim from VSCode and ZX Basic




Useful links
------------

  * [CSpect](http://dailly.blogspot.com/)
  * [HDFMonkey by Matt Westcott](https://github.com/gasman/hdfmonkey), [windows version by Uto](https://uto.speccy.org) 
  * [VSCode NextBasic Add-on by Remy Sharp](https://github.com/remy/vscode-nextbasic)
  * [VSCode NextBasic Add-on by Kounch] (https://github.com/kounch/vscode_zx)
  * [txt2bas by Remy Sharp](https://github.com/remy/txt2bas)
  * [Link to a file in an external repository](https://stackoverflow.com/questions/15844542/git-symlink-reference-to-a-file-in-an-external-repository/27770463#27770463)
