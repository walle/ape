class WikiController < ApplicationController
  before_filter :get_project

  def index
    load_project_data @project, ''
  end

  def show
    @page = params[:id]
    load_project_data @project, @page
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

    if (params[:commit] == I18n.t(:save_and_continue))
      redirect_to edit_wiki_page_url :id => page
    else
      redirect_to wiki_page_url :id => page
    end
  end

  def edit
    load_contents @project, params[:id].to_s, params[:revision], false
  end

  def update
    page = params[:id]

    message = params[:commit_message]
    if message.empty?
      message = 'Update page: ' + (page.nil? ? 'index' : page )
    end

    set_content page.to_s, params[:content], message

    if (page.nil?)
      if (params[:commit] == I18n.t(:save_and_continue))
        redirect_to edit_wiki_index_url
      else
        redirect_to wiki_index_url
      end
    else
      if (params[:commit] == I18n.t(:save_and_continue))
        redirect_to edit_wiki_page_url :id => page
      else
        redirect_to wiki_page_url :id => page
      end
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

  def pages
    page = params[:id].to_s
    Dir.chdir File.join @project.directory, 'wiki/', page
    @pages = Dir['*/'].map do |p|
      File.join page, p.delete('/')
    end
  end

  def revisions
    page = params[:id].to_s
    filename = build_filename @project, page

    git_repository = Git.open @project.directory
    @revisions = git_repository.log(500).path(File.join('wiki', page, 'index.txt')).map do |commit|
      commit
    end
  end

  private
    def get_project
      @project = Project.find_by_slug params[:project_id]
    end

    def load_project_data(project, page, revision = nil, rewrite_links = true)
      load_contents(project, page, revision, rewrite_links)
      if !@contents.empty?
        @contents = RedCloth.new(@contents).to_html.html_safe
      else
        dirs = File.split page
        parent_dir = dirs[0]
        if (File.exists? File.join project.directory, 'wiki/', parent_dir)
          redirect_to new_wiki_page_url :id => parent_dir, :name => dirs[1]
        else
          render_404
        end
      end
    end

    def load_contents(project, page, revision = nil, rewrite_links = true)
      filename = build_filename project, page
      @contents = file_contents filename, revision
      do_rewrite_links project, page if rewrite_links
    end

    def do_rewrite_links(project, page)git_repository = Git.open @project.directory
      @contents.gsub!(/\[\[(.+)\]\]/) do
        url = $1.split('/').map { |file| file.parameterize }
        url = File.join page, url unless page.empty?
        if (File.exists?(File.join project.directory, 'wiki/', url, 'index.txt'))
          '<a href="' + wiki_page_url(:id => url) + '">' + $1 + '</a>'
        else
          '<a class="new" href="' + wiki_page_url(:id => url) + '">[[' + $1 + ']]</a>'
        end
      end
    end

    def build_filename(project, page)
      File.join project.directory, 'wiki/', page, 'index.txt'
    end

    def file_contents(filename, revision)
      contents = ''
      if (revision.nil?)
        contents = read_file filename
      else
        git_repository = Git.open @project.directory
        git_repository.checkout revision
        contents = read_file filename
        git_repository.checkout 'master'
      end
      contents
    end

    def read_file(filename)
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

