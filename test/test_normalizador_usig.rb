#encoding: utf-8
require "geokit-geocoders-usig_caba"
require "test/unit"
require "logger"
class TestUsigCaba < Test::Unit::TestCase
  def setup
    Geokit::Geocoders.logger = Logger.new(STDERR)
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

  def test_calle_que_es_av_pero_no_a_la_altura_que_no_dice
    res = Geokit::Geocoders::Usigcaba.geocode("av. monroe 2224", lookup_code: true)
    assert(res.success, "Debería matchear av. monroe 2224")
    assert_equal("MONROE AV.", res.street_name)
    assert_equal(2224, res.street_number)
  end

  def test_calle_que_es_pasaje_pero_el_nombre_no_dice
    res = Geokit::Geocoders::Usigcaba.geocode("pasaje portugal 530", lookup_code: true)
    assert(res.success, "Debería matchear pasaje portugal 530")
    assert_equal("PORTUGAL", res.street_name)
    assert_equal(530, res.street_number)
  end

  def test_calle_con_separadores_Y_y_E
    res = Geokit::Geocoders::Usigcaba.geocode("URIBURU JOSE E., Pres. 1003", lookup_code: true)
    assert(res.success, "Debería matchear URIBURU JOSE E., Pres. 1003")
    assert_equal("URIBURU JOSE E., Pres.", res.street_name)
    assert_equal(1003, res.street_number)
  end

  def test_calle_con_separadores_Y_y_E2
    res = Geokit::Geocoders::Usigcaba.geocode("BATLLE Y ORDOÑEZ, JOSE P.T. 5105", lookup_code: true)
    assert(res.success, "Debería matchear BATLLE Y ORDOÑEZ, JOSE P.T. 5105")
    assert_equal("BATLLE Y ORDOÑEZ, JOSE P.T.", res.street_name)
    assert_equal(5105, res.street_number)
  end

  def test_calle_con_separadores_Y_y_E3
    res = Geokit::Geocoders::Usigcaba.geocode("BENEDETTI, OSVALDO E., Dip.Nac. 14", lookup_code: true)
    assert(res.success, "Debería matchear BENEDETTI, OSVALDO E., Dip.Nac.")
    assert_equal("BENEDETTI, OSVALDO E., Dip.Nac.", res.street_name)
    assert_equal(14, res.street_number)
  end

  def test_calle_con_separadores_Y_y_E4
    res = Geokit::Geocoders::Usigcaba.geocode("BUTTY, E., Ing. 240", lookup_code: true)
    assert(res.success, "Debería matchear BUTTY, E., Ing. 240")
    assert_equal("BUTTY, E., Ing.", res.street_name)
    assert_equal(240, res.street_number)
  end

end
