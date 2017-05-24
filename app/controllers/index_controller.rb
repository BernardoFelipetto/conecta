require_relative 'controller.rb'
require "sinatra/base"

class IndexController < Controller

  get "/" do
    @error = []
    erb :index
  end

  get "/index_search" do
    @error = []
    erb :index_search
  end

  get "/companies" do
    @companies = Company.all
    erb :companies
  end

  get "/segments" do
    @segments = Segment.all
    erb :segments
  end

  get "/competences" do
    @competences = Competence.all
    erb :competences
  end

  get "/search" do
    erb :search
  end

  get "/research_centers" do
    # SE CRASHAR FOI AQ
    # @research_centers = ResearchCenter.all
    # erb :research_centers
    @research_centers = ResearchCenter.all
    erb :results_centers
  end

  get "/results" do
    @companies = Company.all
    #metodo de pesquisa
    area_competence
    erb :results
  end

  get "/search_all" do
    @value = params[:value]
    @search_type = params[:search_type]
    @value_sql = "%#{@value.downcase}%"

    if @search_type == 'competencia'
      @companies = Company.all
      area_competence
      @companies_searched = []

      @competences = Competence.all(:conditions => ["lower(name) like ?", @value_sql])
      if(@competences.length != 0)
        @competences_id =   @competences.map{|c| c.id}
        @company_competence = CompetenceInstitution.all(conditions: ['competence_id in ? and (competence_value >= 4)',@competences_id])
        @company_competence.each do |single_cmp_competence|
          local_company = single_cmp_competence.company
          if !@companies_searched.include? local_company
            @companies_searched.push(local_company)
          end
        end
      end
    elsif @search_type == 'segmento'
      @companies = Company.all
      area_competence
      @segments_searched = []

      @segments = Segment.all(:conditions => ["lower(name) like ?", @value_sql])

      if @segments.length != 0
        @segments_id = @segments.map{|s| s.id}
        @company_segments = InstitutionSegment.all(conditions: ['segment_id in ?',@segments_id])
        @company_segments.each do |single_segment|
          local_company = single_segment.company
          if !(@segments_searched.include? local_company)
            @segments_searched.push(local_company)
          end
        end
        puts "@@@ Segments Serached #{@segments_searched}"
      end
    elsif @search_type == 'empresa'
      @companies = Company.all(:conditions => ["lower(name) like ?", @value_sql])
      area_competence

    elsif @search_type == 'centro-pesquisa'
      @research_center = ResearchCenter.all(:conditions => ["lower(name) like ?", @value_sql])

    elsif @search_type == 'area-pesquisa'

      @research_centers = ResearchCenter.all

      @areas = ResearchArea.all(:conditions => ["lower(name) like ?", @value_sql])

    elsif @search_type == 'eixo-pesquisa'

      @research_centers = ResearchCenter.all

      @fields = ResearchField.all(:conditions => ["lower(name) like ?", @value_sql])

    elsif @search_type == 'project'

      @research_centers = ResearchCenter.all

      @project = ResearchCenter.all(:conditions => ["lower(project) like ?", @value_sql])


    end

    erb :search_all
  end

  get "/components" do
    erb :components
  end

  get "/import-companies" do
    require_relative "../../config/importCompany.rb"
  end


  def area_competence
    @competences_by_company = {}
    @companies.each do |company|
      filtered_competences = {}
      company.competence_institutions.each do |comp_all|
        if filtered_competences.key?(comp_all.competence.competence_area.name)
          competence_area_array = filtered_competences[comp_all.competence.competence_area.name]
          competence_area_array.push(comp_all.competence.name + " | " + comp_all.competence_value.to_s + " | ")
        else
          competence_area_array = [comp_all.competence.name + " | " + comp_all.competence_value.to_s + " | "]
          filtered_competences[comp_all.competence.competence_area.name] = competence_area_array
        end
        @competences_by_company[company] = filtered_competences
      end
    end
  end


end
