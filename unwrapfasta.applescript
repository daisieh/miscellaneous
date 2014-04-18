tell application "BBEdit"
	activate
	set x to active document of window 1
	replace "(>.*)\\n" using "#\\1#" searching in text of x options {search mode:grep, starting at top:true, wrap around:false, backwards:false, case sensitive:false, match words:false, extend selection:false}
	replace "\\n" using "" searching in text of x options {search mode:grep, starting at top:true, wrap around:false, backwards:false, case sensitive:false, match words:false, extend selection:false}
	replace "#(.*?)#" using "\\n\\1\\n" searching in text of x options {search mode:grep, starting at top:true, wrap around:false, backwards:false, case sensitive:false, match words:false, extend selection:false}
	replace "^\\n" using "" searching in text of x options {search mode:grep, starting at top:true, wrap around:false, backwards:false, case sensitive:false, match words:false, extend selection:false}
end tell