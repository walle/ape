module NavigationHelper

  def base_navigation
    links = []

    klass = controller.is_a?(WikiController) ? 'active' : nil
    links << link_to(t(:wiki), wiki_index_path)

    links.map {|i| "<li#{(klass.nil? ? '' : ' class="'+klass+'"')}>#{i}</li>" }.join('').html_safe
  end

end

