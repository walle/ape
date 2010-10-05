module CommentsHelper
  def gravatar_for(comment, options = { :size => 50 })
    gravatar_image_tag(comment.email.downcase, :alt => comment.name,
                                               :class => 'gravatar',
                                               :gravatar => options)
  end
end

