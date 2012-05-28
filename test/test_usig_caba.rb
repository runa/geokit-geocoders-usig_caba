require "geokit-geocoders-usig_caba"
require "test/unit"
require "logger"
class TestUsigCaba < Test::Unit::TestCase
  def setup
    Geokit::Geocoders.logger = Logger.new(STDERR)
  end
  def test_valid_address
    res = Geokit::Geocoders::Usigcaba.geocode("Chenaut, Indalesio, Gral. Av. 1724")
    assert(res.success, "Error quering geocoder")
    assert_equal(-34.56998029273584, res.lat, "Bad lat")
    assert_equal(-58.43087213419635, res.lng, "Bad lon")
    assert_equal("Chenaut, Indalesio, Gral. Av.", res.street_name, "Bad Street Name")
    assert_equal(1724, res.street_number, "Bad Street Number")
  end
  def test_lookup_address_code
    res = Geokit::Geocoders::Usigcaba.geocode("Chenaut 1724", lookup_code: true)
    assert(res.success, "Error quering geocoder")
    assert_equal(-34.56998029273584, res.lat, "Bad lat")
    assert_equal(-58.43087213419635, res.lng, "Bad lon")
    assert_equal("CHENAUT, INDALESIO, GRAL. AV.", res.street_name, "Bad Street Name")
    assert_equal(1724, res.street_number, "Bad Street Number")
  end
  def test_lookup_address_code_choose_by_range
    # filters out the street INCA because the number is outside the range
    res = Geokit::Geocoders::Usigcaba.geocode("Inca 4050", lookup_code: true)
    assert(res.success, "Error quering geocoder")
    assert_equal("PUENTE DEL INCA", res.street_name, "Bad Street Name")
    assert_equal(4050, res.street_number, "Bad Street Number")
  end
  def test_lookup_address_code_filter_by_range
    res = Geokit::Geocoders::Usigcaba.geocode("Inca 3857", lookup_code: true)
    assert(res.success, "Error quering geocoder")
    assert_equal("INCA", res.street_name, "Bad Street Name")
    assert_equal(3857, res.street_number, "Bad Street Number")
  end

  def test_invalid_address
    res = Geokit::Geocoders::Usigcaba.geocode("Foobar 1724")
    refute(res.success, "Error quering geocoder")
  end
end

