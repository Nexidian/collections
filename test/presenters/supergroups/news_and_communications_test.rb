require 'test_helper'

describe Supergroups::NewsAndCommunications do
  include RummagerHelpers
  include SupergroupHelpers

  DEFAULT_WHITEHALL_IMAGE_URL = "https://assets.publishing.service.gov.uk/government/assets/placeholder.jpg".freeze
  let(:taxon_id) { '12345' }
  let(:news_and_communications_supergroup) { Supergroups::NewsAndCommunications.new }

  describe '#document_list' do
    before do
      content = content_item_for_base_path('/government/tagged/content').merge(
        "details": {
          "image": {
            "url": "an/image/path",
            "alt_text": "some alt text"
          }
        }
      )

      content_store_has_item('/government/tagged/content', content)
    end

    it 'returns a document list for the news and communications supergroup' do
      MostRecentContent.any_instance
        .stubs(:fetch)
        .returns(section_tagged_content_list('news_story'))

      expected = [
        {
          link: {
            text: 'Tagged Content Title',
            path: '/government/tagged/content'
          },
          metadata: {
            public_updated_at: '2018-02-28T08:01:00.000+00:00',
            organisations: 'Tagged Content Organisation',
            document_type: 'News story'
          },
          image: {
            url: 'an/image/path',
            alt: 'some alt text'
          }
        }
      ]

      assert_equal expected, news_and_communications_supergroup.document_list(taxon_id)
    end

    it 'returns an image for the first news item only' do
      tagged_document_list = %w(news_story correspondance press_release)

      MostRecentContent.any_instance
        .stubs(:fetch)
        .returns(tagged_content(tagged_document_list))

      news_and_communications_supergroup.document_list(taxon_id).each_with_index do |content_item, i|
        if i.eql?(0)
          assert content_item.key?(:image)
        else
          refute content_item.key?(:image)
        end
      end
    end

    it 'returns the default whitehall image if no image is present' do
      content = content_item_for_base_path('/government/tagged/content').merge(
        "details": {}
      )

      content_store_has_item('/government/tagged/content', content)

      MostRecentContent.any_instance
      .stubs(:fetch)
      .returns(section_tagged_content_list('news_story'))

      assert_equal DEFAULT_WHITEHALL_IMAGE_URL, news_and_communications_supergroup.document_list(taxon_id).first[:image][:url]
    end

    it 'uses empty alt text if using the default whitehall image' do
      # The default whitehall image does not give more context/information to the user about the news item they are viewing.
      # We therefore want to hide the image from screenreaders by setting alt_text to a blank value

      content = content_item_for_base_path('/government/tagged/content').merge(
        "details": {}
      )

      content_store_has_item('/government/tagged/content', content)

      MostRecentContent.any_instance
      .stubs(:fetch)
      .returns(section_tagged_content_list('news_story'))

      assert_equal "", news_and_communications_supergroup.document_list(taxon_id).first[:image][:alt]
    end
  end
end