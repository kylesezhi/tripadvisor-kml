require 'open-uri'
require 'geocoder'
require 'ruby_kml'
require 'nokogiri'
require 'ruby-progressbar'
require 'date'

site_url = 'http://www.tripadvisor.com/RestaurantsNear-g294305-d2538166-Plaza_Nunoa-Santiago_Santiago_Metropolitan_Region.html'

doc = Nokogiri::HTML(open(site_url))

locality = ' ' + doc.css('.locality').text
locality += doc.css('.country-name').text
title = doc.css('#HEADING').text
listings = doc.css('div.near_listing')

locations = []
bar = ProgressBar.create(:title => "Locating", :total => 15)

listings[0..14].each { |l|
    place = l.css('.location_name').text
    address = l.css('.format_address').text + locality
    x = Hash.new
    x = Geocoder.search(place + ' ' + address)[0].data['geometry']['location']
    x['name'] = place
    locations << x
    bar.increment
    sleep(0.25)
}

kml = KMLFile.new
folder = KML::Folder.new(:name => title)
locations.each { |l|
    folder.features << KML::Placemark.new(
        :name => l['name'],
        #'styleUrl' => '#icon-1085-nodesc',
        #:description => 'Attached to the ground. Intelligently places itself at the height of the underlying terrain.',
        :geometry => KML::Point.new(:coordinates=>l['lng'].to_s + ',' + l['lat'].to_s + ',0.0')
    )
}

kml.objects << folder
kml.save "santiago-#{Date.today.to_s}.kml"
puts "santiago-#{Date.today.to_s}.kml saved."
