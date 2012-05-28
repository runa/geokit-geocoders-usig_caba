#encoding: utf-8
require "geokit"
require "geokit-geocoders-usig_caba/version"

module Geokit
  module Geocoders
    class Usigcaba < Geocoder
      require "cgi"
      require "proj4"
      # Replae name 'External' (below) with the name of your custom geocoder class
      # and use :external to specify this geocoder in your list of geocoders.
      def self.do_geocode(address, options = {})
        res = GeoLoc.new
        res.provider = 'USIG - GCBA'
        numero = address.scan(/([0-9]+)/).flatten.first.to_i
        calle = address.gsub(/([0-9]+)/,"").strip
        url="http://ws.usig.buenosaires.gob.ar/geocoder/2.2/geocoding/?cod_calle=#{CGI.escape(calle)}&altura=#{CGI.escape(numero.to_s)}"
        resp = do_get(url)
        return {} if resp.code != '200'
        data = resp.body[1 .. -2]
        if data == '"ErrorCalleInexistente"'
          logger.debug("Calle o número inexistente: '#{calle}' '#{numero}': #{url} #{data}")
          res.success = false
          return res 
        end
        begin
          pos = MultiJson.decode(data)
        rescue
          logger.debug("Bad json: #{$!} - street, number, response: '#{calle}' '#{numero}' #{url} #{data}")
          res.success = false
          return res 
        end
        proj = Proj4::Projection.new("+proj=tmerc +lat_0=-34.629269 +lon_0=-58.4633 +k=0.9999980000000001 +x_0=100000 +y_0=100000 +ellps=intl +units=m +no_defs ")
        begin
          pos_latlon = proj.inverseDeg(Proj4::Point.new(pos['x'].to_f, pos['y'].to_f))
        rescue
          logger.debug("Bad x or y: #{$!} - street, number, response: '#{calle}' '#{numero}' #{url} #{pos.inspect}")
          res.success = false
          return res 
        end
        res.success = true
        res.lat = pos_latlon.lat 
        res.lng = pos_latlon.lon 
        res.street_name = calle
        res.street_number = numero
        res.street_address = "#{calle} #{numero}"
        res.city = "Ciudad de Buenos Aires"
        res.country_code = "AR"
        res
      end

      def self.parse_http_resp(body) # :nodoc:
        # Helper method to parse http response. See geokit/geocoders.rb.
      end
    end
  end
end
