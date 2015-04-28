class GenesController < ApplicationController
  include WithComment
  actions_without_auth :index, :show, :mygene_info_proxy, :datatable

  def index
    genes = Gene.view_scope
      .page(params[:page].to_i)
      .per(params[:count].to_i)
      .map { |g| GenePresenter.new(g) }

    render json: genes
  end

  def create
    gene = Gene.new(gene_params)
    authorize gene
    status = if gene.save
     :created
    else
     :unprocessable_entity
    end
    render json: GenePresenter.new(gene), status: status
  end

  def show
    gene = Gene.view_scope.find_by!(id: params[:id])
    render json: GenePresenter.new(gene, true)
  end

  def update
    gene = Gene.view_scope.find_by!(id: params[:id])
    authorize gene
    status = if gene.update_attributes(gene_params)
               :ok
             else
               :unprocessable_entity
             end

    attach_comment(gene)
    render json: GenePresenter.new(gene), status: status
  end

  def destroy
    gene = Gene.view_scope.find_by!(id: params[:id])
    authorize gene
    if gene.destroy
      head :no_content, status: :no_content
    else
      render json: GenePresenter.new(gene), status: :unprocessable_entity
    end
  end

  def mygene_info_proxy
    entrez_id = params[:entrez_id]
    mygene_info_data = Rails.cache.fetch("mygene_info_#{entrez_id}", expires_in: 12.hours) do
      Scrapers::Util.make_get_request(my_gene_info_url(entrez_id))
    end
    render json: mygene_info_data
  end

  def datatable
    render json: GeneBrowseTable.new(view_context)
  end

  private
  def gene_params
    params.permit(:clinical_description, :description)
  end

  def my_gene_info_url(entrez_id)
    "http://mygene.info/v2/gene/#{entrez_id}?fields=name,symbol,alias,interpro,pathway,summary"
  end
end
