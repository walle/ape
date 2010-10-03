class WikiController < ApplicationController
  before_filter :get_project

  def index
    @wiki = Wiki.find({:project => @project, :page => ''})
    @contents = @wiki.to_html
    rewrite_links ''
  end

  def show
    @wiki = Wiki.find({:project => @project, :page => params[:id]})
    if @wiki.contents.empty?
      parent = @wiki.parent
      if (parent.nil?)
        render_404
      else
        dirs = File.split @wiki.page
        new_page = dirs[1]
        if parent.index?
          redirect_to new_wiki_index_page_url :name => new_page
        else
          redirect_to new_wiki_page_url :id => parent.page, :name => new_page
        end
      end
    else
      @contents = @wiki.to_html
      rewrite_links @wiki.page
      @comments = Comment.all({:project => @project, :type => 'wiki', :type_id => @wiki.page})
    end
  end

  def new
    @wiki = Wiki.new @project, File.join(params[:id].to_s, ''), ''
  end

  def create
    wiki = Wiki.new @project, File.join(params[:id].to_s, params[:name]), params[:content]

    message = params[:commit_message]
    if message.empty?
      message = 'Add page: ' + params[:name]
    end

    wiki.save! message

    if (params[:commit] == I18n.t(:save_and_continue))
      redirect_to edit_wiki_page_url :id => wiki.page
    else
      redirect_to wiki_page_url :id => wiki.page
    end
  end

  def edit
    @wiki = Wiki.find({:project => @project, :page => params[:id], :revision => params[:revision]})
    @contents = @wiki.contents
  end

  def update
    wiki = Wiki.find({:project => @project, :page => params[:id]})

    message = params[:commit_message]
    if message.empty?
      message = 'Update page: ' + wiki.page
    end

    wiki.contents = params[:content]

    wiki.save! message

    if (params[:commit] == I18n.t(:save_and_continue))
      redirect_to((wiki.index? ? edit_wiki_index_url : edit_wiki_page_url(:id => wiki.page)))
    else
      redirect_to((wiki.index? ? wiki_index_url : wiki_page_url(:id => wiki.page)))
    end
  end

  def destroy
    wiki = Wiki.find({:project => @project, :page => params[:id]})

    message = params[:commit_message].to_s
    if message.empty?
      message = 'Delete page: ' + wiki.page
    end

    parent = wiki.parent

    wiki.destroy! message

    if (parent.nil?)
      redirect_to wiki_index_url
    else
      redirect_to((parent.index? ? wiki_index_url : wiki_page_url(:id => parent.page)))
    end
  end

  def pages
    @wiki = Wiki.find({:project => @project, :page => params[:id]})
    @pages = @wiki.pages
  end

  def revisions
    @wiki = Wiki.find({:project => @project, :page => params[:id]})
    @revisions = @wiki.revisions
  end

  private
    def get_project
      @project = Project.find_by_slug params[:project_id]
    end

    def rewrite_links(page)
      @contents.gsub!(/\[\[(.+)\]\]/) do
        url = $1.split('/').map { |file| file.parameterize }
        url = File.join page, url unless page.empty? || $1.start_with?('/')

        if (File.exists?(File.join @project.directory, 'wiki', url, 'index.txt'))
          '<a href="' + (url.empty? ? wiki_index_url : wiki_page_url(:id => url)) + '">' + $1 + '</a>'
        else
          '<a class="new" href="' + wiki_page_url(:id => url) + '">[[' + $1 + ']]</a>'
        end
      end
    end
end

