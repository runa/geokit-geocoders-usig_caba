require "geokit-geocoders-usig_caba"
require "test/unit"
class TestUsigCaba < Test::Unit::TestCase
  def test_valid_address
    res = Geokit::Geocoders::Usigcaba.geocode("Chenaut, Indalesio, Gral. Av. 1724")
    assert(res.success, "Error quering geocoder")
    assert_equal(-34.56998029273584, res.lat, "Bad lat")
    assert_equal(-58.43087213419635, res.lng, "Bad lon")
    assert_equal("Chenaut, Indalesio, Gral. Av.", res.street_name, "Bad Street Name")
    assert_equal(1724, res.street_number, "Bad Street Number")
  end
  def test_invalid_address
    res = Geokit::Geocoders::Usigcaba.geocode("Foobar 1724")
    refute(res.success, "Error quering geocoder")
  end
end

