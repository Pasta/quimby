module Foursquare
  class Venue
    attr_reader :json

    def initialize(foursquare, json)
      @foursquare, @json = foursquare, json
    end

    def id
      @json["id"]
    end

    def name
      @json["name"]
    end

    def contact
      @json["contact"]
    end

    def location
      Foursquare::Location.new(@json["location"])
    end

    def categories
      @categories ||= @json["categories"].map { |hash| Foursquare::Category.new(hash) }
    end

    def verified?
      @json["verified"]
    end

    def checkins_count
      @json["stats"]["checkinsCount"]
    end

    def users_count
      @json["stats"]["usersCount"]
    end

    def todos_count
      @json["todos"]["count"]
    end
    
    def stats
      @json["stats"]
    end
    
    def primary_category
      return nil if categories.blank?
      @primary_category ||= categories.select { |category| category.primary? }.try(:first)
    end
    
    # return the url to the icon of the primary category
    # if no primary is available, then return a default icon
    def icon
      primary_category ? primary_category["icon"] : "https://foursquare.com/img/categories/none.png"
    end
    
    def photos_count
      @json["photos"]["count"]
    end
    
    # not all photos may be present here (but we try to avoid one extra API call)
    # if you want to get all the photos, try all_photos
    def photos
      return all_photos if @json["photos"].blank?
      @json["photos"]["groups"].select { |g| g["type"] == "venue" }.first["items"].map do |item|
        Foursquare::Photo.new(@foursquare, item)
      end
    end
    
    # https://developer.foursquare.com/docs/venues/photos.html
    def all_photos(options={:group => "venue"})
      @foursquare.get("venues/#{id}/photos", options)["photos"]["items"].map do |item|
        Foursquare::Photo.new(@foursquare, item)
      end
    end
    
  end
end
