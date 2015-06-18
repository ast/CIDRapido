SHELL = /bin/sh
.SUFFIXES: .png
# Should be square
ICON=Icon-1024.png

all: Icon-29.png Icon-29@2x.png Icon-29@3x.png Icon-40.png Icon-40@2x.png Icon-40@3x.png Icon-60@2x.png Icon-60@3x.png Icon-76.png Icon-76@2x.png

clean:
	-rm Icon-29*
	-rm Icon-40*
	-rm Icon-60*
	-rm Icon-76*

Icon-29.png: $(ICON)
	convert $(ICON) -resize 29 Icon-29.png

Icon-29@2x.png: $(ICON)
	convert $(ICON) -resize 58 Icon-29@2x.png

Icon-29@3x.png: $(ICON)
	convert $(ICON) -resize 87 Icon-29@3x.png

Icon-40.png: $(ICON)
	convert $(ICON) -resize 40 Icon-40.png

Icon-40@2x.png: $(ICON)
	convert $(ICON) -resize 80 Icon-40@2x.png

Icon-40@3x.png: $(ICON)
	convert $(ICON) -resize 120 Icon-40@3x.png

Icon-60@2x.png: $(ICON)
	convert $(ICON) -resize 120 Icon-60@2x.png

Icon-60@3x.png: $(ICON)
	convert $(ICON) -resize 180 Icon-60@3x.png

Icon-76.png: $(ICON)
	convert $(ICON) -resize 76 Icon-76.png

Icon-76@2x.png: $(ICON)
	convert $(ICON) -resize 152 Icon-76@2x.png