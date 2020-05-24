
## Applied Machine Learning with Python and R


![https://github.com/duttashi/applied-machine-learning/pulls](https://img.shields.io/badge/contributions-welcome-green.svg)
![](https://img.shields.io/badge/Open%20Source-always-brightgreen.svg)
![](https://img.shields.io/badge/Made%20with%20Python%20%26%20R-dual%20support-blue.svg)



### Table of Contents

#### Introduction

- The purpose of this project is to provide a comprehensive and yet simple course in Machine Learning using Python and R


#### Required Software information

This project uses the following IDE's and programming languages:

**Python**

- IDE is Spyder 4
	- *How to install Spyder*: See [here](https://docs.spyder-ide.org/installation.html). 
		- Open a command prompt window and browse to your local python installation directory. In my case its, `c:\users\myusername\miniconda3` and then type `pip3 install spyder`
		- To launch spyder IDE, open a command prompt window, type the command, `spyder3` and hit the enter key. Spyder IDE will launch
		
- Python 3 distribution is Miniconda 3

**R**

- IDE is RStudio version - `1.1.463` 
- R version - `3.6.1` 

#### Python folder/file naming conventions

This repository follows the [PEP 8](https://www.python.org/dev/peps/pep-0008/) standard for Python file and folder naming conventions.

- A Python module is simply a Python source file, which can expose classes, functions and global variables.
	- Modules: should have short, all-lowercase names. Underscores can be used in the module name if it improves readability. Example: `my_module.py`
	- Function: Function names should be lowercase, with words separated by underscores as necessary to improve readability. Example: `my_function`
		- Function arguments: Always use `self` for the first argument to instance methods.
		- Always use `cls` for the first argument to class methods.
		- If a function argument's name clashes with a reserved keyword, it is generally better to append a single trailing underscore rather than use an abbreviation or spelling corruption. Thus `class_` is better than clss. (Perhaps better is to avoid such clashes by using a synonym.)
	- Variable: use a lowercase single letter, word, or words. Separate words with underscores to improve readability. Example: `my_variable`
- A Python package is simply a directory of Python module(s).
	- Python packages should also have short, all-lowercase names, although the use of underscores is discouraged. Example: `mypackage`
	- Constant - Use an uppercase single letter, word, or words. Separate words with underscores to improve readability. Example: `MY_CONSTANT`
	- Class - start each word with a capital letter. Do not separate words with underscores. This style is called camel case. Example: `MyClass`
	- Every script will begin with a prefix of `aml_`. Followed by a distinct meaningful name, that describe the task the script is meant to perform.

#### R folder/file naming conventions

This repository follows the Hadley Wickham [R Style Guide](http://stat405.had.co.nz/r-style.html)

- **Folder** name: A folder name should be meaningful and multiple words are separated by a hyphen. Example: `data-extraction`  
- **File** name: A File names should end in .r and be meaningful and multiple words are separated by hyphen `-`. Example: `explore-diamonds.R`
- **Variable** name: A variable name should be lowercase. Use `_` to separate words within a name. Generally, variable names should be nouns. Example: `butter` `good_butter`.
- **Function** name: A function name should be lowercase. Use `_` to separate words within a name. Generally, function names should be verbs. Example: `calculate_salary()`.
- **Spacing** syntax: Place spaces around all binary operators (=, +, -, <-, etc.). Do not place a space before a comma, but always place one after a comma. Example: `average <- mean(feet / 12 + inches, na.rm = T)`
- Commenting guidelines
	- Comment your code. Entire commented lines should begin with # and one space. Comments should explain the why, not the what.
	- Use commented lines of - and = to break up your files into scannable chunks.
