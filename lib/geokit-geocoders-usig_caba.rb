#encoding: utf-8
require "geokit"
require "geokit-geocoders-usig_caba/version"

module Geokit
  module Geocoders
    class Usigcaba < Geocoder
      require "cgi"
      require "proj4"

      # Geocode using USIG - GCBA geocoder
      # options:
      #   :lookup_code => try to find the street code from USIG DB before geocoding
      def self.do_geocode(address, options = {})
        res = GeoLoc.new
        res.provider = 'USIG - GCBA'
        numero = address.scan(/([0-9]+)/).flatten.first.to_i
        calle_name = calle = address.gsub(/([0-9]+)/,"").strip
        if options[:lookup_code]
          calle, calle_name, other_names, ranges = find_street_code(calle, numero) 
          logger.debug("Calle: #{calle_name} => (#{numero}) => cod: #{calle}")
        end
        url="http://ws.usig.buenosaires.gob.ar/geocoder/2.2/geocoding/?cod_calle=#{CGI.escape(calle.to_s)}&altura=#{CGI.escape(numero.to_s)}"
        resp = do_get(url)
        if resp.code != '200'
          logger.debug("Geocoder response #{url}: #{resp.code}")
          res.success = false
          return res
        end

        data = resp.body[1 .. -2] # remove wrapping "(" and ")" from response (JSON-P)

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
        res.street_name = calle_name
        res.street_number = numero
        res.street_address = "#{calle} #{numero}"
        res.city = "Ciudad de Buenos Aires"
        res.country_code = "AR"
        res
      end

      # Returns an array of strings from USIG, tries to memoize the data
      def self.streets
        @streets ||= begin
          req = do_get("http://servicios.usig.buenosaires.gov.ar/callejero?")
          data = req.body
          logger.debug("got HTTP #{req.code}, #{data.length} bytes from http://servicios.usig.buenosaires.gov.ar/callejero") 
          streets = MultiJson.decode(data)
          streets.each{|s|
            s[1].force_encoding("ISO-8859-1")
            s[2].force_encoding("ISO-8859-1")
          }
          streets
        end
      end

      # Find street code from USIG DB
      def self.find_street_code(name,street_number=false)
        words = name.upcase.split.compact.sort.uniq
        candidates = streets.find_all{|c| # finds candidates based on the name 
          match_words(c[2],words)
        }
        logger.debug("Street candidates for #{name} #{street_number}: #{candidates}")

        if street_number # filters out candidates using the street number ranges
          candidates = candidates.find_all{|street|
            street[3].find{|range_from, range_to|
              range_to >= street_number && range_to >= street_number 
            }
          }
        end
        logger.debug("Candidate for #{name}: #{candidates}")
        candidates.first
      end
      private

      # Checks all words against a string. Returns false if any of them is not found
      def self.match_words(string,words)
        words_re = words.map{|w| Regexp.new("(\\s|^)#{w}(\\s|$)")}
        words_re.each{|w| 
          logger.debug("#{string}.index(#{w})")
          return false if not string.index(w)
        }
      end
    end
  end
end
