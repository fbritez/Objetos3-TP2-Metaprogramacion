class MyMock


  def self.mock(aClass)
    class_name = (aClass).to_s + "Mock"
    (Object.const_set(class_name, Class.new(MyMock){
                                  def initialize(aClass)
                                    @classMocked = aClass
                                    @lastMethodToBeMocked = MethodMock.new(:emptyMethod)
                                    @mocked_methods = []
                                    @expectedMethods = []
                                    @executionStack = []
                                    @check = LazyCheck.new()
                                    self.class.define_original_class_methods(aClass)
                                  end

                                  def when(aSymbol)
                                    raise RuntimeError.new('no existe el metodo ' + aSymbol.to_s+ ' en la clase ' + @classMocked.to_s) unless @classMocked.instance_methods.include?(aSymbol)
                                    @lastMethodToBeMocked = MethodMock.new(aSymbol)
                                    @mocked_methods.push(@lastMethodToBeMocked)

                                    self
                                  end

                                  def with(*aParameter)
                                    raise 'la cantidad de parametros pasados como argumentos no es correcta' unless @classMocked.new.method(@lastMethodToBeMocked.name).arity == aParameter.length
                                    @lastMethodToBeMocked.addParameters(aParameter)
                                    self
                                  end

                                  def thenReturn(aValueToReturn)
                                    @lastMethodToBeMocked.set_return(aValueToReturn)
                                    name = @lastMethodToBeMocked.name
                                    self.class.send(:define_method, name) do |*x|
                                      m = @mocked_methods.select{|m| m.appliesFor(name, x) }.pop
                                      @executionStack.push(m)
                                      m.get_return
                                    end
                                  end

                                  def expects(aCall)
                                    @check = LazyCheck.new
                                  end

                                  def addToExpects(aCall)
                                    @expectedMethods.push(aCall)
                                  end

                                  def check_expects

                                    raise RuntimeError.new( 'error se ha llamado mas de una vez a alguno de los metodos interesados en ser llamado solo una vez') unless
                                        someMethodCalledMoreThanOnce

                                    @check.doCheck(self)

                                  end


                                  def someMethodCalledMoreThanOnce
                                    booleanList = @expectedMethods.map{|call| checkTheOnceConditionIn(call,@executionStack)}
                                    booleanList.all?
                                  end

                                  def checkTheOnceConditionIn(call, aStack)
                                    call.getOnce >= aStack.count{|m| m.appliesFor(call.method.name, call.method.parameters)}
                                  end

                                  def expectedMethods
                                    @expectedMethods
                                  end

                                  def executionStack
                                    @executionStack
                                  end

                                  def strict_expect (&aBlock)
                                    @check = StrictCheck.new
                                    aBlock.call

                                  end

                                  def self.define_original_class_methods(clase)
                                    instanceMethods(clase).each { |method|
                                      define_instance_method(method)
                                    }
                                    end

                                  def self.define_instance_method(m)

                                    send(:define_method, m) do |*x|
                                      raise UndefinedBehaviourException.new('No se especifico el valor de retorno de metodo ' + m.to_s)
                                    end

                                  end

                                  def self.instanceMethods(clase)
                                    clase.instance_methods - Object.instance_methods
                                  end

                                })

    ).new(aClass)
  end

end

class UndefinedBehaviourException < StandardError
end

class Check

  def doCheck(aMockedClass)

  end
end

class StrictCheck < Check


  def doCheck(aMockedClass)
    if(aMockedClass.executionStack.size == aMockedClass.expectedMethods.size)
     (aMockedClass.executionStack.zip aMockedClass.expectedMethods).map{
         |method, call| method.isSame(call.method)}.all?
    else false
    end
  end
end

class LazyCheck < Check


  def doCheck(aMockedClass)



    mockedClassMethods = aMockedClass.expectedMethods.map{|call| call.method}


    (mockedClassMethods.map{|m| aMockedClass.executionStack.map{|methodStack| methodStack.isSame(m)}}).flatten.any?

    #((aMockedClass.executionStack).select{|m| (aMockedClass.expectedMethods).each{|call| m.appliesFor(call.method.name, call.method.parameters)}}.uniq).size == aMockedClass.expectedMethods.size
  end
end


#--------------- MethodMock ---------------------

class MethodMock
  def initialize(aSymbol)
    @methodName = aSymbol
    @parameters =[]
    @return = 0
  end

  def isSame(aMethodMock)
    (aMethodMock.name == @methodName && aMethodMock.parameters == @parameters)
  end

  def to_s
    @methodName.to_s + @parameters.to_s
  end

  def appliesFor(name, args)
    return (@methodName == name) && (@parameters == args)
  end

  def addParameters(aListOfParamaters)
    @parameters.concat(aListOfParamaters)
  end

  def setParameter(aValue)
    @parameters.push(aValue)
  end

  def named(aSymbol)
    @methodName = aSymbol
  end

  def parameters
    @parameters
  end

  def name
    @methodName
  end

  def set_return(aReturn)
    @return = aReturn
  end

  def get_return
    @return
  end
end

#--------------- Pepita ---------------------


class Pepita
  def initialize
    @energia = 10
  end

  def puede_volar?
    puede_gastar?(10)
  end

  def puede_gastar?(esfuerzo)
    @energia >= esfuerzo
  end

  def puede_comer?(comida)

  end

  def volar!

    @energia -= 10
  end
end


class Object

  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end


  def call(aSymbol)

    subclasses = []
    ObjectSpace.each_object MyMock do |post|
      subclasses << post
    end

    m =subclasses.select{|s| s.methods.include?(aSymbol) }

    call = Call.new(aSymbol)
    m.first.addToExpects(call)
    call
  end

  def mock(aSymbol)
    MyMock.mock(aSymbol)
  end
end


class Call
  def initialize(aSymbol)
    @methodMockToBeCalled = MethodMock.new(aSymbol)
    @once = 100
  end

  def to_s
    @methodMockToBeCalled.to_s
  end

  def once
    @once = 1
    self
  end

  def with_param(aValue)
    @methodMockToBeCalled.setParameter(aValue)
    self
  end

  def getOnce
    @once
  end

  def method
    @methodMockToBeCalled
  end

end







