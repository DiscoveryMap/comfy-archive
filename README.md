# ComfyArchive

ComfyArchive is a management engine for chronologically & categorically archived sections for [Comfortable Mexican Sofa](https://github.com/comfy/comfortable-mexican-sofa) 2.x. You can select one or more Comfortable Mexican Sofa pages to act as an index for child pages, which will then be organized both cronologically, by year and month, and by category.

## Dependencies

Make sure that you have [ComfortableMexicanSofa](https://github.com/comfy/comfortable-mexican-sofa) installed first.

## Installation

1) Add gem definition to your Gemfile:

    gem "comfy_archive", "~> 0.1.0"

2) From your Rails project's root run:

    bundle install
    rails generate comfy:archive
    rake db:migrate

3) Add the following lines to your `config/routes.rb` file, after the "`comfy_route :cms_admin`" line and before the "`comfy_route :cms`" line:

    comfy_route :archive_admin
    comfy_route :archive

4) You should also find view templates in your `/app/views/comfy/archive` folder. Feel free to adjust them as you see fit.

## Configuration

1) Add a `datetime` tag to the layout used by any page which will be ordered chronologically under an index page, then set the field to a valid date & time in the pages themselves.

2) Add a new Archive Index, selecting the parent page which will act as an index for child pages and enter the name of the `datetime` tag you created in Step 1

## Architecture

* `ComfyArchive`: Rails Engine which manages configuration, adds scopes & associations to `Comfy::Cms::Site` & `Comfy::Cms::Page` models, and adds route matching methods
* `Comfy::Archive::Index`: A model which represents pages which will become chronological archive pages, it has a `Comfy::Cms::Page` association and also the name of the page's `datetime` fragment to use for chronological ordering
* `Comfy::Admin::Archive::IndicesController`: A Comfortable Mexican Sofa admin controller for managing `Comfy::Archive::Index` models
* `Comfy::Archive::IndexController`: A controller for rendering `Comfy::Archive::Index` pages, plus chronological & categorical archive pages

---

Copyright (c) 2019 Discovery Map International, Inc.
