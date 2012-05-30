#encoding: utf-8
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

  def test_lookup_address_code_with_abbr
    res = Geokit::Geocoders::Usigcaba.geocode("Av. de los incas 4004", lookup_code: true)
    assert(res.success, "Debería matchear: 'Av. de los incas 4004' ")
    assert_equal("DE LOS INCAS AV.", res.street_name, "Bad Street Name")
    res = Geokit::Geocoders::Usigcaba.geocode("Av de los incas 4004", lookup_code: true)
    assert(res.success, "Debería matchear: 'Av de los incas 4004'")
    assert_equal("DE LOS INCAS AV.", res.street_name, "Bad Street Name")
  end


  # Imported tests from: http://servicios.usig.buenosaires.gob.ar/nd-js/1.3/tests/tests.js
  def test_invalid_address
    res = Geokit::Geocoders::Usigcaba.geocode("Foobar 1724")
    refute(res.success, "Error quering geocoder")
  end
  def test_calle_inexistente
    res = Geokit::Geocoders::Usigcaba.geocode("asdfp 1234", lookup_code: true)
    refute(res.success, "Esta calle no debería existir")

    res = Geokit::Geocoders::Usigcaba.geocode("av arcos 1234", lookup_code: true)
    refute(res.success, "Esta calle no debería existir")
  end

  def test_calle_existente
    res = Geokit::Geocoders::Usigcaba.geocode("corrientes 1234", lookup_code: true)
    assert(res.success, "Debería matchear..")
    assert_equal("CORRIENTES AV.", res.street_name)
    assert_equal(1234, res.street_number)

    res = Geokit::Geocoders::Usigcaba.geocode("Pasteur 234", lookup_code: true)
    assert(res.success, "Debería matchear..")
    assert_equal("PASTEUR", res.street_name)
    assert_equal(234, res.street_number)

  end

  def test_unica_calle_existente_con_altura_inexistente
    res = Geokit::Geocoders::Usigcaba.geocode("corrientes 12340", lookup_code: true)
    refute(res.success, "No hay matches")
  end

  def test_muchas_calles_sin_altura_valida
    res = Geokit::Geocoders::Usigcaba.geocode("sarm 35000", lookup_code: true)
    refute(res.success, "No hay matches")
  end

  def test_muchas_calles_con_una_altura_valida
    res = Geokit::Geocoders::Usigcaba.geocode("Sarm 2560", lookup_code: true)
    assert(res.success, "'Sarm 2560' debería matchar 'Sarmiento 2560'")
    assert_equal("SARMIENTO", res.street_name)
    assert_equal(2560, res.street_number)
  end

# testMuchasCallesVariasConAlturaValida
  def test_calle_con_varios_tramos_con_altura_invalida
    res = Geokit::Geocoders::Usigcaba.geocode("Zapiola 5700", lookup_code: true)
    refute(res.success, "No hay matches")
  end

  def test_calle_con_varios_tramos_con_altura_invalida
    res = Geokit::Geocoders::Usigcaba.geocode("Cordoba 6400", lookup_code: true)
    assert(res.success, "Debería matchear..")
    assert_equal("CORDOBA", res.street_name)
    assert_equal(6400, res.street_number)
  end

  def test_calle_con_nombre_compuesto_con_altura_valida
    res = Geokit::Geocoders::Usigcaba.geocode("Julian Alvarez 1440", lookup_code: true)
    assert(res.success, "Debería matchear Julian Alvarez 1440..")
    assert_equal("ALVAREZ, JULIAN", res.street_name)
    assert_equal(1440, res.street_number)
  end

  def test_calle_con_nombre_compuesto_con_altura_valida2
    res = Geokit::Geocoders::Usigcaba.geocode("Alvarez, Julian 1440", lookup_code: true)
    assert(res.success, "Debería matchear Alvarez, Julian 1440..")
    assert_equal("ALVAREZ, JULIAN", res.street_name)
    assert_equal(1440, res.street_number)
  end

  def test_calle_con_nombre_compuesto_con_altura_valida2
    res = Geokit::Geocoders::Usigcaba.geocode("Alvarez,Julian 1440", lookup_code: true)
    assert(res.success, "Debería matchear Alvarez,Julian 1440..")
    assert_equal("ALVAREZ, JULIAN", res.street_name)
    assert_equal(1440, res.street_number)
  end

  def test_calle_con_nombre_compuesto_con_altura_valida3
    res = Geokit::Geocoders::Usigcaba.geocode("Alvare Julia 1440", lookup_code: true)
    assert(res.success, "Debería matchear Alvare Julia 1440..")
    assert_equal("ALVAREZ, JULIAN", res.street_name)
    assert_equal(1440, res.street_number)
  end

  def test_calle_con_nombre_compuesto_con_altura_valida4
    res = Geokit::Geocoders::Usigcaba.geocode("Julián Alvarez 1440", lookup_code: true)
    assert(res.success, "Debería matchear Julián Alvarez 1440..")
    assert_equal("ALVAREZ, JULIAN", res.street_name)
    assert_equal(1440, res.street_number)
  end

  def test_calle_con_nombre_compuesto_con_altura_valida5
    res = Geokit::Geocoders::Usigcaba.geocode("Julián Álvarez 1440", lookup_code: true)
    assert(res.success, "Debería matchear Julián Álvarez 1440..")
    assert_equal("ALVAREZ, JULIAN", res.street_name)
    assert_equal(1440, res.street_number)
  end

  def test_calle_con_punto_con_altura_valida
    res = Geokit::Geocoders::Usigcaba.geocode("Av. Cordoba 1440", lookup_code: true)
    assert(res.success, "Debería matchear Av. Cordoba 1440..")
    assert_equal("CORDOBA AV.", res.street_name)
    assert_equal(1440, res.street_number)
  end

  def test_calle_con_enie_con_altura_valida2
    res = Geokit::Geocoders::Usigcaba.geocode("El ÑANDU 3144", lookup_code: true)
    assert(res.success, "Debería matchear El ÑANDU 3144")
    assert_equal("EL ÑANDU", res.street_name)
    assert_equal(3144, res.street_number)
  end

  def test_calle_con_dieresis_con_altura_valida
    res = Geokit::Geocoders::Usigcaba.geocode("agüero 2144", lookup_code: true)
    assert(res.success, "Debería matchear agüero 2144")
    assert_equal("AGUERO", res.street_name)
    assert_equal(2144, res.street_number)
  end

  def test_calle_con_apostrofe_con_altura_valida
    res = Geokit::Geocoders::Usigcaba.geocode("o'higgins 2144", lookup_code: true)
    assert(res.success, "Debería matchear o'higgins 2144")
    assert_equal("O'HIGGINS", res.street_name)
    assert_equal(2144, res.street_number)
  end

  def test_calle_que_es_av_pero_el_nombre_no_dice
    res = Geokit::Geocoders::Usigcaba.geocode("av montes de oca 100", lookup_code: true)
    assert(res.success, "Debería matchear av montes de oca 100")
    assert_equal("MONTES DE OCA, MANUEL", res.street_name)
    assert_equal(100, res.street_number)
  end

end
