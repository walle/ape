class WikiController < ApplicationController
  before_filter :get_project

  def index
    load_project_data @project, ''
  end

  def show
    load_project_data @project, params[:id]
  end

  def create
    id = params[:id]
    name = params[:name].parameterize

    if (id.nil?)
      page = params[:name].parameterize
    else
      page = File.join id, name
    end

    message = params[:commit_message]
    if message.empty?
      message = 'Add page: ' + name
    end

    set_content page, params[:content], message

    redirect_to wiki_page_url :id => page
  end

  def edit
    load_contents @project, params[:id].to_s
  end

  def update
    page = params[:id]

    message = params[:commit_message]
    if message.empty?
      message = 'Update page: ' + (page.nil? ? 'index' : page )
    end

    set_content page.to_s, params[:content], message

    if (page.nil?)
      redirect_to wiki_index_url
    else
      redirect_to wiki_page_url :id => page
    end
  end

  def destroy
    page = params[:id]

    message = params[:commit_message].to_s
    if message.empty?
      message = 'Delete page: ' + (page.nil? ? 'index' : page )
    end

    delete_file page, message

    redirect_to wiki_index_url
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
        render_404
      end
    end

    def load_contents(project, page)
      filename = File.join project.directory, 'wiki/', page, 'index.txt'
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

    def set_content(page, content, message)
      page_dir = File.join @project.directory, 'wiki/', page
      Dir.mkdir page_dir unless File.exists? page_dir
      filename =  File.join page_dir, 'index.txt'
      File.open filename, 'w' do |f|
        f.puts content
      end
      git_repository = Git.open @project.directory
      git_repository.add filename
      git_repository.commit message rescue nil
    end

    def delete_file(page, message)
      page_dir = File.join @project.directory, 'wiki/', page
      filename =  File.join page_dir, 'index.txt'
      if (File.exists? filename)
        git_repository = Git.open @project.directory
        git_repository.remove filename
        git_repository.commit message rescue nil
      end
    end
end

