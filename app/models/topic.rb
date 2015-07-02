class Topic

  LinkedTopic = Struct.new(:title, :base_path) do
    def self.build(attributes)
      new(attributes["title"], attributes["base_path"])
    end
  end

  def self.find(base_path, pagination_options = {})
    api_response = ContentItem.find!(base_path)
    new(api_response.to_hash, pagination_options)
  end

  def initialize(content_item_data, pagination_options = {})
    @content_item_data = content_item_data
    @pagination_options = pagination_options
  end

  [
    :base_path,
    :title,
    :description,
  ].each do |field|
    define_method field do
      @content_item_data[field.to_s]
    end
  end

  def beta?
    !! @content_item_data["details"]["beta"]
  end

  def parent
    if @content_item_data.has_key?("links") &&
        @content_item_data["links"].has_key?("parent") &&
        @content_item_data["links"]["parent"].any?
      LinkedTopic.build(@content_item_data["links"]["parent"].first)
    else
      nil
    end
  end

  def children
    if @content_item_data.has_key?("links") &&
        @content_item_data["links"].has_key?("children")
      @content_item_data["links"]["children"].map { |child|
        LinkedTopic.build(child)
      }
    else
      []
    end
  end

  def combined_title
    if parent
      "#{parent.title}: #{title}"
    else
      title
    end
  end

  def lists
    ListSet.new("specialist_sector", slug, @content_item_data["details"]["groups"])
  end

  def changed_documents
    ChangedDocuments.new(slug, @pagination_options)
  end

  def slug
    base_path.sub(%r{\A/topic/}, '')
  end

private

  def self.filtered_api_options(options)
    options.slice(:start, :count).reject {|_,v| v.blank? }
  end
end
