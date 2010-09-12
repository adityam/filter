default: slides.html

slides.html: slides.md
	pandoc -t slidy -i slides.md -s | tidy -utf8 > slides.html 
