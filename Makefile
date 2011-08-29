REPOS = filter vim

.PHONY: zips 

zips:
	$(foreach repo, $(REPOS), git archive -o $(repo).zip $(repo);)

clean:
	$(foreach repo, $(REPOS), rm $(repo).zip)
