class WikiController < ApplicationController
  def index
    project_data
  end

  def show
    project_data
  end

  private
    def project_data
      @project = Project.find_by_slug params[:project_id]
      @contents = file_contents File.join @project.project_dir, 'wiki/index.txt'
      @contents = RedCloth.new(@contents).to_html.html_safe
    end
    def file_contents(file)
      file = File.open(file, "r")
      contents = file.read
    end
end

