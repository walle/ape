class CommentsController < ApplicationController
  before_filter :get_project

  def create
    comment = Comment.new @project, nil, params[:type], params[:type_id], '', '', '', params[:comment]

    comment.save! 'Add comment to ' + params[:type_id].to_s

    if (params[:type] == 'wiki')
      if params[:type_id].nil?
        redirect_to wiki_index_url
      else
        redirect_to wiki_page_url :id => params[:type_id]
      end
    end
  end

  def edit
    @comment = Comment.find({:project => @project, :id => params[:id], :type => params[:type], :type_id => params[:type_id]})
  end

  def update
    comment = Comment.find({:project => @project, :id => params[:id], :type => params[:type], :type_id => params[:type_id]})

    comment.contents = params[:comment]

    comment.save! 'Update comment from ' + params[:type_id].to_s

    if (params[:type] == 'wiki')
      if params[:type_id].nil?
        redirect_to wiki_index_url
      else
        redirect_to wiki_page_url :id => params[:type_id]
      end
    end
  end

  def destroy
    comment = Comment.find({:project => @project, :id => params[:id], :type => params[:type], :type_id => params[:type_id]})

    comment.destroy! 'Delete comment from ' + params[:type_id].to_s

    if (params[:type] == 'wiki')
      if params[:type_id].nil?
        redirect_to wiki_index_url
      else
        redirect_to wiki_page_url :id => params[:type_id]
      end
    end
  end

  private
    def get_project
      @project = Project.find_by_slug params[:project_id]
    end

end

