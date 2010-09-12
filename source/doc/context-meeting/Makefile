default: slides.html

slides.html: slides.txt
	pandoc -t slidy -i slides.txt -s | tidy -utf8 > slides.html 
