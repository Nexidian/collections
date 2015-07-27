module RummagerHelpers
  def stub_topic_organisations(slug)
    Collections::Application.config.search_client.stubs(:unified_search).with(
      count: "0",
      filter_specialist_sectors: [slug],
      facet_organisations: "1000",
    ).returns(
      rummager_has_specialist_sector_organisations(slug)
    )
  end

  def rummager_document_for_slug(slug, updated_at = 1.hour.ago, format = "guide")
    {
      "format" => "#{format}",
      "latest_change_note" => "This has changed",
      "public_timestamp" => updated_at.iso8601,
      "title" => "#{slug.titleize.humanize}",
      "link" => "/#{slug}",
      "index" => "/",
      "_id" => "/#{slug}",
      "document_type" => "edition"
    }
  end

  def rummager_has_latest_documents_for_subtopic(subtopic_slug, document_slugs, page_size: 50)
    results = document_slugs.map.with_index do |slug, i|
      rummager_document_for_slug(slug, (i + 1).hours.ago)
    end

    results.each_slice(page_size).with_index do |results_page, page|
      start = page * page_size
      Collections::Application.config.search_client.stubs(:unified_search).with(
        has_entries(
          start: start,
          count: page_size,
          filter_specialist_sectors: [subtopic_slug],
          order: "-public_timestamp",
        )
      ).returns({
        "results" => results_page,
        "start" => start,
        "total" => results.size,
      })
    end
  end

  def rummager_has_documents_for_subtopic(subtopic_slug, document_slugs, format = "guide", page_size: 50)
    results = document_slugs.map.with_index do |slug, i|
      rummager_document_for_slug(slug, (i + 1).hours.ago, format)
    end

    results.each_slice(page_size).with_index do |results_page, page|
      start = page * page_size
      Collections::Application.config.search_client.stubs(:unified_search).with(
        has_entries(
          start: start,
          count: page_size,
          filter_specialist_sectors: [subtopic_slug],
        )
      ).returns({
        "results" => results_page,
        "start" => start,
        "total" => results.size,
      })
    end
  end

  def rummager_has_documents_for_browse_page(browse_page_slug, document_slugs, format = "guide", page_size: 50)
    results = document_slugs.map.with_index do |slug, i|
      rummager_document_for_slug(slug, (i + 1).hours.ago, format)
    end

    results.each_slice(page_size).with_index do |results_page, page|
      start = page * page_size
      Collections::Application.config.search_client.stubs(:unified_search).with(
        has_entries(
          start: start,
          count: page_size,
          filter_mainstream_browse_pages: [browse_page_slug],
        )
      ).returns({
        "results" => results_page,
        "start" => start,
        "total" => results.size,
      })
    end
  end

  def expect_search_params(params)
    GdsApi::Rummager.any_instance.expects(:unified_search)
      .with(has_entries(params))
      .returns(:some_results)
  end
end