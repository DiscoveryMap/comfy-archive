require 'rails_helper'

RSpec.describe ComfyArchive do

  describe "configuration" do
    let(:config) { ComfyArchive.configuration }

    it "creates a default configuration" do
      expect(config).to_not be_nil
      expect(config.posts_per_page).to eq(10)
    end

    it "can override configuration defaults" do
      orig = config.posts_per_page
      config.posts_per_page = 5
      expect(config.posts_per_page).to eq(5)
      config.posts_per_page = orig
    end
  end

end
