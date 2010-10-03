class CommentsController < ApplicationController
  before_filter :get_project

  def create
    comment = Comment.new @project, nil, params[:type], params[:type_id], params[:comment]

    comment.save! 'Add comment to ' + params[:type_id]

    # Change this to take type into account
    redirect_to wiki_page_url :id => params[:type_id]
  end

  private
    def get_project
      @project = Project.find_by_slug params[:project_id]
    end

end

