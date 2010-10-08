module LinksHelper

  def rewrite_wiki_links(wiki)
    wiki.to_html.gsub(/\[\[(.+)\]\]/) do
      url = $1.split('/').map { |file| file.parameterize }
      url = File.join wiki.page, url unless wiki.index? || $1.start_with?('/')

      if (File.exists?(File.join wiki.project.directory, 'wiki', url, 'index.txt'))
        '<a href="' + (url.empty? ? wiki_index_url : wiki_page_url(:id => url)) + '">' + $1 + '</a>'
      else
        '<a class="new" href="' + wiki_page_url(:id => url) + '">[[' + $1 + ']]</a>'
      end
    end.html_safe
  end
end

