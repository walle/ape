class WikiController < ApplicationController
  before_filter :get_project

  def index
    @wiki = Wiki.find({:project => @project, :id => ''})
    @comments = Comment.all({:project => @project, :type => 'wiki', :type_id => ''})
  end

  def show
    @wiki = Wiki.find({:project => @project, :id => params[:id]})
    if @wiki.contents.empty?
      parent = @wiki.parent
      if (parent.nil?)
        render_404
      else
        dirs = File.split @wiki.id
        new_page = dirs[1]
        if parent.index?
          redirect_to new_wiki_index_page_url :name => new_page
        else
          redirect_to new_wiki_page_url :id => parent.id, :name => new_page
        end
      end
    else
      @comments = Comment.all({:project => @project, :type => 'wiki', :type_id => @wiki.id})
    end
  end

  def new
    @wiki = Wiki.new({:project => @project, :id => File.join(params[:id].to_s, '')})
  end

  def create
    wiki = Wiki.new({:project => @project, :id => File.join(params[:id].to_s, params[:name]), :contents => params[:content]})

    message = params[:commit_message]
    if message.empty?
      message = 'Add page: ' + params[:name]
    end

    wiki.save! message

    if (params[:commit] == I18n.t(:save_and_continue))
      redirect_to edit_wiki_page_url :id => wiki.id
    else
      redirect_to wiki_page_url :id => wiki.id
    end
  end

  def edit
    @wiki = Wiki.find({:project => @project, :id => params[:id], :revision => params[:revision]})
    @contents = @wiki.contents
  end

  def update
    wiki = Wiki.find({:project => @project, :id => params[:id]})

    message = params[:commit_message]
    if message.empty?
      message = 'Update page: ' + wiki.id
    end

    wiki.contents = params[:content]

    wiki.save! message

    if (params[:commit] == I18n.t(:save_and_continue))
      redirect_to((wiki.index? ? edit_wiki_index_url : edit_wiki_page_url(:id => wiki.id)))
    else
      redirect_to((wiki.index? ? wiki_index_url : wiki_page_url(:id => wiki.id)))
    end
  end

  def destroy
    wiki = Wiki.find({:project => @project, :id => params[:id]})

    message = params[:commit_message].to_s
    if message.empty?
      message = 'Delete page: ' + wiki.id
    end

    parent = wiki.parent

    wiki.destroy! message

    if (parent.nil?)
      redirect_to wiki_index_url
    else
      redirect_to((parent.index? ? wiki_index_url : wiki_page_url(:id => parent.id)))
    end
  end

  def pages
    @wiki = Wiki.find({:project => @project, :id => params[:id]})
    @pages = @wiki.children
  end

  def revisions
    @wiki = Wiki.find({:project => @project, :id => params[:id]})
    @revisions = @wiki.revisions
  end

  def structure
    @pages = Wiki.all({:project => @project})
  end

  private
    def get_project
      @project = Project.find_by_slug params[:project_id]
    end
end

