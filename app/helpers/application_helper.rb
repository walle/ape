module ApplicationHelper

  # Requires item to have name and email attributes
  def gravatar_for(item, options = { :size => 50 })
    gravatar_image_tag(item.email.downcase, :alt => item.name,
                                               :class => 'gravatar',
                                               :gravatar => options)
  end
end

