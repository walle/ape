class ProjectsController < ApplicationController
  def index
    @projects = Project.all
    redirect_to wiki_index_url(@projects[0]) if @projects.size == 1
  end

  def show
    @project = Project.find_by_slug params[:id]
    if @project
      redirect_to wiki_index_url(@project)
    else
      render :status => 404
    end
  end

  def new
    @project = Project.new
  end

  def create
    @project  = Project.new params[:project]
    if @project.save
      redirect_to @project
    else
      render 'projects/new'
    end
  end

  def edit

  end

  def update

  end

  def destroy

  end
end

