.PHONY: run
run: UI.lua love
	./love .

UI.lua:
	wget https://raw.githubusercontent.com/karolBak/love2d-ui/master/UI.lua

love:
	wget -O love https://bitbucket.org/rude/love/downloads/love-11.3-x86_64.AppImage
	chmod +x love
