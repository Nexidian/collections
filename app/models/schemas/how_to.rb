class Schemas::HowTo
  delegate(
    :base_path,
    :title,
    :description,
    :details,
    to: :step_by_step,
  )

  def initialize(step_by_step)
    @step_by_step = step_by_step
  end

  def structured_data(image_urls)
    step_items = details["step_by_step_nav"]["steps"].map.with_index(1) do |step, step_index|
      contents = step["contents"].map.with_index(1) do |content, item_index|
        direction_index = item_index

        if content["type"] == "paragraph"
          how_to_direction(content, direction_index)
        elsif content["type"] == "list"
          content["contents"].map do |c|
            how_to_direction(c, direction_index).tap do
              direction_index += 1
            end
          end
        end
      end

      {
        "@type": "HowToStep",
        "image": image_urls,
        "name": step["title"],
        "url": step_url(step["title"].parameterize),
        "position": step_index,
        "itemListElement": contents.flatten.compact,
      }
    end

    {
      "@context": "http://schema.org",
      "@type": "HowTo",
      "description": description,
      "image": image_urls,
      "name": title,
      "step": step_items,
    }
  end

private

  attr_reader :step_by_step

  def how_to_direction(content, index)
    {
      "@type": "HowToDirection",
      "text": content["text"],
      "position": index,
    }.merge(direction_url(content))
  end

  def direction_url(content)
    if content["href"]
      { "url": url_for_base_path_or_absolute_url(content["href"]) }
    else
      {}
    end
  end

  def url_for_base_path_or_absolute_url(href)
    if href.starts_with?("http")
      href
    else
      Plek.new.website_root + href
    end
  end

  def step_url(step_slug)
    Plek.new.website_root + base_path + "#" + step_slug
  end
end
