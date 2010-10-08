module NavigationHelper

  def base_navigation
    items = ''

    klass = controller.is_a?(WikiController) ? 'active' : nil
    items += '<li' + (klass.nil? ? '' : ' class="'+klass+'"') + '>' + link_to(t(:wiki), wiki_index_path) + '</li>'

    klass = controller.is_a?(TicketsController) ? 'active' : nil
    items += '<li' + (klass.nil? ? '' : ' class="'+klass+'"') + '>' + link_to(t(:tickets), tickets_path) + '</li>'

    items.html_safe
  end

end

