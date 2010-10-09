module LinksHelper

  def rewrite_wiki_links(item)
    item.to_html.gsub(/\[\[([\w\s\-\/]+)\]\]/) do
      url = $1.split('/').map { |file| file.parameterize }

      if (item.is_a? Comment)
        url = File.join item.type_id, url unless item.type_id.empty? || $1.start_with?('/')
      else
        url = File.join item.id, url unless item.id.empty? || $1.start_with?('/')
      end

      if (File.exists?(File.join item.project.directory, 'wiki', url, 'index.txt'))
        '<a href="' + (url.empty? ? wiki_index_url : wiki_page_url(:id => url)) + '">' + $1 + '</a>'
      else
        '<a class="new" href="' + wiki_page_url(:id => url) + '">[[' + $1 + ']]</a>'
      end
    end.html_safe
  end
end

