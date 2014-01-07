module Methodize
  def self.extend_object(base)
    __normalize__(base)
  end

  def self.__normalize__(value)
    case value
    when Hash
      value.extend(MethodizedHash) unless value.kind_of?(MethodizedHash)
    when Array
      value.extend(MethodizedArray) unless value.kind_of?(MethodizedArray)
    end
    value
  end

end

module MethodizedHash
  def self.extended(base)
    # ruby >1.9 returns an array of symbols for object.public_methods
    # while <1.9 returns an array of string. This methods guess it right
    @@key_coerce = RUBY_VERSION.match(/^(1\.9[.\d]*|2[.\d]+)$/) ? lambda { |k| k.to_sym } : lambda { |k| k.to_s }

    # if some of the Hash keys and public methods names conflict
    # we free the existant method to enable the user to call it
    __metaclass__ = base.__metaclass__
    base.keys.each do |k|
      base.__free_method__(k.to_sym, __metaclass__) if base.public_methods.include?(@@key_coerce.call(k))
    end
  end

  def [](key)
    ::Methodize.__normalize__(super(key))
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
      __fetch__key__(method_name)
    end
  end

  # if you have a key that is also a method (such as Array#size)
  # you can use this to free the method and use the method obj.size
  # to access the value of key "size".
  # you still can access the old method with __[method_name]__
  def __free_method__(sym, __metaclass__ = self.__metaclass__)
    __sym__ = "__#{sym}__"
    __metaclass__.send(:alias_method, __sym__.to_sym, sym) unless respond_to?(__sym__)
    __metaclass__.send(:define_method, sym) { __fetch__key__(sym.to_s) }
    self
  end

  def __metaclass__
    class << self; self; end
  end

private

  def __fetch__key__(key)
    self[key?(key) ? key : key.to_sym]
  end
end

module MethodizedArray
  def [](*args)
    ::Methodize.__normalize__(super(*args))
  end
  def first(*args)
    ::Methodize.__normalize__(super(*args))
  end
  def last(*args)
    ::Methodize.__normalize__(super(*args))
  end

  def each(*args, &block)
    unless defined?(@methodized)
      @methodized = true
      super(*args) do |*args2|
        ::Methodize.__normalize__(args2.first) if args2.any?
      end
    end
    super(*args, &block)
  end

  def map(*args, &block)
    each(*args) unless defined?(@methodized)
    super(*args, &block)
  end
end
