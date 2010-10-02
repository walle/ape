class ApplicationController < ActionController::Base
  protect_from_forgery

  def render_404
    respond_to do |type|
      type.html { render :template => 'errors/404', :layout => 'application', :status => 404 }
      type.all  { render :nothing => true, :status => 404 }
    end
    true  # so we can do "render_404 and return"
  end
end

