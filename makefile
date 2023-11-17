DEST_DIR := ramanpdf.app/Contents/MacOS

.PHONY: clean copying 

copying: list.txt ramanpdf
	cp ramanpdf $(DEST_DIR)/ramanpdf
	for lib in $$(cat list.txt); do \
	  APP_LIB=$$(basename $$lib) ; \
	  cp $$lib $(DEST_DIR)/ ; \
	  install_name_tool -change $$lib @executable_path/$$APP_LIB $(DEST_DIR)/ramanpdf ; \
	done
	cp Info.plist ramanpdf.app/Contents/Info.plist
	mkdir ramanpdf.app/Contents/Resources
	cp ramanpdf.icns ramanpdf.app/Contents/Resources/ramanpdf.icns

list.txt: ramanpdf
	$(eval USR_OPT=$(shell otool -L ramanpdf | cut -f 1 -d " " | tr -d "[:blank:]" | grep '^\/usr\/local\/opt' ))
	echo $(USR_OPT) > list.txt

ramanpdf: ramanpdf.vala
	export PKG_CONFIG_PATH=$$PKG_CONFIG_PATH:/usr/local/opt/libffi/lib/pkgconfig ; \
	export PKG_CONFIG_PATH=$$PKG_CONFIG_PATH:/usr/local/Cellar/glib/2.78.0/lib/pkgconfig; \
	valac --Xcc=-headerpad_max_install_names --pkg poppler-glib --pkg glib-2.0 --pkg gtk4 -o ramanpdf ramanpdf.vala  
	mkdir -p $(DEST_DIR)

clean:
	rm -f ramanpdf
	rm -fr ramanpdf.app
	rm -f list.txt 
