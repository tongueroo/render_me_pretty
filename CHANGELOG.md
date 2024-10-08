# Change Log

All notable changes to this project will be documented in this file.
This project *tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

## [1.0.0] - 2024-08-29
- [#5](https://github.com/tongueroo/render_me_pretty/pull/5) Standardrb
- [#6](https://github.com/tongueroo/render_me_pretty/pull/6) add mit license
- [#7](https://github.com/tongueroo/render_me_pretty/pull/7) on_error config option error exit or raise

## [0.9.0] - 2023-06-06
- [#2](https://github.com/tongueroo/render_me_pretty/pull/2) require tilt so EMPTY_HASH is defined
- [#3](https://github.com/tongueroo/render_me_pretty/pull/3) CI: Github Actions Rspec
- add github action badge
- remove circleci

## [0.8.4] - 2021-12-28
- fix activesupport require

## [0.8.3]
- add .circleci/config.yml
- show full backtrace when error not found within users layout or project path

## [0.8.2]
- use rainbow gem for terminal color

## [0.8.1]
- tilt default_encoding utf-8
- update readme with layout support

## [0.8.0]
- pull request #1 from tongueroo/layout-support

## [0.7.1]
- trim - mode

## [0.7.0]
- allow normal exit
- show full error message for syntax error

## [0.6.0]
- Handle SyntaxError errors correctly
- refactor into MainErrorHandler and SyntaxError classes

## [0.5.0]
- fix find_template_error_line
- remove some of the filtering for backtrace lines

## [0.4.0]
- fix erb and context definitions, fix bug with empty variables={}
- improve original backtrace info, colorize exact line

## [0.3.0]
- fix bug with empty variables={}
- fix erb and context definitions

## [0.2.0]
- add RenderMePretty.result convenience class method

## [0.1.0]
- initial release

