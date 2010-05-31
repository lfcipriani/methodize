module Methodize
  def self.extended(base)
    [:type, :id].each { |m| base.__free_method__(m) }      
  end
  
  def [](key)
    __normalize__(super(key))
  end

  def []=(key, value)
    super(key,value)
  end

  def method_missing(name, *args)
    method_name = name.to_s
    if method_name[-1,1] == '='
      method_name = method_name.chop
      self.key?(method_name) ? key = method_name : key = method_name.to_sym
      self[key] = args[0]
    else
      self[method_name] || self[method_name.to_sym]
    end
  end

  # if you have a key that is also a method (such as Array#size)
  # you can use this to free the method and use the method obj.size
  # to access the value of key "size".
  # you still can access the old method with __[method_name]__
  def __free_method__(sym)
    self.__metaclass__.send(:alias_method, "__#{sym.to_s}__".to_sym, sym) unless self.respond_to?("__#{sym.to_s}__")
    self.__metaclass__.send(:define_method, sym) { method_missing(sym.to_s) }
    self
  end

  def __metaclass__
    class << self; self; end
  end
  
private

  def __normalize__(value)
    case value
    when Hash
      value.extend(Methodize)
    when Array
      value.map { |v| __normalize__(v) }
    else
      value
    end
    value
  end

end

