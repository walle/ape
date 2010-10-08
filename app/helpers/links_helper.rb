module LinksHelper

  def rewrite_wiki_links(item)
    item.to_html.gsub(/\[\[(.+)\]\]/) do
      url = $1.split('/').map { |file| file.parameterize }

      if (File.exists?(File.join item.project.directory, 'wiki', url, 'index.txt'))
        '<a href="' + (url.empty? ? wiki_index_url : wiki_page_url(:id => url)) + '">' + $1 + '</a>'
      else
        '<a class="new" href="' + wiki_page_url(:id => url) + '">[[' + $1 + ']]</a>'
      end
    end.html_safe
  end
end

