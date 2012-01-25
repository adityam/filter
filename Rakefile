require 'fileutils'
require 'rake/clean'

def make_tds(name, files, doc)
  tex_dir = "#{name}/tex/context/third/#{name}"
  doc_dir = "#{name}/doc/context/third/#{name}"
  sh "mkdir -p #{tex_dir}"
  sh "mkdir -p #{doc_dir}"
  files.each do |tex|
    FileUtils.cp tex, tex_dir
  end
  FileUtils.cp doc, (doc_dir + "/#{name}.txt")
end

def make_zip name
  # Ideally, one could have used
  # sh "zip #{name} #{name}" 
  # but that creates a top level directory #{name}.
  # So, we take the following round about alternative.
  sh "cd #{name} && zip -r ../#{name} ./ && cd ../"
end

def run_tests tests
  FileUtils.mkdir_p "output"
  tests.each do |file|
    sh "context --noconsole --purgeall --purgeresult #{file}"
  end
  sh "context --purgeall"
end

FILTER_TEX  = %W[t-filter.mkii t-filter.mkiv t-module-catcodes.tex]
FILTER_DOC  = "README.md"
FILTER_TEST = FileList['tests/[0-9][0-9]-*.tex']

VIM_TEX  = %W[t-vim.tex t-syntax-groups.tex t-syntax-highlight.mkii t-syntax-highlight.mkiv]
VIM_DOC  = "vim-README.md"
VIM_TEST = FileList['tests/vim/[0-9][0-9]-*.tex']


desc "Run tests for filter module"
task :test_filter => FILTER_TEST do
  run_tests FILTER_TEST
end

desc "Run tests for vim module"
task :test_vim => VIM_TEST do
  run_tests VIM_TEST
end


task :clean_vim do
  sh "rm -rf vim"
end

task :clean_filter do
  sh "rm -rf filter"
end

desc "Make TDS for filter module"
task :filter => :clean_filter do
  make_tds :filter, FILTER_TEX, FILTER_DOC
  make_zip :filter
end

desc "Make TDS for vim module"
task :vim => :clean_vim do
  make_tds :vim, VIM_TEX, VIM_DOC
  make_zip :vim
end

CLEAN.include('*.zip')


