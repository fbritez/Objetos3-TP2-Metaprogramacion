require 'test/unit'
require '../mock model/my_mock'

class MyMockTestCase < Test::Unit::TestCase
  @pepitaMock
  def setup
    @pepitaMock = MyMock.mock(Pepita)
  end

  def test_creationClassMock1
    assert_equal(@pepitaMock.class, PepitaMock)
  end

  def test_mockAPepitaClassAndOverridePuedeVolar2?

    @pepitaMock.when(:puede_volar?).thenReturn(true)
    assert @pepitaMock.puede_volar?
  end

  def test_mockAPepitaClassAndOverridePuede_gastarWithOneParameter3

    @pepitaMock.when(:puede_gastar?).with(30).thenReturn(40)
    assert_equal(40,@pepitaMock.puede_gastar?(30))
  end

  def test_mockAPepitaClassAndOverridePuede_gastarAndPuede_volar4

    @pepitaMock.when(:puede_gastar?).with(30).thenReturn(40)
    @pepitaMock.when(:puede_volar?).thenReturn(true)

    assert_equal(40,@pepitaMock.puede_gastar?(30))
    assert @pepitaMock.puede_volar?
  end

  def test_givenAnExpectedMethodThenAssertsIfItWasCalled5
    @pepitaMock.when(:puede_volar?).thenReturn(true)
    @pepitaMock.expects(call :puede_volar?)

    @pepitaMock.puede_volar?


    assert @pepitaMock.check_expects
  end

  def test_givenAnExpectedMethodThenAssertsIfItWasCalledOnlyOnce6
    @pepitaMock.when(:puede_volar?).thenReturn(false)
    @pepitaMock.expects call(:puede_volar?).once

    @pepitaMock.puede_volar?

    assert @pepitaMock.check_expects
  end

  def test_givenAnExpectedMethodThenAssertsIfItWasNotCalledOnlyOnce7
    #mockPepita = mock(Pepita)
    @pepitaMock.when(:puede_volar?).thenReturn(false)
    @pepitaMock.expects call(:puede_volar?).once

    @pepitaMock.puede_volar?
    @pepitaMock.puede_volar?

    assert_raises(RuntimeError) do
      @pepitaMock.check_expects
    end
  end


  def test_givenAnExpectedMethodWithAParameterThenAssertsIfItWasCalled8
    mockPepita = mock(Pepita)
    mockPepita.when(:puede_gastar?).with(20).thenReturn(true)
    mockPepita.expects (call(:puede_gastar?).with_param(20).once())

    mockPepita.puede_gastar?(20)

    assert mockPepita.check_expects

  end

  def test_givenSomeExpectedMethodsThenAssertIfWereCalledInOrder9
    mockPepita = mock(Pepita)
    mockPepita.when(:volar!).thenReturn(true)
    mockPepita.when(:puede_gastar?).with(10).thenReturn(true)

    mockPepita.strict_expect do
      call(:volar!)
      call(:puede_gastar?).with_param(10)
      call(:volar!)
    end

    mockPepita.volar!
    mockPepita.puede_gastar?(10)
    mockPepita.volar!

    assert mockPepita.check_expects
  end

  def test_givenAnExpectedExceptionThenAssertsIfItWasRaised10
    assert_raise(NoMethodError) do
    pepitaMock = mock(Pepita)
    pepitaMock.sabarasa
    end

  end

  def test_givenAnExpectedUndefinedBehavourExceptionThenAsserts11
    assert_raise(UndefinedBehaviourException) do
      pepitaMock = mock(Pepita)
      pepitaMock.volar!
    end
  end

end