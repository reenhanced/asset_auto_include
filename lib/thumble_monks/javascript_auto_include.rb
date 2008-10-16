require 'ruby-debug'
require 'pathname'

module ThumbleMonks # - like the kebab.
  module JavascriptAutoInclude
    # I don't want to just blindly re-open AssetTagHelper.
    # Because of Ruby method lookup, I can't just include another module
    # into AssetTagHelper
    # So let's try a new compromise.
    AssetTagHelper = lambda do
      mattr_accessor :asset_autoinclude_options
      self.asset_autoinclude_options = {}
      asset_autoinclude_options[:asset_glob_patterns] = %w[controller %s %s-* *-%s *-%s-*]
      asset_autoinclude_options[:autoinclude_subdir] = "app"
      asset_autoinclude_options[:js_autoinclude_full_path] = Pathname.new("#{RAILS_ROOT}/public/javascripts/#{asset_autoinclude_options[:autoinclude_subdir]}")

      def javascript_auto_include_tags
        path = controller.controller_path
        search_glob = asset_glob(controller.action_name, "js")
        finds = search_dir(asset_autoinclude_options[:js_autoinclude_full_path], path, search_glob)
        include_paths = finds.map { |js_file| "#{asset_autoinclude_options[:autoinclude_subdir]}/#{path}/#{js_file}"  }
        javascript_include_tag(*include_paths)
      end
      
    private
      
      def asset_glob(action_name, file_extension)
        alternated = asset_autoinclude_options[:asset_glob_patterns].map do |pattern|
          pattern % action_name
        end.join(',')
        "{#{alternated}}.#{file_extension}"
      end
      
      def search_dir(root, subdir, asset_glob_pattern)
        full = (root + subdir)
        Pathname.glob("#{root}/#{subdir}/#{asset_glob_pattern}").map do |matches|
          matches.relative_path_from(full)
        end
      end
      
    end # AssetTagHelper
  end   # JavascriptAutoInclude
end     # ThumbleMonks

ActionView::Helpers::AssetTagHelper.module_eval(&ThumbleMonks::JavascriptAutoInclude::AssetTagHelper)
