module Methodize
  def self.extended(base)
    # ruby >1.9 returns an array of symbols for object.public_methods 
    # while <1.9 returns an array of string. This methods guess it right
    @@key_coerce = RUBY_VERSION.start_with?("1.9") ? lambda { |k| k.to_sym } : lambda { |k| k.to_s }
    
    # if some of the Hash keys and public methods names conflict
    # we free the existant method to enable the user to call it
    base.keys.each do |k|
      base.__free_method__(k.to_sym) if base.public_methods.include?(@@key_coerce.call(k))
    end
  end
  
  def [](key)
    __normalize__(super(key))
  end

  def []=(key, value)
    __free_method__(key) if !keys.include?(key) && public_methods.include?(@@key_coerce.call(key))
    super(key,value)
  end

  def method_missing(name, *args)
    method_name = name.to_s
    if method_name[-1,1] == '='
      method_name = method_name.chop
      key = key?(method_name) ? method_name : method_name.to_sym
      self[key] = args[0]
    else
      key = key?(method_name) ? method_name : method_name.to_sym
      self[key]
    end
  end

  # if you have a key that is also a method (such as Array#size)
  # you can use this to free the method and use the method obj.size
  # to access the value of key "size".
  # you still can access the old method with __[method_name]__
  def __free_method__(sym)
    __sym__ = "__#{sym}__"
    __metaclass__ = self.__metaclass__
    __metaclass__.send(:alias_method, __sym__.to_sym, sym) unless self.respond_to?(__sym__)
    __metaclass__.send(:define_method, sym) { method_missing(sym.to_s) }
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