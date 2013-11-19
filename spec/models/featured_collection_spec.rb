# coding: utf-8
require 'spec_helper'

describe FeaturedCollection do
  fixtures :affiliates
  before do
    @affiliate = affiliates(:usagov_affiliate)
  end

  it { should validate_presence_of :affiliate }
  it { should validate_presence_of :title }
  it { should validate_presence_of :publish_start_on }
  it { should have_attached_file :image }
  it { should validate_attachment_content_type(:image).allowing(%w{ image/gif image/jpeg image/pjpeg image/png image/x-png }).rejecting(nil) }

  FeaturedCollection::STATUSES.each do |status|
    it { should allow_value(status).for(:status) }
  end
  it { should_not allow_value("bogus status").for(:status) }

  specify { FeaturedCollection.new(:status => 'active').should be_is_active }
  specify { FeaturedCollection.new(:status => 'active').should_not be_is_inactive }
  specify { FeaturedCollection.new(:status => 'inactive').should be_is_inactive }
  specify { FeaturedCollection.new(:status => 'inactive').should_not be_is_active }

  FeaturedCollection::LAYOUTS.each do |layout|
    it { should allow_value(layout).for(:layout) }
  end
  it { should_not allow_value("bogus layout").for(:layout) }

  specify { FeaturedCollection.new(:layout => 'one column').should have_one_column_layout }
  specify { FeaturedCollection.new(:layout => 'two column').should have_two_column_layout }

  it { should belong_to :affiliate }
  it { should have_many(:featured_collection_keywords).dependent(:destroy) }
  it { should have_many(:featured_collection_links).dependent(:destroy) }

  describe ".recent" do
    it "should include a scope called 'recent'" do
      FeaturedCollection.recent.should_not be_nil
    end
  end

  describe "title URL should have http(s):// prefix" do
    context "when the title URL does not start with http(s):// prefix" do
      title_url = 'usasearch.howto.gov/post/9866782725/did-you-mean-roes-or-rose'
      prefixes = %w( http https HTTP HTTPS invalidhttp:// invalidHtTp:// invalidhttps:// invalidHTtPs:// invalidHttPsS://)
      prefixes.each do |prefix|
        specify { FeaturedCollection.create!(:title => 'Did You Mean Roes or Rose?',
                                             :title_url => "#{prefix}#{title_url}",
                                             :status => 'active',
                                             :layout => 'one column',
                                             :publish_start_on => '07/01/2011',
                                             :affiliate => @affiliate).title_url.should == "http://#{prefix}#{title_url}" }
      end
    end

    context "when the title URL starts with http(s):// prefix" do
      title_url = 'usasearch.howto.gov/post/9866782725/did-you-mean-roes-or-rose'
      prefixes = %w( http:// https:// HTTP:// HTTPS:// )
      prefixes.each do |prefix|
        specify { FeaturedCollection.create!(:title => 'Did You Mean Roes or Rose?',
                                             :title_url => "#{prefix}#{title_url}",
                                             :status => 'active',
                                             :layout => 'one column',
                                             :publish_start_on => '07/01/2011',
                                             :affiliate => @affiliate).title_url.should == "#{prefix}#{title_url}" }
      end
    end
  end

  it "should not allow publish start date before publish end date" do
    featured_collection = FeaturedCollection.create(:title => 'test title',
                                                    :status => 'active',
                                                    :layout => 'one column',
                                                    :publish_start_on => '07/01/2012',
                                                    :publish_end_on => '07/01/2011',
                                                    :affiliate => @affiliate)
    featured_collection.errors.full_messages.join.should =~ /Publish end date can't be before publish start date/
  end

  describe "#display_status" do
    context "when status is set to active" do
      subject { FeaturedCollection.new(:status => 'active') }
      its(:display_status) { should == 'Active' }
    end

    context "when status is set to inactive" do
      subject { FeaturedCollection.new(:status => 'inactive') }
      its(:display_status) { should == 'Inactive' }
    end
  end

  describe "#update_attributes" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:image) { mock('image') }
    let(:featured_collection) do
      featured_collection = affiliate.featured_collections.build(:title => 'My awesome featured collection',
                                                                 :status => 'active',
                                                                 :layout => 'one column',
                                                                 :publish_start_on => Date.current)
      featured_collection.featured_collection_keywords.build(:value => 'test')
      featured_collection.save!
      featured_collection
    end

    context "when there is an existing image" do
      before do
        featured_collection.should_receive(:image?).and_return(true)
        featured_collection.should_receive(:image).at_least(:once).and_return(image)
      end

      context "when marking an existing image for deletion" do
        it "should clear existing image" do
          image.should_receive(:dirty?).and_return(false)
          image.should_receive(:clear)
          featured_collection.update_attributes({ :mark_image_for_deletion => '1' })
        end
      end

      context "when uploading a new image" do
        it "should not clear the existing image" do
          image.should_receive(:dirty?).and_return(true)
          image.should_not_receive(:clear)
          featured_collection.update_attributes({ :title => 'updated' })
        end
      end
    end

    context "when there is no existing image" do
      it "should not clear image" do
        featured_collection.should_receive(:image?).and_return(false)
        image.should_not_receive(:clear)
        featured_collection.update_attributes(:title => 'new title')
      end
    end
  end

  describe '.substring_match(query)' do
    context 'with an affiliate' do
      let(:affiliate) { affiliates(:basic_affiliate) }

      context 'when only the parent record has substring match in selected text fields' do
        before do
          affiliate.featured_collections.create!(:title => 'My awesome featured collection abc',
                                                 :title_url => 'http://www.dotgov.gov/page.html',
                                                 :status => 'active',
                                                 :layout => 'one column',
                                                 :publish_start_on => Date.current)
          affiliate.featured_collections.create!(:title => 'Another awesome featured collection',
                                                 :title_url => 'http://www.dotgov.gov/defg.html',
                                                 :status => 'active',
                                                 :layout => 'one column',
                                                 :publish_start_on => Date.current)
        end

        it 'should find the records' do
          %w{abc defg}.each do |substring|
            affiliate.featured_collections.substring_match(substring).size.should == 1
          end
          affiliate.featured_collections.substring_match('awesome').size.should == 2
        end

        context 'when keywords have substring match in selected fields' do
          before do
            fc = FeaturedCollection.last
            fc.featured_collection_keywords.build(:value => 'page2')
            fc.featured_collection_keywords.build(:value => 'hello')
            fc.save!
          end

          it 'should find the record just once' do
            %w{page2 llo}.each do |substring|
              affiliate.featured_collections.substring_match(substring).size.should == 1
            end
          end
        end
      end

      context 'when at least one has_many association has substring match in selected fields' do
        before do
          fc = affiliate.featured_collections.build(:title => 'My awesome featured collection',
                                                    :title_url => 'http://www.dotgov.gov/page.html',
                                                    :status => 'active',
                                                    :layout => 'one column',
                                                    :publish_start_on => Date.current)
          fc.featured_collection_keywords.build(:value => 'word1')
          fc.featured_collection_links.build(:title => 'Worldwide Tropical Cyclone Names Part1',
                                             :url => 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                             :position => '0')

          fc.save!
        end

        it 'should find the records' do
          %w{word1 cyclone}.each do |substring|
            affiliate.featured_collections.substring_match(substring).size.should == 1
          end
        end
      end

      context 'when neither the parent or the child records have a match' do
        before do
          fc = affiliate.featured_collections.build(:title => 'My awesome featured collection',
                                                    :title_url => 'http://www.dotgov.gov/page.html',
                                                    :status => 'active',
                                                    :layout => 'one column',
                                                    :publish_start_on => Date.current)
          fc.featured_collection_keywords.build(:value => 'word1')
          fc.featured_collection_links.build(:title => 'Worldwide Tropical Cyclone Names Part1',
                                             :url => 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                             :position => '0')

          fc.save!
        end

        it 'should not find any records' do
          affiliate.featured_collections.substring_match('sdfsdfsdf').size.should be_zero
        end
      end

    end
  end

  describe ".search_for" do
    context "with an affiliate" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      context "when there is an active English featured collection without date range" do
        before do
          @featured_collection = affiliate.featured_collections.build(:title => 'Tropical Hurricane Names',
                                                                      :status => 'active',
                                                                      :layout => 'one column',
                                                                      :publish_start_on => Date.current)
          @featured_collection.featured_collection_keywords.build(:value => 'typhoon')
          @featured_collection.featured_collection_links.build(:title => 'Worldwide Tropical Cyclone Names Part1',
                                                               :url => 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                                               :position => '0')
          @featured_collection.featured_collection_links.build(:title => 'Worldwide Tropical Cyclone Names Part2',
                                                               :url => 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                                               :position => '0')
          @featured_collection.save!
          inactive_featured_collection = affiliate.featured_collections.build(:title => 'Retired Hurricane names',
                                                                              :status => 'inactive',
                                                                              :layout => 'one column',
                                                                              :publish_start_on => Date.current)
          inactive_featured_collection.featured_collection_keywords.build(:value => 'typhoon')
          inactive_featured_collection.featured_collection_links.build(:title => 'Retired Hurricane Names Since 1954',
                                                                       :url => 'http://www.nhc.noaa.gov/retirednames.shtml',
                                                                       :position => '0')
          inactive_featured_collection.save!
          FeaturedCollection.reindex
        end

        it "should return only active Featured Collections" do
          FeaturedCollection.search_for('tropical', affiliate).results.each do |result|
            result.should be_is_active
          end
        end

        it "should return Featured Collection when searching for query term that exists in the title" do
          FeaturedCollection.search_for('tropical', affiliate).results.first.should == @featured_collection
        end

        it "should return Featured Collection when searching for query term that exists in featured collection keywords" do
          FeaturedCollection.search_for('typhoon', affiliate).results.first.should == @featured_collection
        end

        it "should return Featured Collection when searching for query term that exists in the link title" do
          FeaturedCollection.search_for('cyclone', affiliate).results.first.should == @featured_collection
        end

        it "should highlight matching Featured Collection title" do
          highlighted_title = FeaturedCollection.search_for('tropical', affiliate).hits.first.highlights(:title).first.format
          highlighted_title.should == "<em>Tropical</em> Hurricane Names"
        end

        it "should highlight matching Featured Collection link titles" do
          highlighted_link_titles = FeaturedCollection.search_for('tropical', affiliate).hits.first.highlights(:link_titles).first.format.split(FeaturedCollection::LINK_TITLE_SEPARATOR)
          highlighted_link_titles.should include("Worldwide <em>Tropical</em> Cyclone Names Part1")
          highlighted_link_titles.should include("Worldwide <em>Tropical</em> Cyclone Names Part2")
        end
      end

      context "when there is an active English featured collection and current date is within publish date range" do
        before do
          @featured_collection_params = [
              { :title => 'today',
                :publish_start_on => Date.current,
                :publish_end_on => Date.current },
              { :title => 'within_publish_date_range',
                :publish_start_on => Date.current.prev_month,
                :publish_end_on => Date.current.next_month },
          ]
          @featured_collection_params.each_with_index do |params, index|
            featured_collection = affiliate.featured_collections.build(:title => "Featured collection #{params[:title]}",
                                                                       :status => 'active',
                                                                       :layout => 'one column',
                                                                       :publish_start_on => params[:publish_start_on],
                                                                       :publish_end_on => params[:publish_end_on])
            featured_collection.featured_collection_keywords.build(:value => "keyword#{index + 1}")
            featured_collection.save!
          end
          FeaturedCollection.reindex
        end

        it "should return featured_collections with publish date range today" do
          FeaturedCollection.search_for('today', affiliate).results.first.should_not be_blank
        end

        it "should return featured_collections within publish date range" do
          FeaturedCollection.search_for('within_publish_date_range', affiliate).results.first.should_not be_blank
        end

        context "when query contains special characters" do
          ['"   ', '   "       ', '+++', '+-', '-+'].each do |query|
            specify { FeaturedCollection.search_for(query, affiliate).should be_nil }
          end

          %w(+++today --today +-today).each do |query|
            specify { FeaturedCollection.search_for(query, affiliate).total.should == 1 }
          end
        end
      end

      context "when there is an active English featured collection and current date is not within publish date range" do
        before do
          featured_collection_params = [
              { :title => 'past_publish_date_range',
                :publish_start_on => Date.current.prev_year,
                :publish_end_on => Date.current.yesterday },
              { :title => 'future_publish_date_range',
                :publish_start_on => Date.current.tomorrow,
                :publish_end_on => Date.current.next_month },
              { :title => 'future_publish_start_date',
                :publish_start_on => Date.current.tomorrow }
          ]
          featured_collection_params.each_with_index do |params, index|
            featured_collection = affiliate.featured_collections.build(:title => "Featured collection #{params[:title]}",
                                                                       :status => 'active',
                                                                       :layout => 'one column',
                                                                       :publish_start_on => params[:publish_start_on],
                                                                       :publish_end_on => params[:publish_end_on])
            featured_collection.featured_collection_keywords.build(:value => "keyword#{index + 1}")
            featured_collection.save!
          end
          FeaturedCollection.reindex
        end

        it "should not return featured_collections with past publish date range" do
          FeaturedCollection.search_for('past_publish_date_range', affiliate).results.should be_empty
        end

        it "should not return featured_collections with future publish date range" do
          FeaturedCollection.search_for('future_publish_date_range', affiliate).results.should be_empty
        end

        it "should not return featured_collections with future publish start date" do
          FeaturedCollection.search_for('future_publish_start_date', affiliate).results.should be_empty
        end
      end

      context "when there is an active Spanish featured collection" do
        let(:affiliate) { affiliates(:gobiernousa_affiliate) }
        before do
          @featured_collection = affiliate.featured_collections.build(:title => 'Nombres de huracanes tropicales',
                                                                      :status => 'active',
                                                                      :layout => 'one column',
                                                                      :publish_start_on => Date.current)
          @featured_collection.featured_collection_keywords.build(:value => 'tifón')
          @featured_collection.featured_collection_links.build(:title => 'Nombres de ciclones tropicales en todo el mundo',
                                                               :url => 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                                               :position => '0')
          @featured_collection.save!
          inactive_featured_collection = affiliate.featured_collections.build(:title => 'Retiró los nombres de huracán',
                                                                              :status => 'inactive',
                                                                              :layout => 'one column',
                                                                              :publish_start_on => Date.current)
          inactive_featured_collection.featured_collection_keywords.build(:value => 'tifón')
          inactive_featured_collection.featured_collection_links.build(:title => 'Se retiró nombres de huracanes desde 1954',
                                                                       :url => 'http://www.nhc.noaa.gov/retirednames.shtml',
                                                                       :position => '0')
          inactive_featured_collection.save!
          FeaturedCollection.reindex
        end

        it "should return only active Featured Collections" do
          FeaturedCollection.search_for('tropicales', affiliate).results.each do |result|
            result.should be_is_active
          end
        end

        it "should return Featured Collection when searching for query term that exists in the title" do
          FeaturedCollection.search_for('tropicales', affiliate).results.first.should == @featured_collection
        end

        it "should return Featured Collection when searching for query term that exists in featured collection keywords" do
          FeaturedCollection.search_for('tifón', affiliate).results.first.should == @featured_collection
        end

        it "should return Featured Collection when searching for query term that exists in the link title" do
          FeaturedCollection.search_for('ciclones', affiliate).results.first.should == @featured_collection
        end
      end

      context "when .search raise an exception" do
        it "should return nil" do
          FeaturedCollection.should_receive(:search).and_raise(RSolr::Error::Http.new({}, {}))
          FeaturedCollection.search_for('tropicales', affiliate).should be_nil
        end
      end
    end
  end

  describe ".human_attribute_name" do
    specify { FeaturedCollection.human_attribute_name("publish_start_on").should == "Publish start date" }
  end
end
