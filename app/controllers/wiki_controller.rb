class WikiController < ApplicationController
  before_filter :get_project

  def index
    load_project_data @project, 'index'
  end

  def show
    load_project_data @project, params[:id]
  end

  def create
    page = params[:name].parameterize

    message = params[:commit_message]
    if message.empty?
      message = 'Add page: ' + page
    end

    set_content page, params[:content], message

    redirect_to project_wiki_url :id => page
  end

  def edit
    load_contents @project, params[:id]
  end

  def update
    set_content params[:id], params[:content], 'Update page: ' + page

    redirect_to project_wiki_url :id => params[:id]
  end

  def destroy

  end

  private
    def get_project
      @project = Project.find_by_slug params[:project_id]
    end

    def load_project_data(project, page)
      load_contents(project, page)
      if !@contents.empty?
        @contents = RedCloth.new(@contents).to_html.html_safe
      else
        render :status => 404
      end
    end

    def load_contents(project, page)
      filename = File.join project.directory, 'wiki/', page_name(page)
      @contents = file_contents filename
    end

    def file_contents(filename)
      contents = ''
      if File.exists? filename
        file = File.open(filename, "r")
        contents = file.read
      end
      contents
    end

    def page_name(page)
      page + '.txt'
    end

    def set_content(page, content, message)
      filename = File.join @project.directory, 'wiki/', page_name(page)
      File.open filename, 'w' do |f|
        f.puts content
      end
      git_repository = Git.open @project.directory
      git_repository.add filename
      git_repository.commit message
    end
end

