require 'minitest/autorun'
require 'minitest/pride'
require 'i18n-globals'

class TestI18nGlobals < Minitest::Test
  def setup
    I18n.backend.load_translations 'test/fixtures/translations.yml'
    I18n.config = I18n::Config.new
  end

  def test_that_simple_translations_work
    assert_equal I18n.translate('test'), 'Hello World!'
  end

  def test_that_interpolated_variables_work
    assert_equal I18n.translate('greeting', name: 'Joe'), 'Hi there, Joe!'
  end

  def test_that_global_variables_work
    I18n.config.globals[:name] = 'Bill'

    assert_equal I18n.translate('greeting'), 'Hi there, Bill!'
  end

  def test_that_global_variables_can_be_overwritten
    I18n.config.globals[:name] = 'Nick'

    assert_equal I18n.translate('greeting', name: 'Jill'), 'Hi there, Jill!'
  end

  def test_that_multiple_global_variables_work
    I18n.config.globals[:name] = 'Chell'
    I18n.config.globals[:company] = 'Aperture Science'

    assert_equal I18n.translate('welcome'), 'Hello Chell, welcome to Aperture Science!'
  end

  def test_that_one_of_the_global_variables_can_be_overwritten
    I18n.config.globals[:name] = 'Barney'
    I18n.config.globals[:company] = 'Black Mesa'

    assert_equal I18n.translate('welcome', name: 'Gordon'), 'Hello Gordon, welcome to Black Mesa!'
  end

  def test_that_the_other_global_variable_can_be_overwritten
    I18n.config.globals[:name] = 'Barney'
    I18n.config.globals[:company] = 'Black Mesa'

    assert_equal I18n.translate('welcome', company: 'Aperture Science'), 'Hello Barney, welcome to Aperture Science!'
  end

  def test_that_all_of_the_global_variables_can_be_overwritten
    I18n.config.globals[:name] = 'Barney'
    I18n.config.globals[:company] = 'Black Mesa'

    assert_equal I18n.translate('welcome', name: 'Gordon', company: 'Aperture Science'), 'Hello Gordon, welcome to Aperture Science!'
  end

  def test_that_the_t_alias_work
    I18n.config.globals[:name] = 'Chell'
    I18n.config.globals[:company] = 'Aperture Science'

    assert_equal I18n.t('welcome'), 'Hello Chell, welcome to Aperture Science!'
  end

  def test_that_global_variables_are_shared_between_config_instances
    I18n.config.globals[:name] = 'Greg'

    I18n.config = I18n::Config.new

    assert_equal I18n.translate('greeting'), 'Hi there, Greg!'
  end
end
